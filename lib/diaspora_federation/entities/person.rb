module DiasporaFederation
  module Entities
    # this entity contains the base data of a person
    #
    # @see Validators::PersonValidator
    class Person < Entity
      # @!attribute [r] guid
      #   @see HCard#guid
      #   @return [String] guid
      property :guid

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle

      # @!attribute [r] url
      #   @see WebFinger#seed_url
      #   @return [String] link to the pod
      property :url

      # @!attribute [r] profile
      #   all profile data of the person
      #   @return [Profile] the profile of the person
      entity :profile, Entities::Profile

      # @!attribute [r] exported_key
      #   @see HCard#public_key
      #   @return [String] public key
      property :exported_key
    end
  end
end
