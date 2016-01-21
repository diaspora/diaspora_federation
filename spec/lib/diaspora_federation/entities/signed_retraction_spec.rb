module DiasporaFederation
  describe Entities::SignedRetraction do
    let(:data) { Test.attributes_with_signatures(:signed_retraction_entity) }

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

    describe "#to_signed_h" do
      let(:author_pkey) { OpenSSL::PKey::RSA.generate(1024) }
      let(:hash) { FactoryGirl.attributes_for(:signed_retraction_entity) }

      it "updates author signature when it was nil and key was supplied" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, hash[:diaspora_id]
        ).and_return(author_pkey)

        signable_hash = hash.select do |key, _|
          %i(target_guid target_type).include?(key)
        end

        signed_hash = Entities::SignedRetraction.new(hash).to_signed_h

        expect(Signing.verify_signature(signable_hash, signed_hash[:target_author_signature], author_pkey)).to be_truthy
      end

      it "doesn't change signature if it is already set" do
        hash[:target_author_signature] = "aa"

        expect(Entities::SignedRetraction.new(hash).to_signed_h).to eq(hash)
      end

      it "doesn't change signature if a key wasn't supplied" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, hash[:diaspora_id]
        ).and_return(nil)

        signed_hash = Entities::SignedRetraction.new(hash).to_signed_h
        expect(signed_hash[:author_signature]).to eq(nil)
      end
    end
  end
end
