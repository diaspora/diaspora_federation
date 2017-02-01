require "fixture_builder"

FixtureBuilder.configure do |fbuilder|
  # rebuild fixtures automatically when these files change:
  fbuilder.files_to_check += Dir[
      "lib/**/*.rb",
      "spec/factories.rb",
      "spec/support/fixture_builder.rb",
      "test/dummy/app/models/*.rb"
  ]

  # now declare objects
  fbuilder.factory do
    Fabricate(:user, diaspora_id: "alice@localhost:3000")
    Fabricate(:user, diaspora_id: "bob@localhost:3000")
  end
end
