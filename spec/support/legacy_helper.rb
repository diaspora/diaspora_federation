# This file only exists to generate legacy XMLs to test that we can still parse it.

def generate_legacy_salmon_slap(entity, sender, sender_privkey)
  build_salmon_slap_xml do |xml|
    xml.header {
      xml.author_id(sender)
    }

    xml.parent << DiasporaFederation::Salmon::MagicEnvelope.new(entity, sender).envelop(sender_privkey).root
  end
end

def generate_legacy_encrypted_salmon_slap(entity, sender, sender_privkey, recipient_pubkey)
  magic_envelope = DiasporaFederation::Salmon::MagicEnvelope.new(entity)
  cipher_params = encrypt_magic_env(magic_envelope)

  build_salmon_slap_xml do |xml|
    xml.encrypted_header(encrypted_header(sender, cipher_params, recipient_pubkey))

    xml.parent << magic_envelope.envelop(sender_privkey).root
  end
end

def build_salmon_slap_xml
  Nokogiri::XML::Builder.new(encoding: "UTF-8") {|xml|
    xml.diaspora("xmlns"    => DiasporaFederation::Salmon::XMLNS,
                 "xmlns:me" => DiasporaFederation::Salmon::MagicEnvelope::XMLNS) {
      yield xml
    }
  }.to_xml
end

def encrypt_magic_env(magic_env)
  DiasporaFederation::Salmon::AES.generate_key_and_iv.tap do |key|
    magic_env.instance_variable_set(
      "@payload_data", DiasporaFederation::Salmon::AES.encrypt(magic_env.send(:payload_data), key[:key], key[:iv])
    )
  end
end

def encrypted_header(author_id, envelope_key, pubkey)
  data = decrypted_header_xml(author_id, strict_base64_encode(envelope_key))
  header_key = DiasporaFederation::Salmon::AES.generate_key_and_iv
  ciphertext = DiasporaFederation::Salmon::AES.encrypt(data, header_key[:key], header_key[:iv])

  json_key = JSON.generate(strict_base64_encode(header_key))
  encrypted_key = Base64.strict_encode64(pubkey.public_encrypt(json_key))

  json_header = JSON.generate(aes_key: encrypted_key, ciphertext: ciphertext)

  Base64.strict_encode64(json_header)
end

def decrypted_header_xml(author_id, envelope_key)
  Nokogiri::XML::Builder.new(encoding: "UTF-8") {|xml|
    xml.decrypted_header {
      xml.iv(envelope_key[:iv])
      xml.aes_key(envelope_key[:key])
      xml.author_id(author_id)
    }
  }.to_xml.strip
end

def strict_base64_encode(hash)
  hash.map {|k, v| [k, Base64.strict_encode64(v)] }.to_h
end
