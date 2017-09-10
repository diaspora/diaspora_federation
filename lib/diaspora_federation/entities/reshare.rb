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
      property :root_guid, :string, optional: true

      # @!attribute [r] public
      #   Has no meaning at the moment
      #   @return [Boolean] public
      property :public, :boolean, optional: true, default: true # always true? (we only reshare public posts)

      # @!attribute [r] text
      #   A comment about the reshared post
      #   @return [String] text of the comment about the reshare
      property :text, :string, optional: true

      # @return [String] string representation of this object
      def to_s
        "#{super}:#{root_guid}"
      end

      # Fetch and receive root post from remote, if not available locally
      # and validates if it's from the correct author
      def validate_root
        return if root_author.nil? && root_guid.nil?

        raise Entity::ValidationError, "#{self}: root_guid can't be nil if root_author is present" if root_guid.nil?
        raise Entity::ValidationError, "#{self}: root_author can't be nil if root_guid is present" if root_author.nil?

        root = RelatedEntity.fetch(root_author, "Post", root_guid)

        return if root_author == root.author

        raise Entity::ValidationError,
              "root_author mismatch: obj=#{self} root_author=#{root_author} known_root_author=#{root.author}"
      end

      # Fetch root post after parse
      # @see Entity.from_hash
      # @return [Entity] instance
      def self.from_hash(hash)
        super.tap(&:validate_root)
      end
    end
  end
end
