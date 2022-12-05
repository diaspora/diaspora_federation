# frozen_string_literal: true

module DiasporaFederation
  describe Federation::Sender::HydraWrapper do
    let(:sender_id) { Fabricate.sequence(:diaspora_id) }
    let(:obj_str) { "status_message@guid" }
    let(:xml) { "<xml>post</xml>" }
    let(:json) { "{\"aes_key\": \"...\", \"encrypted_magic_envelope\": \"...\"}" }
    let(:url) { "https://example.org/receive/public" }
    let(:url2) { "https://example.com/receive/public" }

    let(:hydra) { Typhoeus::Hydra.new }
    let(:hydra_wrapper) { Federation::Sender::HydraWrapper.new(sender_id, obj_str) }

    before do
      allow(Typhoeus::Hydra).to receive(:new).and_return(hydra)
    end

    describe "#insert_magic_env_request" do
      it "queues a request to hydra" do
        expect(hydra).to receive(:queue).with(kind_of(Typhoeus::Request))
        expect(Typhoeus::Request).to receive(:new).with(
          url,
          Federation::Sender::HydraWrapper.hydra_opts.merge(
            body: xml, headers: Federation::Sender::HydraWrapper.xml_headers
          )
        ).and_call_original

        hydra_wrapper.insert_magic_env_request(url, xml)
      end

      it "queues multiple requests to hydra" do
        expect(hydra).to receive(:queue).twice.with(kind_of(Typhoeus::Request))

        hydra_wrapper.insert_magic_env_request(url, xml)
        hydra_wrapper.insert_magic_env_request(url2, xml)
      end
    end

    describe "#insert_enc_magic_env_request" do
      it "queues a request to hydra" do
        expect(hydra).to receive(:queue).with(kind_of(Typhoeus::Request))
        expect(Typhoeus::Request).to receive(:new).with(
          url,
          Federation::Sender::HydraWrapper.hydra_opts.merge(
            body: json, headers: Federation::Sender::HydraWrapper.json_headers
          )
        ).and_call_original

        hydra_wrapper.insert_enc_magic_env_request(url, json)
      end

      it "queues multiple requests to hydra" do
        expect(hydra).to receive(:queue).twice.with(kind_of(Typhoeus::Request))

        hydra_wrapper.insert_enc_magic_env_request(url, json)
        hydra_wrapper.insert_enc_magic_env_request(url2, json)
      end
    end

    describe "#send" do
      let(:response) {
        Typhoeus::Response.new(
          code:        202,
          body:        "",
          time:        0.2,
          return_code: :ok
        )
      }
      let(:error_response) {
        Typhoeus::Response.new(
          code:        0,
          body:        "",
          time:        0.2,
          return_code: :couldnt_resolve_host
        )
      }

      before do
        Typhoeus.stub(url).and_return(response)
        Typhoeus.stub(url2).and_return(error_response)
        hydra_wrapper.insert_magic_env_request(url, xml)
        hydra_wrapper.insert_magic_env_request(url2, xml)
      end
      before :all do
        WebMock::HttpLibAdapters::TyphoeusAdapter.disable!
      end
      after :all do
        WebMock::HttpLibAdapters::TyphoeusAdapter.enable!
      end

      it "returns all failed urls" do
        expect(hydra_wrapper.send).to eq([url2])
      end

      it "calls the update_pod callback for all responses with effective_url and status" do
        expect_callback(:update_pod, url, 202)
        expect_callback(:update_pod, url2, :couldnt_resolve_host)

        hydra_wrapper.send
      end

      it "calls the update_pod callback with http status code when there was no error" do
        not_found_url = "https://example.net/receive/not_found"

        expect_callback(:update_pod, url, 202)
        expect_callback(:update_pod, not_found_url, 404)
        allow(DiasporaFederation.callbacks).to receive(:trigger)

        not_found = Typhoeus::Response.new(
          code:        404,
          body:        "",
          time:        0.2,
          return_code: :ok
        )
        Typhoeus.stub(not_found_url).and_return(not_found)
        hydra_wrapper.insert_magic_env_request(not_found_url, xml)

        hydra_wrapper.send
      end
    end
  end
end
