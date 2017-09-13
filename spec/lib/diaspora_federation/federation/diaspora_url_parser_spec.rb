module DiasporaFederation
  describe Federation::DiasporaUrlParser do
    let(:author) { Fabricate.sequence(:diaspora_id) }
    let(:guid) { Fabricate.sequence(:guid) }

    describe ".fetch_linked_entities" do
      it "parses linked posts from the text" do
        guid2 = Fabricate.sequence(:guid)
        guid3 = Fabricate.sequence(:guid)
        expect_callback(:fetch_related_entity, "Post", guid).and_return(double)
        expect_callback(:fetch_related_entity, "Post", guid2).and_return(double)
        expect_callback(:fetch_related_entity, "Post", guid3).and_return(double)

        text = "This is a [link to a post with markdown](diaspora://#{author}/post/#{guid}) and one without " \
               "diaspora://#{author}/post/#{guid2} and finally a last one diaspora://#{author}/post/#{guid3}."

        Federation::DiasporaUrlParser.fetch_linked_entities(text)
      end

      it "ignores invalid diaspora:// urls" do
        expect(DiasporaFederation.callbacks).not_to receive(:trigger)

        text = "This is an invalid link diaspora://#{author}/Post/#{guid} and another one " \
               "diaspora://#{author}/post/abcd and last one: diaspora://example.org/post/#{guid}."

        Federation::DiasporaUrlParser.fetch_linked_entities(text)
      end

      it "allows to link other entities" do
        expect_callback(:fetch_related_entity, "Event", guid).and_return(double)

        text = "This is a link to an event diaspora://#{author}/event/#{guid}."

        Federation::DiasporaUrlParser.fetch_linked_entities(text)
      end

      it "handles unknown entities gracefully" do
        expect(DiasporaFederation.callbacks).not_to receive(:trigger)

        text = "This is a link to an event diaspora://#{author}/unknown/#{guid}."

        Federation::DiasporaUrlParser.fetch_linked_entities(text)
      end

      it "fetches entities from sender when not found locally" do
        expect_callback(:fetch_related_entity, "Post", guid).and_return(nil)
        expect(Federation::Fetcher).to receive(:fetch_public).with(author, "post", guid)

        text = "This is a link to a post: diaspora://#{author}/post/#{guid}."

        Federation::DiasporaUrlParser.fetch_linked_entities(text)
      end

      it "handles fetch errors gracefully" do
        expect_callback(:fetch_related_entity, "Post", guid).and_return(nil)
        expect(Federation::Fetcher).to receive(:fetch_public).with(
          author, "post", guid
        ).and_raise(Federation::Fetcher::NotFetchable, "Something went wrong!")

        text = "This is a link to a post: diaspora://#{author}/post/#{guid}."

        expect {
          Federation::DiasporaUrlParser.fetch_linked_entities(text)
        }.not_to raise_error
      end
    end
  end
end
