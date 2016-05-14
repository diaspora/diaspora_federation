module DiasporaFederation
  describe Entities::RelayableRetraction do
    let(:target) { FactoryGirl.create(:comment, author: bob) }
    let(:target_entity) {
      FactoryGirl.build(
        :related_entity,
        author: bob.diaspora_id,
        parent: FactoryGirl.build(:related_entity, author: alice.diaspora_id)
      )
    }
    let(:data) {
      FactoryGirl.build(
        :relayable_retraction_entity,
        author:      alice.diaspora_id,
        target_guid: target.guid,
        target_type: target.entity_type,
        target:      target_entity
      ).send(:xml_elements).tap do |data|
        data[:target_author_signature] = nil
        data[:target] = target_entity
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
    let(:string) { "RelayableRetraction:#{data[:target_type]}:#{data[:target_guid]}" }

    it_behaves_like "an Entity subclass", [:target]

    it_behaves_like "an XML Entity", %i(parent_author_signature target_author_signature)

    it_behaves_like "a retraction"

    describe "#to_xml" do
      let(:author_pkey) { OpenSSL::PKey::RSA.generate(1024) }
      let(:hash) { FactoryGirl.attributes_for(:relayable_retraction_entity) }

      it "updates author signature when it was nil and key was supplied" do
        expect_callback(:fetch_private_key, hash[:author]).and_return(author_pkey)

        signed_string = "#{hash[:target_guid]};#{hash[:target_type]}"

        xml = Entities::RelayableRetraction.new(hash).to_xml

        signature = Base64.decode64(xml.at_xpath("target_author_signature").text)
        expect(author_pkey.verify(OpenSSL::Digest::SHA256.new, signature, signed_string)).to be_truthy
      end

      it "updates parent author signature when it was nil, key was supplied and sender is author of the parent" do
        parent = FactoryGirl.build(:related_entity, author: hash[:author])
        hash[:target] = FactoryGirl.build(:related_entity, author: bob.diaspora_id, parent: parent)

        expect_callback(:fetch_private_key, hash[:author]).and_return(author_pkey)

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
        expect_callback(:fetch_private_key, hash[:author]).and_return(nil)

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

    context "parse retraction" do
      it "parses the xml as a retraction" do
        retraction = Entities::RelayableRetraction.from_xml(Nokogiri::XML::Document.parse(xml).root)
        expect(retraction).to be_a(Entities::Retraction)
      end
    end
  end
end
