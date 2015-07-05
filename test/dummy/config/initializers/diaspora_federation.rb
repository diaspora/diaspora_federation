# configure the federation engine
DiasporaFederation.configure do |config|
  # the pod url
  config.server_uri = URI("http://localhost:3000/")

  config.define_callbacks do
    on :person_webfinger_fetch do |handle|
    end

    on :person_hcard_fetch do |guid|
    end
  end
end
