# frozen_string_literal: true

module DiasporaFederation
  describe Validators::MessageValidator do
    let(:entity) { :message_entity }
    it_behaves_like "a common validator"

    it_behaves_like "a diaspora* ID validator" do
      let(:property) { :author }
    end

    describe "#guid" do
      it_behaves_like "a guid validator" do
        let(:property) { :guid }
      end
    end

    describe "#conversation_guid" do
      it_behaves_like "a guid validator" do
        let(:property) { :conversation_guid }
      end
    end

    describe "#text" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :text }
        let(:wrong_values) { ["", "a" * 65_536] }
        let(:correct_values) { ["a" * 65_535] }
      end
    end
  end
end
