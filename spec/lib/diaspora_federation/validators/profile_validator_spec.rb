module DiasporaFederation
  describe Validators::ProfileValidator do
    let(:entity) { :profile_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora* ID validator" do
      let(:property) { :author }
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
        it_behaves_like "a property with a value validation/restriction" do
          let(:property) { prop }
          let(:wrong_values) { [] }
          let(:correct_values) { [nil] }
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
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :birthday }
        let(:wrong_values) { ["asdf asdf", true, 1234] }
        let(:correct_values) { [nil, "", Date.parse("2013-06-29"), "2013-06-29"] }
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
      # more than 5 tags are not allowed
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :tag_string }
        let(:wrong_values) { ["#i #have #too #many #tags #in #my #profile"] }
        let(:correct_values) { [] }
      end
    end
  end
end
