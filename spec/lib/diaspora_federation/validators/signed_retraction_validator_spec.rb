module DiasporaFederation
  describe Validators::SignedRetractionValidator do
    let(:entity) { :signed_retraction_entity }
    it_behaves_like "a common validator"

    it_behaves_like "a diaspora id validator" do
      let(:property) { :sender_id }
      let(:mandatory) { true }
    end

    it_behaves_like "a guid validator" do
      let(:property) { :target_guid }
    end

    context "#target_type, #target_author_signature" do
      %i(target_type target_author_signature).each do |prop|
        it_behaves_like "a property that mustn't be empty" do
          let(:property) { prop }
        end
      end
    end
  end
end
