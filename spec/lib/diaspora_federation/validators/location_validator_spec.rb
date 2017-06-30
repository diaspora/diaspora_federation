module DiasporaFederation
  describe Validators::LocationValidator do
    let(:entity) { :location_entity }
    it_behaves_like "a common validator"

    %i[lat lng].each do |prop|
      describe "##{prop}" do
        it_behaves_like "a property that mustn't be empty" do
          let(:property) { prop }
        end
      end
    end
  end
end
