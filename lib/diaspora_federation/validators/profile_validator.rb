module DiasporaFederation
  module Validators
    class ProfileValidator < Validation::Validator
      include Validation

      rule :diaspora_id, :diaspora_id

      # the name must not contain a semicolon because of mentions
      # @{<full_name> ; <diaspora_id>}
      rule :first_name, regular_expression: {regex: /\A[^;]{,32}\z/}
      rule :last_name, regular_expression: {regex: /\A[^;]{,32}\z/}

      rule :tag_string, tag_count: {maximum: 5}

      rule :birthday, :birthday

      rule :searchable, :boolean

      rule :nsfw, :boolean
    end
  end
end
