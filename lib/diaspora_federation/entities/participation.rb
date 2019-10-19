# frozen_string_literal: true

module DiasporaFederation
  module Entities
    # Participation is sent to subscribe a user on updates for some post.
    #
    # @see Validators::Participation
    class Participation < Entity
      # @!attribute [r] author
      #   The diaspora* ID of the author
      #   @see Person#author
      #   @return [String] diaspora* ID
      property :author, :string, xml_name: :diaspora_handle

      # @!attribute [r] guid
      #   A random string of at least 16 chars
      #   @see Validation::Rule::Guid
      #   @return [String] guid
      property :guid, :string

      # @!attribute [r] parent_guid
      #   @see StatusMessage#guid
      #   @return [String] parent guid
      property :parent_guid, :string

      # @!attribute [r] parent_type
      #   A string describing a type of the target to subscribe on
      #   Currently only "Post" is supported.
      #   @return [String] parent type
      property :parent_type, :string, xml_name: :target_type

      # @return [String] string representation of this object
      def to_s
        "#{super}:#{parent_type}:#{parent_guid}"
      end

      # Validates that the parent exists and the parent author is local
      def validate_parent
        parent = DiasporaFederation.callbacks.trigger(:fetch_related_entity, parent_type, parent_guid)
        raise ParentNotLocal, "obj=#{self}" unless parent&.local
      end

      # Validate that the parent is local.
      # @see Entity.from_hash
      # @param [Hash] hash entity initialization hash
      # @return [Entity] instance
      def self.from_hash(hash)
        super.tap(&:validate_parent)
      end

      # Raised, if the parent is not owned by the receiving pod.
      class ParentNotLocal < RuntimeError
      end
    end
  end
end
