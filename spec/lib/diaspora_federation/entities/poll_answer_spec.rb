module DiasporaFederation
  describe Entities::PollAnswer do
    let(:data) { Fabricate.attributes_for(:poll_answer_entity) }

    let(:xml) { <<-XML }
<poll_answer>
  <guid>#{data[:guid]}</guid>
  <answer>#{data[:answer]}</answer>
</poll_answer>
XML

    let(:json) { <<-JSON }
{
  "entity_type": "poll_answer",
  "entity_data": {
    "guid": "#{data[:guid]}",
    "answer": "#{data[:answer]}"
  }
}
JSON

    let(:string) { "PollAnswer:#{data[:guid]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a JSON Entity"
  end
end
