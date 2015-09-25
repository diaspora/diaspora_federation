module DiasporaFederation
  module Salmon
    # Raised, if the element containing the Magic Envelope is missing from the XML
    class MissingMagicEnvelope < RuntimeError
    end

    # Raised, if the element containing the author is empty.
    class MissingAuthor < RuntimeError
    end

    # Raised, if the element containing the header is missing from the XML
    class MissingHeader < RuntimeError
    end

    # Raised if the decrypted header has an unexpected XML structure
    class InvalidHeader < RuntimeError
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

    # Raised, if the XML structure of the parsed document doesn't resemble the
    # expected structure.
    class InvalidStructure < RuntimeError
    end

    # Raised, if the entity name in the XML is invalid
    class InvalidEntityName < RuntimeError
    end

    # Raised, if the entity contained within the XML cannot be mapped to a
    # defined {Entity} subclass.
    class UnknownEntity < RuntimeError
    end
  end
end
