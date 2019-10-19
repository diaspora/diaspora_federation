# frozen_string_literal: true

module DiasporaFederation
  describe Validators::EmbedValidator do
    let(:entity) { :embed_entity }
    it_behaves_like "a common validator"

    describe "#url" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :url }
        let(:wrong_values) { %w[https://asdf$%.com example.com] }
        let(:correct_values) { [nil, "https://example.org", "https://example.org/index.html"] }
      end
    end

    describe "#title" do
      it_behaves_like "a length validator" do
        let(:property) { :title }
        let(:length) { 255 }
      end
    end

    describe "#description" do
      it_behaves_like "a length validator" do
        let(:property) { :description }
        let(:length) { 65_535 }
      end
    end

    describe "#image" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :image }
        let(:wrong_values) { %w[https://asdf$%.com example.com] }
        let(:correct_values) { [nil] }
      end

      it_behaves_like "a url path validator" do
        let(:property) { :image }
      end
    end
  end
end
