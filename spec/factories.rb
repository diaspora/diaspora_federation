require "diaspora_federation/test"

DiasporaFederation::Test::Factories.federation_factories

FactoryGirl.define do
  factory :person do
    diaspora_id
    url "http://localhost:3000/"
    serialized_public_key { generate(:public_key) }
    after(:create, &:save)
  end
end
