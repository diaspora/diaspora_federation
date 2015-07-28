shared_examples "an Entity subclass" do
  it "should be an Entity" do
    expect(klass).to be < DiasporaFederation::Entity
  end

  it "has its properties set" do
    expect(klass.class_prop_names).to include(*data.keys)
  end

  context "behaviour" do
    let(:instance) { klass.new(data) }

    describe "initialize" do
      it "must not create blank instances" do
        expect { klass.new({}) }.to raise_error ArgumentError
      end

      it "fails if nil was given" do
        expect { klass.new(nil) }.to raise_error ArgumentError, "expected a Hash"
      end

      it "should be frozen" do
        expect(instance).to be_frozen
      end
    end

    describe "#to_h" do
      it "should resemble the input data" do
        expect(instance.to_h).to eq(data)
      end
    end
  end
end
