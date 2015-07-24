module DiasporaFederation
  module Entities
    class TestEntity < DiasporaFederation::Entity
      property :test
    end

    class TestDefaultEntity < DiasporaFederation::Entity
      property :test1
      property :test2
      property :test3, default: true
      property :test4, default: -> { true }
    end

    class OtherEntity < DiasporaFederation::Entity
      property :asdf
    end

    class TestNestedEntity < DiasporaFederation::Entity
      property :asdf
      entity :test, TestEntity
      entity :multi, [OtherEntity]
    end

    class TestEntityWithXmlName < DiasporaFederation::Entity
      property :test
      property :qwer, xml_name: :asdf
    end
  end
end
