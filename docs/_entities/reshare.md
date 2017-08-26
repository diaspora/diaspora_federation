---
title: Reshare
---

This entity represents a reshare of a [StatusMessage][status_message]. It inherits from [Post][post].

The recipient must [fetch][fetching] the root from `root_author` if the post is not already known.
When the `root_guid` is already available locally, the recipient must validate that it's from `root_author`.

A special case when the entity doesn't include `root_author` and `root_guid` is allowed. This case represents
a reshare for a deleted post. If there is only one of `root_author` and `root_guid` is present, then the entity
is not valid.

## Properties

| Property      | Type                         | Description                                                   |
| ------------- | ---------------------------- | ------------------------------------------------------------- |
| `author`      | [diaspora\* ID][diaspora-id] | The diaspora\* ID of the author of the reshare.               |
| `guid`        | [GUID][guid]                 | The GUID of the reshare.                                      |
| `created_at`  | [Timestamp][timestamp]       | The create timestamp of the reshare.                          |
| `root_author` | [diaspora\* ID][diaspora-id] | The diaspora\* ID of the author of the reshared [Post][post]. |
| `root_guid`   | [GUID][guid]                 | The GUID of the reshared [Post][post].                        |

## Optional Properties

| Property                | Type (Length)          | Description                                                                                |
| ----------------------- | ---------------------- | ------------------------------------------------------------------------------------------ |
| `provider_display_name` | [String][string] (255) | The means by which the author has posted the reshare.                                      |
| `public`                | [Boolean][boolean]     | `false` if the reshare is not public (diaspora\* currenlty only supports public reshares). |

## Example

~~~xml
<reshare>
  <author>alice@example.org</author>
  <guid>a0b53e5029f6013487753131731751e9</guid>
  <created_at>2016-07-12T00:36:42Z</created_at>
  <provider_display_name/>
  <root_author>bob@example.com</root_author>
  <root_guid>a0b53bc029f6013487753131731751e9</root_guid>
  <public>true</public>
</reshare>
~~~

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[guid]: {{ site.baseurl }}/federation/types.html#guid
[timestamp]: {{ site.baseurl }}/federation/types.html#timestamp
[string]: {{ site.baseurl }}/federation/types.html#string
[boolean]: {{ site.baseurl }}/federation/types.html#boolean
[fetching]: {{ site.baseurl }}/federation/fetching.html
[post]: {{ site.baseurl }}/entities/post.html
[status_message]: {{ site.baseurl }}/entities/status_message.html
