require "diaspora_federation"
require "factory_girl"

FactoryGirl.define do
  initialize_with { new(attributes) }
  sequence(:guid) { UUID.generate :compact }
  sequence(:diaspora_id) {|n| "person-#{n}-#{SecureRandom.hex(3)}@localhost:3000" }
  sequence(:public_key) { OpenSSL::PKey::RSA.generate(1024).public_key.export }

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
      FactoryGirl.build(:profile_entity, diaspora_id: diaspora_id)
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

  factory :location_entity, class: DiasporaFederation::Entities::Location do
    address "Vienna, Austria"
    lat 48.208174.to_s
    lng 16.373819.to_s
  end

  factory :photo_entity, class: DiasporaFederation::Entities::Photo do
    guid
    diaspora_id
    public(true)
    created_at { Time.zone.now }
    remote_photo_path "https://diaspora.example.tld/uploads/images/"
    remote_photo_name "f2a41e9d2db4d9a199c8.jpg"
    text "what you see here..."
    status_message_guid { generate(:guid) }
    height 480
    width 800
  end

  factory :relayable_entity, class: DiasporaFederation::Entities::Relayable do
    parent_guid { generate(:guid) }
  end

  factory :participation_entity, class: DiasporaFederation::Entities::Participation, parent: :relayable_entity do
    guid
    target_type "Post"
    diaspora_id
  end

  factory :status_message_entity, class: DiasporaFederation::Entities::StatusMessage do
    raw_message "i am a very interesting status update"
    guid
    diaspora_id
    public(true)
    created_at { Time.zone.now }
  end

  factory :request_entity, class: DiasporaFederation::Entities::Request do
    sender_id { generate(:diaspora_id) }
    recipient_id { generate(:diaspora_id) }
  end

  factory :comment_entity, class: DiasporaFederation::Entities::Comment, parent: :relayable_entity do
    guid
    text "this is a very informative comment"
    diaspora_id
  end

  factory :like_entity, class: DiasporaFederation::Entities::Like, parent: :relayable_entity do
    positive true
    guid
    target_type "Post"
    diaspora_id
  end

  factory :account_deletion_entity, class: DiasporaFederation::Entities::AccountDeletion do
    diaspora_id
  end

  factory :conversation_entity, class: DiasporaFederation::Entities::Conversation do
    guid
    subject "this is a very informative subject"
    created_at { DateTime.now.utc }
    messages []
    diaspora_id
    participant_ids { 3.times.map { generate(:diaspora_id) }.join(";") }
  end

  factory :message_entity, class: DiasporaFederation::Entities::Message, parent: :relayable_entity do
    guid
    text "this is a very informative text"
    created_at { DateTime.now.utc }
    diaspora_id
    conversation_guid { generate(:guid) }
  end

  factory :relayable_retraction_entity, class: DiasporaFederation::Entities::RelayableRetraction do
    target_guid { generate(:guid) }
    target_type "Comment"
    diaspora_id
  end

  factory :reshare_entity, class: DiasporaFederation::Entities::Reshare do
    root_diaspora_id { generate(:diaspora_id) }
    root_guid { generate(:guid) }
    guid
    diaspora_id
    public(true)
    created_at { DateTime.now.utc }
    provider_display_name { "the testsuite" }
  end

  factory :retraction_entity, class: DiasporaFederation::Entities::Retraction do
    target_guid { generate(:guid) }
    diaspora_id
    target_type "Post"
  end

  factory :signed_retraction_entity, class: DiasporaFederation::Entities::SignedRetraction do
    target_guid { generate(:guid) }
    target_type "Post"
    diaspora_id
  end

  factory :poll_answer_entity, class: DiasporaFederation::Entities::PollAnswer do
    guid
    answer { "Obama is a bicycle" }
  end

  factory :poll_entity, class: DiasporaFederation::Entities::Poll do
    guid
    question { "Select an answer" }
    poll_answers { 3.times.map { FactoryGirl.build(:poll_answer_entity) } }
  end

  factory :poll_participation_entity,
          class:  DiasporaFederation::Entities::PollParticipation,
          parent: :relayable_entity do
    guid
    diaspora_id
    poll_answer_guid { generate(:guid) }
  end
end
