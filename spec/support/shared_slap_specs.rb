shared_examples "a Slap instance" do
  it "should match the author_id" do
    expect(subject.author_id).to eq(author_id)
  end

  context "#entity" do
    it "requires the pubkey for the first time (to verify the signature)" do
      expect { subject.entity }.to raise_error ArgumentError
    end

    it "works when the pubkey is given" do
      expect {
        subject.entity(privkey.public_key)
      }.not_to raise_error
    end

    it "returns the entity" do
      entity = subject.entity(privkey.public_key)
      expect(entity).to be_an_instance_of DiasporaFederation::Entities::TestEntity
      expect(entity.test).to eq("qwertzuiop")
    end
  end
end
