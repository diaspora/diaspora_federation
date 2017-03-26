module DiasporaFederation
  describe Entities::Signable do
    TEST_STRING_VALUE = "abc123".freeze
    let(:private_key) { OpenSSL::PKey::RSA.generate(1024) }
    let(:test_string) { TEST_STRING_VALUE }
    let(:test_signature) { sign_with_key(private_key, test_string) }

    class TestSignableEntity < Entity
      include Entities::Signable

      property :my_signature, :string, default: nil

      def signature_data
        TEST_STRING_VALUE
      end
    end

    describe "#signature_data" do
      it "raises NotImplementedError when not overridden" do
        class TestEntity < Entity
          include Entities::Signable
        end

        expect {
          TestEntity.new({}).signature_data
        }.to raise_error(NotImplementedError)
      end
    end

    describe "#sign_with_key" do
      it "produces a correct signature" do
        signature = TestSignableEntity.new({}).sign_with_key(private_key)
        expect(verify_signature(private_key.public_key, signature, test_string)).to be_truthy
      end
    end

    describe "#verify_signature" do
      it "doesn't raise if signature is correct" do
        expect_callback(:fetch_public_key, "id@example.tld").and_return(private_key.public_key)

        expect {
          TestSignableEntity
            .new(my_signature: test_signature)
            .verify_signature("id@example.tld", :my_signature)
        }.not_to raise_error
      end

      it "raises PublicKeyNotFound when key isn't provided" do
        expect_callback(:fetch_public_key, "id@example.tld").and_return(nil)

        expect {
          TestSignableEntity
            .new(my_signature: test_signature)
            .verify_signature("id@example.tld", :my_signature)
        }.to raise_error(Entities::Signable::PublicKeyNotFound)
      end

      it "raises SignatureVerificationFailed when signature isn't provided" do
        expect_callback(:fetch_public_key, "id@example.tld").and_return(private_key.public_key)

        expect {
          TestSignableEntity.new({}).verify_signature("id@example.tld", :my_signature)
        }.to raise_error(Entities::Signable::SignatureVerificationFailed)
      end

      it "raises SignatureVerificationFailed when signature is wrong" do
        expect_callback(:fetch_public_key, "id@example.tld").and_return(private_key.public_key)

        expect {
          TestSignableEntity
            .new(my_signature: "faked signature")
            .verify_signature("id@example.tld", :my_signature)
        }.to raise_error(Entities::Signable::SignatureVerificationFailed)
      end
    end
  end
end
