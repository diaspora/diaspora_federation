# frozen_string_literal: true

module DiasporaFederation
  module Salmon
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

    # Raised, if the parsed Magic Envelope specifies an unhandled data type.
    class InvalidDataType < RuntimeError
    end

    # Raised, if the parsed Magic Envelope specifies an unhandled algorithm.
    class InvalidAlgorithm < RuntimeError
    end

    # Raised, if the parsed Magic Envelope specifies an unhandled encoding.
    class InvalidEncoding < RuntimeError
    end
  end
end
