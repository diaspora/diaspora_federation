# frozen_string_literal: true

module DiasporaFederation
  module Entities
    # This entity is used to specify embed information about an URL that should be embedded.
    #
    # @see Validators::EmbedValidator
    class Embed < Entity
      # @!attribute [r] url
      #   URL that should be embedded.
      #   @return [String] url
      property :url, :string, optional: true

      # @!attribute [r] title
      #   The title of the embedded URL.
      #   @return [String] title
      property :title, :string, optional: true

      # @!attribute [r] description
      #   The description of the embedded URL.
      #   @return [String] description
      property :description, :string, optional: true

      # @!attribute [r] image
      #   The image of the embedded URL.
      #   @return [String] image
      property :image, :string, optional: true

      # @!attribute [r] nothing
      #   True, if nothing should be embedded.
      #   @return [String] nothing
      property :nothing, :boolean, optional: true

      # @return [String] string representation of this object
      def to_s
        "Embed#{":#{url}" if url}"
      end

      def validate
        super

        raise ValidationError, "Either 'url' must be set or 'nothing' must be 'true'" unless nothing ^ url
      end
    end
  end
end
