module DiasporaFederation
  module Validators
    # This validates a {Discovery::HCard}
    #
    # @todo activate guid and public key validation after all pod have it in
    #   the hcard.
    #
    # @note
    class HCardValidator < Validation::Validator
      include Validation

      # rule :guid, :guid

      # the name must not contain a semicolon because of mentions
      # @{<full_name> ; <diaspora_id>}
      rule :full_name, regular_expression: {regex: /\A[^;]{,70}\z/}
      rule :first_name, regular_expression: {regex: /\A[^;]{,32}\z/}
      rule :last_name, regular_expression: {regex: /\A[^;]{,32}\z/}

      # this urls can be relative
      rule :photo_large_url, [:not_nil, URI: [:path]]
      rule :photo_medium_url, [:not_nil, URI: [:path]]
      rule :photo_small_url, [:not_nil, URI: [:path]]

      # rule :exported_key, :public_key

      rule :searchable, :boolean
    end
  end
end
