module DiasporaFederation
  describe Validators::CommentValidator do
    let(:entity) { :comment_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora id validator" do
      let(:property) { :diaspora_id }
      let(:mandatory) { true }
    end

    %i(guid parent_guid).each do |prop|
      it_behaves_like "a guid validator" do
        let(:property) { prop }
      end
    end

    %i(author_signature parent_author_signature).each do |prop|
      describe "##{prop}" do
        it_behaves_like "a property that mustn't be empty" do
          let(:property) { prop }
        end
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
