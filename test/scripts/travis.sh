#!/usr/bin/env bash

set -x

if [[ ${TRAVIS_RUBY_VERSION} == "2.1" ]]; then
  # ruby 2.1
  export NO_COVERAGE="true" # No coverage for rails 4, because controller specs are disabled
  bundle exec rake --trace
else
  # ruby >= 2.2
  bundle exec rake --trace
  test_exit_code=$?
  bundle exec codeclimate-test-reporter
  exit $test_exit_code
fi
