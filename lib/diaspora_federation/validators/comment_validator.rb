module DiasporaFederation
  module Validators
    class CommentValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      include RelayableValidator

      rule :text, [:not_empty,
                   length: {maximum: 65_535}]

      rule :diaspora_id, %i(not_empty diaspora_id)
    end
  end
end
