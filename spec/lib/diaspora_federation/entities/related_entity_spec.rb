module DiasporaFederation
  describe Entities::RelatedEntity do
    let(:data) { FactoryGirl.attributes_for(:related_entity) }

    it_behaves_like "an Entity subclass"
  end
end
