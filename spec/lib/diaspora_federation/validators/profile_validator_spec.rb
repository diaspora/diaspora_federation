module DiasporaFederation
  describe Validators::ProfileValidator do
    let(:entity) { :profile_entity }

    def profile_stub(data={})
      OpenStruct.new(FactoryGirl.attributes_for(:profile_entity).merge(data))
    end

    it "validates a well-formed instance" do
      validator = Validators::ProfileValidator.new(profile_stub)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it_behaves_like "a diaspora id validator" do
      let(:property) { :diaspora_id }
      let(:mandatory) { false }
    end

    %i(first_name last_name).each do |prop|
      describe "##{prop}" do
        it_behaves_like "a name validator" do
          let(:property) { prop }
          let(:length) { 32 }
        end
      end
    end

    %i(image_url image_url_medium image_url_small).each do |prop|
      describe "##{prop}" do
        it "is allowed to be nil" do
          validator = Validators::ProfileValidator.new(profile_stub(prop => nil))

          expect(validator).to be_valid
          expect(validator.errors).to be_empty
        end

        it_behaves_like "a url path validator" do
          let(:property) { prop }
        end
      end
    end

    describe "#gender" do
      it_behaves_like "a length validator" do
        let(:property) { :gender }
        let(:length) { 255 }
      end
    end

    describe "#bio" do
      it_behaves_like "a length validator" do
        let(:property) { :bio }
        let(:length) { 65_535 }
      end
    end

    describe "#location" do
      it_behaves_like "a length validator" do
        let(:property) { :location }
        let(:length) { 255 }
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
          let(:property) { prop }
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
  end
end
