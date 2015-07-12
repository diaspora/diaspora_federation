source "https://rubygems.org"

# Declare your gem's dependencies in diaspora_federation.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec name: "diaspora_federation"

Dir["diaspora_federation-*.gemspec"].each do |gemspec|
  plugin = gemspec.scan(/diaspora_federation-(.*)\.gemspec/).flatten.first
  gemspec(name: "diaspora_federation-#{plugin}", development_group: plugin)
end

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

group :development do
  # code style
  gem "rubocop", "0.32.1"

  # debugging
  gem "pry"
  gem "pry-debundle"
  gem "pry-byebug"

  # documentation
  gem "yard", require: false
end

group :test do
  # rspec formatter
  gem "fuubar",                    "2.0.0",  require: false
  gem "nyan-cat-formatter",                  require: false

  # test coverage
  gem "simplecov",                 "0.10.0", require: false
  gem "simplecov-rcov",            "0.2.3",  require: false
  gem "codeclimate-test-reporter",           require: false

  # test helpers
  gem "fixture_builder",           "~> 0.4.1"
  gem "factory_girl_rails",        "~> 4.5.0"
  gem "rspec-collection_matchers", "~> 1.1.2"
  gem "webmock",                   "~> 1.21.0"
end

group :development, :test do
  # unit tests
  gem "rspec-rails", "~> 3.3.2"

  # automatic test runs
  gem "guard-rspec", require: false

  # preloading environment
  gem "spring"
  gem "spring-commands-rspec"
  gem "spring-watcher-listen"

  # GUID generation
  gem "uuid", "~> 2.3.8"

  # test database
  gem "sqlite3", "~> 1.3.10"
end

group :development, :production do
  # Logging (only for dummy-app, not for the gem)
  gem "logging-rails", "0.5.0"
end
