module DiasporaFederation
  module Validators
    # This validates a {Entities::Person}.
    class PersonValidator < OptionalAwareValidator
      include Validation

      rule :guid, :guid

      rule :author, :diaspora_id

      rule :url, %i[not_nil URI]

      rule :profile, :not_nil

      rule :exported_key, :public_key
    end
  end
end
