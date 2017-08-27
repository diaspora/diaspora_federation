module DiasporaFederation
  module Validators
    # This validates a {Entities::StatusMessage}.
    class StatusMessageValidator < OptionalAwareValidator
      include Validation

      rule :author, %i[not_empty diaspora_id]

      rule :guid, :guid

      rule :text, length: {maximum: 65_535}

      rule :photos, :not_nil

      rule :public, :boolean
    end
  end
end
