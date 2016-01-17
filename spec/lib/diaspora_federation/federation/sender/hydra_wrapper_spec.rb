module DiasporaFederation
  describe Federation::Sender::HydraWrapper do
    let(:sender_id) { FactoryGirl.generate(:diaspora_id) }
    let(:obj_str) { "status_message@guid" }
    let(:xml) { "<xml>post</xml>" }
    let(:url) { "http://example.org/receive/public" }
    let(:url2) { "http://example.com/receive/public" }

    let(:hydra) { Typhoeus::Hydra.new }
    let(:hydra_wrapper) { Federation::Sender::HydraWrapper.new(sender_id, obj_str) }

    before do
      allow(Typhoeus::Hydra).to receive(:new).and_return(hydra)
    end

    describe "#insert_job" do
      it "queues a request to hydra" do
        expect(hydra).to receive(:queue).with(kind_of(Typhoeus::Request))
        expect(Typhoeus::Request).to receive(:new)
                                       .with(url, Federation::Sender::HydraWrapper.hydra_opts.merge(body: {xml: xml}))
                                       .and_call_original

        hydra_wrapper.insert_job(url, xml)
      end

      it "queues multiple requests to hydra" do
        expect(hydra).to receive(:queue).twice.with(kind_of(Typhoeus::Request))

        hydra_wrapper.insert_job(url, xml)
        hydra_wrapper.insert_job(url2, xml)
      end
    end

    describe "#send" do
      let(:response) {
        Typhoeus::Response.new(
          code:          200,
          body:          "",
          time:          0.2,
          effective_url: url.sub("http://", "https://"),
          return_code:   :ok
        )
      }
      let(:error_response) {
        Typhoeus::Response.new(
          code:          0,
          body:          "",
          time:          0.2,
          effective_url: url2,
          return_code:   :couldnt_resolve_host
        )
      }

      before do
        Typhoeus.stub(url).and_return(response)
        Typhoeus.stub(url2).and_return(error_response)
        hydra_wrapper.insert_job(url, xml)
        hydra_wrapper.insert_job(url2, xml)
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

      it "calls the update_pod callback for all responses with effective_url and success-status" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(:update_pod, "https://example.org/", true)
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(:update_pod, "http://example.com/", false)

        hydra_wrapper.send
      end
    end
  end
end
