module DiasporaFederation
  describe WebFinger::HCard do
    let(:guid) { "abcdef0123456789" }
    let(:nickname) { "user" }
    let(:first_name) { "Test" }
    let(:last_name)  { "Testington" }
    let(:name) { "#{first_name} #{last_name}" }
    let(:url) { "https://pod.example.tld/users/me" }
    let(:photo_url) { "https://pod.example.tld/uploads/f.jpg" }
    let(:photo_url_m) { "https://pod.example.tld/uploads/m.jpg" }
    let(:photo_url_s) { "https://pod.example.tld/uploads/s.jpg" }
    let(:key) { "-----BEGIN PUBLIC KEY-----\nABCDEF==\n-----END PUBLIC KEY-----" }
    let(:searchable) { true }

    let(:html) {
      <<-HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta charset="UTF-8" />
    <title>#{name}</title>
  </head>
  <body>
    <div id="content">
      <h1>#{name}</h1>
      <div id="content_inner" class="entity_profile vcard author">
        <h2>User profile</h2>
        <dl class="entity_uid">
          <dt>Uid</dt>
          <dd>
            <span class="uid">#{guid}</span>
          </dd>
        </dl>
        <dl class="entity_nickname">
          <dt>Nickname</dt>
          <dd>
            <span class="nickname">#{nickname}</span>
          </dd>
        </dl>
        <dl class="entity_full_name">
          <dt>Full_name</dt>
          <dd>
            <span class="fn">#{name}</span>
          </dd>
        </dl>
        <dl class="entity_searchable">
          <dt>Searchable</dt>
          <dd>
            <span class="searchable">#{searchable}</span>
          </dd>
        </dl>
        <dl class="entity_key">
          <dt>Key</dt>
          <dd>
            <pre class="key">#{key}</pre>
          </dd>
        </dl>
        <dl class="entity_first_name">
          <dt>First_name</dt>
          <dd>
            <span class="given_name">#{first_name}</span>
          </dd>
        </dl>
        <dl class="entity_family_name">
          <dt>Family_name</dt>
          <dd>
            <span class="family_name">#{last_name}</span>
          </dd>
        </dl>
        <dl class="entity_url">
          <dt>Url</dt>
          <dd>
            <a id="pod_location" class="url" rel="me" href="#{url}">#{url}</a>
          </dd>
        </dl>
        <dl class="entity_photo">
          <dt>Photo</dt>
          <dd>
            <img class="photo avatar" width="300" height="300" src="#{photo_url}" />
          </dd>
        </dl>
        <dl class="entity_photo_medium">
          <dt>Photo_medium</dt>
          <dd>
            <img class="photo avatar" width="100" height="100" src="#{photo_url_m}" />
          </dd>
        </dl>
        <dl class="entity_photo_small">
          <dt>Photo_small</dt>
          <dd>
            <img class="photo avatar" width="50" height="50" src="#{photo_url_s}" />
          </dd>
        </dl>
      </div>
    </div>
  </body>
</html>
HTML
    }

    it "must not create blank instances" do
      expect { WebFinger::HCard.new }.to raise_error NameError
    end

    context "generation" do
      it "creates an instance from a data hash" do
        hcard = WebFinger::HCard.from_profile(
          guid:             guid,
          nickname:         nickname,
          full_name:        name,
          url:              url,
          photo_full_url:   photo_url,
          photo_medium_url: photo_url_m,
          photo_small_url:  photo_url_s,
          pubkey:           key,
          searchable:       searchable,
          first_name:       first_name,
          last_name:        last_name
        )
        expect(hcard.to_html).to eq(html)
      end

      it "fails if some params are missing" do
        expect {
          WebFinger::HCard.from_profile(
            guid:     guid,
            nickname: nickname
          )
        }.to raise_error WebFinger::InvalidData
      end

      it "fails if nothing was given" do
        expect { WebFinger::HCard.from_profile({}) }.to raise_error WebFinger::InvalidData
      end

      it "fails if nil was given" do
        expect { WebFinger::HCard.from_profile(nil) }.to raise_error WebFinger::InvalidData
      end
    end

    context "parsing" do
      it "reads its own output" do
        hcard = WebFinger::HCard.from_html(html)
        expect(hcard.guid).to eq(guid)
        expect(hcard.nickname).to eq(nickname)
        expect(hcard.full_name).to eq(name)
        expect(hcard.url).to eq(url)
        expect(hcard.photo_full_url).to eq(photo_url)
        expect(hcard.photo_medium_url).to eq(photo_url_m)
        expect(hcard.photo_small_url).to eq(photo_url_s)
        expect(hcard.pubkey).to eq(key)
        expect(hcard.searchable).to eq(searchable)

        expect(hcard.first_name).to eq(first_name)
        expect(hcard.last_name).to eq(last_name)
      end

      it "searchable is false, if it is empty in html" do
        changed_html = html.sub(
          "class=\"searchable\">#{searchable}<",
          "class=\"searchable\"><"
        )

        hcard = WebFinger::HCard.from_html(changed_html)

        expect(hcard.searchable).to eq(false)
      end

      it "reads old-style HTML" do
        historic_html = <<-HTML
