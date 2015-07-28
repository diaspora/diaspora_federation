module DiasporaFederation
  module Validators
    # This validates a {Entities::Profile}
    class ProfileValidator < Validation::Validator
      include Validation

      rule :diaspora_id, :diaspora_id

      # the name must not contain a semicolon because of mentions
      # @{<full_name> ; <diaspora_id>}
      rule :first_name, regular_expression: {regex: /\A[^;]{,32}\z/}
      rule :last_name, regular_expression: {regex: /\A[^;]{,32}\z/}

      # this urls can be relative
      rule :image_url, nilableURI: [:path]
      rule :image_url_medium, nilableURI: [:path]
      rule :image_url_small, nilableURI: [:path]

      rule :birthday, :birthday

      # TODO: replace regex with "length: {maximum: xxx}" but this rule doesn't allow nil now.
      rule :gender, regular_expression: {regex: /\A.{,255}\z/}
      rule :bio, regular_expression: {regex: /\A.{,65535}\z/}
      rule :location, regular_expression: {regex: /\A.{,255}\z/}

      rule :searchable, :boolean

      rule :nsfw, :boolean

      rule :tag_string, tag_count: {maximum: 5}
    end
  end
end
