module DiasporaFederation
  # Logging module for the diaspora* federation
  #
  # It uses the logging-gem if available.
  module Logging
    # Add +logger+ also as class method when included
    # @param [Class] klass the class into which the module is included
    def self.included(klass)
      klass.extend(self)
    end

    private

    # Get the logger for this class
    #
    # Use the logging-gem if available, else use a default logger.
    def logger
      @logger ||= begin
                    # Use logging-gem if available
                    return ::Logging::Logger[self] if defined?(::Logging::Logger)

                    # Use rails logger if running in rails and no logging-gem is available
                    return ::Rails.logger if defined?(::Rails)

                    # fallback logger
                    @logger = Logger.new(STDOUT)
                    @logger.level = Logger::INFO
                    @logger
                  end
    end
  end
end
