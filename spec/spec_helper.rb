unless ENV["NO_COVERAGE"] == "true"
  require "simplecov"
  require "simplecov-rcov"
  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovFormatter
  ]
  SimpleCov.start do
    add_filter "lib/diaspora_federation/logging.rb"
    add_filter "spec"
    add_filter "test"
  end
end

ENV["RAILS_ENV"] ||= "test"
require File.join(File.dirname(__FILE__), "..", "test", "dummy", "config", "environment")

require "rspec/rails"
require "webmock/rspec"
require "rspec/json_expectations"

# load factories
require "factories"

# load test entities
require "entities"

# some helper methods

def alice
  @alice ||= Fabricate(:user, diaspora_id: "alice@localhost:3000")
end

def bob
  @bob ||= Fabricate(:user, diaspora_id: "bob@localhost:3000")
end

def expect_callback(*opts)
  expect(DiasporaFederation.callbacks).to receive(:trigger).with(*opts)
end

def add_signatures(hash, klass=described_class)
  properties = klass.new(hash).send(:enriched_properties)
  hash[:author_signature] = properties[:author_signature]
  hash[:parent_author_signature] = properties[:parent_author_signature]
end

def sign_with_key(privkey, signature_data)
  Base64.strict_encode64(privkey.sign(OpenSSL::Digest::SHA256.new, signature_data))
end

def verify_signature(pubkey, signature, signed_string)
  pubkey.verify(OpenSSL::Digest::SHA256.new, Base64.decode64(signature), signed_string)
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f }

RSpec.configure do |config|
  config.include JSON::SchemaMatchers
  config.json_schemas[:entity_schema] = "lib/diaspora_federation/schemas/federation_entities.json"

  config.example_status_persistence_file_path = "spec/rspec-persistance.txt"

  config.infer_spec_type_from_file_location!

  config.render_views

  config.expect_with :rspec do |expect_config|
    expect_config.syntax = :expect
  end

  config.use_transactional_fixtures = true

  config.filter_run_excluding rails: (Rails::VERSION::MAJOR == 5 ? 4 : 5)

  # whitelist codeclimate.com so test coverage can be reported
  config.after(:suite) do
    WebMock.disable_net_connect!(allow: "codeclimate.com")
  end

  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = "doc"
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
end
