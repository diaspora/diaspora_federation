require "uuid"
require "securerandom"
require "diaspora_federation/test"

module DiasporaFederation
  module Test
    # Factories for federation entities
    module Factories
      Fabricate.sequence(:guid) { UUID.generate(:compact) }
      Fabricate.sequence(:diaspora_id) {|n| "person-#{n}-#{SecureRandom.hex(3)}@localhost:3000" }
      Fabricate.sequence(:public_key) { OpenSSL::PKey::RSA.generate(1024).public_key.export }

      Fabricator(:webfinger, class_name: DiasporaFederation::Discovery::WebFinger) do
        acct_uri { "acct:#{Fabricate.sequence(:diaspora_id)}" }
        alias_url "http://localhost:3000/people/0123456789abcdef"
        hcard_url "http://localhost:3000/hcard/users/user"
        seed_url "http://localhost:3000/"
        profile_url "http://localhost:3000/u/user"
        atom_url "http://localhost:3000/public/user.atom"
        salmon_url "http://localhost:3000/receive/users/0123456789abcdef"
        subscribe_url "http://localhost:3000/people?q={uri}"
      end

      Fabricator(:h_card, class_name: DiasporaFederation::Discovery::HCard) do
        guid { Fabricate.sequence(:guid) }
        nickname "some_name"
        full_name "my name"
        first_name "my name"
        last_name ""
        url "http://localhost:3000/"
        public_key { Fabricate.sequence(:public_key) }
        photo_large_url "/assets/user/default.png"
        photo_medium_url "/assets/user/default.png"
        photo_small_url "/assets/user/default.png"
        searchable true
      end

      Fabricator(:account_deletion_entity, class_name: DiasporaFederation::Entities::AccountDeletion) do
        author { Fabricate.sequence(:diaspora_id) }
      end

      Fabricator(:account_migration_entity, class_name: DiasporaFederation::Entities::AccountMigration) do
        author { Fabricate.sequence(:diaspora_id) }
        profile { Fabricate(:profile_entity) }
      end

      Fabricator(:person_entity, class_name: DiasporaFederation::Entities::Person) do
        guid { Fabricate.sequence(:guid) }
        author { Fabricate.sequence(:diaspora_id) }
        url "http://localhost:3000/"
        exported_key { Fabricate.sequence(:public_key) }
        profile {|attrs| Fabricate(:profile_entity, author: attrs[:author]) }
      end

      Fabricator(:profile_entity, class_name: DiasporaFederation::Entities::Profile) do
        author { Fabricate.sequence(:diaspora_id) }
        first_name "my name"
        last_name ""
        image_url "/assets/user/default.png"
        image_url_medium "/assets/user/default.png"
        image_url_small "/assets/user/default.png"
        birthday "1988-07-15"
        gender "Male"
        bio "some text about me"
        location "github"
        searchable true
        public false
        nsfw false
        tag_string "#i #love #tags"
      end

      Fabricator(:location_entity, class_name: DiasporaFederation::Entities::Location) do
        address "Vienna, Austria"
        lat 48.208174.to_s
        lng 16.373819.to_s
      end

      Fabricator(:photo_entity, class_name: DiasporaFederation::Entities::Photo) do
        guid { Fabricate.sequence(:guid) }
        author { Fabricate.sequence(:diaspora_id) }
        public true
        created_at { Time.now.utc }
        remote_photo_path "https://diaspora.example.tld/uploads/images/"
        remote_photo_name "f2a41e9d2db4d9a199c8.jpg"
        text "what you see here..."
        status_message_guid { Fabricate.sequence(:guid) }
        height 480
        width 800
      end

      Fabricator(:relayable_entity, class_name: DiasporaFederation::Entities::Relayable) do
        parent_guid { Fabricate.sequence(:guid) }
        parent { Fabricate(:related_entity) }
      end

      Fabricator(:participation_entity,
                 class_name: DiasporaFederation::Entities::Participation, from: :relayable_entity) do
        author { Fabricate.sequence(:diaspora_id) }
        guid { Fabricate.sequence(:guid) }
        parent_type "Post"
      end

      Fabricator(:status_message_entity, class_name: DiasporaFederation::Entities::StatusMessage) do
        text "i am a very interesting status update"
        author { Fabricate.sequence(:diaspora_id) }
        guid { Fabricate.sequence(:guid) }
        public true
        created_at { Time.now.utc }
      end

      Fabricator(:request_entity, class_name: DiasporaFederation::Entities::Request) do
        author { Fabricate.sequence(:diaspora_id) }
        recipient { Fabricate.sequence(:diaspora_id) }
      end

      Fabricator(:contact_entity, class_name: DiasporaFederation::Entities::Contact) do
        author { Fabricate.sequence(:diaspora_id) }
        recipient { Fabricate.sequence(:diaspora_id) }
        following true
        sharing true
      end

      Fabricator(:comment_entity, class_name: DiasporaFederation::Entities::Comment, from: :relayable_entity) do
        author { Fabricate.sequence(:diaspora_id) }
        guid { Fabricate.sequence(:guid) }
        text "this is a very informative comment"
      end

      Fabricator(:like_entity, class_name: DiasporaFederation::Entities::Like, from: :relayable_entity) do
        positive true
        author { Fabricate.sequence(:diaspora_id) }
        guid { Fabricate.sequence(:guid) }
        parent_type "Post"
      end

      Fabricator(:conversation_entity, class_name: DiasporaFederation::Entities::Conversation) do
        author { Fabricate.sequence(:diaspora_id) }
        guid { Fabricate.sequence(:guid) }
        subject "this is a very informative subject"
        created_at { Time.now.utc }
        messages []
        participants { Array.new(3) { Fabricate.sequence(:diaspora_id) }.join(";") }
      end

      Fabricator(:message_entity, class_name: DiasporaFederation::Entities::Message) do
        guid { Fabricate.sequence(:guid) }
        author { Fabricate.sequence(:diaspora_id) }
        text "this is a very informative text"
        created_at { Time.now.utc }
        conversation_guid { Fabricate.sequence(:guid) }
      end

      Fabricator(:relayable_retraction_entity, class_name: DiasporaFederation::Entities::RelayableRetraction) do
        author { Fabricate.sequence(:diaspora_id) }
        target_guid { Fabricate.sequence(:guid) }
        target_type "Comment"
        target {|attrs| Fabricate(:related_entity, author: attrs[:author]) }
      end

      Fabricator(:reshare_entity, class_name: DiasporaFederation::Entities::Reshare) do
        root_author { Fabricate.sequence(:diaspora_id) }
        root_guid { Fabricate.sequence(:guid) }
        guid { Fabricate.sequence(:guid) }
        author { Fabricate.sequence(:diaspora_id) }
        public true
        created_at { Time.now.utc }
        provider_display_name { "the testsuite" }
      end

      Fabricator(:retraction_entity, class_name: DiasporaFederation::Entities::Retraction) do
        author { Fabricate.sequence(:diaspora_id) }
        target_guid { Fabricate.sequence(:guid) }
        target_type "Post"
        target {|attrs| Fabricate(:related_entity, author: attrs[:author]) }
      end

      Fabricator(:signed_retraction_entity, class_name: DiasporaFederation::Entities::SignedRetraction) do
        author { Fabricate.sequence(:diaspora_id) }
        target_guid { Fabricate.sequence(:guid) }
        target_type "Post"
        target {|attrs| Fabricate(:related_entity, author: attrs[:author]) }
      end

      Fabricator(:poll_answer_entity, class_name: DiasporaFederation::Entities::PollAnswer) do
        guid { Fabricate.sequence(:guid) }
        answer { "Obama is a bicycle" }
      end

      Fabricator(:poll_entity, class_name: DiasporaFederation::Entities::Poll) do
        guid { Fabricate.sequence(:guid) }
        question { "Select an answer" }
        poll_answers { Array.new(3) { Fabricate(:poll_answer_entity) } }
      end

      Fabricator(:poll_participation_entity,
                 class_name: DiasporaFederation::Entities::PollParticipation, from: :relayable_entity) do
        author { Fabricate.sequence(:diaspora_id) }
        guid { Fabricate.sequence(:guid) }
        poll_answer_guid { Fabricate.sequence(:guid) }
      end

      Fabricator(:event_entity, class_name: DiasporaFederation::Entities::Event) do |f|
        author { Fabricate.sequence(:diaspora_id) }
        guid { Fabricate.sequence(:guid) }
        summary "Cool event"
        description "You need to see this!"
        start { change_time(Time.now.utc, min: 0) - 3600 }
        f.end { change_time(Time.now.utc, min: 0) + 3600 }
        all_day false
        timezone "Europe/Berlin"
      end

      Fabricator(:event_participation_entity,
                 class_name: DiasporaFederation::Entities::EventParticipation, from: :relayable_entity) do
        author { Fabricate.sequence(:diaspora_id) }
        guid { Fabricate.sequence(:guid) }
        status "accepted"
      end

      Fabricator(:related_entity, class_name: DiasporaFederation::Entities::RelatedEntity) do
        author { Fabricate.sequence(:diaspora_id) }
        local true
        public false
        parent nil
      end
    end
  end
end
