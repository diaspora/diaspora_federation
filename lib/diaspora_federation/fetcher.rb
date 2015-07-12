require "faraday"
require "faraday_middleware/response/follow_redirects"
require "typhoeus/adapters/faraday"

module DiasporaFederation
  # A wrapper for {https://github.com/lostisland/faraday Faraday} used for
  # fetching
  #
  # @see Discovery::Discovery
  class Fetcher
    # Perform a GET request
    #
    # @param [String] uri the URI
    # @return [Faraday::Response] the response
    def self.get(uri)
      connection.get(uri)
    end

    # gets the Faraday connection
    #
    # @return [Faraday::Connection] the response
    def self.connection
      create_default_connection unless @connection
      @connection.dup
    end

    def self.create_default_connection
      options = {
        request: {timeout: 30},
        ssl:     {ca_file: DiasporaFederation.certificate_authorities}
      }

      @connection = Faraday::Connection.new(options) do |builder|
        builder.use FaradayMiddleware::FollowRedirects, limit: 4
        builder.adapter :typhoeus
      end

      @connection.headers["User-Agent"] = "DiasporaFederation/#{DiasporaFederation::VERSION}"
    end
    private_class_method :create_default_connection
  end
end
