module DiasporaFederation
  describe Validators::ReshareValidator do
    let(:entity) { :reshare_entity }
    it_behaves_like "a common validator"

    context "#root_diaspora_id, #diaspora_id" do
      %i(root_diaspora_id diaspora_id).each do |prop|
        it_behaves_like "a diaspora id validator" do
          let(:property) { prop }
          let(:mandatory) { true }
        end
      end
    end

    context "#root_guid, #guid" do
      %i(root_guid guid).each do |prop|
        it_behaves_like "a guid validator" do
          let(:property) { prop }
        end
      end
    end

    it_behaves_like "a boolean validator" do
      let(:property) { :public }
    end
  end
end
