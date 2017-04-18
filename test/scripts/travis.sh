#!/usr/bin/env bash

set -x

if [[ ${BUNDLE_GEMFILE} =~ .*test/gemfiles/.*.Gemfile ]]; then
  # No coverage for other gemfiles, because some specs are disabled
  export NO_COVERAGE="true"
  bundle exec rake --trace
else
  bundle exec rake --trace
  test_exit_code=$?
  bundle exec codeclimate-test-reporter
  exit $test_exit_code
fi
