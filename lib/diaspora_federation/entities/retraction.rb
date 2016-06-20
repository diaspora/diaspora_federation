module DiasporaFederation
  module Entities
    # this entity represents a claim of deletion of a previously federated entity
    #
    # @see Validators::RetractionValidator
    class Retraction < Entity
      # @!attribute [r] author
      #   The diaspora ID of the person who deletes the entity
      #   @see Person#author
      #   @return [String] diaspora ID
      property :author, xml_name: :diaspora_handle

      # @!attribute [r] target_guid
      #   guid of the entity to be deleted
      #   @return [String] target guid
      property :target_guid, xml_name: :post_guid

      # @!attribute [r] target_type
      #   A string describing the type of the target.
      #   @return [String] target type
      property :target_type, xml_name: :type

      # @!attribute [r] target
      #   target entity
      #   @return [RelatedEntity] target entity
      entity :target, Entities::RelatedEntity

      def sender_valid?(sender)
        case target_type
        when "Comment", "Like", "PollParticipation"
          sender == target.author || sender == target.parent.author
        else
          sender == target.author
        end
      end

      # @return [String] string representation of this object
      def to_s
        "Retraction:#{target_type}:#{target_guid}"
      end

      # @param [Nokogiri::XML::Element] root_node xml nodes
      # @return [Retraction] instance
      private_class_method def self.populate_entity(root_node)
        entity_data = entity_data(root_node)
        entity_data[:target] = fetch_target(entity_data[:target_type], entity_data[:target_guid])
        new(entity_data)
      end

      private_class_method def self.fetch_target(target_type, target_guid)
        DiasporaFederation.callbacks.trigger(:fetch_related_entity, target_type, target_guid).tap do |target|
          raise TargetNotFound, "not found: #{target_type}:#{target_guid}" unless target
        end
      end

      # Raised, if the target of the {Retraction} was not found.
      class TargetNotFound < RuntimeError
      end
    end
  end
end
