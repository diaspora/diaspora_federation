# frozen_string_literal: true

source "https://rubygems.org"

# Declare your gem's dependencies in diaspora_federation.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec name: "diaspora_federation", path: "../../"

Dir["diaspora_federation-*.gemspec"].each do |gemspec|
  plugin = gemspec.scan(/diaspora_federation-(.*)\.gemspec/).flatten.first
  gemspec(name: "diaspora_federation-#{plugin}", development_group: plugin, path: "../../") unless plugin == "rails"
end

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

group :test do
  # rspec formatter
  gem "fuubar", "2.5.1",    require: false
  gem "nyan-cat-formatter", require: false

  # test coverage
  gem "simplecov",                 "0.21.2",   require: false
  gem "simplecov-rcov",            "0.3.1",    require: false

  # test helpers
  gem "json-schema",               "~> 3.0"
  gem "rspec-collection_matchers", "~> 1.2.0"
  gem "rspec-json_expectations",   "~> 2.1"
  gem "webmock",                   "~> 3.0"
end

group :development, :test do
  gem "rake"

  # unit tests
  gem "rspec", "~> 3.11.0"
end
