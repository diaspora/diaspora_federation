module DiasporaFederation
  describe Validators::MessageValidator do
    let(:entity) { :message_entity }
    it_behaves_like "a common validator"

    it_behaves_like "a diaspora id validator" do
      let(:property) { :diaspora_id }
      let(:mandatory) { true }
    end

    context "#guid, #parent_guid, #conversation_guid" do
      %i(guid parent_guid conversation_guid).each do |prop|
        it_behaves_like "a guid validator" do
          let(:property) { prop }
        end
      end
    end

    context "#author_signature and #parent_author_signature" do
      %i(author_signature parent_author_signature).each do |prop|
        it_behaves_like "a property that mustn't be empty" do
          let(:property) { prop }
        end
      end
    end
  end
end
