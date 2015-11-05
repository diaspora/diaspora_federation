module DiasporaFederation
  describe Validators::PhotoValidator do
    let(:entity) { :photo_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora id validator" do
      let(:property) { :diaspora_id }
      let(:mandatory) { true }
    end

    context "#guid, #status_message_guid" do
      %i(guid status_message_guid).each do |prop|
        it_behaves_like "a guid validator" do
          let(:property) { prop }
        end
      end
    end

    it_behaves_like "a boolean validator" do
      let(:property) { :public }
    end

    context "#remote_photo_path, #remote_photo_name" do
      %i(remote_photo_name remote_photo_path).each do |prop|
        it_behaves_like "a property with data-types restriction" do
          let(:property) { prop }
          let(:wrong_values) { [""] }
          let(:correct_values) { [] }
        end
      end
    end

    context "#height, #width" do
      %i(height width).each do |prop|
        it_behaves_like "a property with data-types restriction" do
          let(:property) { prop }
          let(:wrong_values) { [true, :num, "asdf"] }
          let(:correct_values) { [123, "123"] }
        end
      end
    end
  end
end
