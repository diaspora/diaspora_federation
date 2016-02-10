module DiasporaFederation
  describe Validators::RequestValidator do
    let(:entity) { :request_entity }

    it_behaves_like "a common validator"

    %i(author recipient).each do |prop|
      describe "##{prop}" do
        it_behaves_like "a diaspora id validator" do
          let(:property) { prop }
          let(:mandatory) { true }
        end
      end
    end
  end
end
