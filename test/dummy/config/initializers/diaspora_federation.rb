require "diaspora_federation/web_finger"

# configure the federation engine
DiasporaFederation.configure do |config|
  # the pod url
  config.server_uri = URI("http://localhost:3000/")

  config.define_callbacks do
    on :person_webfinger_fetch do |handle|
      person = Person.find_by(diaspora_handle: handle)
      if person
        DiasporaFederation::WebFinger::WebFinger.new(
          acct_uri:    "acct:#{person.diaspora_handle}",
          alias_url:   person.alias_url,
          hcard_url:   person.hcard_url,
          seed_url:    person.url,
          profile_url: person.profile_url,
          atom_url:    person.atom_url,
          salmon_url:  person.salmon_url,
          guid:        person.guid,
          public_key:  person.serialized_public_key
        )
      end
    end

    on :person_hcard_fetch do |guid|
    end
  end
end
