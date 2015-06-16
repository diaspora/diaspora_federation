# configure the federation engine
DiasporaFederation.configure do |config|
  # the pod url
  config.server_uri = URI("http://localhost:3000/")

  # the class to be used for a person
  config.person_class = Person.to_s
end