<div id="content">
<h1>#{name}</h1>
<div id="content_inner">
<div class="entity_profile vcard author" id="i">
<h2>User profile</h2>
<dl class="entity_nickname">
<dt>Nickname</dt>
<dd>
<a class="nickname url uid" href="#{url}" rel="me">#{name}</a>
</dd>
</dl>
<dl class="entity_given_name">
<dt>First name</dt>
<dd>
<span class="given_name">#{first_name}</span>
</dd>
</dl>
<dl class="entity_family_name">
<dt>Family name</dt>
<dd>
<span class="family_name">#{last_name}</span>
</dd>
</dl>
<dl class="entity_fn">
<dt>Full name</dt>
<dd>
<span class="fn">#{name}</span>
</dd>
</dl>
<dl class="entity_url">
<dt>URL</dt>
<dd>
<a class="url" href="#{url}" id="pod_location" rel="me">#{url}</a>
</dd>
</dl>
<dl class="entity_photo">
<dt>Photo</dt>
<dd>
<img class="photo avatar" height="300px" src="#{photo_url}" width="300px">
</dd>
</dl>
<dl class="entity_photo_medium">
<dt>Photo</dt>
<dd>
<img class="photo avatar" height="100px" src="#{photo_url_m}" width="100px">
</dd>
</dl>
<dl class="entity_photo_small">
<dt>Photo</dt>
<dd>
<img class="photo avatar" height="50px" src="#{photo_url_s}" width="50px">
</dd>
</dl>
<dl class="entity_searchable">
<dt>Searchable</dt>
<dd>
<span class="searchable">#{searchable}</span>
</dd>
</dl>
</div>
</div>
</div>
HTML

        hcard = WebFinger::HCard.from_html(historic_html)
        expect(hcard.url).to eq(url)
        expect(hcard.photo_full_url).to eq(photo_url)
        expect(hcard.photo_medium_url).to eq(photo_url_m)
        expect(hcard.photo_small_url).to eq(photo_url_s)
        expect(hcard.searchable).to eq(searchable)

        expect(hcard.first_name).to eq(first_name)
        expect(hcard.last_name).to eq(last_name)
      end

      it "fails if the document is incomplete" do
        invalid_html = <<-HTML
<div id="content">
  <span class="fn">#{name}</span>
</div>
HTML
        expect { WebFinger::HCard.from_html(invalid_html) }.to raise_error WebFinger::InvalidData
      end

      it "fails if the document is not HTML" do
        expect { WebFinger::HCard.from_html("") }.to raise_error WebFinger::InvalidData
      end
    end
  end
end
