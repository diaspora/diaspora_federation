module DiasporaFederation
  module Entities
    # This entity represents the fact that a user reshared another user's post.
    #
    # @see Validators::ReshareValidator
    class Reshare < Entity
      include Post

      # @!attribute [r] root_author
      #   The diaspora* ID of the person who posted the original post
      #   @see Person#author
      #   @return [String] diaspora* ID
      property :root_author, :string, xml_name: :root_diaspora_id

      # @!attribute [r] root_guid
      #   Guid of the original post
      #   @see StatusMessage#guid
      #   @return [String] root guid
      property :root_guid, :string

      # @!attribute [r] public
      #   Has no meaning at the moment
      #   @return [Boolean] public
      property :public, :boolean, default: true # always true? (we only reshare public posts)

      # @return [String] string representation of this object
      def to_s
        "#{super}:#{root_guid}"
      end

      # Fetch and receive root post from remote, if not available locally
      def fetch_root
        root = DiasporaFederation.callbacks.trigger(:fetch_related_entity, "Post", root_guid)
        Federation::Fetcher.fetch_public(root_author, "Post", root_guid) unless root
      end

      # Fetch root post after parse
      # @see Entity.from_hash
      # @return [Entity] instance
      def self.from_hash(hash)
        super.tap(&:fetch_root)
      end
    end
  end
end
