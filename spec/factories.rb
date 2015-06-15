require "factory_girl"

def r_str
  SecureRandom.hex(3)
end

FactoryGirl.define do
  factory :person do
    sequence(:diaspora_handle) {|n| "person-#{n}-#{r_str}@localhost:3000" }
    url "http://localhost:3000/"
    serialized_public_key OpenSSL::PKey::RSA.generate(1024).public_key.export
    after(:create) do |u|
      u.save
    end
  end
end
