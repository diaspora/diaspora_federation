module DiasporaFederation
  module Salmon
    # Raised, if the element containing the Magic Envelope is missing from the XML
    # @deprecated
    class MissingMagicEnvelope < RuntimeError
    end

    # Raised, if the element containing the author is empty.
    # @deprecated
    class MissingAuthor < RuntimeError
    end

    # Raised, if the element containing the header is missing from the XML
    # @deprecated
    class MissingHeader < RuntimeError
    end

    # Raised if the decrypted header has an unexpected XML structure
    # @deprecated
    class InvalidHeader < RuntimeError
    end

    # Raised, if failed to fetch the public key of the sender of the received message
    class SenderKeyNotFound < RuntimeError
    end

    # Raised, if the Magic Envelope XML structure is malformed.
    class InvalidEnvelope < RuntimeError
    end

    # Raised, if the calculated signature doesn't match the one contained in the
    # Magic Envelope.
    class InvalidSignature < RuntimeError
    end

    # Raised, if the parsed Magic Envelope specifies an unhandled algorithm.
    class InvalidAlgorithm < RuntimeError
    end

    # Raised, if the parsed Magic Envelope specifies an unhandled encoding.
    class InvalidEncoding < RuntimeError
    end
  end
end
