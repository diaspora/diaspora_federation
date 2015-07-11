# diaspora* federation library

**A library that provides functionalities needed for the diaspora* federation protocol**

[![Build Status](https://travis-ci.org/SuperTux88/diaspora_federation.svg?branch=master)](https://travis-ci.org/SuperTux88/diaspora_federation)
[![Code Climate](https://codeclimate.com/github/SuperTux88/diaspora_federation/badges/gpa.svg)](https://codeclimate.com/github/SuperTux88/diaspora_federation)
[![Test Coverage](https://codeclimate.com/github/SuperTux88/diaspora_federation/badges/coverage.svg)](https://codeclimate.com/github/SuperTux88/diaspora_federation/coverage)
[![Dependency Status](https://gemnasium.com/SuperTux88/diaspora_federation.svg)](https://gemnasium.com/SuperTux88/diaspora_federation)
[![Inline docs](https://inch-ci.org/github/SuperTux88/diaspora_federation.svg?branch=master)](https://inch-ci.org/github/SuperTux88/diaspora_federation)
[![Gem Version](https://badge.fury.io/rb/diaspora_federation.svg)](https://badge.fury.io/rb/diaspora_federation)

[Documentation](http://www.rubydoc.info/gems/diaspora_federation/) |
[Bugtracker](https://github.com/SuperTux88/diaspora_federation/issues)

## Library

The ```diaspora_federation``` gem provides the functionality for de-/serialization and de-/encryption of Entities
in the protocols used for communication among the various installations of Diaspora*

## Rails Engine

The ```diaspora_federation-rails``` gem is a rails engine that adds the diaspora* federation protocol to a rails app.

### Usage

Add the gem to your ```Gemfile```:

```ruby
gem "diaspora_federation-rails"
```

Mount the routes in your ```config/routes.rb```:

```ruby
mount DiasporaFederation::Engine => "/"
```

Configure the engine in ```config/initializers/diaspora_federation.rb```:

```ruby
DiasporaFederation.configure do |config|
  # the pod url
  config.server_uri = AppConfig.pod_uri

  config.define_callbacks do
    on :person_webfinger_fetch do |handle|
      person = Person.find_local_by_diaspora_handle(handle)
      if person
        DiasporaFederation::Discovery::WebFinger.new(
          # ...
        )
      end
    end

    on :person_hcard_fetch do |guid|
      # ...
    end
  end
end
```

## Development

**!!! This gem is currently under heavy development, so every release can contain breaking changes !!!**

If you want to help, please contact me, help is welcome.

After the first stable release, this repo will be moved to the [diaspora organization](https://github.com/diaspora/).

## Diaspora

A privacy-aware, distributed, open source social network

Links:
[Project site](https://diasporafoundation.org) |
[Wiki](https://wiki.diasporafoundation.org)

## License

This gem is published under the terms of the "GNU Affero General Public License". See the LICENSE file for the exact wording.
