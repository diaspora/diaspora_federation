module DiasporaFederation
  module Federation
    module Receiver
      # receiver for public entities
      class Public < AbstractReceiver
        private

        def validate
          super
          raise NotPublic if entity_can_be_public_but_it_is_not?
        end

        def entity_can_be_public_but_it_is_not?
          entity.respond_to?(:public) && !entity.public
        end
      end
    end
  end
end
