# Gitar + SonarQube demo

## 1. What this demo is

A minimal Java project used to show one loop end to end:

1. A pull request introduces **one** intentional code-quality issue.
2. SonarQube analyses the pull request and the quality gate fails.
3. The required `SonarCloud Code Analysis` check goes red, so GitHub will not
   let the pull request merge.
4. **Gitar** pushes a small follow-up commit that fixes exactly that issue.
5. That commit triggers a **fresh** analysis, the gate passes, and the pull
   request becomes mergeable.

### The intentional issue

| | |
|---|---|
| Rule | [`java:S1206`](https://rules.sonarsource.com/java/RSPEC-1206) — `equals(Object)` and `hashCode()` should be overridden in pairs |
| File | `src/main/java/com/example/demo/StockKeepingUnit.java` (added by the demo branch) |
| Fix | Add `hashCode()` built from the same fields `equals()` compares |
| Fix size | 1 file, +5 lines |

### Two things that make it work

- **The build stays green throughout.** The fix only *adds* `hashCode()`, so
  behaviour never changes and the tests pass before and after. The pull request
  is blocked by code quality alone, never by a broken build.
- **`StockKeepingUnit` must stay a class, not a record.** It carries a cached
  `lookupKey` field for exactly that reason: a record may not declare instance
  fields beyond its components, which stops SonarQube raising `java:S6206`
  ("use a record"). A record would also generate `hashCode()` automatically, so
  the intended issue could not exist. Do not remove that field.

---

## 2. How to run it

### Prerequisites (one-time)

| What | Where | Value |
|---|---|---|
| `SONAR_TOKEN` | repo secret | SonarQube Cloud analysis token |
| Sonar project | SonarQube Cloud | key `wenhan-sqc-org_Gitar-SonarQube-demo`, Automatic Analysis **off** |
| Quality gate | SonarQube Cloud | any condition a single new issue trips (this project uses `new_violations > 0`) |
| Required check | **Settings → Rules → Rulesets → `master protection`** | `SonarCloud Code Analysis`, provider **SonarQubeCloud** |
| Gitar | Gitar workspace | app installed with **Contents: write** so it can push to the pull request branch |

> The required check must be `SonarCloud Code Analysis` — SonarQube Cloud's own
> app publishes it and it carries the gate result. CI does not evaluate the
> gate, so do not require a GitHub Actions check for it.

### Step 1 — Create the failing pull request

```bash
git switch master && git pull
demo/introduce-issue.sh
git push -u origin demo/missing-hashcode

gh pr create --base master --head demo/missing-hashcode \
  --title "Add StockKeepingUnit value object" \
  --body "Adds an immutable SKU identifier used to key stock records."
```

The script copies two files from `demo/templates/` into `src/` in one commit:
the flawed class and its unit tests.

### Step 2 — Confirm the pull request is blocked

```bash
gh pr checks
gh pr view --json mergeable,mergeStateStatus
```

Expected: `Build and analyze` passes, **`SonarCloud Code Analysis` fails**, and
`mergeStateStatus` is `BLOCKED`. The **Merge** button is disabled.

Confirm SonarQube sees exactly one issue:

```bash
PR=<pull request number>
sonar list issues -p wenhan-sqc-org_Gitar-SonarQube-demo --pull-request $PR --statuses OPEN,CONFIRMED --format table
sonar api GET "/api/qualitygates/project_status?projectKey=wenhan-sqc-org_Gitar-SonarQube-demo&pullRequest=$PR"
```

Expected: one `java:S1206` row, and `"status":"ERROR"`.

### Step 3 — Let Gitar fix it

Trigger a fix pass on the open pull request from your Gitar workspace, or wait
for the automatic one. Gitar pushes one commit to `demo/missing-hashcode`.

### Step 4 — Confirm a fresh analysis, then merge

Tie the result to the fix commit — never read the pre-fix result.

```bash
git pull
FIX_SHA=$(git rev-parse HEAD)

gh api "repos/{owner}/{repo}/commits/$FIX_SHA/check-runs" \
  --jq '.check_runs[] | "\(.name): \(.conclusion) | app=\(.app.name)"'

sonar list issues -p wenhan-sqc-org_Gitar-SonarQube-demo --pull-request $PR --statuses OPEN,CONFIRMED --format table
```

Expected: `SonarCloud Code Analysis: success` against `$FIX_SHA`, and no open
issues. Then:

```bash
gh pr view --json mergeable,mergeStateStatus     # MERGEABLE / CLEAN
gh pr merge --squash --delete-branch
```

If `mergeStateStatus` is `BEHIND`, run `gh pr update-branch` first.

### Step 5 — Reset for the next run

Merging puts the demo class on `master`, so `introduce-issue.sh` will refuse to
run again until it is removed.

```bash
# if the pull request was merged, revert it on master
git switch master && git pull
git revert --mainline 1 <merge-commit-sha>    # or: git revert <squash-commit-sha>
git push

# clean up the local branch
git branch -D demo/missing-hashcode
```

To keep `master` untouched instead, close the pull request without merging and
delete its branch — the demo is repeatable that way with no revert.
