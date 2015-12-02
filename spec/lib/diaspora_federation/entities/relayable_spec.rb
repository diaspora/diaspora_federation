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

    describe ".verify_signatures" do
      it "doesn't raise anything if correct data were passed" do
        hash[:author_signature] = Signing.sign_with_key(hash, author_pkey)
        hash[:parent_author_signature] = Signing.sign_with_key(hash, parent_pkey)

        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(:fetch_public_key_by_diaspora_id, hash[:diaspora_id])
                                                  .and_return(author_pkey.public_key)
        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(
                                                    :fetch_author_public_key_by_entity_guid,
                                                    "Post",
                                                    hash[:parent_guid]
                                                  )
                                                  .and_return(parent_pkey.public_key)
        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(:entity_author_is_local?, "Post", hash[:parent_guid])
                                                  .and_return(false)
        expect { Entities::Relayable.verify_signatures(hash) }.not_to raise_error
      end

      it "raises when no public key for author was fetched" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(:fetch_public_key_by_diaspora_id, anything)
                                                  .and_return(nil)

        expect { Entities::Relayable.verify_signatures(hash) }.to raise_error(
          Entities::Relayable::SignatureVerificationFailed
        )
      end

      it "raises when bad author signature was passed" do
        hash[:author_signature] = nil

        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(:fetch_public_key_by_diaspora_id, hash[:diaspora_id])
                                                  .and_return(author_pkey.public_key)
        expect { Entities::Relayable.verify_signatures(hash) }.to raise_error(
          Entities::Relayable::SignatureVerificationFailed
        )
      end

      it "raises when no public key for parent author was fetched" do
        hash[:author_signature] = Signing.sign_with_key(hash, author_pkey)

        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(:fetch_public_key_by_diaspora_id, hash[:diaspora_id])
                                                  .and_return(author_pkey.public_key)
        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(
                                                    :fetch_author_public_key_by_entity_guid,
                                                    "Post",
                                                    hash[:parent_guid]
                                                  )
                                                  .and_return(nil)
        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(:entity_author_is_local?, "Post", hash[:parent_guid])
                                                  .and_return(false)
        expect { Entities::Relayable.verify_signatures(hash) }.to raise_error(
          Entities::Relayable::SignatureVerificationFailed
        )
      end

      it "raises when bad parent author signature was passed" do
        hash[:author_signature] = Signing.sign_with_key(hash, author_pkey)
        hash[:parent_author_signature] = nil

        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(:fetch_public_key_by_diaspora_id, hash[:diaspora_id])
                                                  .and_return(author_pkey.public_key)
        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(
                                                    :fetch_author_public_key_by_entity_guid,
                                                    "Post",
                                                    hash[:parent_guid]
                                                  )
                                                  .and_return(parent_pkey.public_key)
        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(:entity_author_is_local?, "Post", hash[:parent_guid])
                                                  .and_return(false)
        expect { Entities::Relayable.verify_signatures(hash) }.to raise_error(
          Entities::Relayable::SignatureVerificationFailed
        )
      end

      it "doesn't raise if parent_author_signature isn't set but we're on upstream federation" do
        hash[:author_signature] = Signing.sign_with_key(hash, author_pkey)
        hash[:parent_author_signature] = nil

        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(:fetch_public_key_by_diaspora_id, hash[:diaspora_id])
                                                  .and_return(author_pkey.public_key)
        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(:entity_author_is_local?, "Post", hash[:parent_guid])
                                                  .and_return(true)
        expect { Entities::Relayable.verify_signatures(hash) }.not_to raise_error
      end
    end

    describe ".update_singatures!" do
      it "updates signatures when they were nil and keys were supplied" do
        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(:fetch_private_key_by_diaspora_id, hash[:diaspora_id])
                                                  .and_return(author_pkey)
        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(
                                                    :fetch_author_private_key_by_entity_guid,
                                                    "Post",
                                                    hash[:parent_guid]
                                                  )
                                                  .and_return(parent_pkey)

        Entities::Relayable.update_signatures!(hash)
        expect(Signing.verify_signature(hash, hash[:author_signature], author_pkey)).to be_truthy
        expect(Signing.verify_signature(hash, hash[:parent_author_signature], parent_pkey)).to be_truthy
      end

      it "doesn't change signatures if they are already set" do
        signatures = {author_signature: "aa", parent_author_signature: "bb"}
        hash.merge!(signatures)

        Entities::Relayable.update_signatures!(hash)
        expect(hash[:author_signature]).to eq(signatures[:author_signature])
        expect(hash[:parent_author_signature]).to eq(signatures[:parent_author_signature])
      end

      it "doesn't change signatures if keys weren't supplied" do
        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(:fetch_private_key_by_diaspora_id, hash[:diaspora_id])
                                                  .and_return(nil)
        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(
                                                    :fetch_author_private_key_by_entity_guid,
                                                    "Post",
                                                    hash[:parent_guid]
                                                  )
                                                  .and_return(nil)

        Entities::Relayable.update_signatures!(hash)
        expect(hash[:author_signature]).to eq(nil)
        expect(hash[:parent_author_signature]).to eq(nil)
      end
    end
  end
end
