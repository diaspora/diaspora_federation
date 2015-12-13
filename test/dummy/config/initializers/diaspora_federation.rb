require "diaspora_federation/discovery"

if File.file?("/etc/ssl/certs/ca-certificates.crt")
  # For Debian, Ubuntu, Archlinux, Gentoo
  ca_file = "/etc/ssl/certs/ca-certificates.crt"
else
  # For CentOS, Fedora
  ca_file = "/etc/pki/tls/certs/ca-bundle.crt"
end

# configure the federation engine
DiasporaFederation.configure do |config|
  # the pod url
  config.server_uri = URI("http://localhost:3000/")

  config.certificate_authorities = ca_file

  config.define_callbacks do
    on :fetch_person_for_webfinger do |diaspora_id|
      person = Person.find_by(diaspora_id: diaspora_id)
      if person
        DiasporaFederation::Discovery::WebFinger.new(
          acct_uri:    "acct:#{person.diaspora_id}",
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

    on :fetch_person_for_hcard do |guid|
      person = Person.find_by(guid: guid)
      if person
        DiasporaFederation::Discovery::HCard.new(
          guid:             person.guid,
          nickname:         person.nickname,
          full_name:        person.full_name,
          url:              person.url,
          photo_large_url:  person.photo_default_url,
          photo_medium_url: person.photo_default_url,
          photo_small_url:  person.photo_default_url,
          public_key:       person.serialized_public_key,
          searchable:       person.searchable,
          first_name:       person.first_name,
          last_name:        person.last_name
        )
      end
    end

    on :save_person_after_webfinger do |person|
      unless Person.exists?(diaspora_id: person.diaspora_id)
        Person.new(diaspora_id: person.diaspora_id, guid: person.guid,
                   serialized_public_key: person.exported_key, url: person.url).save!
      end
    end

    def pkey
      @test_pkey ||= OpenSSL::PKey::RSA.generate(1024)
    end

    on :fetch_private_key_by_diaspora_id do
      pkey
    end

    on :fetch_author_private_key_by_entity_guid do
      pkey
    end

    on :fetch_public_key_by_diaspora_id do
      pkey.public_key
    end

    on :fetch_author_public_key_by_entity_guid do
      pkey.public_key
    end

    on :entity_author_is_local? do
      false
    end

    on :fetch_entity_author_id_by_guid do
      nil
    end

    on :fetch_private_key_by_user_guid do
      nil
    end

    on :entity_persist do
    end
  end
end
