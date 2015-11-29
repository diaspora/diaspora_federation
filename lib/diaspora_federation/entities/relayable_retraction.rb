module DiasporaFederation
  module Entities
    # this entity represents a claim of deletion of a previously federated
    # relayable entity ({Entities::Comment}, {Entities::Like})
    #
    # There are two cases of federation of the RelayableRetraction.
    # Retraction from the dowstream object owner is when an author of the
    # relayable (e.g. Comment) deletes it himself. In this case only target_author_signature
    # is filled and retraction is sent to the commented post's author. Here
    # he (upstream object owner) signes it with parent's author key and fills
    # signature in parent_author_signature and sends it to other pods where
    # other participating people present. This is the second case - retraction
    # from the upstream object owner.
    # Retraction from the upstream object owner can also be performed by the
    # upstream object owner himself - he has a right to delete comments on his posts.
    # In any case in the retraction by the upstream author target_author_signature
    # is not checked, only parent_author_signature is checked.
    #
    # @see Validators::RelayableRetractionValidator
    class RelayableRetraction < Entity
      # @!attribute [r] parent_author_signature
      #   Contains a signature of the entity using the private key of the author of a parent post
      #   This signature is mandatory only when federation from an upstream author to the subscribers.
      #   @return [String] parent author signature
      property :parent_author_signature

      # @!attribute [r] target_guid
      #   guid of a post to be deleted
      #   @see HCard#guid
      #   @return [String] target guid
      property :target_guid

      # @!attribute [r] target_type
      #   @return [String] target type
      property :target_type

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person who deletes a post
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :sender_handle

      # @!attribute [r] target_author_signature
      #   Contains a signature of the entity using the private key of the
      #   author of a federated relayable entity ({Entities::Comment}, {Entities::Like})
      #   This signature is mandatory only when federation from the subscriber to an upstream
      #   author is done.
      #   @return [String] target author signature
      property :target_author_signature
    end
  end
end
