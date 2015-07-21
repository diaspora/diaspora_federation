module DiasporaFederation
  module Validators
    class PersonValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      rule :diaspora_handle, :diaspora_id

      rule :url, :u_r_i # WTF? :uri -> Uri -> "uninitialized constant Uri", :u_r_i -> URI -> \o/

      rule :profile, :not_nil

      rule :exported_key, :public_key
    end
  end
end
