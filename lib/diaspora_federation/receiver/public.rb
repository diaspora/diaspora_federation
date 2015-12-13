module DiasporaFederation
  class Receiver
    # Receiver::Public is used to receive public messages, which are not addressed to a specific user, unencrypted
    # and packed using Salmon::Slap
    class Public < Receiver
      protected

      def slap
        @salmon ||= Salmon::Slap.from_xml(@salmon_xml)
      end
    end
  end
end
