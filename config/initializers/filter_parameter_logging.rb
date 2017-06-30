# Don't log received xml data.
Rails.application.config.filter_parameters += %i[xml aes_key encrypted_magic_envelope]
