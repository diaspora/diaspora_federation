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
        entity = OpenStruct.new(FactoryGirl.attributes_for(:participation_entity, target_type: ""))
        validator = Validators::ParticipationValidator.new(entity)
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
          p = OpenStruct.new(FactoryGirl.attributes_for(:participation_entity))
          p.public_send("#{prop}=", "")

          v = Validators::ParticipationValidator.new(p)
          expect(v).not_to be_valid
          expect(v.errors).to include(prop)
        end
      end
    end
  end
end
