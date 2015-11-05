module DiasporaFederation
  describe Validators::LikeValidator do
    let(:entity) { :like_entity }
    it_behaves_like "a common validator"

    %i(guid parent_guid).each do |prop|
      it_behaves_like "a guid validator" do
        let(:property) { prop }
      end
    end

    %i(author_signature parent_author_signature).each do |prop|
      describe "##{prop}" do
        it_behaves_like "a property that mustn't be empty" do
          let(:property) { prop }
        end
      end
    end

    it_behaves_like "a diaspora id validator" do
      let(:property) { :diaspora_id }
      let(:mandatory) { true }
    end
  end
end
