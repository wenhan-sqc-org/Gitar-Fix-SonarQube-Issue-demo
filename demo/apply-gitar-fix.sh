#!/usr/bin/env bash
#
# Manual fallback for step 2 of the demo, for when Gitar is not wired to this
# repository yet. Produces the same one-hunk, behaviour-preserving commit that
# Gitar creates for java:S1206.
#
# Run this ON the demo branch, then push. Pushing appends a commit to the open
# pull request, which fires a fresh CI run and a fresh SonarQube PR analysis.
#
# Usage: demo/apply-gitar-fix.sh
#
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

TARGET="src/main/java/com/example/demo/StockKeepingUnit.java"

if [ ! -e "$TARGET" ]; then
  echo "error: $TARGET not found - run demo/introduce-issue.sh first." >&2
  exit 1
fi

if grep -q "public int hashCode()" "$TARGET"; then
  echo "error: $TARGET already overrides hashCode() - the fix is already applied." >&2
  exit 1
fi

git apply --check demo/gitar-fix.patch
git apply demo/gitar-fix.patch

git add "$TARGET"
git commit --message "fix(java:S1206): override hashCode() alongside equals()

StockKeepingUnit compared code and warehouse in equals() but inherited
Object.hashCode(), so equal instances could report different hash codes.
Adds a hashCode() derived from the same two fields.

Additive change only - no existing method was modified, so behaviour is
unchanged and the existing tests still pass.

Rule: https://rules.sonarsource.com/java/RSPEC-1206"

cat <<'EOF'

Fix committed. Push it to re-trigger analysis:
  git push

Then verify a NEW analysis ran for THIS commit (see DEMO.md, step 5).
EOF
