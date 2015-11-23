module DiasporaFederation
  module Entities
    # this entity represents a claim of deletion of a previously federated
    # entity of post type ({Entities::StatusMessage})
    #
    # @see Validators::SignedRetractionValidator
    class SignedRetraction < Entity
      # @!attribute [r] target_guid
      #   guid of a post to be deleted
      #   @see HCard#guid
      #   @return [String] target guid
      property :target_guid

      # @!attribute [r] target_type
      #   @return [String] target type
      property :target_type

      # @!attribute [r] sender_id
      #   The diaspora ID of the person who deletes a post
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :sender_id, xml_name: :sender_handle

      # @!attribute [r] author_signature
      #   Contains a signature of the entity using the private key of the author of a post
      #   This signature is mandatory.
      #   @return [String] author signature
      property :target_author_signature
    end
  end
end
