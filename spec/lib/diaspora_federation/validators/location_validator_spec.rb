module DiasporaFederation
  describe Validators::LocationValidator do
    let(:entity) { :location_entity }
    it_behaves_like "a common validator"

    context "#lat and #lng" do
      %i(lat lng).each do |prop|
        it "must not be empty" do
          validator = Validators::LocationValidator.new(entity_stub(entity, prop => ""))
          expect(validator).not_to be_valid
          expect(validator.errors).to include(prop)
        end
      end
    end
  end
end
