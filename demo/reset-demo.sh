#!/usr/bin/env bash
#
# The opposite of demo/introduce-issue.sh: puts the repository back to the
# state where the demo can be run again.
#
# Merging the demo pull request leaves StockKeepingUnit on the base branch, and
# introduce-issue.sh refuses to run while it is there. This script removes both
# demo files on a fresh branch and deletes the leftover local demo branch.
#
# The base branch is protected, so this script does not push. It prepares the
# commit and prints the push / pull request / merge commands.
#
# Usage: demo/reset-demo.sh [reset-branch-name]
#        DEMO_BRANCH=demo/other demo/reset-demo.sh
#
set -euo pipefail

RESET_BRANCH="${1:-chore/reset-demo}"
DEMO_BRANCH="${DEMO_BRANCH:-demo/missing-hashcode}"

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

MAIN_SRC="src/main/java/com/example/demo/StockKeepingUnit.java"
TEST_SRC="src/test/java/com/example/demo/StockKeepingUnitTest.java"

# Base branch: whatever origin's HEAD points at, else master.
BASE="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')"
BASE="${BASE:-master}"

if [ -n "$(git status --porcelain)" ]; then
  echo "error: working tree has uncommitted changes - commit or stash them first." >&2
  exit 1
fi

if git show-ref --quiet --verify "refs/heads/$RESET_BRANCH"; then
  echo "error: branch '$RESET_BRANCH' already exists - delete it or pass another name." >&2
  exit 1
fi

git switch "$BASE"
git pull --ff-only || echo "warning: could not fast-forward $BASE; using local state" >&2

# --- 1. remove the demo files, if the pull request was merged -----------------

if [ -e "$MAIN_SRC" ] || [ -e "$TEST_SRC" ]; then
  git switch --create "$RESET_BRANCH"
  git rm --quiet -- "$MAIN_SRC" "$TEST_SRC"
  git commit --quiet --message "Reset demo: remove StockKeepingUnit

Removes the files added by demo/introduce-issue.sh so the demo can be run
again. Reverses the merged demo pull request; no other code is affected." \
    --message "The class and its tests are regenerated from demo/templates/ on
the next run."
  REMOVED=yes
  echo
  echo "Removed on branch '$RESET_BRANCH':"
  echo "  $MAIN_SRC"
  echo "  $TEST_SRC"
else
  REMOVED=no
  echo
  echo "$BASE is already clean - the demo pull request was not merged."
fi

# --- 2. drop the leftover local demo branch -----------------------------------

if git show-ref --quiet --verify "refs/heads/$DEMO_BRANCH"; then
  DEMO_SHA="$(git rev-parse --short "$DEMO_BRANCH")"
  git branch -D "$DEMO_BRANCH" >/dev/null
  echo "Deleted local branch '$DEMO_BRANCH' (was $DEMO_SHA; recoverable via git reflog)."
fi

git fetch --prune --quiet || true

# --- 3. what to do next -------------------------------------------------------

if [ "$REMOVED" = yes ]; then
  cat <<EOF

$BASE is protected, so the removal has to go through a pull request:

  git push --set-upstream origin $RESET_BRANCH
  gh pr create --base $BASE --head $RESET_BRANCH \\
    --title "Reset demo" \\
    --body "Removes the merged demo files so the demo can be run again."
  gh pr merge --squash --delete-branch

Then start the next run:

  git switch $BASE && git pull
  demo/introduce-issue.sh
EOF
else
  cat <<EOF

Nothing to push. Start the next run:

  demo/introduce-issue.sh

If the demo branch still exists on the remote:

  git push origin --delete $DEMO_BRANCH
EOF
fi
