# set default users as initial database for each test
RSpec.configure do |config|
  config.before(:suite) do
    Person.reset_database
    Fabricate(:user, diaspora_id: "alice@localhost:3000")
    Fabricate(:user, diaspora_id: "bob@localhost:3000")
    Person.init_database = Person.database
  end

  config.after(:each) do
    Entity.reset_database
    Person.reset_database
  end
end
