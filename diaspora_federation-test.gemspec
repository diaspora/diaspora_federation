$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "diaspora_federation/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "diaspora_federation-test"
  s.version     = DiasporaFederation::VERSION
  s.authors     = ["Benjamin Neff"]
  s.email       = ["benjamin@coding4.coffee"]
  s.homepage    = "https://github.com/SuperTux88/diaspora_federation"
  s.summary     = "diaspora* federation test utils"
  s.description = "This gem provides some supplimentary code (factory definitions), that"\
                  "helps to build tests for users of the diaspora_federation gem."
  s.license     = "AGPL 3.0 - http://www.gnu.org/licenses/agpl-3.0.html"

  s.files       = Dir["lib/diaspora_federation/test.rb", "lib/diaspora_federation/test/*"]

  s.required_ruby_version = "~> 2.0"

  s.add_dependency "diaspora_federation", DiasporaFederation::VERSION
  s.add_dependency "factory_girl", "~> 4.5", ">= 4.5.0"
end
