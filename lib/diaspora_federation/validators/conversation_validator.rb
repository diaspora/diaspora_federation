module DiasporaFederation
  module Validators
    # This validates a {Entities::Conversation}.
    class ConversationValidator < OptionalAwareValidator
      include Validation

      rule :author, %i[not_empty diaspora_id]
      rule :guid, :guid

      rule :subject, [:not_empty, length: {maximum: 255}]

      rule :participants, diaspora_id_count: {maximum: 20}
      rule :messages, :not_nil
    end
  end
end
