#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# from diaspora for testing

module Diaspora
  module Guid
    # Creates a before_create callback which calls #set_guid
    def self.included(model)
      model.class_eval do
        after_initialize :set_guid
        validates :guid, uniqueness: true
      end
    end

    # @return [String] The model's guid.
    def set_guid
      self.guid = UUID.generate :compact if guid.blank?
    end
  end
end
