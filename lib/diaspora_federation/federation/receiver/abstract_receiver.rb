module DiasporaFederation
  module Federation
    module Receiver
      # common functionality for receivers
      class AbstractReceiver
        # create a new receiver
        # @param [MagicEnvelope] magic_envelope the received magic envelope
        # @param [Object] recipient_id the identifier of the recipient of a private message
        def initialize(magic_envelope, recipient_id=nil)
          @entity = magic_envelope.payload
          @sender = magic_envelope.sender
          @recipient_id = recipient_id
        end

        # validate and receive the entity
        def receive
          validate
          DiasporaFederation.callbacks.trigger(:receive_entity, entity, recipient_id)
        end

        private

        attr_reader :entity, :sender, :recipient_id

        def validate
          raise InvalidSender unless sender_valid?
        end

        def sender_valid?
          case entity
          when Entities::Retraction
            case entity.target_type
            when "Comment", "Like", "PollParticipation"
              sender == entity.target.author || sender == entity.target.parent.author
            else
              sender == entity.target.author
            end
          when Entities::Relayable
            sender == entity.author || sender == entity.parent.author
          else
            sender == entity.author
          end
        end
      end
    end
  end
end
