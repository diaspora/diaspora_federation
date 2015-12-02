module DiasporaFederation
  describe Entities::SignedRetraction do
    let(:data) { Test.signed_retraction_attributes_with_signatures }

    let(:xml) {
      <<-XML
<signed_retraction>
  <target_guid>#{data[:target_guid]}</target_guid>
  <target_type>#{data[:target_type]}</target_type>
  <sender_handle>#{data[:diaspora_id]}</sender_handle>
  <target_author_signature>#{data[:target_author_signature]}</target_author_signature>
</signed_retraction>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    describe ".update_singatures!" do
      let(:author_pkey) { OpenSSL::PKey::RSA.generate(1024) }
      let(:hash) { FactoryGirl.attributes_for(:signed_retraction_entity) }

      it "updates author signature when it was nil and key was supplied" do
        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(:fetch_private_key_by_diaspora_id, hash[:diaspora_id])
                                                  .and_return(author_pkey)

        signable_hash = hash.select do |key, _|
          %i(target_guid target_type).include?(key)
        end

        Entities::SignedRetraction.update_signatures!(hash)

        expect(Signing.verify_signature(signable_hash, hash[:target_author_signature], author_pkey)).to be_truthy
      end

      it "doesn't change signature if it is already set" do
        signatures = {target_author_signature: "aa"}
        hash.merge!(signatures)

        Entities::SignedRetraction.update_signatures!(hash)
        expect(hash[:target_author_signature]).to eq(signatures[:target_author_signature])
      end

      it "doesn't change signature if a key wasn't supplied" do
        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(:fetch_private_key_by_diaspora_id, hash[:diaspora_id])
                                                  .and_return(nil)

        Entities::SignedRetraction.update_signatures!(hash)
        expect(hash[:author_signature]).to eq(nil)
      end
    end
  end
end
