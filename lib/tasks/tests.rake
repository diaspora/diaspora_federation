namespace :ci do
  namespace :travis do
    task prepare_db: %w(db:create db:test:load)
    task :prepare_fixtures do
      ENV["NO_COVERAGE"] = "true"
      Rake::Task["spec:generate_fixtures"].invoke
      ENV["NO_COVERAGE"] = "false"
    end
    task prepare: %w(prepare_db prepare_fixtures)

    desc "Run specs"
    task run: %w(prepare spec)
  end
end

if defined?(RSpec)
  namespace :spec do
    desc "Run all specs that generate fixtures for rspec"
    RSpec::Core::RakeTask.new(generate_fixtures: "spec:prepare") do |t|
      t.rspec_opts = ["--tag fixture"]
    end
  end
end
