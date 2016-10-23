module DiasporaFederation
  module Federation
    module Sender
      # A wrapper for [Typhoeus::Hydra]
      #
      # Uses parallel http requests to send out the salmon-messages
      class HydraWrapper
        include Logging

        # Hydra default opts
        # @return [Hash] hydra opts
        def self.hydra_opts
          @hydra_opts ||= {
            followlocation: true,
            maxredirs:      DiasporaFederation.http_redirect_limit,
            timeout:        DiasporaFederation.http_timeout,
            method:         :post,
            verbose:        DiasporaFederation.http_verbose,
            cainfo:         DiasporaFederation.certificate_authorities,
            forbid_reuse:   true,
            headers:        {
              "Expect"            => "",
              "Transfer-Encoding" => "",
              "User-Agent"        => DiasporaFederation.http_user_agent
            }
          }
        end

        # Create a new instance for a message
        #
        # @param [String] sender_id sender diaspora-ID
        # @param [String] obj_str object string representation for logging (e.g. type@guid)
        def initialize(sender_id, obj_str)
          @sender_id = sender_id
          @obj_str = obj_str
          @urls_to_retry = []
        end

        # Prepares and inserts job into the hydra queue
        # @param [String] url the receive-url for the xml
        # @param [String] xml xml salmon message
        def insert_job(url, xml)
          request = Typhoeus::Request.new(url, HydraWrapper.hydra_opts.merge(body: {xml: xml}))
          prepare_request(request)
          hydra.queue(request)
        end

        # Sends all queued messages
        # @return [Array<String>] urls to retry
        def send
          hydra.run
          @urls_to_retry
        end

        private

        # @return [Typhoeus::Hydra] hydra
        def hydra
          @hydra ||= Typhoeus::Hydra.new(max_concurrency: DiasporaFederation.http_concurrency)
        end

        # Logic for after complete
        # @param [Typhoeus::Request] request
        def prepare_request(request)
          request.on_complete do |response|
            success = validate_response_and_update_pod(request, response)
            log_line = "success=#{success} sender=#{@sender_id} obj=#{@obj_str} url=#{response.effective_url} " \
                       "message=#{response.return_code} code=#{response.response_code} time=#{response.total_time}"
            if success
              logger.info(log_line)
            else
              logger.warn(log_line)

              @urls_to_retry << request.url
            end
          end
        end

        def validate_response_and_update_pod(request, response)
          url = URI.parse(request.url)
          effective_url = URI.parse(response.effective_url)
          same_host = url.host == effective_url.host

          (response.success? && same_host).tap do |success|
            pod_url = (success ? effective_url : url).tap {|uri| uri.path = "/" }.to_s
            status = same_host ? status_from_response(response) : :redirected_to_other_hostname
            DiasporaFederation.callbacks.trigger(:update_pod, pod_url, status)
          end
        end

        def status_from_response(response)
          response.return_code == :ok ? response.response_code : response.return_code
        end
      end
    end
  end
end
