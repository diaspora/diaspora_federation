module DiasporaFederation
  module Validators
    # This validates a {Entities::Conversation}.
    class ConversationValidator < OptionalAwareValidator
      include Validation

      rule :author, :diaspora_id
      rule :guid, :guid

      rule :subject, [:not_empty, length: {maximum: 255}]

      rule :participants, diaspora_id_list: {minimum: 2}
      rule :messages, :not_nil
    end
  end
end
