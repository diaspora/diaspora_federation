class Entity < ActiveRecord::Base
  include ::Diaspora::Guid

  belongs_to :author, class_name: "Person"
end
