#!/usr/bin/env bash

set -x

gem install bundler

if [[ ${TRAVIS_RUBY_VERSION} == "2.1" ]]; then
  # use rails 4 for ruby 2.1, because rails 5 needs ruby >= 2.2.2
  echo "gem 'rails', '4.2.7.1'" >> Gemfile
  bundle install --without development --jobs=3 --retry=3
  bundle update rails
fi
