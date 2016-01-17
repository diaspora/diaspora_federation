module DiasporaFederation
  describe Federation::Sender do
    let(:sender_id) { FactoryGirl.generate(:diaspora_id) }
    let(:obj_str) { "status_message@guid" }
    let(:hydra_wrapper) { double }

    before do
      expect(Federation::Sender::HydraWrapper).to receive(:new).with(sender_id, obj_str).and_return(hydra_wrapper)
    end

    describe ".public" do
      let(:xml) { "<xml>post</xml>" }
      let(:urls) { ["https://example.org/receive/public", "https://example.com/receive/public"] }

      before do
        expect(hydra_wrapper).to receive(:insert_job).with(urls.at(0), xml)
        expect(hydra_wrapper).to receive(:insert_job).with(urls.at(1), xml)
      end

      it "returns empty array if send was successful" do
        expect(hydra_wrapper).to receive(:send).and_return([])

        expect(Federation::Sender.public(sender_id, obj_str, urls, xml)).to eq([])
      end

      it "returns failing urls array if send was not successful" do
        failing_urls = ["https://example.com/receive/public"]
        expect(hydra_wrapper).to receive(:send).and_return(failing_urls)

        expect(Federation::Sender.public(sender_id, obj_str, urls, xml)).to eq(failing_urls)
      end
    end

    describe ".private" do
      let(:targets) {
        {
          "https://example.org/receive/user/guid" => "<xml>post</xml>",
          "https://example.com/receive/user/guid" => "<xml>post2</xml>"
        }
      }

      before do
        targets.each do |url, xml|
          expect(hydra_wrapper).to receive(:insert_job).with(url, xml)
        end
      end

      it "returns empty array if send was successful" do
        expect(hydra_wrapper).to receive(:send).and_return([])

        expect(Federation::Sender.private(sender_id, obj_str, targets)).to eq({})
      end

      it "returns failing urls array if send was not successful" do
        expect(hydra_wrapper).to receive(:send).and_return(["https://example.com/receive/user/guid"])

        expect(Federation::Sender.private(sender_id, obj_str, targets))
          .to eq("https://example.com/receive/user/guid" => "<xml>post2</xml>")
      end
    end
  end
end
