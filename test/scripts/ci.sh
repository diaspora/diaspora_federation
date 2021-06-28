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
  if [[ -n ${CC_TEST_REPORTER_ID} ]]; then
    curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./cc-test-reporter
    chmod +x ./cc-test-reporter
    ./cc-test-reporter before-build
  fi

  bundle exec rake --trace
  test_exit_code=$?

  if [[ -n ${CC_TEST_REPORTER_ID} ]]; then
    ./cc-test-reporter after-build --exit-code ${test_exit_code}
  fi

  exit ${test_exit_code}
fi
