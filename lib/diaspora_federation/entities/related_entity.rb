module DiasporaFederation
  module Entities
    # Entity meta informations for a related entity (parent or target of
    # another entity).
    class RelatedEntity < Entity
      # @!attribute [r] author
      #   The diaspora* ID of the author
      #   @see Person#author
      #   @return [String] diaspora* ID
      property :author, :string

      # @!attribute [r] local
      #   +true+ if the owner of the entity is local on the pod
      #   @return [Boolean] is it a like or a dislike
      property :local, :boolean

      # @!attribute [r] public
      #   Shows whether the entity is visible to everyone or only to some aspects
      #   @return [Boolean] is it public
      property :public, :boolean, default: false

      # @!attribute [r] parent
      #   Parent if the entity also has a parent (Comment or Like) or +nil+ if it has no parent
      #   @return [RelatedEntity] parent entity
      entity :parent, Entities::RelatedEntity, default: nil

      # never add {RelatedEntity} to xml
      def to_xml
        nil
      end

      def to_json
        nil
      end
    end
  end
end
