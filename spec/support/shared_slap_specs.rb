shared_examples "a Slap instance" do
  it "should match the author_id" do
    expect(subject.author_id).to eq(author_id)
  end

  context "#entity" do
    it "returns the entity" do
      allow(DiasporaFederation.callbacks).to receive(:trigger).with(
        :fetch_public_key_by_diaspora_id, author_id
      ).and_return(privkey.public_key)

      entity = subject.entity
      expect(entity).to be_an_instance_of DiasporaFederation::Entities::TestEntity
      expect(entity.test).to eq("qwertzuiop")
    end
  end
end
