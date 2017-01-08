module DiasporaFederation
  describe Validators::EventValidator do
    let(:entity) { :event_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora* ID validator" do
      let(:property) { :author }
      let(:mandatory) { true }
    end

    it_behaves_like "a guid validator" do
      let(:property) { :guid }
    end

    describe "#summary" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :summary }
        let(:wrong_values) { ["a" * 256, nil, ""] }
        let(:correct_values) { ["a" * 255] }
      end
    end

    describe "#description" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :description }
        let(:wrong_values) { ["a" * 65_536] }
        let(:correct_values) { ["a" * 65_535, nil, ""] }
      end
    end

    describe "#start" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :start }
        let(:wrong_values) { [nil] }
        let(:correct_values) { [Time.now.utc] }
      end
    end

    describe "#end" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :end }
        let(:wrong_values) { [] }
        let(:correct_values) { [nil, Time.now.utc] }
      end
    end

    describe "#all_day" do
      it_behaves_like "a boolean validator" do
        let(:property) { :all_day }
      end
    end

    describe "#timezone" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :timezone }
        let(:wrong_values) { ["foobar"] }
        let(:correct_values) { [nil, "Europe/Berlin", "America/Argentina/ComodRivadavia"] }
      end
    end
  end
end
