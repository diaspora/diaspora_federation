---
title: WebFinger
---

diaspora\* uses an old draft of [WebFinger][webfinger-draft] to discover users from other pods.

{% include warning_box.html
   title="Old WebFinger"
   content="<p>diaspora* doesn't yet support the RFC 7033 WebFinger!</p>"
%}

## WebFinger endpoint discovery

To find the WebFinger endpoint, the requesting server must get the [host metadata][host-meta] information for the
domain of the searched diaspora\* ID.

### Request

Let's assume we are searching for `alice@example.org`, then we need the host metadata for `example.org`.

The request should first be tried with https, if this doesn't work, the requesting server should fallback to http.

If the server response indicates that the host-meta resource is located elsewhere (a 301, 302, or 307 response status
code), the requesting server should try to obtain the resource from the location provided in the response.

#### Example

~~~
GET /.well-known/host-meta
Host: example.org
~~~

### Response

The host-meta document must be in the [XRD 1.0 document format][xrd] and should be served with the
`application/xrd+xml` media type.

#### Mandatory Link Relations

The Host Metadata response must contain the following link relations:

| Link Relation | Type         | Description                                                               |
| ------------- | ------------ | ------------------------------------------------------------------------- |
| lrdd          | url template | The template to the URL where the server provides the WebFinger endpoint. |

The Host Metadata response may contain other optional link relations.

#### Example

~~~
Status: 200 OK
Content-Type: application/xrd+xml; charset=utf-8
~~~
~~~xml
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Link rel="lrdd" type="application/xrd+xml" template="https://example.org/webfinger?q={uri}"/>
</XRD>
~~~

## WebFinger

### Request

#### Parameters

The requesting server must replace the ``{uri}`` in the lrdd-template from the host-meta request with the diaspora\* ID
of the searched person.

#### Example

~~~
GET /webfinger?q=acct:alice@example.org
Host: example.org
~~~

### Response

The webfinger document must be in the [XRD 1.0 document format][xrd] and should be served with the
`application/xrd+xml` media type.

If the requested diaspora\* ID is unknown by the server, it must return a 404 status code.

#### Subject

The ``Subject`` element should contain the webfinger address that was asked for. If it does not, then this webfinger
profile must be ignored.

#### Mandatory Link Relations

The WebFinger response must contain the following link relations:

| Link Relation                         | Type | Description                            |
| ------------------------------------- | ---- | -------------------------------------- |
| http://microformats.org/profile/hcard | url  | The URL to the person's [hCard][hcard] |
| http://joindiaspora.com/seed_location | url  | The URL to the person's server         |

The WebFinger response may contain other optional link relations.

#### Example

~~~
Status: 200 OK
Content-Type: application/xrd+xml; charset=utf-8
~~~
~~~xml
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Subject>acct:alice@example.org</Subject>
  <Link rel="http://microformats.org/profile/hcard" type="text/html" href="https://example.org/hcard/users/7dba7ca01d64013485eb3131731751e9"/>
  <Link rel="http://joindiaspora.com/seed_location" type="text/html" href="https://example.org/"/>
</XRD>
~~~

## Additional information and specifications

* [RFC 6415: Web Host Metadata][host-meta]
* [WebFinger draft][webfinger-draft]
* [Extensible Resource Descriptor (XRD) Version 1.0][xrd]

[host-meta]: https://tools.ietf.org/html/rfc6415
[webfinger-draft]: https://tools.ietf.org/html/draft-jones-appsawg-webfinger-06
[webfinger-rfc]: https://tools.ietf.org/html/rfc7033
[xrd]: http://docs.oasis-open.org/xri/xrd/v1.0/xrd-1.0.html
[hcard]: {{ site.baseurl }}/discovery/hcard.html
