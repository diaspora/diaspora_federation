module DiasporaFederation
  module Validators
    # This validates a {Entities::Contact}.
    class ContactValidator < Validation::Validator
      include Validation

      rule :author, %i[not_empty diaspora_id]
      rule :recipient, %i[not_empty diaspora_id]
      rule :following, :boolean
      rule :sharing, :boolean
    end
  end
end
