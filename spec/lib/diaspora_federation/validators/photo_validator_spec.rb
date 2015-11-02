module DiasporaFederation
  describe Validators::PhotoValidator do
    let(:entity) { :photo_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora id validator" do
      let(:property) { :diaspora_id }
      let(:mandatory) { true }
    end

    context "#guid, #status_message_guid" do
      %i(guid status_message_guid).each do |prop|
        it_behaves_like "a guid validator" do
          let(:property) { prop }
        end
      end
    end

    it_behaves_like "a boolean validator" do
      let(:property) { :public }
    end

    context "#remote_photo_path, #remote_photo_name" do
      %i(remote_photo_name remote_photo_path).each do |prop|
        it "must not be empty" do
          validator = Validators::PhotoValidator.new(entity_stub(entity, prop => ""))
          expect(validator).not_to be_valid
          expect(validator.errors).to include(prop)
        end
      end
    end

    context "#height, #width" do
      %i(height width).each do |prop|
        it "validates an integer" do
          [123, "123"].each do |val|
            validator = Validators::PhotoValidator.new(entity_stub(entity, prop => val))
            expect(validator).to be_valid
            expect(validator.errors).to be_empty
          end
        end

        it "fails for non numeric types" do
          [true, :num, "asdf"].each do |val|
            validator = Validators::PhotoValidator.new(entity_stub(entity, prop => val))
            expect(validator).not_to be_valid
            expect(validator.errors).to include(prop)
          end
        end
      end
    end
  end
end
