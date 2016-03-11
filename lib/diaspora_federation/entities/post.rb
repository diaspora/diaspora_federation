module DiasporaFederation
  module Entities
    # this is a module that defines common properties for a post which
    # include {StatusMessage} and {Reshare}.
    module Post
      # on inclusion of this module the required properties for a post are added to the object that includes it
      #
      # @!attribute [r] author
      #   The diaspora ID of the person who posts the post
      #   @see Person#author
      #   @return [String] diaspora ID
      #
      # @!attribute [r] guid
      #   a random string of at least 16 chars.
      #   @see Validation::Rule::Guid
      #   @return [String] status message guid
      #
      # @!attribute [r] created_at
      #   post entity creation time
      #   @return [Time] creation time
      #
      # @!attribute [r] provider_display_name
      #   a string that describes a means by which a user has posted the post
      #   @return [String] provider display name
      def self.included(entity)
        entity.class_eval do
          property :author, xml_name: :diaspora_handle
          property :guid
          property :created_at, default: -> { Time.now.utc }
          property :provider_display_name, default: nil
        end
      end
    end
  end
end
