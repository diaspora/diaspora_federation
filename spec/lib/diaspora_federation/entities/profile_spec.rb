module DiasporaFederation
  describe Entities::Profile do
    let(:data) { FactoryGirl.attributes_for(:profile_entity) }
    let(:klass) { Entities::Profile }

    it_behaves_like "an Entity subclass"
  end
end
