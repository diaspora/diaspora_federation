#!/usr/bin/env bash

set -x

if [[ ${TRAVIS_RUBY_VERSION} == "2.1" ]]; then
  # ruby 2.1
  export NO_COVERAGE="true" # No coverage for rails 4, because controller specs are disabled
  bundle exec rake rails4:test --trace
else
  # ruby >= 2.2
  bundle exec rake --trace
  bundle exec codeclimate-test-reporter
fi
