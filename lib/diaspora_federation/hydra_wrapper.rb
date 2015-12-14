require "typhoeus"
require "diaspora_federation/version"

module DiasporaFederation
  class HydraWrapper
    include Logging

    OPTS = {
      maxredirs: 3,
      timeout:   25,
      method:    :post,
      verbose:   true, # AppConfig.settings.typhoeus_verbose?,
      cainfo:    DiasporaFederation.certificate_authorities,
      headers:   {
        "Expect"            => "",
        "Transfer-Encoding" => "",
        "User-Agent"        => "DiasporaFederation #{VERSION}"
      }
    }

    attr_reader :people_to_retry, :user, :entity
    attr_accessor :dispatcher_class, :people

    def run
      hydra.run
    end

    def initialize(user, people, entity, is_public)
      @user = user
      @people_to_retry = []
      @people = people
      @is_public = is_public
      @entity = entity
      @keep_for_retry_proc = proc do
        true
      end
    end

    # Inserts jobs for all @people
    def enqueue_batch
      grouped_people.each do |receive_url, people_for_receive_url|
        xml = entity_xml_for(people_for_receive_url.first)
        insert_job(receive_url, xml, people_for_receive_url) if xml
      end
    end

    # This method can be used to tell the hydra whether or not to
    # retry a request that it made which failed.
    # @yieldparam response [Typhoeus::Response] The response object for the failed request.
    # @yieldreturn [Boolean] Whether the request whose response was passed to the block should be retried.
    def keep_for_retry_if(&block)
      @keep_for_retry_proc = block
    end

    private

    def hydra
      @hydra ||= Typhoeus::Hydra.new(max_concurrency: 20) # AppConfig.settings.typhoeus_concurrency.to_i)
    end

    def entity_xml_for(person)
      if @is_public
        Salmon::Slap.generate_xml(
          @user.diaspora_id,
          @user.private_key,
          @entity
        )
      else
        Salmon::EncryptedSlap.generate_xml(
          @user.diaspora_id,
          @user.private_key,
          @entity,
          DiasporaFederation.callbacks.trigger(:fetch_public_key_by_diaspora_id, person.diaspora_id)
        )
      end
    end

    # Group people on their receiving_urls
    # @return [Hash] People grouped by receive_url ([String] => [Array<Person>])
    def grouped_people
      @people.group_by { |person|
        receive_url_for(person)
      }
    end

    def receive_url_for(person)
      @is_public ? person.url + "receive/public" : person.receive_url
    end

    # Prepares and inserts job into the hydra queue
    # @param url [String]
    # @param xml [String]
    # @params people [Array<Person>]
    def insert_job(url, xml, people)
      request = Typhoeus::Request.new url, OPTS.merge(body: {xml: CGI.escape(xml)})
      prepare_request request, people
      hydra.queue request
    end

    # @param request [Typhoeus::Request]
    # @param person [Person]
    def prepare_request(request, people_for_receive_url)
      request.on_complete do |response|
        # Save the reference to the pod to the database if not already present
        # Pod.find_or_create_by(url: response.effective_url)

        # if redirecting_to_https? response
        #  Person.url_batch_update people_for_receive_url, response.headers_hash['Location']
        # end

        unless response.success?
          logger.warn "event=http_multi_fail sender_id=#{@user.diaspora_id} url=#{response.effective_url} " \
                      "return_code=#{response.return_code} response_code=#{response.response_code}"

          if @keep_for_retry_proc.call(response)
            @people_to_retry += people_for_receive_url.map(&:id)
          end

        end
      end
    end

    # @return [Boolean]
    def redirecting_to_https?(response)
      response.code >= 300 && response.code < 400 &&
      response.headers_hash["Location"] == response.request.url.sub("http://", "https://")
    end
  end
end
