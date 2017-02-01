require "diaspora_federation/test/factories"

Fabricator(:person) do
  diaspora_id { Fabricate.sequence(:diaspora_id) }
  url "http://somehost:3000/"
  serialized_public_key { Fabricate.sequence(:public_key) }
end

Fabricator(:user, class_name: Person) do
  diaspora_id { Fabricate.sequence(:diaspora_id) }
  url "http://localhost:3000/"
  after_build do |user|
    private_key = OpenSSL::PKey::RSA.generate(1024)
    user.serialized_private_key = private_key.export
    user.serialized_public_key = private_key.public_key.export
  end
end

Fabricator(:post, class_name: Entity) do
  on_init { init_with(entity_type: "Post") }
  author { Fabricate(:person) }
end

Fabricator(:comment, class_name: Entity) do
  on_init { init_with(entity_type: "Comment") }
  author { Fabricate(:person) }
end

Fabricator(:poll, class_name: Entity) do
  on_init { init_with(entity_type: "Poll") }
  author { Fabricate(:person) }
end

Fabricator(:event, class_name: Entity) do
  on_init { init_with(entity_type: "Event") }
  author { Fabricate(:person) }
end

Fabricator(:conversation, class_name: Entity) do
  on_init { init_with(entity_type: "Conversation") }
  author { Fabricate(:person) }
end
