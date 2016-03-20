module DiasporaFederation
  module Federation
    module Receiver
      # Common base for Private and Public receivers
      # @see PublicSlapReceiver
      # @see PrivateSlapReceiver
      # @deprecated
      class SlapReceiver
        # initializes a new SlapReceiver for a salmon slap XML
        # @param [String] slap_xml the message salmon xml
        def initialize(slap_xml)
          @slap_xml = slap_xml
        end

        # Parse the salmon xml
        def parse
          slap.entity
        end
      end
    end
  end
end
