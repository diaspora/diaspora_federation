module DiasporaFederation
  module Entities
    # this entity represents a claim of deletion of a previously federated
    # entity that is not a post or a relayable (now it includes only {Entities::Photo})
    #
    # @see Validators::RetractionValidator
    class Retraction < Entity
      # @!attribute [r] target_guid
      #   guid of the entity to be deleted
      #   @see HCard#guid
      #   @return [String] target guid
      property :target_guid, xml_name: :post_guid

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person who deletes a post
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle

      # @!attribute [r] target_type
      #   @return [String] target type
      property :target_type, xml_name: :type
    end
  end
end
