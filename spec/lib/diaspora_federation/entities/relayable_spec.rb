module DiasporaFederation
  describe Entities::Relayable do
    let(:author_pkey) { OpenSSL::PKey::RSA.generate(1024) }
    let(:parent_pkey) { OpenSSL::PKey::RSA.generate(1024) }

    let(:guid) { FactoryGirl.generate(:guid) }
    let(:parent_guid) { FactoryGirl.generate(:guid) }
    let(:author) { FactoryGirl.generate(:diaspora_id) }
    let(:property) { "hello" }
    let(:new_property) { "some text" }
    let(:hash) { {guid: guid, author: author, parent_guid: parent_guid, property: property} }

    let(:signature_data) { "#{author};#{guid};#{parent_guid};#{property}" }
    let(:signature_data_with_new_property) { "#{author};#{guid};#{new_property};#{parent_guid};#{property}" }
    let(:legacy_signature_data) { "#{guid};#{author};#{property};#{parent_guid}" }

    class SomeRelayable < Entity
      LEGACY_SIGNATURE_ORDER = %i(guid author property parent_guid).freeze

      include Entities::Relayable

      property :property

      def parent_type
        "Parent"
      end
    end

    def verify_signature(pubkey, signature, signed_string)
      pubkey.verify(OpenSSL::Digest::SHA256.new, Base64.decode64(signature), signed_string)
    end

    describe "#verify_signatures" do
      def sign_with_key(privkey, signature_data)
        Base64.strict_encode64(privkey.sign(OpenSSL::Digest::SHA256.new, signature_data))
      end

      it "doesn't raise anything if correct signatures with legacy-string were passed" do
        signed_hash = hash.dup
        signed_hash[:author_signature] = sign_with_key(author_pkey, legacy_signature_data)
        signed_hash[:parent_author_signature] = sign_with_key(parent_pkey, legacy_signature_data)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_key_by_diaspora_id, author
        ).and_return(author_pkey.public_key)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_author_public_key_by_entity_guid, "Parent", parent_guid
        ).and_return(parent_pkey.public_key)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :entity_author_is_local?, "Parent", parent_guid
        ).and_return(false)

        expect { SomeRelayable.new(signed_hash).verify_signatures }.not_to raise_error
      end

      it "raises when no public key for author was fetched" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_key_by_diaspora_id, anything
        ).and_return(nil)

        expect {
          SomeRelayable.new(hash).verify_signatures
        }.to raise_error Entities::Relayable::PublicKeyNotFound
      end

      it "raises when bad author signature was passed" do
        hash[:author_signature] = nil

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_key_by_diaspora_id, author
        ).and_return(author_pkey.public_key)

        expect {
          SomeRelayable.new(hash).verify_signatures
        }.to raise_error Entities::Relayable::SignatureVerificationFailed
      end

      it "raises when no public key for parent author was fetched" do
        hash[:author_signature] = sign_with_key(author_pkey, legacy_signature_data)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_key_by_diaspora_id, author
        ).and_return(author_pkey.public_key)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_author_public_key_by_entity_guid, "Parent", parent_guid
        ).and_return(nil)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :entity_author_is_local?, "Parent", parent_guid
        ).and_return(false)

        expect {
          SomeRelayable.new(hash).verify_signatures
        }.to raise_error Entities::Relayable::PublicKeyNotFound
      end

      it "raises when bad parent author signature was passed" do
        hash[:author_signature] = sign_with_key(author_pkey, legacy_signature_data)
        hash[:parent_author_signature] = nil

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_key_by_diaspora_id, author
        ).and_return(author_pkey.public_key)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_author_public_key_by_entity_guid, "Parent", parent_guid
        ).and_return(parent_pkey.public_key)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :entity_author_is_local?, "Parent", parent_guid
        ).and_return(false)

        expect {
          SomeRelayable.new(hash).verify_signatures
        }.to raise_error Entities::Relayable::SignatureVerificationFailed
      end

      it "doesn't raise if parent_author_signature isn't set but we're on upstream federation" do
        hash[:author_signature] = sign_with_key(author_pkey, legacy_signature_data)
        hash[:parent_author_signature] = nil

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_key_by_diaspora_id, author
        ).and_return(author_pkey.public_key)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :entity_author_is_local?, "Parent", parent_guid
        ).and_return(true)

        expect { SomeRelayable.new(hash).verify_signatures }.not_to raise_error
      end

      context "new signatures" do
        it "fallback to new signature verification if the legacy signature-check failed" do
          signed_hash = hash.dup
          signed_hash[:author_signature] = sign_with_key(author_pkey, signature_data)
          signed_hash[:parent_author_signature] = sign_with_key(parent_pkey, signature_data)

          expect(DiasporaFederation.callbacks).to receive(:trigger).with(
            :fetch_public_key_by_diaspora_id, author
          ).and_return(author_pkey.public_key)

          expect(DiasporaFederation.callbacks).to receive(:trigger).with(
            :fetch_author_public_key_by_entity_guid, "Parent", parent_guid
          ).and_return(parent_pkey.public_key)

          expect(DiasporaFederation.callbacks).to receive(:trigger).with(
            :entity_author_is_local?, "Parent", parent_guid
          ).and_return(false)

          expect { SomeRelayable.new(signed_hash).verify_signatures }.not_to raise_error
        end

        it "doesn't raise anything if correct signatures with new property were passed" do
          signed_hash = hash.dup
          signed_hash[:author_signature] = sign_with_key(author_pkey, signature_data_with_new_property)
          signed_hash[:parent_author_signature] = sign_with_key(parent_pkey, signature_data_with_new_property)

          expect(DiasporaFederation.callbacks).to receive(:trigger).with(
            :fetch_public_key_by_diaspora_id, author
          ).and_return(author_pkey.public_key)

          expect(DiasporaFederation.callbacks).to receive(:trigger).with(
            :fetch_author_public_key_by_entity_guid, "Parent", parent_guid
          ).and_return(parent_pkey.public_key)

          expect(DiasporaFederation.callbacks).to receive(:trigger).with(
            :entity_author_is_local?, "Parent", parent_guid
          ).and_return(false)

          expect { SomeRelayable.new(signed_hash, "new_property" => new_property).verify_signatures }.not_to raise_error
        end

        it "raises with legacy-signatures and with new property" do
          signed_hash = hash.dup
          signed_hash[:author_signature] = sign_with_key(author_pkey, legacy_signature_data)

          expect(DiasporaFederation.callbacks).to receive(:trigger).with(
            :fetch_public_key_by_diaspora_id, author
          ).and_return(author_pkey.public_key)

          expect {
            SomeRelayable.new(signed_hash, "new_property" => new_property).verify_signatures
          }.to raise_error Entities::Relayable::SignatureVerificationFailed
        end
      end
    end

    describe "#to_signed_h" do
      it "updates signatures when they were nil and keys were supplied" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, author
        ).and_return(author_pkey)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_author_private_key_by_entity_guid, "Parent", parent_guid
        ).and_return(parent_pkey)

        signed_hash = SomeRelayable.new(hash).to_signed_h

        expect(verify_signature(author_pkey, signed_hash[:author_signature], legacy_signature_data)).to be_truthy
        expect(verify_signature(parent_pkey, signed_hash[:parent_author_signature], legacy_signature_data)).to be_truthy
      end

      it "doesn't change signatures if they are already set" do
        hash.merge!(author_signature: "aa", parent_author_signature: "bb")

        expect(SomeRelayable.new(hash).to_signed_h).to eq(hash)
      end

      it "raises when author_signature not set and key isn't supplied" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, author
        ).and_return(nil)

        expect {
          SomeRelayable.new(hash).to_signed_h
        }.to raise_error Entities::Relayable::AuthorPrivateKeyNotFound
      end

      it "doesn't set parent_author_signature if key isn't supplied" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, author
        ).and_return(author_pkey)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_author_private_key_by_entity_guid, "Parent", parent_guid
        ).and_return(nil)

        signed_hash = SomeRelayable.new(hash).to_signed_h

        expect(signed_hash[:parent_author_signature]).to eq(nil)
      end

      context "new signatures" do
        it "updates parent_author_signature with new signature-data if additional_xml_elements is present" do
          hash[:author_signature] = "aa"

          expect(DiasporaFederation.callbacks).to receive(:trigger).with(
            :fetch_author_private_key_by_entity_guid, "Parent", parent_guid
          ).and_return(parent_pkey)

          signed_hash = SomeRelayable.new(hash, "new_property" => new_property).to_signed_h

          expect(
            verify_signature(parent_pkey, signed_hash[:parent_author_signature], signature_data_with_new_property)
          ).to be_truthy
        end
      end
    end

    describe "#to_xml" do
      it "adds new unknown xml elements to the xml again" do
        hash.merge!(author_signature: "aa", parent_author_signature: "bb")
        xml = SomeRelayable.new(hash, "new_property" => new_property).to_xml

        expected_xml = <<-XML
<some_relayable>
  <diaspora_handle>#{author}</diaspora_handle>
  <guid>#{guid}</guid>
  <parent_guid>#{parent_guid}</parent_guid>
  <author_signature>aa</author_signature>
  <parent_author_signature>bb</parent_author_signature>
  <property>#{property}</property>
  <new_property>#{new_property}</new_property>
</some_relayable>
XML

        expect(xml.to_s.strip).to eq(expected_xml.strip)
      end

      it "computes correct signatures for the entity" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, author
        ).and_return(author_pkey)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_author_private_key_by_entity_guid, "Parent", parent_guid
        ).and_return(parent_pkey)

        xml = DiasporaFederation::Salmon::XmlPayload.pack(SomeRelayable.new(hash))

        author_signature = xml.at_xpath("post/*[1]/author_signature").text
        parent_author_signature = xml.at_xpath("post/*[1]/parent_author_signature").text

        expect(verify_signature(author_pkey, author_signature, legacy_signature_data)).to be_truthy
        expect(verify_signature(parent_pkey, parent_author_signature, legacy_signature_data)).to be_truthy
      end
    end
  end
end
