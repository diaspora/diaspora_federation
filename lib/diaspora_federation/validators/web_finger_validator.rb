module DiasporaFederation
  module Validators
    # This validates a {Discovery::WebFinger}.
    #
    # @note It does not validate the guid and public key, because it will be
    #   removed in the webfinger.
    class WebFingerValidator < OptionalAwareValidator
      include Validation

      rule :acct_uri, :not_empty

      rule :hcard_url, [:not_nil, URI: %i[host path]]
      rule :seed_url, %i[not_nil URI]
      rule :profile_url, URI: %i[host path]
      rule :atom_url, URI: %i[host path]
      rule :salmon_url, URI: %i[host path]
    end
  end
end
