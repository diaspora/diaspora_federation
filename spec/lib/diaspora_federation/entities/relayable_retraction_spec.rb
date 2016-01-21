module DiasporaFederation
  describe Entities::RelayableRetraction do
    let(:data) { Test.attributes_with_signatures(:relayable_retraction_entity) }

    let(:xml) {
      <<-XML
<relayable_retraction>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
  <target_guid>#{data[:target_guid]}</target_guid>
  <target_type>#{data[:target_type]}</target_type>
  <sender_handle>#{data[:diaspora_id]}</sender_handle>
  <target_author_signature/>
</relayable_retraction>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    describe "#to_signed_h" do
      let(:author_pkey) { OpenSSL::PKey::RSA.generate(1024) }
      let(:hash) { FactoryGirl.attributes_for(:relayable_retraction_entity) }

      it "updates author signature when it was nil and key was supplied" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_entity_author_id_by_guid, hash[:target_type], hash[:target_guid]
        ).and_return(hash[:diaspora_id])

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, hash[:diaspora_id]
        ).and_return(author_pkey)

        signed_hash = Entities::RelayableRetraction.new(hash).to_signed_h

        signable_hash = hash.select do |key, _|
          %i(target_guid target_type).include?(key)
        end
        expect(Signing.verify_signature(signable_hash, signed_hash[:target_author_signature], author_pkey)).to be_truthy
      end

      it "updates parent author signature when it was nil, key was supplied and sender is not author of the target" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_entity_author_id_by_guid, hash[:target_type], hash[:target_guid]
        ).and_return(FactoryGirl.generate(:diaspora_id))

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, hash[:diaspora_id]
        ).and_return(author_pkey)

        signed_hash = Entities::RelayableRetraction.new(hash).to_signed_h

        signable_hash = hash.select do |key, _|
          %i(target_guid target_type).include?(key)
        end
        expect(Signing.verify_signature(signable_hash, signed_hash[:parent_author_signature], author_pkey)).to be_truthy
      end

      it "doesn't change signatures if they are already set" do
        hash.merge!(target_author_signature: "aa", parent_author_signature: "bb")

        expect(Entities::RelayableRetraction.new(hash).to_signed_h).to eq(hash)
      end

      it "doesn't change signatures if keys weren't supplied" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, hash[:diaspora_id]
        ).and_return(nil)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_entity_author_id_by_guid, "Comment", hash[:target_guid]
        ).and_return(hash[:diaspora_id])

        signed_hash = Entities::RelayableRetraction.new(hash).to_signed_h
        expect(signed_hash[:target_author_signature]).to eq(nil)
      end
    end
  end
end
