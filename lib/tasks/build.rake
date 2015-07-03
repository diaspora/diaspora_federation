desc "Build gem into the pkg directory"
task build: :test do
  FileUtils.rm_rf("pkg")
  Dir["*.gemspec"].each do |gemspec|
    system "gem build #{gemspec}"
  end
  FileUtils.mkdir_p("pkg")
  FileUtils.mv(Dir["*.gem"], "pkg")
end

desc "Tags version, pushes to remote, and pushes gem"
task release: :build do
  sh "git tag v#{DiasporaFederation::VERSION}"
  sh "git push origin master"
  sh "git push origin v#{DiasporaFederation::VERSION}"
  sh "ls pkg/*.gem | xargs -n 1 gem push"
end
