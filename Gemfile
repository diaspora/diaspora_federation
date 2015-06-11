source "https://rubygems.org"

# Declare your gem's dependencies in diaspora_federation.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

group :development do
  gem "rubocop",  "0.32.0"
end

group :test do
  gem "codeclimate-test-reporter", require: false
end

group :development, :test do
  gem "rspec-rails",     "3.2.3"
  gem "rspec-instafail", "0.2.6", require: false
  gem "fuubar",          "2.0.0"
  gem "nyan-cat-formatter", require: false

  # test database
  gem "sqlite3"
end
