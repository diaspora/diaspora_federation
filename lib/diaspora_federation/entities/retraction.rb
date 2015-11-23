module DiasporaFederation
  module Entities
    # this entity represents a claim of deletion of a previously federated
    # entity that is not a post or a relayable (now it includes only {Entities::Photo})
    #
    # @see Validators::RetractionValidator
    class Retraction < Entity
      # @!attribute [r] post_guid
      #   guid of a post to be deleted
      #   @see HCard#guid
      #   @return [String] post guid
      property :post_guid

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person who deletes a post
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle

      # @!attribute [r] type
      #   @return [String] type
      property :type
    end
  end
end
