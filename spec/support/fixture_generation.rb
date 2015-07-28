module FixtureGeneration
  # Saves the markup to a fixture file using the given name
  def save_fixture(markup, name, fixture_path=nil)
    fixture_path = Rails.root.join("tmp", "fixtures") unless fixture_path
    Dir.mkdir(fixture_path) unless File.exist?(fixture_path)

    fixture_file = fixture_path.join("#{name}.fixture.html")
    File.open(fixture_file, "w") do |file|
      file.puts(markup)
    end
  end

  def self.load_fixture(name, fixture_path=nil)
    fixture_path = Rails.root.join("tmp", "fixtures") unless fixture_path
    fixture_file = fixture_path.join("#{name}.fixture.html")
    File.open(fixture_file).read
  end
end

RSpec::Rails::ControllerExampleGroup.class_eval do
  include FixtureGeneration
end
