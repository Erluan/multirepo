#!/bin/bash

REPO_PATH=$1
shift

if [ -z $REPO_PATH ]; then
  echo "Missing 1st argument: should be path to folder of a git SubRepo";
  exit 1;
fi

git submodule add "$REPO_PATH"
git submodule init

# Now the submodules are in the state you want, so
git commit -am "Adding new SubRepo"

git push
