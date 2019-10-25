# frozen_string_literal: true

module DiasporaFederation
  module Validators
    # This validates a {Entities::RelatedEntity}.
    class RelatedEntityValidator < Validation::Validator
      include Validation

      rule :author, :diaspora_id
      rule :local, :boolean
      rule :public, :boolean
    end
  end
end
