module DiasporaFederation
  describe Entities::RelayableRetraction do
    let(:data) { FactoryGirl.build(:relayable_retraction_entity, diaspora_id: alice.diaspora_id).to_h }

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

    describe "#to_h" do
      let(:author_pkey) { OpenSSL::PKey::RSA.generate(1024) }
      let(:hash) { FactoryGirl.attributes_for(:relayable_retraction_entity) }

      it "updates author signature when it was nil and key was supplied" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_entity_author_id_by_guid, hash[:target_type], hash[:target_guid]
        ).and_return(hash[:diaspora_id])

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, hash[:diaspora_id]
        ).and_return(author_pkey)

        signed_string = "#{hash[:target_guid]};#{hash[:target_type]}"

        signed_hash = Entities::RelayableRetraction.new(hash).to_h

        signature = Base64.decode64(signed_hash[:target_author_signature])
        expect(author_pkey.verify(OpenSSL::Digest::SHA256.new, signature, signed_string)).to be_truthy
      end

      it "updates parent author signature when it was nil, key was supplied and sender is not author of the target" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_entity_author_id_by_guid, hash[:target_type], hash[:target_guid]
        ).and_return(FactoryGirl.generate(:diaspora_id))

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, hash[:diaspora_id]
        ).and_return(author_pkey)

        signed_string = "#{hash[:target_guid]};#{hash[:target_type]}"

        signed_hash = Entities::RelayableRetraction.new(hash).to_h

        signature = Base64.decode64(signed_hash[:parent_author_signature])
        expect(author_pkey.verify(OpenSSL::Digest::SHA256.new, signature, signed_string)).to be_truthy
      end

      it "doesn't change signatures if they are already set" do
        hash.merge!(target_author_signature: "aa", parent_author_signature: "bb")

        expect(Entities::RelayableRetraction.new(hash).to_h).to eq(hash)
      end

      it "doesn't change signatures if keys weren't supplied" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, hash[:diaspora_id]
        ).and_return(nil)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_entity_author_id_by_guid, "Comment", hash[:target_guid]
        ).and_return(hash[:diaspora_id])

        signed_hash = Entities::RelayableRetraction.new(hash).to_h
        expect(signed_hash[:target_author_signature]).to eq(nil)
      end
    end

    describe "#to_retraction" do
      it "copies the attributes to a Retraction" do
        relayable_retraction = FactoryGirl.build(:relayable_retraction_entity)
        retraction = relayable_retraction.to_retraction

        expect(retraction).to be_a(Entities::Retraction)
        expect(retraction.diaspora_id).to eq(relayable_retraction.diaspora_id)
        expect(retraction.target_guid).to eq(relayable_retraction.target_guid)
        expect(retraction.target_type).to eq(relayable_retraction.target_type)
      end
    end
  end
end
