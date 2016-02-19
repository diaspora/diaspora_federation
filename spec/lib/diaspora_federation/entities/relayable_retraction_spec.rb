module DiasporaFederation
  describe Entities::RelayableRetraction do
    let(:data) {
      FactoryGirl.build(:relayable_retraction_entity, author: alice.diaspora_id).send(:xml_elements).tap do |data|
        data[:target_author_signature] = nil
      end
    }

    let(:xml) {
      <<-XML
<relayable_retraction>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
  <target_guid>#{data[:target_guid]}</target_guid>
  <target_type>#{data[:target_type]}</target_type>
  <sender_handle>#{data[:author]}</sender_handle>
  <target_author_signature/>
</relayable_retraction>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    describe "#to_xml" do
      let(:author_pkey) { OpenSSL::PKey::RSA.generate(1024) }
      let(:hash) { FactoryGirl.attributes_for(:relayable_retraction_entity) }

      it "updates author signature when it was nil and key was supplied" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_entity_author_id_by_guid, hash[:target_type], hash[:target_guid]
        ).and_return(hash[:author])

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, hash[:author]
        ).and_return(author_pkey)

        signed_string = "#{hash[:target_guid]};#{hash[:target_type]}"

        xml = Entities::RelayableRetraction.new(hash).to_xml

        signature = Base64.decode64(xml.at_xpath("target_author_signature").text)
        expect(author_pkey.verify(OpenSSL::Digest::SHA256.new, signature, signed_string)).to be_truthy
      end

      it "updates parent author signature when it was nil, key was supplied and sender is not author of the target" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_entity_author_id_by_guid, hash[:target_type], hash[:target_guid]
        ).and_return(FactoryGirl.generate(:diaspora_id))

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, hash[:author]
        ).and_return(author_pkey)

        signed_string = "#{hash[:target_guid]};#{hash[:target_type]}"

        xml = Entities::RelayableRetraction.new(hash).to_xml

        signature = Base64.decode64(xml.at_xpath("parent_author_signature").text)
        expect(author_pkey.verify(OpenSSL::Digest::SHA256.new, signature, signed_string)).to be_truthy
      end

      it "doesn't change signatures if they are already set" do
        hash.merge!(target_author_signature: "aa", parent_author_signature: "bb")

        xml = Entities::RelayableRetraction.new(hash).to_xml

        expect(xml.at_xpath("target_author_signature").text).to eq("aa")
        expect(xml.at_xpath("parent_author_signature").text).to eq("bb")
      end

      it "doesn't change signatures if keys weren't supplied" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, hash[:author]
        ).and_return(nil)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_entity_author_id_by_guid, "Comment", hash[:target_guid]
        ).and_return(hash[:author])

        xml = Entities::RelayableRetraction.new(hash).to_xml
        expect(xml.at_xpath("target_author_signature").text).to eq("")
        expect(xml.at_xpath("parent_author_signature").text).to eq("")
      end
    end

    describe "#to_retraction" do
      it "copies the attributes to a Retraction" do
        relayable_retraction = FactoryGirl.build(:relayable_retraction_entity)
        retraction = relayable_retraction.to_retraction

        expect(retraction).to be_a(Entities::Retraction)
        expect(retraction.author).to eq(relayable_retraction.author)
        expect(retraction.target_guid).to eq(relayable_retraction.target_guid)
        expect(retraction.target_type).to eq(relayable_retraction.target_type)
      end
    end
  end
end
