module DiasporaFederation
  describe Entities::SignedRetraction do
    let(:target) { Fabricate(:post, author: alice) }
    let(:target_entity) { Fabricate(:related_entity, author: alice.diaspora_id) }
    let(:data) {
      Fabricate(
        :signed_retraction_entity,
        author:      alice.diaspora_id,
        target_guid: target.guid,
        target_type: target.entity_type,
        target:      target_entity
      ).send(:enriched_properties).merge(target: target_entity)
    }

    let(:xml) { <<-XML }
<signed_retraction>
  <target_guid>#{data[:target_guid]}</target_guid>
  <target_type>#{data[:target_type]}</target_type>
  <author>#{data[:author]}</author>
  <target_author_signature>#{data[:target_author_signature]}</target_author_signature>
</signed_retraction>
XML

    let(:string) { "SignedRetraction:#{data[:target_type]}:#{data[:target_guid]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity", [:target_author_signature]

    it_behaves_like "a retraction"

    describe "#to_xml" do
      let(:author_pkey) { OpenSSL::PKey::RSA.generate(1024) }
      let(:hash) { Fabricate.attributes_for(:signed_retraction_entity) }

      it "updates author signature when it was nil and key was supplied" do
        expect_callback(:fetch_private_key, hash[:author]).and_return(author_pkey)

        signed_string = "#{hash[:target_guid]};#{hash[:target_type]}"

        xml = Entities::SignedRetraction.new(hash).to_xml

        signature = Base64.decode64(xml.at_xpath("target_author_signature").text)
        expect(author_pkey.verify(OpenSSL::Digest::SHA256.new, signature, signed_string)).to be_truthy
      end

      it "doesn't change signature if it is already set" do
        hash[:target_author_signature] = "aa"

        xml = Entities::SignedRetraction.new(hash).to_xml

        expect(xml.at_xpath("target_author_signature").text).to eq("aa")
      end

      it "doesn't change signature if a key wasn't supplied" do
        expect_callback(:fetch_private_key, hash[:author]).and_return(nil)

        xml = Entities::SignedRetraction.new(hash).to_xml
        expect(xml.at_xpath("target_author_signature").text).to eq("")
      end
    end

    describe "#to_retraction" do
      it "copies the attributes to a Retraction" do
        signed_retraction = Fabricate(:signed_retraction_entity)
        retraction = signed_retraction.to_retraction

        expect(retraction).to be_a(Entities::Retraction)
        expect(retraction.author).to eq(signed_retraction.author)
        expect(retraction.target_guid).to eq(signed_retraction.target_guid)
        expect(retraction.target_type).to eq(signed_retraction.target_type)
      end
    end

    context "parse retraction" do
      it "parses the xml as a retraction" do
        retraction = Entities::SignedRetraction.from_xml(Nokogiri::XML::Document.parse(xml).root)
        expect(retraction).to be_a(Entities::Retraction)
      end
    end
  end
end
