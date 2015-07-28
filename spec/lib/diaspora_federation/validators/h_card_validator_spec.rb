module DiasporaFederation
  describe Validators::HCardValidator do
    let(:entity) { :h_card }

    def hcard_stub(data={})
      OpenStruct.new(FactoryGirl.attributes_for(:h_card).merge(data))
    end

    it "validates a well-formed instance" do
      validator = Validators::HCardValidator.new(hcard_stub)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    describe "#full_name" do
      it_behaves_like "a name validator" do
        let(:property) { :full_name }
        let(:length) { 70 }
      end
    end

    %i(first_name last_name).each do |prop|
      describe "##{prop}" do
        it_behaves_like "a name validator" do
          let(:property) { prop }
          let(:length) { 32 }
        end
      end
    end

    %i(photo_large_url photo_medium_url photo_small_url).each do |prop|
      describe "##{prop}" do
        it "must not be nil or empty" do
          [nil, ""].each do |val|
            validator = Validators::HCardValidator.new(hcard_stub(prop => val))

            expect(validator).not_to be_valid
            expect(validator.errors).to include(prop)
          end
        end

        it_behaves_like "a url path validator" do
          let(:property) { prop }
        end
      end
    end

    describe "#searchable" do
      it_behaves_like "a boolean validator" do
        let(:property) { :searchable }
      end
    end
  end
end
