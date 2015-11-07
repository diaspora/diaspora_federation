module DiasporaFederation
  describe Entities::PollAnswer do
    let(:data) { FactoryGirl.attributes_for(:poll_answer_entity) }

    let(:xml) {
      <<-XML
<poll_answer>
  <guid>#{data[:guid]}</guid>
  <answer>#{data[:answer]}</answer>
</poll_answer>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
