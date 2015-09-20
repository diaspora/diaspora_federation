require "factory_girl"

def r_str
  SecureRandom.hex(3)
end

FactoryGirl.define do
  sequence(:guid) { UUID.generate :compact }
  sequence(:diaspora_id) {|n| "person-#{n}-#{r_str}@localhost:3000" }
  sequence(:public_key) { OpenSSL::PKey::RSA.generate(1024).public_key.export }

  factory :person do
    diaspora_id
    url "http://localhost:3000/"
    serialized_public_key { generate(:public_key) }
    after(:create, &:save)
  end

  factory :webfinger, class: DiasporaFederation::Discovery::WebFinger do
    guid
    acct_uri { "acct:#{generate(:diaspora_id)}" }
    alias_url "http://localhost:3000/people/0123456789abcdef"
    hcard_url "http://localhost:3000/hcard/users/user"
    seed_url "http://localhost:3000/"
    profile_url "http://localhost:3000/u/user"
    atom_url "http://localhost:3000/public/user.atom"
    salmon_url "http://localhost:3000/receive/users/0123456789abcdef"
    public_key
  end

  factory :h_card, class: DiasporaFederation::Discovery::HCard do
    guid
    nickname "some_name"
    full_name "my name"
    first_name "my name"
    last_name nil
    url "http://localhost:3000/"
    public_key
    photo_large_url "/assets/user/default.png"
    photo_medium_url "/assets/user/default.png"
    photo_small_url "/assets/user/default.png"
    searchable true
  end

  factory :person_entity, class: DiasporaFederation::Entities::Person do
    guid
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
    first_name "my name"
    last_name nil
    image_url "/assets/user/default.png"
    image_url_medium "/assets/user/default.png"
    image_url_small "/assets/user/default.png"
    birthday "1988-07-15"
    gender "Male"
    bio "some text about me"
    location "github"
    searchable true
    nsfw false
    tag_string "#i #love #tags"
  end
end
