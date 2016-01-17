module DiasporaFederation
  module Federation
    class Receiver
      # Receiver::Public is used to receive public messages, which are not addressed to a specific user, unencrypted
      # and packed using Salmon::Slap
      class Public < Receiver
        protected

        # parses the public slap xml
        # @return [Salmon::Slap] slap instance
        def slap
          @salmon ||= Salmon::Slap.from_xml(@salmon_xml)
        end
      end
    end
  end
end
