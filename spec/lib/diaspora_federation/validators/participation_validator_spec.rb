module DiasporaFederation
  describe Validators::ParticipationValidator do
    let(:entity) { :participation_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora id validator" do
      let(:property) { :diaspora_id }
      let(:mandatory) { true }
    end

    context "#guid, #parent_guid" do
      %i(guid parent_guid).each do |prop|
        it_behaves_like "a guid validator" do
          let(:property) { prop }
        end
      end
    end

    context "#target_type and #author_signature and #parent_author_signature" do
      %i(target_type author_signature parent_author_signature).each do |prop|
        it_behaves_like "a property with data-types restriction" do
          let(:property) { prop }
          let(:wrong_values) { [""] }
          let(:correct_values) { [] }
        end
      end
    end
  end
end
