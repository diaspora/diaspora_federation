module DiasporaFederation
  module Federation
    module Receiver
      # Receiver for a magic envelope
      #
      # @see Salmon::MagicEnvelope
      class MagicEnvelopeReceiver
        # create a new receiver for a magic envelope
        # @param [String] data the message magic envelope xml
        def initialize(data)
          @data = data
        end

        # parse the magic envelope and create the entity
        # @return [Entity] the parsed entity
        def parse
          Salmon::MagicEnvelope.unenvelop(magic_env_xml)
        end

        protected

        def magic_env_xml
          Nokogiri::XML::Document.parse(@data).root
        end
      end
    end
  end
end
