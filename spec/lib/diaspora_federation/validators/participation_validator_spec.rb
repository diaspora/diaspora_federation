module DiasporaFederation
  describe Validators::ParticipationValidator do
    let(:entity) { :participation_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora id validator" do
      let(:property) { :diaspora_id }
      let(:mandatory) { true }
    end

    %i(guid parent_guid).each do |prop|
      describe "##{prop}" do
        it_behaves_like "a guid validator" do
          let(:property) { prop }
        end
      end
    end

    %i(target_type author_signature parent_author_signature).each do |prop|
      describe "##{prop}" do
        it_behaves_like "a property that mustn't be empty" do
          let(:property) { prop }
        end
      end
    end
  end
end
