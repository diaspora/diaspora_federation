module DiasporaFederation
  describe Validators::LikeValidator do
    let(:entity) { :like_entity }
    it_behaves_like "a common validator"

    it_behaves_like "a relayable validator"

    describe "#guid" do
      it_behaves_like "a guid validator" do
        let(:property) { :guid }
      end
    end

    it_behaves_like "a diaspora id validator" do
      let(:property) { :diaspora_id }
      let(:mandatory) { true }
    end
  end
end
