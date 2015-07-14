module DiasporaFederation
  describe Discovery::HCard do
    let(:person) { FactoryGirl.create(:person) }
    let(:photo_large_url) { "#{person.url}/upload/large.png" }
    let(:photo_medium_url) { "#{person.url}/upload/medium.png" }
    let(:photo_small_url) { "#{person.url}/upload/small.png" }

    let(:html) {
      <<-HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta charset="UTF-8" />
    <title>#{person.full_name}</title>
  </head>
  <body>
    <div id="content">
      <h1>#{person.full_name}</h1>
      <div id="content_inner" class="entity_profile vcard author">
        <h2>User profile</h2>
        <dl class="entity_uid">
          <dt>Uid</dt>
          <dd>
            <span class="uid">#{person.guid}</span>
          </dd>
        </dl>
        <dl class="entity_nickname">
          <dt>Nickname</dt>
          <dd>
            <span class="nickname">#{person.nickname}</span>
          </dd>
        </dl>
        <dl class="entity_full_name">
          <dt>Full_name</dt>
          <dd>
            <span class="fn">#{person.full_name}</span>
          </dd>
        </dl>
        <dl class="entity_searchable">
          <dt>Searchable</dt>
          <dd>
            <span class="searchable">#{person.searchable}</span>
          </dd>
        </dl>
        <dl class="entity_key">
          <dt>Key</dt>
          <dd>
            <pre class="key">#{person.serialized_public_key}</pre>
          </dd>
        </dl>
        <dl class="entity_first_name">
          <dt>First_name</dt>
          <dd>
            <span class="given_name">#{person.first_name}</span>
          </dd>
        </dl>
        <dl class="entity_family_name">
          <dt>Family_name</dt>
          <dd>
            <span class="family_name">#{person.last_name}</span>
          </dd>
        </dl>
        <dl class="entity_url">
          <dt>Url</dt>
          <dd>
            <a id="pod_location" class="url" rel="me" href="#{person.url}">#{person.url}</a>
          </dd>
        </dl>
        <dl class="entity_photo">
          <dt>Photo</dt>
          <dd>
            <img class="photo avatar" width="300" height="300" src="#{photo_large_url}" />
          </dd>
        </dl>
        <dl class="entity_photo_medium">
          <dt>Photo_medium</dt>
          <dd>
            <img class="photo avatar" width="100" height="100" src="#{photo_medium_url}" />
          </dd>
        </dl>
        <dl class="entity_photo_small">
          <dt>Photo_small</dt>
          <dd>
            <img class="photo avatar" width="50" height="50" src="#{photo_small_url}" />
          </dd>
        </dl>
      </div>
    </div>
  </body>
</html>
HTML
    }

    it "must not create blank instances" do
      expect { Discovery::HCard.new({}) }.to raise_error ArgumentError
    end

    context "generation" do
      it "creates an instance from a data hash" do
        hcard = Discovery::HCard.new(
          guid:             person.guid,
          nickname:         person.nickname,
          full_name:        person.full_name,
          url:              person.url,
          photo_large_url:  photo_large_url,
          photo_medium_url: photo_medium_url,
          photo_small_url:  photo_small_url,
          public_key:       person.serialized_public_key,
          searchable:       person.searchable,
          first_name:       person.first_name,
          last_name:        person.last_name
        )
        expect(hcard.to_html).to eq(html)
      end

      it "fails if nil was given" do
        expect { Discovery::HCard.new(nil) }.to raise_error ArgumentError, "expected a Hash"
      end
    end

    context "parsing" do
      it "reads its own output" do
        hcard = Discovery::HCard.from_html(html)
        expect(hcard.guid).to eq(person.guid)
        expect(hcard.nickname).to eq(person.nickname)
        expect(hcard.full_name).to eq(person.full_name)
        expect(hcard.url).to eq(person.url)
        expect(hcard.photo_large_url).to eq(photo_large_url)
        expect(hcard.photo_medium_url).to eq(photo_medium_url)
        expect(hcard.photo_small_url).to eq(photo_small_url)
        expect(hcard.public_key).to eq(person.serialized_public_key)
        expect(hcard.searchable).to eq(person.searchable)

        expect(hcard.first_name).to eq(person.first_name)
        expect(hcard.last_name).to eq(person.last_name)
      end

      it "is frozen after parsing" do
        hcard = Discovery::HCard.from_html(html)
        expect(hcard).to be_frozen
      end

      it "searchable is false, if it is empty in html" do
        changed_html = html.sub(
          "class=\"searchable\">#{person.searchable}<",
          "class=\"searchable\"><"
        )

        hcard = Discovery::HCard.from_html(changed_html)

        expect(hcard.searchable).to eq(false)
      end

      it "name is nil if empty" do
        changed_html = html.sub(
          "class=\"fn\">#{person.full_name}<",
          "class=\"fn\"><"
        ).sub(
          "class=\"given_name\">#{person.first_name}<",
          "class=\"given_name\"><"
        ).sub(
          "class=\"family_name\">#{person.last_name}<",
          "class=\"family_name\"><"
        )

        hcard = Discovery::HCard.from_html(changed_html)

        expect(hcard.full_name).to be_nil
        expect(hcard.first_name).to be_nil
        expect(hcard.last_name).to be_nil
      end

      it "reads old-style HTML" do
        historic_html = <<-HTML
