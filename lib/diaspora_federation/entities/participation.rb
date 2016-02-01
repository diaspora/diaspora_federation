module DiasporaFederation
  module Entities
    # participation is sent to subscribe a user on updates for some post
    #
    # @see Validators::Participation
    class Participation < Entity
      # old signature order
      # @deprecated
      LEGACY_SIGNATURE_ORDER = %i(guid parent_type parent_guid diaspora_id).freeze

      # @!attribute [r] guid
      #   a random string of at least 16 chars.
      #   @see Validation::Rule::Guid
      #   @return [String] participation guid
      property :guid

      # @!attribute [r] parent_type
      #   a string describing a type of the target to subscribe on.
      #   currently only "Post" is supported.
      #   @return [String] parent type
      property :parent_type, xml_name: :target_type

      include Relayable

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person who subscribes on a post
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle
    end
  end
end
