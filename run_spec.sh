#!/usr/bin/env bash

set -e

rubies=()
versions=false
while read -r line; do
  if [[ $line == "rvm:" ]]
  then
    versions=true
  elif $versions && [[ $line == -* ]]
  then
    rubies+=(${line:2})
  elif [[ ${line:0:1} != "#" ]]
  then
    versions=false
  fi
done < ".travis.yml"

for i in "${rubies[@]}"
do
  echo "====================================================="
  echo "$i: Start Test"
  echo "====================================================="
  rvm $i exec bundle exec appraisal rake spec
  echo "====================================================="
  echo "$i: End Test"
  echo "====================================================="
done
