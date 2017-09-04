module DiasporaFederation
  module Validators
    # This validates a {Entities::Contact}.
    class ContactValidator < OptionalAwareValidator
      include Validation

      rule :author, %i[not_empty diaspora_id]
      rule :recipient, %i[not_empty diaspora_id]
      rule :following, :boolean
      rule :sharing, :boolean
      rule :blocking, :boolean
    end
  end
end
