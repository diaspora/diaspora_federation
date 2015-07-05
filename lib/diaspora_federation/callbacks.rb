module DiasporaFederation
  class Callbacks
    def initialize(events)
      @events   = events
      @handlers = {}
    end

    def on(event, &callback)
      raise ArgumentError, "Undefined event #{event}" unless @events.include? event
      raise ArgumentError, "Already defined event #{event}" if @handlers.has_key? event

      @handlers[event] = callback
    end

    def trigger(event, *args)
      raise ArgumentError, "Undefined event #{event}" unless @events.include? event

      @handlers[event].call(*args)
    end

    def definition_complete?
      missing_handlers.empty?
    end

    def missing_handlers
      @events - @handlers.keys
    end
  end
end
