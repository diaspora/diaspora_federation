module DiasporaFederation
  module Entities
    # this entity represents the fact the a user reshared some other user's post
    #
    # @see Validators::ReshareValidator
    class Reshare < Entity
      include Post

      # @!attribute [r] root_author
      #   The diaspora ID of the person who posted the original post
      #   @see Person#author
      #   @return [String] diaspora ID
      property :root_author, xml_name: :root_diaspora_id

      # @!attribute [r] root_guid
      #   guid of the original post
      #   @see StatusMessage#guid
      #   @return [String] root guid
      property :root_guid

      # @!attribute [r] public
      #   has no meaning at the moment
      #   @return [Boolean] public
      property :public, default: true # always true? (we only reshare public posts)

      # @return [String] string representation of this object
      def to_s
        "#{super}:#{root_guid}"
      end

      # fetch and receive root post from remote, if not available locally.
      def fetch_root
        root = DiasporaFederation.callbacks.trigger(:fetch_related_entity, "Post", root_guid)
        Federation::Fetcher.fetch_public(root_author, "Post", root_guid) unless root
      end

      # Fetch root post after parse.
      # @see Entity.populate_entity
      # @param [Nokogiri::XML::Element] root_node xml nodes
      # @return [Entity] instance
      private_class_method def self.populate_entity(root_node)
        new(entity_data(root_node)).tap(&:fetch_root)
      end
    end
  end
end
