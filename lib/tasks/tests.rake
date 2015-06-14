namespace :ci do
  namespace :travis do
    task prepare_db: %w(db:create db:test:load)
    task prepare: %w(prepare_db)

    desc "Run specs"
    task run: %w(prepare spec)
  end
end
