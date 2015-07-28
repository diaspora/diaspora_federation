module DiasporaFederation
  module Validators
    # This validates a {Discovery::WebFinger}
    #
    # @note it does not validate the guid and public key, because it will be
    #   removed in the webfinger
    class WebFingerValidator < Validation::Validator
      include Validation

      rule :acct_uri, :not_empty

      rule :alias_url, [:not_nil, nilableURI: %i(host path)]
      rule :hcard_url, [:not_nil, nilableURI: %i(host path)]
      rule :seed_url, %i(not_nil nilableURI)
      rule :profile_url, [:not_nil, nilableURI: %i(host path)]
      rule :atom_url, [:not_nil, nilableURI: %i(host path)]
      rule :salmon_url, [:not_nil, nilableURI: %i(host path)]
    end
  end
end
