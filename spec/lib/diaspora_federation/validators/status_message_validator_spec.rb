module DiasporaFederation
  describe Validators::StatusMessageValidator do
    let(:entity) { :status_message_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora id validator" do
      let(:property) { :author }
      let(:mandatory) { true }
    end

    it_behaves_like "a guid validator" do
      let(:property) { :guid }
    end

    it_behaves_like "a boolean validator" do
      let(:property) { :public }
    end
  end
end
