---
title: Relayable
---

If a person participates on an entity, it needs to be relayed via the author of the parent entity, because only the
parent author knows, to whom they shared the original entity.

Such entities are:

* [Comment][comment]
* [Like][like]
* [PollParticipation][poll_participation]

## Common Properties

All relayables have the following properties:

| Property                  | Type                         | Description                                       |
| ------------------------- | ---------------------------- | ------------------------------------------------- |
| `author`                  | [diaspora\* ID][diaspora-id] | The diaspora\* ID of the author of the relayable. |
| `guid`                    | [GUID][guid]                 | The GUID of the relayable.                        |
| `parent_guid`             | [GUID][guid]                 | The GUID of the parent entity.                    |
| `author_signature`        | [Signature][signature]       | The signature from the author of the relayable.   |
| `parent_author_signature` | [Signature][signature]       | The signature from the parent entity author.      |

## Relaying

The author of the relayable sends the entity to the parent author. The author must include the `author_signature`. The
`parent_author_signature` may be empty or missing.

The parent author then must add the `parent_author_signature` and send the entity to all the recipients of the parent
entity.

If someone other then the parent author receives an relayable without a valid `parent_author_signature`, it must be
ignored. If the `author_signature` is missing or invalid, it also must be ignored.

## Signatures

The string to sign is built with the content of all properties (except the `author_signature` and
`parent_author_signature` itself), concatenated using `;` as separator in the same order as they appear in the XML. The
order in the XML is not specified.

This ensures that relayables even work, if the parent author or another recipient does not know all properties of the
relayable entity (e.g. older version of diaspora\*).

This string is then signed with the private RSA key using the RSA-SHA256 algorithm and base64-encoded.

The parent author must use the same order as the relayable author. Unknown properties must be included again in the XML
and the signature.

To support fetching of the relayables, the parent author should save the following information:

* order of the received XML
* additional (unknown) properties
* `author_signature`

## Retraction / Reject

The parent author is allowed to retract the entity, so there are no additional signatures required for the
[Retraction][retraction] (only the [Salmon Magic Signature][magicsig]).

If the author retracts the entity, they send a [Retraction][retraction] to the parent author. The parent author also
must relay this retraction to all recipients of the parent entity.

If the parent author wants to reject the entity (e.g. if they ignore the author of the relayable), they can simply send
a [Retraction][retraction] for it back to the author.


[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[guid]: {{ site.baseurl }}/federation/types.html#guid
[signature]: {{ site.baseurl }}/federation/types.html#signature
[comment]: {{ site.baseurl }}/entities/comment.html
[like]: {{ site.baseurl }}/entities/like.html
[poll_participation]: {{ site.baseurl }}/entities/poll_participation.html
[retraction]: {{ site.baseurl }}/entities/retraction.html
[magicsig]: {{ site.baseurl }}/federation/magicsig.html
