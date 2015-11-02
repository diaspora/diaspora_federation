module DiasporaFederation
  describe Validators::RequestValidator do
    let(:entity) { :request_entity }

    it_behaves_like "a common validator"

    context "#sender_id, #recipient_id" do
      %i(sender_id recipient_id).each do |prop|
        it_behaves_like "a diaspora id validator" do
          let(:property) { prop }
          let(:mandatory) { true }
        end
      end
    end
  end
end
