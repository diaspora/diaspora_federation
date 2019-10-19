# frozen_string_literal: true

module DiasporaFederation
  module Entities
    # This entity represents a claim of deletion of a previously federated
    # entity of post type. ({Entities::StatusMessage})
    #
    # @see Validators::SignedRetractionValidator
    # @deprecated will be replaced with {Entities::Retraction}
    class SignedRetraction < Entity
      # @!attribute [r] target_guid
      #   Guid of a post to be deleted
      #   @see Retraction#target_guid
      #   @return [String] target guid
      property :target_guid, :string

      # @!attribute [r] target_type
      #   A string describing the type of the target
      #   @see Retraction#target_type
      #   @return [String] target type
      property :target_type, :string

      # @!attribute [r] author
      #   The diaspora* ID of the person who deletes a post
      #   @see Person#author
      #   @return [String] diaspora* ID
      property :author, :string, xml_name: :sender_handle

      # @!attribute [r] author_signature
      #   Contains a signature of the entity using the private key of the author of a post
      #   This signature is mandatory.
      #   @return [String] author signature
      property :target_author_signature, :string, default: nil

      def initialize(*)
        raise "Sending SignedRetraction is not supported anymore! Use Retraction instead!"
      end

      # @return [Retraction] instance
      def self.from_hash(hash)
        Retraction.from_hash(hash)
      end
    end
  end
end
