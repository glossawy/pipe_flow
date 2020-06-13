#!/bin/sh
set -euo pipefail

git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"

mkdir -p ./docs/  # In case docs/ is ever deleted for some reason

branch_is_new=true
(
  # Setup git in docs directory
  cd docs
  git init
  git remote add origin https://${GH_TOKEN}@github.com/Glossawy/pipe_flow.git > /dev/null 2>&1
  git fetch >/dev/null
  if git checkout gh-pages 2>/dev/null; then
    branch_is_new=false
    git reset origin/gh-pages --hard >/dev/null
    git fetch >/dev/null
  else
    git checkout -b gh-pages
    touch .nojekyll
  fi
)

# Install and run yard
gem list -i yard >/dev/null 2>&1 || gem install yard
yardoc

cd docs

if ${branch_is_new} || git status --porcelain; then
  # Commit and push updated documentation
  git add ./
  git commit -m "Build ${TRAVIS_BUILD_NUMBER}: Documentation Update"
  git push --quiet --set-upstream origin gh-pages
fi
