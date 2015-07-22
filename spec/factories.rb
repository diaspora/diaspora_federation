require "factory_girl"

def r_str
  SecureRandom.hex(3)
end

FactoryGirl.define do
  sequence(:diaspora_id) {|n| "person-#{n}-#{r_str}@localhost:3000" }
  sequence(:public_key) { OpenSSL::PKey::RSA.generate(1024).public_key.export }

  factory :person do
    diaspora_id
    url "http://localhost:3000/"
    serialized_public_key { generate(:public_key) }
    after(:create) do |u|
      u.save
    end
  end

  factory :person_entity, class: DiasporaFederation::Entities::Person do
    guid UUID.generate :compact
    diaspora_id
    url "http://localhost:3000/"
    exported_key { generate(:public_key) }
    profile {
      DiasporaFederation::Entities::Profile.new(
        FactoryGirl.attributes_for(:profile_entity, diaspora_id: diaspora_id))
    }
  end

  factory :profile_entity, class: DiasporaFederation::Entities::Profile do
    diaspora_id
    first_name "my_name"
    last_name nil
    tag_string "#i #love #tags"
    birthday "1988-07-15"
    searchable true
    nsfw false
  end
end
