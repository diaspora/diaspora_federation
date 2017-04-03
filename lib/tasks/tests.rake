if defined?(RSpec)
  namespace :spec do
    task prepare_db: %w(db:create db:test:load)

    desc "Prepare for rspec"
    task prepare: %w(db:environment:set prepare_db)
  end
end
