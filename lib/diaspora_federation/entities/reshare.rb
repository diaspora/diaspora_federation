module DiasporaFederation
  module Entities
    # This entity represents the fact that a user reshared another user's post.
    #
    # @see Validators::ReshareValidator
    class Reshare < Entity
      # @!attribute [r] author
      #   The diaspora* ID of the person who reshares the post
      #   @see Person#author
      #   @return [String] diaspora* ID
      property :author, :string, xml_name: :diaspora_handle

      # @!attribute [r] guid
      #   A random string of at least 16 chars
      #   @see Validation::Rule::Guid
      #   @return [String] status message guid
      property :guid, :string

      # @!attribute [r] created_at
      #   Post entity creation time
      #   @return [Time] creation time
      property :created_at, :timestamp, default: -> { Time.now.utc }

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

      # @return [String] string representation of this object
      def to_s
        "#{super}:#{root_guid}"
      end

      # Fetch and receive root post from remote, if not available locally
      # and validates if it's from the correct author
      # TODO: after reshares are only used to increase the reach of a post (and
      # legacy reshares with own interactions are migrated to the new form),
      # root_author and root_guid aren't allowed to be empty anymore, so a
      # not_nil check should be added to the validator and the first few lines
      # here can be removed.
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
