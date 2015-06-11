namespace :ci do
  namespace :travis do
    desc "Run specs"
    task run: %w(spec)
  end
end
