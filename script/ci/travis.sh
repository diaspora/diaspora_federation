#!/bin/sh

command="bundle exec rake --trace ci:travis:run"
exec $command