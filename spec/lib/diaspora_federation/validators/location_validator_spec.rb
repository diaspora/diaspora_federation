module DiasporaFederation
  describe Validators::LocationValidator do
    let(:entity) { :location_entity }
    it_behaves_like "a common validator"

    context "#lat and #lng" do
      %i(lat lng).each do |prop|
        it_behaves_like "a property with data-types restriction" do
          let(:property) { prop }
          let(:wrong_values) { [""] }
          let(:correct_values) { [] }
        end
      end
    end
  end
end
