require "validation"
require "validation/rule/regular_expression"
require "validation/rule/uri"

# +valid+ gem namespace
module Validation
  # This module contains custom validation rules for various data field types.
  # That includes types for which there are no provided rules by the +valid+ gem
  # or types that are very specific to Diaspora* federation and need special handling.
  # The rules are used inside the {DiasporaFederation::Validators validator classes}
  # to perform basic sanity-checks on {DiasporaFederation::Entities federation entities}.
  module Rule
  end
end

require "diaspora_federation/validators/rules/birthday"
require "diaspora_federation/validators/rules/boolean"
require "diaspora_federation/validators/rules/diaspora_id"
require "diaspora_federation/validators/rules/guid"
require "diaspora_federation/validators/rules/not_nil"
require "diaspora_federation/validators/rules/public_key"
require "diaspora_federation/validators/rules/tag_count"

module DiasporaFederation
  # Validators to perform basic sanity-checks on {DiasporaFederation::Entities federation entities}.
  module Validators
  end
end

require "diaspora_federation/validators/person_validator"
require "diaspora_federation/validators/profile_validator"
