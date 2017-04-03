if defined?(RSpec)
  namespace :rails4 do
    RSpec::Core::RakeTask.new(:spec)
    task test: %w(spec:prepare_db spec)
  end
end
