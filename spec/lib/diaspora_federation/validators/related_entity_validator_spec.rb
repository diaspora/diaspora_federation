module DiasporaFederation
  describe Validators::RelatedEntityValidator do
    let(:entity) { :related_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora* ID validator" do
      let(:property) { :author }
      let(:mandatory) { true }
    end

    %i[local public].each do |prop|
      it_behaves_like "a boolean validator" do
        let(:property) { prop }
      end
    end
  end
end
