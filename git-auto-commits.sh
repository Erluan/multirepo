#!/bin/bash

APP_PATH=$1
shift

if [ -z $APP_PATH ]; then
  echo "Missing 1st argument: should be path to folder of a git repo";
  exit 1;
fi

BRANCH=$1
shift

if [ -z $BRANCH ]; then
  echo "Missing 2nd argument (branch name)";
  exit 1;
fi

echo "Working in: $APP_PATH"
cd $APP_PATH || exit

# Local:
_check_branch=$(git branch --list "${BRANCH}")
# do check Condition_Vars_Must_Be_Not_Empty
if [[ -z ${_check_branch} ]]; then
    echo "local: branch does not exist"
    git checkout -b $BRANCH && git pull --ff origin $BRANCH
else
    echo "local: Good lets continue"
    git checkout $BRANCH
fi

# Remote:
_check_branch=$(git ls-remote --heads origin "${BRANCH}")
# do check Condition_Vars_Must_Be_Not_Empty
if [[ -z ${_check_branch} ]]; then
    echo "remote: branch does not exist"
else
    echo "remote: Good lets continue"
    git checkout $BRANCH
fi

[ -z "$(git ls-remote --heads origin "${BRANCH}")" ] && echo "NULL" || echo "Not NULL"

git submodule sync
git submodule init
git submodule update
git submodule foreach "[ -z $(git ls-remote --heads origin "${BRANCH}") ] && git checkout -b $BRANCH && git push origin $BRANCH || git checkout $BRANCH && git pull --ff origin $BRANCH && git push origin $BRANCH"

for i in $(git submodule foreach --quiet 'echo $path')
do
  echo "Adding $i to root repo"
  git add "$i"
  cd $i || exit
  git add .
  git commit -m ":hammer: adding change"
  git push
  cd ..
done

git add .
git commit -m ":package: Updated $BRANCH branch of deployment repo to point to latest head of submodules"
git push origin $BRANCH