module DiasporaFederation
  describe Entities::AccountMigration do
    let(:new_diaspora_id) { alice.diaspora_id }
    let(:new_author_pkey) { alice.private_key }
    let(:hash) {
      Fabricate.attributes_for(:account_deletion_entity).merge(
        profile: Fabricate(:profile_entity, author: new_diaspora_id)
      )
    }
    let(:data) {
      hash.tap {|hash|
        properties = described_class.new(hash).send(:enriched_properties)
        hash[:signature] = properties[:signature]
      }
    }
    let(:signature_data) { "AccountMigration:#{hash[:author]}:#{new_diaspora_id}" }

    let(:xml) { <<-XML }
<account_migration>
  <author>#{data[:author]}</author>
  <profile>
    <author>#{data[:profile].author}</author>
    <first_name>#{data[:profile].first_name}</first_name>
    <image_url>#{data[:profile].image_url}</image_url>
    <image_url_medium>#{data[:profile].image_url}</image_url_medium>
    <image_url_small>#{data[:profile].image_url}</image_url_small>
    <birthday>#{data[:profile].birthday}</birthday>
    <gender>#{data[:profile].gender}</gender>
    <bio>#{data[:profile].bio}</bio>
    <location>#{data[:profile].location}</location>
    <searchable>#{data[:profile].searchable}</searchable>
    <public>#{data[:profile].public}</public>
    <nsfw>#{data[:profile].nsfw}</nsfw>
    <tag_string>#{data[:profile].tag_string}</tag_string>
  </profile>
  <signature>#{data[:signature]}</signature>
</account_migration>
XML

    let(:string) { "AccountMigration:#{data[:author]}:#{data[:profile].author}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    describe "#to_xml" do
      it "computes signature when no signature was provided" do
        expect_callback(:fetch_private_key, new_diaspora_id).and_return(new_author_pkey)

        entity = Entities::AccountMigration.new(hash)
        xml = entity.to_xml

        signature = xml.at_xpath("signature").text
        expect(verify_signature(new_author_pkey, signature, entity.to_s)).to be_truthy
      end

      it "doesn't change signature if it is already set" do
        hash[:signature] = "aa"

        xml = Entities::AccountMigration.new(hash).to_xml

        expect(xml.at_xpath("signature").text).to eq("aa")
      end

      it "raises when signature isn't set and key isn't supplied" do
        expect_callback(:fetch_private_key, new_diaspora_id).and_return(nil)

        expect {
          Entities::AccountMigration.new(hash).to_xml
        }.to raise_error Entities::AccountMigration::NewPrivateKeyNotFound
      end
    end

    describe "#verify_signature" do
      it "doesn't raise anything if correct signatures were passed" do
        hash[:signature] = sign_with_key(new_author_pkey, signature_data)
        expect_callback(:fetch_public_key, new_diaspora_id).and_return(new_author_pkey)
        expect { Entities::AccountMigration.new(hash).verify_signature }.not_to raise_error
      end

      it "raises when no public key for author was fetched" do
        expect_callback(:fetch_public_key, anything).and_return(nil)

        expect {
          Entities::AccountMigration.new(hash).verify_signature
        }.to raise_error Entities::AccountMigration::PublicKeyNotFound
      end

      it "raises when bad author signature was passed" do
        hash[:signature] = "abcdef"

        expect_callback(:fetch_public_key, new_diaspora_id).and_return(new_author_pkey.public_key)

        expect {
          Entities::AccountMigration.new(hash).verify_signature
        }.to raise_error Entities::AccountMigration::SignatureVerificationFailed
      end
    end

    describe ".from_hash" do
      it "calls #verify_signature" do
        expect_any_instance_of(Entities::AccountMigration).to receive(:freeze)
        expect_any_instance_of(Entities::AccountMigration).to receive(:verify_signature)
        Entities::AccountMigration.from_hash(hash)
      end

      it "raises when bad author signature was passed" do
        hash[:signature] = "abcdef"

        expect_callback(:fetch_public_key, new_diaspora_id).and_return(new_author_pkey.public_key)

        expect {
          Entities::AccountMigration.from_hash(hash)
        }.to raise_error Entities::AccountMigration::SignatureVerificationFailed
      end
    end
  end
end
