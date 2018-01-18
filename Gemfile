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
  gem "pronto",         "0.9.5",  require: false
  gem "pronto-rubocop", "0.9.0",  require: false
  gem "rubocop",        "0.52.1", require: false

  # automatic test runs
  gem "guard-rspec",   require: false
  gem "guard-rubocop", require: false

  # preloading environment
  gem "spring"
  gem "spring-commands-rspec"
  gem "spring-watcher-listen"

  # debugging
  gem "pry"
  gem "pry-byebug"

  # documentation
  gem "yard", require: false
end

group :test do
  # rspec formatter
  gem "fuubar", "2.3.1",    require: false
  gem "nyan-cat-formatter", require: false

  # test coverage
  gem "simplecov",                 "0.15.1",   require: false
  gem "simplecov-rcov",            "0.2.3",    require: false

  # test helpers
  gem "json-schema-rspec", "0.0.4"
  gem "rspec-collection_matchers", "~> 1.1.2"
  gem "rspec-json_expectations",   "~> 2.1"
  gem "webmock",                   "~> 3.0"
end

group :development, :test do
  gem "rake"

  # unit tests
  gem "rspec", "~> 3.7.0"
  gem "rspec-rails", "~> 3.7.0"
end
