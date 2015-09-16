module DiasporaFederation
  describe Validators::WebFingerValidator do
    let(:entity) { :webfinger }

    def webfinger_stub(data={})
      OpenStruct.new(FactoryGirl.attributes_for(:webfinger).merge(data))
    end

    it "validates a well-formed instance" do
      validator = Validators::WebFingerValidator.new(webfinger_stub)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    describe "#acct_uri" do
      it "fails if it is nil or empty" do
        [nil, ""].each do |val|
          validator = Validators::WebFingerValidator.new(webfinger_stub(acct_uri: val))

          expect(validator).not_to be_valid
          expect(validator.errors).to include(:acct_uri)
        end
      end
    end

    %i(hcard_url profile_url atom_url).each do |prop|
      describe "##{prop}" do
        it_behaves_like "a url validator without path"  do
          let(:property) { prop }
        end

        it_behaves_like "a url path validator" do
          let(:property) { prop }
        end
      end
    end

    # optional urls
    %i(alias_url salmon_url).each do |prop|
      describe "##{prop}" do
        it "is allowed to be nil" do
          validator = described_class.new(webfinger_stub(prop => nil))

          expect(validator).to be_valid
          expect(validator.errors).to be_empty
        end

        it "must not be empty" do
          validator = described_class.new(webfinger_stub(prop => ""))

          expect(validator).not_to be_valid
          expect(validator.errors).to include(prop)
        end

        it "fails for url with special chars" do
          validator = described_class.new(webfinger_stub(prop => "https://asdf$%.com"))

          expect(validator).not_to be_valid
          expect(validator.errors).to include(prop)
        end

        it "fails for url without scheme" do
          validator = described_class.new(webfinger_stub(prop => "example.com"))

          expect(validator).not_to be_valid
          expect(validator.errors).to include(prop)
        end

        it_behaves_like "a url path validator" do
          let(:property) { prop }
        end
      end
    end

    describe "#seed_url" do
      it_behaves_like "a url validator without path" do
        let(:property) { :seed_url }
      end
    end
  end
end
