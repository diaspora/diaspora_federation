# frozen_string_literal: true

module DiasporaFederation
  module Entities
    # This entity contains the base data of a person.
    #
    # @see Validators::PersonValidator
    class Person < Entity
      # @!attribute [r] guid
      #   This is just the guid. When a user creates an account on a pod, the pod
      #   MUST assign them a guid - a random string of at least 16 chars.
      #   @see Validation::Rule::Guid
      #   @return [String] guid
      property :guid, :string

      # @!attribute [r] author
      #   The diaspora* ID of the person
      #   @see Validation::Rule::DiasporaId
      #   @return [String] diaspora* ID
      # @!attribute [r] diaspora_id
      #   alias for author
      #   @see Person#author
      #   @return [String] diaspora* ID
      property :author, :string, alias: :diaspora_id, xml_name: :diaspora_handle

      # @!attribute [r] url
      #   @see Discovery::WebFinger#seed_url
      #   @return [String] link to the pod
      property :url, :string

      # @!attribute [r] profile
      #   All profile data of the person
      #   @return [Profile] the profile of the person
      entity :profile, Entities::Profile

      # @!attribute [r] exported_key
      #   @see Discovery::HCard#public_key
      #   @return [String] public key
      property :exported_key, :string
    end
  end
end
