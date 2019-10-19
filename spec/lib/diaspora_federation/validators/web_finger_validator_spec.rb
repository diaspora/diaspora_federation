# frozen_string_literal: true

module DiasporaFederation
  describe Validators::WebFingerValidator do
    let(:entity) { :webfinger }

    it_behaves_like "a common validator"

    describe "#acct_uri" do
      it_behaves_like "a property that mustn't be empty" do
        let(:property) { :acct_uri }
      end
    end

    %i[hcard_url].each do |prop|
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
    %i[salmon_url profile_url atom_url].each do |prop|
      describe "##{prop}" do
        it_behaves_like "a property with a value validation/restriction" do
          let(:property) { prop }
          let(:wrong_values) { %w[https://asdf$%.com example.com] }
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