<div id="content">
<h1>#{person.full_name}</h1>
<div id="content_inner">
<div class="entity_profile vcard author" id="i">
<h2>User profile</h2>
<dl class="entity_nickname">
<dt>Nickname</dt>
<dd>
<a class="nickname url uid" href="#{person.url}" rel="me">#{person.full_name}</a>
</dd>
</dl>
<dl class="entity_given_name">
<dt>First name</dt>
<dd>
<span class="given_name">#{person.first_name}</span>
</dd>
</dl>
<dl class="entity_family_name">
<dt>Family name</dt>
<dd>
<span class="family_name">#{person.last_name}</span>
</dd>
</dl>
<dl class="entity_fn">
<dt>Full name</dt>
<dd>
<span class="fn">#{person.full_name}</span>
</dd>
</dl>
<dl class="entity_url">
<dt>URL</dt>
<dd>
<a class="url" href="#{person.url}" id="pod_location" rel="me">#{person.url}</a>
</dd>
</dl>
<dl class="entity_photo">
<dt>Photo</dt>
<dd>
<img class="photo avatar" height="300px" src="#{photo_large_url}" width="300px">
</dd>
</dl>
<dl class="entity_photo_medium">
<dt>Photo</dt>
<dd>
<img class="photo avatar" height="100px" src="#{photo_medium_url}" width="100px">
</dd>
</dl>
<dl class="entity_photo_small">
<dt>Photo</dt>
<dd>
<img class="photo avatar" height="50px" src="#{photo_small_url}" width="50px">
</dd>
</dl>
<dl class="entity_searchable">
<dt>Searchable</dt>
<dd>
<span class="searchable">#{person.searchable}</span>
</dd>
</dl>
</div>
</div>
</div>
HTML

        hcard = Discovery::HCard.from_html(historic_html)
        expect(hcard.url).to eq(person.url)
        expect(hcard.photo_large_url).to eq(photo_large_url)
        expect(hcard.photo_medium_url).to eq(photo_medium_url)
        expect(hcard.photo_small_url).to eq(photo_small_url)
        expect(hcard.searchable).to eq(person.searchable)

        expect(hcard.first_name).to eq(person.first_name)
        expect(hcard.last_name).to eq(person.last_name)

        expect(hcard.guid).to be_nil
        expect(hcard.public_key).to be_nil
      end

      it "fails if the document is incomplete" do
        invalid_html = <<-HTML
<div id="content">
  <span class="fn">#{person.full_name}</span>
</div>
HTML
        expect { Discovery::HCard.from_html(invalid_html) }.to raise_error Discovery::InvalidData
      end

      it "fails if the document is not HTML" do
        expect { Discovery::HCard.from_html("") }.to raise_error Discovery::InvalidData
      end
    end
  end
end
