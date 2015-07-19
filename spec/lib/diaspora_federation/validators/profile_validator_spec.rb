module DiasporaFederation
  describe Validators::ProfileValidator do
    def profile_stub(data={})
      OpenStruct.new(FactoryGirl.attributes_for(:profile_entity).merge(data))
    end

    it "validates a well-formed instance" do
      validator = Validators::ProfileValidator.new(profile_stub)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it_behaves_like "a diaspora_handle validator" do
      let(:entity) { :profile_entity }
      let(:validator_class) { Validators::ProfileValidator }
      let(:property) { :diaspora_handle }
    end

    %i(first_name last_name).each do |prop|
      describe "##{prop}" do
        it "allowed to contain special chars" do
          validator = Validators::ProfileValidator.new(profile_stub(prop => "cool name ©"))

          expect(validator).to be_valid
          expect(validator.errors).to be_empty
        end

        it "must not exceed 32 chars" do
          validator = Validators::ProfileValidator.new(profile_stub(prop => "abcdefghijklmnopqrstuvwxyz_aaaaaaaaaa"))

          expect(validator).not_to be_valid
          expect(validator.errors).to include(prop)
        end

        it "must not contain semicolons" do
          validator = Validators::ProfileValidator.new(profile_stub(prop => "asdf;qwer;yxcv"))

          expect(validator).not_to be_valid
          expect(validator.errors).to include(prop)
        end
      end
    end

    describe "#tag_string" do
      it "must not contain more than 5 tags" do
        validator = Validators::ProfileValidator.new(
          profile_stub(tag_string: "#i #have #too #many #tags #in #my #profile"))

        expect(validator).not_to be_valid
        expect(validator.errors).to include(:tag_string)
      end
    end

    describe "#birthday" do
      it "may be empty or nil" do
        [nil, ""].each do |val|
          validator = Validators::ProfileValidator.new(profile_stub(birthday: val))

          expect(validator).to be_valid
          expect(validator.errors).to be_empty
        end
      end

      it "may be a Date or date string" do
        [Date.parse("2013-06-29"), "2013-06-29"].each do |val|
          validator = Validators::ProfileValidator.new(profile_stub(birthday: val))

          expect(validator).to be_valid
          expect(validator.errors).to be_empty
        end
      end

      it "must not be an arbitrary string or other object" do
        ["asdf asdf", true, 1234].each do |val|
          validator = Validators::ProfileValidator.new(profile_stub(birthday: val))

          expect(validator).not_to be_valid
          expect(validator.errors).to include(:birthday)
        end
      end
    end

    %i(searchable nsfw).each do |prop|
      describe "##{prop}" do
        it_behaves_like "a boolean validator" do
          let(:entity) { :profile_entity }
          let(:validator_class) { Validators::ProfileValidator }
          let(:property) { prop }
        end
      end
    end
  end
end
