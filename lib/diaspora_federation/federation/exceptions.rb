module DiasporaFederation
  module Federation
    # Raised if failed to fetch a public key of the sender of the received message
    class SenderKeyNotFound < Exception
    end

    # Raised if recipient private key is missing for a private receive
    class RecipientKeyNotFound < Exception
    end
  end
end
