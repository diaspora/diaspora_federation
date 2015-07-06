module DiasporaFederation
  # logging module for the diaspora federation
  #
  # it uses the logging-gem if available
  module Logging
    private

    # get the logger for this class
    #
    # use the logging-gem if available, else use a default logger
    def logger
      @logger ||= begin
                    # use logging-gem if available
                    return ::Logging::Logger[self] if Object.const_defined?("::Logging::Logger")

                    # fallback logger
                    @logger = Logger.new(STDOUT)
                    loglevel = defined?(::Rails) ? ::Rails.configuration.log_level.to_s.upcase : "INFO"
                    @logger.level = Logger.const_get(loglevel)
                    @logger
                  end
    end
  end
end
