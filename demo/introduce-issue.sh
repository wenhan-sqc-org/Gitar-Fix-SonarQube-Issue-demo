#!/usr/bin/env bash
#
# Step 1 of the demo: create a branch whose diff contains exactly one
# intentional SonarQube issue (java:S1206 - equals() without hashCode()).
#
# Usage: demo/introduce-issue.sh [branch-name]
#
set -euo pipefail

BRANCH="${1:-demo/missing-hashcode}"
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

MAIN_SRC="src/main/java/com/example/demo/StockKeepingUnit.java"
TEST_SRC="src/test/java/com/example/demo/StockKeepingUnitTest.java"

if [ -e "$MAIN_SRC" ]; then
  echo "error: $MAIN_SRC already exists - are you already on the demo branch?" >&2
  exit 1
fi

git switch --create "$BRANCH"

cp demo/templates/StockKeepingUnit.java     "$MAIN_SRC"
cp demo/templates/StockKeepingUnitTest.java "$TEST_SRC"

git add "$MAIN_SRC" "$TEST_SRC"
git commit --message "Add StockKeepingUnit value object

Introduces an immutable code + warehouse identifier used to key stock
records. Includes unit tests for accessors and equality." \
  --message "Demo note: this commit deliberately overrides equals() without
hashCode() (SonarQube java:S1206, Blocker) so that Gitar has exactly one
issue to fix."

cat <<EOF

Branch '$BRANCH' created with one intentional issue.

Next:
  git push --set-upstream origin $BRANCH
  gh pr create --base master --head $BRANCH \\
    --title "Add StockKeepingUnit value object" \\
    --body "Adds an immutable SKU identifier."

Expected on the PR:
  Build and Test           PASS  (behaviour is fine; only the contract is broken)
  SonarQube Quality Gate   FAIL  (1 new Blocker issue: java:S1206)
EOF
