module DiasporaFederation
  module Federation
    module Receiver
      # This is used to receive public messages, which are not addressed to
      # a specific user, unencrypted and packed using {Salmon::Slap}.
      # @deprecated
      class PublicSlapReceiver < SlapReceiver
        protected

        # parses the public slap xml
        # @return [Salmon::Slap] slap instance
        def slap
          @slap ||= Salmon::Slap.from_xml(@slap_xml)
        end
      end
    end
  end
end
