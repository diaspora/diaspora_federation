require "validation"
require "validation/rule/regular_expression"
require "validation/rule/length"
require "validation/rule/not_empty"
require "validation/rule/uri"
require "validation/rule/numeric"

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
  #
  # The Validators are mapped with the entities by name. The naming schema
  # is "<EntityName>Validator".
  module Validators
  end
end

require "diaspora_federation/validators/h_card_validator"
require "diaspora_federation/validators/person_validator"
require "diaspora_federation/validators/profile_validator"
require "diaspora_federation/validators/web_finger_validator"
require "diaspora_federation/validators/request_validator"
require "diaspora_federation/validators/photo_validator"
require "diaspora_federation/validators/location_validator"
require "diaspora_federation/validators/status_message_validator"
require "diaspora_federation/validators/participation_validator"
