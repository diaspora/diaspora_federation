require "diaspora_federation/discovery"

ca_file = if File.file?("/etc/ssl/certs/ca-certificates.crt")
            # For Debian, Ubuntu, Archlinux, Gentoo
            "/etc/ssl/certs/ca-certificates.crt"
          else
            # For CentOS, Fedora
            "/etc/pki/tls/certs/ca-bundle.crt"
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
          acct_uri:      "acct:#{person.diaspora_id}",
          alias_url:     person.alias_url,
          hcard_url:     person.hcard_url,
          seed_url:      person.url,
          profile_url:   person.profile_url,
          atom_url:      person.atom_url,
          salmon_url:    person.salmon_url,
          subscribe_url: person.subscribe_url,
          guid:          person.guid,
          public_key:    person.serialized_public_key
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

    on :fetch_private_key_by_diaspora_id do |diaspora_id|
      key = Person.where(diaspora_id: diaspora_id).pluck(:serialized_private_key).first
      OpenSSL::PKey::RSA.new(key) unless key.nil?
    end

    on :fetch_author_private_key_by_entity_guid do |entity_type, guid|
      key = Entity.where(entity_type: entity_type, guid: guid).joins(:author).pluck(:serialized_private_key).first
      OpenSSL::PKey::RSA.new(key) unless key.nil?
    end

    on :fetch_public_key_by_diaspora_id do |diaspora_id|
      key = Person.where(diaspora_id: diaspora_id).pluck(:serialized_public_key).first
      key = DiasporaFederation::Discovery::Discovery.new(diaspora_id).fetch_and_save.exported_key if key.nil?
      OpenSSL::PKey::RSA.new(key) unless key.nil?
    end

    on :fetch_author_public_key_by_entity_guid do |entity_type, guid|
      key = Entity.where(entity_type: entity_type, guid: guid).joins(:author).pluck(:serialized_public_key).first
      OpenSSL::PKey::RSA.new(key) unless key.nil?
    end

    on :entity_author_is_local? do |entity_type, guid|
      Entity.where(entity_type: entity_type, guid: guid).joins(:author)
            .where.not("people.serialized_private_key" => nil).exists?
    end

    on :fetch_entity_author_id_by_guid do |entity_type, guid|
      Entity.where(entity_type: entity_type, guid: guid).joins(:author).pluck(:diaspora_id).first
    end

    on :fetch_related_entity do |entity_type, guid|
      entity = Entity.find_by(entity_type: entity_type, guid: guid)
      if entity
        DiasporaFederation::Entities::RelatedEntity.new(
          author: entity.author.diaspora_id,
          local:  !entity.author.serialized_private_key.nil?
        )
      end
    end

    on :queue_public_receive do
    end

    on :queue_private_receive do
      true
    end

    on :receive_entity do |entity|
      puts "received entity: #{entity.class}: #{entity.to_h}"
    end

    on :fetch_public_entity do |entity_type, guid|
      type = DiasporaFederation::Entities.const_get(entity_type).entity_name
      FactoryGirl.build("#{type}_entity", guid: guid)
    end

    on :fetch_person_url_to do |diaspora_id, path|
      "http://#{diaspora_id.split('@').last}#{path}"
    end

    on :update_pod do
    end
  end
end
