module DiasporaFederation
  describe Entities::Person do
    let(:data) { FactoryGirl.attributes_for(:person_entity) }
    let(:klass) { Entities::Person }

    it_behaves_like "an Entity subclass"
  end
end
