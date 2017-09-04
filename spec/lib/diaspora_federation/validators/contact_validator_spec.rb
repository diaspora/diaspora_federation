module DiasporaFederation
  describe Validators::ContactValidator do
    let(:entity) { :contact_entity }

    it_behaves_like "a common validator"

    %i[author recipient].each do |prop|
      describe "##{prop}" do
        it_behaves_like "a diaspora* ID validator" do
          let(:property) { prop }
          let(:mandatory) { true }
        end
      end
    end

    %i[following sharing blocking].each do |prop|
      describe "##{prop}" do
        it_behaves_like "a boolean validator" do
          let(:property) { prop }
        end
      end
    end
  end
end
