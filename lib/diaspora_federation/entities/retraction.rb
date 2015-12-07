module DiasporaFederation
  module Entities
    # this entity represents a claim of deletion of a previously federated
    #
    # @see Validators::RetractionValidator
    class Retraction < Entity
      # @!attribute [r] target_guid
      #   guid of the entity to be deleted
      #   @return [String] target guid
      property :target_guid, xml_name: :post_guid

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person who deletes the entity
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle

      # @!attribute [r] target_type
      #   A string describing the type of the target.
      #   @return [String] target type
      property :target_type, xml_name: :type
    end
  end
end
