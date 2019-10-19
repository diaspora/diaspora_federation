# frozen_string_literal: true

module DiasporaFederation
  describe Entities::SignedRetraction do
    let(:target) { Fabricate(:post, author: alice) }
    let(:target_entity) { Fabricate(:related_entity, author: alice.diaspora_id) }
    let(:data) { {author: alice.diaspora_id, target_guid: target.guid, target_type: target.entity_type} }

    let(:xml) { <<-XML }
<signed_retraction>
  <target_guid>#{data[:target_guid]}</target_guid>
  <target_type>#{data[:target_type]}</target_type>
  <sender_handle>#{data[:author]}</sender_handle>
  <target_author_signature/>
</signed_retraction>
XML

    describe "#initialize" do
      it "raises because it is not supported anymore" do
        expect {
          Entities::SignedRetraction.new(data)
        }.to raise_error RuntimeError,
                         "Sending SignedRetraction is not supported anymore! Use Retraction instead!"
      end
    end

    context "parse retraction" do
      it "parses the xml as a retraction" do
        expect(Entities::Retraction).to receive(:fetch_target).and_return(target_entity)
        retraction = Entities::SignedRetraction.from_xml(Nokogiri::XML(xml).root)
        expect(retraction).to be_a(Entities::Retraction)
        expect(retraction.author).to eq(data[:author])
        expect(retraction.target_guid).to eq(data[:target_guid])
        expect(retraction.target_type).to eq(data[:target_type])
        expect(retraction.target).to eq(target_entity)
      end
    end
  end
end
