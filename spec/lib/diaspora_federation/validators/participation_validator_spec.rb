module DiasporaFederation
  describe Validators::ParticipationValidator do
    let(:entity) { :participation_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora id validator" do
      let(:property) { :diaspora_id }
      let(:mandatory) { true }
    end

    context "#target_type" do
      it "must not be empty" do
        validator = Validators::ParticipationValidator.new(entity_stub(entity, target_type: ""))
        expect(validator).not_to be_valid
        expect(validator.errors).to include(:target_type)
      end
    end

    context "#guid, #parent_guid" do
      %i(guid parent_guid).each do |prop|
        it_behaves_like "a guid validator" do
          let(:property) { prop }
        end
      end
    end

    context "#author_signature and #parent_author_signature" do
      %i(author_signature parent_author_signature).each do |prop|
        it "must not be empty" do
          validator = Validators::ParticipationValidator.new(entity_stub(entity, prop => ""))
          expect(validator).not_to be_valid
          expect(validator.errors).to include(prop)
        end
      end
    end
  end
end
