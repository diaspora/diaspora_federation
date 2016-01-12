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
            maxredirs: DiasporaFederation.http_redirect_limit,
            timeout:   DiasporaFederation.http_timeout,
            method:    :post,
            verbose:   DiasporaFederation.http_verbose,
            cainfo:    DiasporaFederation.certificate_authorities,
            headers:   {
              "Expect"            => "",
              "Transfer-Encoding" => "",
              "User-Agent"        => DiasporaFederation.http_user_agent
            }
          }
        end

        # Create a new instance for a message
        #
        # @param [String] sender_id sender diaspora-ID
        # @param [String] guid guid of the object to send (can be nil if the object has no guid)
        def initialize(sender_id, guid)
          @sender_id = sender_id
          @guid = guid
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
            success = response.success?
            DiasporaFederation.callbacks.trigger(:update_pod, pod_url(response.effective_url), success)

            log_line = "success=#{success} sender=#{@sender_id} guid=#{@guid} url=#{response.effective_url} " \
                       "message=#{response.return_code} code=#{response.response_code} time=#{response.total_time}"
            if success
              logger.info(log_line)
            else
              logger.warn(log_line)

              @urls_to_retry << request.url
            end
          end
        end

        # Get the pod root-url from the send-url
        # @param [String] url
        # @return [String] pod root-url
        def pod_url(url)
          URI.parse(url).tap {|uri| uri.path = "/" }.to_s
        end
      end
    end
  end
end
