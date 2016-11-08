if defined?(RSpec)
  namespace :rails4 do
    desc "Run all specs that generate fixtures for rspec with rails 4"
    RSpec::Core::RakeTask.new(:generate_fixtures) do |t|
      t.rspec_opts = ["--tag fixture4"]
    end

    desc "Run all specs in spec directory (exluding controller specs)"
    RSpec::Core::RakeTask.new(:spec) do |task|
      task.pattern = FileList["spec/**/*_spec.rb"].exclude("spec/controllers/**/*_spec.rb")
    end

    task test: %w(spec:prepare_db generate_fixtures spec)
  end
end
