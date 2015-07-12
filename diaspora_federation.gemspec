$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "diaspora_federation/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "diaspora_federation"
  s.version     = DiasporaFederation::VERSION
  s.authors     = ["Benjamin Neff"]
  s.email       = ["benjamin@coding4.coffee"]
  s.homepage    = "https://github.com/SuperTux88/diaspora_federation"
  s.summary     = "diaspora* federation library"
  s.description = "This gem provides the functionality for de-/serialization and " \
                  "de-/encryption of Entities in the protocols used for communication " \
                  "among the various installations of Diaspora*"
  s.license     = "AGPL 3.0 - http://www.gnu.org/licenses/agpl-3.0.html"

  s.files      = Dir["lib/**/*", "LICENSE", "README.md"] - Dir["lib/diaspora_federation/{engine,rails}.rb"]

  s.required_ruby_version = "~> 2.0"

  s.add_dependency "nokogiri", "~> 1.6", ">= 1.6.6"
  s.add_dependency "faraday", "~> 0.9.0"
  s.add_dependency "faraday_middleware", "~> 0.9.0"
  s.add_dependency "typhoeus", "~> 0.7.0"
end
