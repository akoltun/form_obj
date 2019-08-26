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
  echo "Install Ruby $i"
  echo "====================================================="
  rvm install $i
done

rvm all do gem install bundler -v '<2'
