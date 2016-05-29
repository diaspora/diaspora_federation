module DiasporaFederation
  # logging module for the diaspora federation
  #
  # it uses the logging-gem if available
  module Logging
    # add +logger+ also as class method when included
    # @param [Class] klass the class into which the module is included
    def self.included(klass)
      klass.extend(self)
    end

    private

    # get the logger for this class
    #
    # use the logging-gem if available, else use a default logger
    def logger
      @logger ||= begin
                    # use logging-gem if available
                    return ::Logging::Logger[self] if defined?(::Logging::Logger)

                    # use rails logger if running in rails and no logging-gem is available
                    return ::Rails.logger if defined?(::Rails)

                    # fallback logger
                    @logger = Logger.new(STDOUT)
                    @logger.level = Logger::INFO
                    @logger
                  end
    end
  end
end
