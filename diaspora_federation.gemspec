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
  s.summary     = "diaspora* federation rails engine"
  s.description = "A rails engine that adds the diaspora* federation protocol to a rails app"
  s.license     = "AGPL 3.0 - http://www.gnu.org/licenses/agpl-3.0.html"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.2"
  s.add_dependency "nokogiri", "~> 1.6.6.2"
end
