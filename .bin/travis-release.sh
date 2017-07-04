#!/usr/bin/env bash
set -e

if [ $TRAVIS != "true" ]; then
  echo "deploying only from Travis CI environment."
  exit 0
fi

if [ $TRAVIS_BRANCH != "master" ]; then
  echo "not deploying from $TRAVIS_BRANCH."
  exit 0
fi

git config user.name 'kamataryo@travis'
git config user.email "kamataryo@users.noreply.github.com"
git remote remove origin
git remote add origin git@github.com:kamataryo/eslint-snippets.git
git checkout master

# Auto upgrade
if [ $TRAVIS_EVENT_TYPE == "cron" ]; then
  echo 'Auto-upgrade is performing.'

  yarn upgrade
  npm-check-updates -u

  if [[ $(git --no-pager diff) != "" ]]; then
    git add .
    git commit -m "Upgrade package [made in travis cron]"
    git push origin master
  fi
fi

echo 'publishing...'

git push origin :latest || true
git checkout latest

rm -rf .bin
rm -rf snippets
rm .gitignore
rm .travis_rsa.enc
rm .travis.yml
rm image.gif

apm publish patch
