module DiasporaFederation
  describe Signing do
    let(:privkey) {
      OpenSSL::PKey::RSA.new <<-RSA
-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQDT7vBTAl0Z55bPcBjM9dvSOTuVtBxsgfrw2W0hTAYpd1H5032C
cVW3mqd0l/9BHscgudVFAkvp+nf+wTQILn4qH4YAhOdWgrlSBA6Rbs3cmtmXzGNq
oQr4NOMbqs6sP+bBjDuDdB+cAFms/NDUH3cHBKPXi3e3csxiErmN1zyfWwIDAQAB
AoGAbpBC1CtxgqgtJz8l0ReafIvbJ/h0s68DyU7E/g/5TvyuyZSp77lMrKKEJfF9
+u0hmVMZjgzqqcA/haopiPMoYcJAwwhJLeXAgAWA+8j60Y524WLDcMPwMxQvVFd9
3FYXdOalojDoS34BWeBy6Gt+lLGyDvo/NnJBqIMPN0/KzYECQQDuslE4f1+RHhUq
wf2rL/7gCgrnkDOcH1SPjN2FrKG5ALmjThCq7Wr1Umj81uvmglfpIRY/ORgYgujA
kwNTB1ohAkEA40v0mHaYDegL//jucFmx/iK9Bs/722rJGIXI7bGIwLRC1hW101h3
DLMEMT0QaamVEEnrXFdqhjz+bfYfqUkh+wJAU3a+t8ayIAgo1p6mmKlbsfNRBM+D
fF/oLZnQC+HlWs9KGjQ918bU05tRYre0HRIOs1ICeXD5X/jGci/1xZ6YgQJAJony
Zwd0sKbvoe8rPpF2xIhPVKBfK8znW+kTMHoxnbryuinkMnmFdfnEdDTOW5wNUj22
Umnf/fLJkQtyQtnLkQJBANMoQPrP6aMRh45bhq+y6DbzHHHc2T5cuGBCtnhu+qrK
hWHXqQT4rArfq8YBpvDUa7qD13WwFGK3TPRpQSVGzNg=
-----END RSA PRIVATE KEY-----
RSA
    }

    let(:hash) {
      {
        param1:           "1",
        param2:           "2",
        signature:        "SIGNATURE_VALUE==",
        param3:           "3",
        parent_signature: "SIGNATURE2_VALUE==",
        param4:           "4"
      }
    }
    let(:signature) {
      "OesXlpesuLcA0t8gPyBjvznvkl0pz63p8z6+o2fxFNUaZkuR6YQv/sJOTSMPYBAFwcWr048Ol7yw4jSHq0gFCdBBeF7Mg287jktCie"\
      "xa6G6mA24hBlOWnyRJLV2OyqcTU1P5pXWlUc1Mbwbr6bSIs6VK9djFMLLQ6wjjpusJ0XU="
    }

    describe ".signable_string" do
      it "forms correct string for a hash" do
        expect(Signing.send(:signable_string, hash)).to eq("1;2;3;4")
      end
    end

    describe ".sign_with_key" do
      it "produces correct signature" do
        expect(Signing.sign_with_key(hash, privkey)).to eq(signature)
      end
    end

    describe ".verify_signature" do
      it "verifies correct signature" do
        expect(Signing.verify_signature(hash, signature, privkey.public_key)).to be_truthy
      end

      it "doesn't verify wrong signature" do
        expect(Signing.verify_signature(hash, "false signature==", privkey.public_key)).to be_falsy
      end

      it "doesn't verify when signature is missing" do
        expect(Signing.verify_signature(hash, nil, privkey.public_key)).to be_falsy
      end

      it "doesn't verify when public key is missing" do
        expect(Signing.verify_signature(hash, signature, nil)).to be_falsy
      end
    end
  end
end
