module DiasporaFederation
  ##
  # logging module for the diaspora federation engine
  #
  # it uses the logging-gem if available
  module Logging
    private

    ##
    # get the logger for this class
    #
    # use the logging-gem if available, else use a default logger
    def logger
      @logger ||= begin
                    # use logging-gem if available
                    return ::Logging::Logger[self] if Object.const_defined?("::Logging::Logger")

                    # fallback logger
                    @logger = Logger.new(STDOUT)
                    @logger.level = Logger.const_get(Rails.configuration.log_level.to_s.upcase)
                    @logger
                  end
    end
  end
end
