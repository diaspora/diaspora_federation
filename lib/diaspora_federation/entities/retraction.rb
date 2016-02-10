module DiasporaFederation
  module Entities
    # this entity represents a claim of deletion of a previously federated entity
    #
    # @see Validators::RetractionValidator
    class Retraction < Entity
      # @!attribute [r] author
      #   The diaspora ID of the person who deletes the entity
      #   @see Person#author
      #   @return [String] diaspora ID
      property :author, xml_name: :diaspora_handle

      # @!attribute [r] target_guid
      #   guid of the entity to be deleted
      #   @return [String] target guid
      property :target_guid, xml_name: :post_guid

      # @!attribute [r] target_type
      #   A string describing the type of the target.
      #   @return [String] target type
      property :target_type, xml_name: :type
    end
  end
end
