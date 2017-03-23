shared_examples ".parse parse error" do |reason, json|
  it "raises error when #{reason}" do
    expect {
      json_parser.parse(JSON.parse(json))
    }.to raise_error DiasporaFederation::Parsers::JsonParser::DeserializationError, reason
  end
end
