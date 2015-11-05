module DiasporaFederation
  describe Validators::WebFingerValidator do
    let(:entity) { :webfinger }

    it_behaves_like "a common validator"

    describe "#acct_uri" do
      it_behaves_like "a property with data-types restriction" do
        let(:property) { :acct_uri }
        let(:wrong_values) { [nil, ""] }
        let(:correct_values) { [] }
      end
    end

    %i(hcard_url profile_url atom_url).each do |prop|
      describe "##{prop}" do
        it_behaves_like "a url validator without path" do
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
        it_behaves_like "a property with a value validation/restriction" do
          let(:property) { prop }
          let(:wrong_values) { ["", "https://asdf$%.com", "example.com"] }
          let(:correct_values) { [nil] }
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
