---
title: AccountMigration
---

This entity is sent when a person changes their diaspora* ID (e.g. when a user migration from one to another pod happens).

## Properties

| Property    | Type                         | Description                                                                          |
| ----------- | ---------------------------- | ------------------------------------------------------------------------------------ |
| `author`    | [diaspora\* ID][diaspora-id] | The diaspora\* ID of the closed account.                                             |
| `person`    | [Profile][profile]           | New profile of a person                                                              |
| `signature` | [Signature][signature]       | Signature that validates original and target diaspora* IDs with the new key of person |

### Signature

The signature base string is produced by concatenating the following substrings together, separated by semicolon (`:`):

1) The entity name specifier: `AccountMigration`.

2) diaspora\* ID of the closed account (old diaspora\* ID).

3) diaspora\* ID of the replacement account (new diaspora\* ID).

Example of a string:

~~~
AccountMigration:old-diaspora-id@example.org:new-diaspora-id@example.com
~~~

## Example

~~~xml
<account_migration>
  <author>alice@example.org</author>
  <profile>
    <author>alice@newpod.example.net</author>
    <first_name>my name</first_name>
    <last_name/>
    <image_url>/assets/user/default.png</image_url>
    <image_url_medium>/assets/user/default.png</image_url_medium>
    <image_url_small>/assets/user/default.png</image_url_small>
    <birthday>1988-07-15</birthday>
    <gender>Female</gender>
    <bio>some text about me</bio>
    <location>github</location>
    <searchable>true</searchable>
    <nsfw>false</nsfw>
    <tag_string>#i #love #tags</tag_string>
  </profile>
  <signature>
    07b1OIY6sTUQwV5pbpgFK0uz6W4cu+oQnlg410Q4uISUOdNOlBdYqhZJm62VFhgvzt4TZXfiJgoupFkRjP0BsaVaZuP2zKMNvO3ngWOeJRf2oRK4Ub5cEA/g7yijkRc+7y8r1iLJ31MFb1czyeCsLxw9Ol8SvAJddogGiLHDhjE=
  </signature>
</account_migration>
~~~

[diaspora-id]: {{ site.baseurl }}/federation/types.html#diaspora-id
[profile]: {{ site.baseurl }}/entities/profile.html
[signature]: {{ site.baseurl }}/federation/types.html#signature
