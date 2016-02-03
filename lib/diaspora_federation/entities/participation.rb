module DiasporaFederation
  module Entities
    # participation is sent to subscribe a user on updates for some post
    #
    # @see Validators::Participation
    class Participation < Entity
      # old signature order
      # @deprecated
      LEGACY_SIGNATURE_ORDER = %i(guid parent_type parent_guid diaspora_id).freeze

      include Relayable

      # @!attribute [r] parent_type
      #   a string describing a type of the target to subscribe on.
      #   currently only "Post" is supported.
      #   @return [String] parent type
      property :parent_type, xml_name: :target_type
    end
  end
end
