module DiasporaFederation
  module Entities
    # This is a module that defines common properties for a post which
    # include {StatusMessage} and {Reshare}.
    module Post
      # On inclusion of this module the required properties for a post are added to the object that includes it.
      #
      # @!attribute [r] author
      #   The diaspora* ID of the person who posts the post
      #   @see Person#author
      #   @return [String] diaspora* ID
      #
      # @!attribute [r] guid
      #   A random string of at least 16 chars
      #   @see Validation::Rule::Guid
      #   @return [String] status message guid
      #
      # @!attribute [r] created_at
      #   Post entity creation time
      #   @return [Time] creation time
      #
      # @!attribute [r] public
      #   Shows whether the post is visible to everyone or only to some aspects
      #   @return [Boolean] is it public
      #
      # @!attribute [r] provider_display_name
      #   A string that describes a means by which a user has posted the post
      #   @return [String] provider display name
      #
      # @param [Entity] entity the entity in which it is included
      def self.included(entity)
        entity.class_eval do
          property :author, :string, xml_name: :diaspora_handle
          property :guid, :string
          property :created_at, :timestamp, default: -> { Time.now.utc }
          property :public, :boolean, default: false
          property :provider_display_name, :string, optional: true
        end
      end
    end
  end
end
