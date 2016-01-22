module DiasporaFederation
  module Validators
    # This validates a {Entities::Like}
    class LikeValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      rule :parent_type, [:not_empty, regular_expression: {regex: /\A(Post|Comment)\z/}]

      include RelayableValidator

      rule :diaspora_id, %i(not_empty diaspora_id)
    end
  end
end
