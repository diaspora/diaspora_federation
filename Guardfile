guard :rspec, cmd: "NO_COVERAGE=true bin/rspec" do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Rails files
  rails = dsl.rails
  dsl.watch_spec_files_for(rails.app_files)

  # Rails config changes
  rails.app_controller = "app/controllers/diaspora_federation/application_controller.rb"
  watch(rails.app_controller)  { "#{rspec.spec_dir}/controllers" }
  watch(rails.routes)          { "#{rspec.spec_dir}/routing" }
end
