$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "diaspora_federation/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "diaspora_federation-rails"
  s.version     = DiasporaFederation::VERSION
  s.authors     = ["Benjamin Neff"]
  s.email       = ["benjamin@coding4.coffee"]
  s.homepage    = "https://github.com/SuperTux88/diaspora_federation"
  s.summary     = "diaspora* federation rails engine"
  s.description = "A rails engine that adds the diaspora* federation protocol to a rails app"
  s.license     = "AGPL 3.0 - http://www.gnu.org/licenses/agpl-3.0.html"

  s.files       = Dir["app/**/*", "config/routes.rb", "config/initializers/*",
                      "lib/diaspora_federation/{engine,rails}.rb", "LICENSE", "README.md"]

  s.required_ruby_version = "~> 2.1"

  s.add_dependency "rails", "~> 4.2"

  s.add_dependency "diaspora_federation", DiasporaFederation::VERSION
end
