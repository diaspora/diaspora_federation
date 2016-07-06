module DiasporaFederation
  describe Validators::PhotoValidator do
    let(:entity) { :photo_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora* ID validator" do
      let(:property) { :author }
      let(:mandatory) { true }
    end

    describe "#guid" do
      it_behaves_like "a guid validator" do
        let(:property) { :guid }
      end
    end

    describe "#status_message_guid" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :status_message_guid }
        let(:wrong_values) { ["aaaaaa", "zzz+-#*$$", ""] }
        let(:correct_values) { ["1234567890ABCDefgh_ijkl-mnopQR@example.com:3000", nil] }
      end
    end

    it_behaves_like "a boolean validator" do
      let(:property) { :public }
    end

    %i(remote_photo_name remote_photo_path).each do |prop|
      describe "##{prop}" do
        it_behaves_like "a property that mustn't be empty" do
          let(:property) { prop }
        end
      end
    end

    %i(height width).each do |prop|
      describe "##{prop}" do
        it_behaves_like "a property with a value validation/restriction" do
          let(:property) { prop }
          let(:wrong_values) { [true, :num, "asdf"] }
          let(:correct_values) { [123, "123"] }
        end
      end
    end

    describe "#text" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :text }
        let(:wrong_values) { ["a" * 65_536] }
        let(:correct_values) { ["a" * 65_535, nil, ""] }
      end
    end
  end
end
