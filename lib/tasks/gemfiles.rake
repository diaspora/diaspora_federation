namespace :gemfiles do
  desc "Generates no-rails.Gemfile"
  task :generate do
    FileUtils.mkdir_p("test/gemfiles")
    FileUtils.rm(Dir["test/gemfiles/*.Gemfile.lock"])

    original_gemfile = File.read("Gemfile")
    original_gemfile.sub!(/(gemspec name:.*)/) { "#{Regexp.last_match[1]}, path: \"../../\"" }
    original_gemfile.sub!(/(gemspec\(name:.*)\)/) { "#{Regexp.last_match[1]}, path: \"../../\")" }
    original_gemfile.sub!(/^group :development do$.*?^end$\n\n/m, "")
    original_gemfile << "\n gem \"fabrication\", \"< 2.17.0\"\n" # new versions are not compatible with ruby 2.1

    no_rails_gemfile = original_gemfile.dup
    no_rails_gemfile.sub!(/(gemspec\(name:.*)/) { "#{Regexp.last_match[1]} unless plugin == \"rails\"" }
    no_rails_gemfile.sub!(/^.*rspec-rails.*$\n/, "")
    no_rails_path = "test/gemfiles/no-rails.Gemfile"
    File.write(no_rails_path, no_rails_gemfile)

    Bundler.with_clean_env do
      system("BUNDLE_GEMFILE=#{no_rails_path} bundle install")
    end
  end
end
