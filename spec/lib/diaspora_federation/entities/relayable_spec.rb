module DiasporaFederation
  describe Entities::Relayable do
    let(:author_pkey) { OpenSSL::PKey::RSA.generate(1024) }
    let(:parent_pkey) { OpenSSL::PKey::RSA.generate(1024) }
    let(:hash) {
      {
        diaspora_id:     FactoryGirl.generate(:diaspora_id),
        parent_guid:     FactoryGirl.generate(:guid),
        some_other_data: "a_random_string"
      }
    }

    class SomeRelayable < Entity
      include Entities::Relayable

      property :diaspora_id, xml_name: :diaspora_handle

      def parent_type
        "Target"
      end
    end

    describe "#verify_signatures" do
      it "doesn't raise anything if correct data were passed" do
        hash[:author_signature] = Signing.sign_with_key(hash, author_pkey)
        hash[:parent_author_signature] = Signing.sign_with_key(hash, parent_pkey)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_key_by_diaspora_id, hash[:diaspora_id]
        ).and_return(author_pkey.public_key)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_author_public_key_by_entity_guid, "Target", hash[:parent_guid]
        ).and_return(parent_pkey.public_key)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :entity_author_is_local?, "Target", hash[:parent_guid]
        ).and_return(false)

        expect { SomeRelayable.new(hash).verify_signatures }.not_to raise_error
      end

      it "raises when no public key for author was fetched" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_key_by_diaspora_id, anything
        ).and_return(nil)

        expect {
          SomeRelayable.new(hash).verify_signatures
        }.to raise_error Entities::Relayable::SignatureVerificationFailed
      end

      it "raises when bad author signature was passed" do
        hash[:author_signature] = nil

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_key_by_diaspora_id, hash[:diaspora_id]
        ).and_return(author_pkey.public_key)

        expect {
          SomeRelayable.new(hash).verify_signatures
        }.to raise_error Entities::Relayable::SignatureVerificationFailed
      end

      it "raises when no public key for parent author was fetched" do
        hash[:author_signature] = Signing.sign_with_key(hash, author_pkey)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_key_by_diaspora_id, hash[:diaspora_id]
        ).and_return(author_pkey.public_key)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_author_public_key_by_entity_guid, "Target", hash[:parent_guid]
        ).and_return(nil)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :entity_author_is_local?, "Target", hash[:parent_guid]
        ).and_return(false)

        expect {
          SomeRelayable.new(hash).verify_signatures
        }.to raise_error Entities::Relayable::SignatureVerificationFailed
      end

      it "raises when bad parent author signature was passed" do
        hash[:author_signature] = Signing.sign_with_key(hash, author_pkey)
        hash[:parent_author_signature] = nil

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_key_by_diaspora_id, hash[:diaspora_id]
        ).and_return(author_pkey.public_key)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_author_public_key_by_entity_guid, "Target", hash[:parent_guid]
        ).and_return(parent_pkey.public_key)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :entity_author_is_local?, "Target", hash[:parent_guid]
        ).and_return(false)

        expect {
          SomeRelayable.new(hash).verify_signatures
        }.to raise_error Entities::Relayable::SignatureVerificationFailed
      end

      it "doesn't raise if parent_author_signature isn't set but we're on upstream federation" do
        hash[:author_signature] = Signing.sign_with_key(hash, author_pkey)
        hash[:parent_author_signature] = nil

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_key_by_diaspora_id, hash[:diaspora_id]
        ).and_return(author_pkey.public_key)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :entity_author_is_local?, "Target", hash[:parent_guid]
        ).and_return(true)

        expect { SomeRelayable.new(hash).verify_signatures }.not_to raise_error
      end
    end

    describe "#to_h" do
      it "updates signatures when they were nil and keys were supplied" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, hash[:diaspora_id]
        ).and_return(author_pkey)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_author_private_key_by_entity_guid, "Target", hash[:parent_guid]
        ).and_return(parent_pkey)

        signed_hash = SomeRelayable.new(hash).to_h

        expect(Signing.verify_signature(signed_hash, signed_hash[:author_signature], author_pkey)).to be_truthy
        expect(Signing.verify_signature(signed_hash, signed_hash[:parent_author_signature], parent_pkey)).to be_truthy
      end

      it "doesn't change signatures if they are already set" do
        hash.merge!(author_signature: "aa", parent_author_signature: "bb").delete(:some_other_data)

        expect(SomeRelayable.new(hash).to_h).to eq(hash)
      end

      it "doesn't change signatures if keys weren't supplied" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, hash[:diaspora_id]
        ).and_return(nil)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_author_private_key_by_entity_guid, "Target", hash[:parent_guid]
        ).and_return(nil)

        signed_hash = SomeRelayable.new(hash).to_h

        expect(signed_hash[:author_signature]).to eq(nil)
        expect(signed_hash[:parent_author_signature]).to eq(nil)
      end
    end
  end
end
