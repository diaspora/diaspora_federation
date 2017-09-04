module DiasporaFederation
  module Validators
    # This validates a {Entities::Retraction}.
    class RetractionValidator < OptionalAwareValidator
      include Validation

      rule :author, %i[not_empty diaspora_id]

      rule :target_guid, :guid
      rule :target_type, :not_empty
      rule :target, :not_nil
    end
  end
end
