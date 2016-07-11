module DiasporaFederation
  module Validators
    # This validates a {Entities::Like}.
    class LikeValidator < Validation::Validator
      include Validation

      include RelayableValidator

      rule :parent_type, [:not_empty, regular_expression: {regex: /\A(Post|Comment)\z/}]
    end
  end
end
