#!/usr/bin/env bash

set -x

if [[ ${BUNDLE_GEMFILE} =~ .*test/gemfiles/.*.Gemfile ]]; then
  if [[ ${BUNDLE_GEMFILE} =~ .*/no-rails.Gemfile ]]; then
    if grep activesupport "${BUNDLE_GEMFILE}.lock"; then
      echo "ERROR! no-rails.Gemfile.lock contains rails dependency!"
      exit 1
    fi
  fi

  # No coverage for other gemfiles, because some specs are disabled
  export NO_COVERAGE="true"
  bundle exec rake --trace
else
  bundle exec rake --trace
  test_exit_code=$?
  bundle exec codeclimate-test-reporter
  exit $test_exit_code
fi
