module DiasporaFederation
  module Validators
    class PersonValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      rule :diaspora_id, :diaspora_id

      rule :url, :URI

      rule :profile, :not_nil

      rule :exported_key, :public_key
    end
  end
end
