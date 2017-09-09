---
title: diaspora:// URI scheme
---

## Server and software independent links

A `diaspora://` URL is used if a user wants to link to another post. It doesn't
contain a server hostname so it is independent of the senders server. And it
isn't software specific, it is thought to be compatible with every software
that is compatible with the protocol, so the receiving software can display
it as software specific URL. 

The format is similar to the route used for [fetching][fetching], so if the
receiving server doesn't know the linked entity yet, it can just be fetched.

### Format

`diaspora://:type/:guid`

#### Parameters

| Name   | Description                                    |
| ------ | ---------------------------------------------- |
| `type` | The type of the linked entity in `snake_case`. |
| `guid` | The [GUID][guid] of the linked entity.         |

#### Example

`diaspora://post/17faf230675101350d995254001bd39e`

[fetching]: {{ site.baseurl }}/federation/fetching.html
[guid]: {{ site.baseurl }}/federation/types.html#guid
