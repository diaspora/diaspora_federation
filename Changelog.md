# 0.1.5

## Refactor

* Use `head` method instead of `:nothing` option [44f6527](https://github.com/diaspora/diaspora_federation/commit/44f6527d64489c212c0f6b050ad343ea0e53e964)
* Add `sender` parameter to `:receive_entity` callback [fb60f83](https://github.com/diaspora/diaspora_federation/commit/fb60f8392698f49b9291f3461e7a68ec84def9e2)

## Bug fixes

* HydraWrapper: Validate hostname after redirect [d18e623](https://github.com/diaspora/diaspora_federation/commit/d18e623082ac620a89e0542ceb97a9f2501c16bf)

# 0.1.4

## Refactor

* Improve magic envelope validation [90d12e7](https://github.com/diaspora/diaspora_federation/commit/90d12e71d00bd4874c09f81cde968360111933f9)
* Raise ValidationError if properties are missing [4295237](https://github.com/diaspora/diaspora_federation/commit/4295237e9e6e8e0ff23a5d8d732654b865f44944)

# 0.1.3

## Refactor

* Improve handling of `xml_order` in relayables [36a787d](https://github.com/diaspora/diaspora_federation/commit/36a787dd87f9770e16fbc1bbc0a6c0d6f059e727) [ba129aa](https://github.com/diaspora/diaspora_federation/commit/ba129aafa38f978f69565d39b7a881a245b03bab) [41de99b](https://github.com/diaspora/diaspora_federation/commit/41de99bd5e4ed2779d574183a58f9ac9550c658a)

# 0.1.2

## Refactor

* Improve code documentation [#38](https://github.com/diaspora/diaspora_federation/pull/38)
* Improve validation [9b32315](https://github.com/diaspora/diaspora_federation/commit/9b3231583d85e6007bf43cedc4480f043c8bde15) [eb8cdef](https://github.com/diaspora/diaspora_federation/commit/eb8cdef604cc8fe71e8455f36a317d80657f1582) [0980294](https://github.com/diaspora/diaspora_federation/commit/0980294a0d259cba1fa2a2a655163b3fa844d239)
* Photo: `status_message_guid` is optional [4136fb9](https://github.com/diaspora/diaspora_federation/commit/4136fb973e7ad27158ef605df12727f4e959c3a3)
* A GUID is at most 255 chars long [f7d269c](https://github.com/diaspora/diaspora_federation/commit/f7d269cd6a4c1b48a7b34083f5fea04ac0835a48)
* hCard: `nickname` is optional [4b94949](https://github.com/diaspora/diaspora_federation/commit/4b949491df3a16b30f6e27113d6fa95c165c1edc)
* StatusMessage: Rename `raw_message` to `text` [2aaff56](https://github.com/diaspora/diaspora_federation/commit/2aaff56e147b505626a615d60564fbbf22c2f452) [#29](https://github.com/diaspora/diaspora_federation/issues/29)

## Bug fixes

* Do not reuse cURL sockets to avoid issues caused by too many simultaneous connections [#37](https://github.com/diaspora/diaspora_federation/pull/37)
* Handle empty xml-elements for nested entities [26b7991](https://github.com/diaspora/diaspora_federation/commit/26b7991defe1d84d10c1186a151676076946b26f)
* Gracefully handle missing xml elements of relayables [9097097](https://github.com/diaspora/diaspora_federation/commit/90970973a58cbc3d897d21a43c0a6c93a30605be)

# 0.1.1

## Features

* Fetch root posts for reshares [9b090a3](https://github.com/diaspora/diaspora_federation/commit/9b090a39501705f00403f124e215e78866039f1e)

# 0.1.0

## Features

* Added Salmon support
