source "https://rubygems.org"

# Declare your gem's dependencies in diaspora_federation.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec name: "diaspora_federation", path: "../../"

Dir["diaspora_federation-*.gemspec"].each do |gemspec|
  plugin = gemspec.scan(/diaspora_federation-(.*)\.gemspec/).flatten.first
  gemspec(name: "diaspora_federation-#{plugin}", development_group: plugin, path: "../../")
end

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

group :test do
  # rspec formatter
  gem "fuubar", "2.2.0",    require: false
  gem "nyan-cat-formatter", require: false

  # test coverage
  gem "codeclimate-test-reporter", "~> 1.0.0", require: false
  gem "simplecov",                 "0.13.0",   require: false
  gem "simplecov-rcov",            "0.2.3",    require: false

  # test helpers
  gem "json-schema-rspec", "0.0.4"
  gem "rspec-collection_matchers", "~> 1.1.2"
  gem "rspec-json_expectations",   "~> 2.1"
  gem "webmock",                   "~> 2.0"
end

group :development, :test do
  gem "rake"

  # unit tests
  gem "rspec", "~> 3.5.0"
  gem "rspec-rails", "~> 3.5.1"
end

gem "actionpack", "4.2.8"
