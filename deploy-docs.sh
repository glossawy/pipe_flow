#!/bin/bash
set -euo pipefail

debug() { printf "!!! $*\n"; }
pdebug() {
  local prefix pipein
  [[ $# -eq 0 ]] && prefix="" || prefix="$1"
  read pipein

  debug "$prefix$pipein" > /dev/tty
  echo "$pipein"
}

git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"

mkdir -p ./docs/  # In case docs/ is ever deleted for some reason

branch_is_new=true
gh_repo_location=$(git config --get remote.origin.url | cut -d ":" -f2 | pdebug "GH Repo Location: ")

(
  # Setup git in docs directory
  cd docs
  git init
  git remote add origin https://${GH_TOKEN}@github.com/${gh_repo_location} > /dev/null 2>&1
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

$branch_is_new && debug 'Run Type: First Time' || debug 'Run Type: Update'

# Install and run yard
gem list -i yard >/dev/null 2>&1 || gem install yard
yardoc

cd docs

# Only push if this is the first time or there are changes.
changed="$(git status --porcelain)"
if $branch_is_new || [ ! -z "$changed" ]; then
  echo "Changes:"
  echo "$changed"

  # Commit and push updated documentation
  git add ./
  echo "Build ${TRAVIS_BUILD_NUMBER}: Documentation Update" | pdebug 'commit: ' | git commit -F -
  git push --quiet --set-upstream origin gh-pages
else
  echo "No changes; will not push."
fi
