---
title: Contact
---

This entity represents a contact state with another person.

## Properties

| Property    | Type                         | Description                                         |
| ----------- | ---------------------------- | --------------------------------------------------- |
| `author`    | [diaspora\* ID][diaspora-id] | The diaspora\* ID of the sender of the contact.     |
| `recipient` | [diaspora\* ID][diaspora-id] | The diaspora\* ID of the recipient.                 |
| `following` | [Boolean][boolean]           | `true` if the author is following the recipient.    |
| `sharing`   | [Boolean][boolean]           | `true` if the author is sharing with the recipient. |

## Example

~~~xml
<contact>
  <author>alice@example.org</author>
  <recipient>bob@example.com</recipient>
  <following>true</following>
  <sharing>true</sharing>
</contact>
~~~

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[boolean]: {{ site.baseurl }}/federation/types.html#boolean
