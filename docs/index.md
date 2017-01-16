---
---

{% include warning_box.html
   title="Future federation protocol"
   content="<p>This document provides the documentation for the future federation protocol for diaspora*. Current diaspora* servers still use an older protocol!</p>"
%}

# diaspora\* federation protocol

The purpose of this document is to specify the communications that go on between diaspora\* servers (and other servers
supporting this protocol). If you experience any issues, feel free to [get in touch][communication] with us.

## Federation support

This document specifies the future protocol for diaspora. diaspora\* release 0.6.0.0 and newer has support to receive
[entities][entities] with this protocol, but still sends entities with an older protocol. Starting with diaspora\*
release X this protocol is fully supported.

## Implementations

An implementation of this protocol is available as a Ruby Gem under the AGPL [on Github][github]. This is the library used by the diaspora* project.

The [Friendica][friendica] project also has [its implementation in PHP][phpimplementation].

[communication]: https://wiki.diasporafoundation.org/How_we_communicate
[entities]: {{ site.baseurl }}/entities/
[github]: https://github.com/diaspora/diaspora_federation
[friendica]: https://github.com/friendica/friendica
[phpimplementation]: https://github.com/friendica/friendica/blob/master/include/diaspora.php
