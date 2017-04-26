module DiasporaFederation
  module Validators
    # This validates a {Entities::Profile}.
    class ProfileValidator < Validation::Validator
      include Validation

      rule :author, :diaspora_id

      # The name must not contain a semicolon because of mentions.
      # @{<full_name> ; <diaspora_id>}
      rule :first_name, regular_expression: {regex: /\A[^;]{,32}\z/}
      rule :last_name, regular_expression: {regex: /\A[^;]{,32}\z/}

      # These urls can be relative.
      rule :image_url, URI: [:path]
      rule :image_url_medium, URI: [:path]
      rule :image_url_small, URI: [:path]

      rule :birthday, :birthday

      rule :gender, length: {maximum: 255}
      rule :bio, length: {maximum: 65_535}
      rule :location, length: {maximum: 255}

      rule :searchable, :boolean
      rule :public, :boolean
      rule :nsfw, :boolean

      rule :tag_string, tag_count: {maximum: 5}
    end
  end
end
