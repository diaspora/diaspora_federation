require "diaspora_federation/test"

DiasporaFederation::Test::Factories.federation_factories

FactoryGirl.define do
  factory :person do
    diaspora_id
    url "http://somehost:3000/"
    serialized_public_key { generate(:public_key) }
    after(:create, &:save)
  end

  factory :user, class: Person do
    diaspora_id
    url "http://localhost:3000/"
    after(:build) do |user|
      private_key = OpenSSL::PKey::RSA.generate(1024)
      user.serialized_private_key = private_key.export
      user.serialized_public_key = private_key.public_key.export
    end
    after(:create, &:save)
  end

  factory :post, class: Entity do
    entity_type "Post"
    author { FactoryGirl.build(:person) }
    after(:create, &:save)
  end

  factory :comment, class: Entity do
    entity_type "Comment"
    author { FactoryGirl.build(:person) }
    after(:create, &:save)
  end

  factory :poll, class: Entity do
    entity_type "Poll"
    author { FactoryGirl.build(:person) }
    after(:create, &:save)
  end

  factory :conversation, class: Entity do
    entity_type "Conversation"
    author { FactoryGirl.build(:person) }
    after(:create, &:save)
  end
end
