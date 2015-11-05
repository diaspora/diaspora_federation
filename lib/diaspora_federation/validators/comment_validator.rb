module DiasporaFederation
  module Validators
    class CommentValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      rule :parent_guid, :guid

      rule :parent_author_signature, :not_empty

      rule :author_signature, :not_empty

      rule :text, [:not_empty,
                   length: {maximum: 65_535}]

      rule :diaspora_id, %i(not_empty diaspora_id)
    end
  end
end
