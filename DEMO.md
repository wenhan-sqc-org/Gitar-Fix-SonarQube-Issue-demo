# Demo: Gitar fixes a Sonar issue and unblocks a pull request

This repository demonstrates the following loop end to end:

1. A pull request introduces **one** intentional code-quality issue.
2. The required `SonarQube Quality Gate` check fails → GitHub refuses to merge.
3. **Gitar** pushes a small follow-up commit that fixes exactly that issue.
4. The new commit triggers a **fresh** SonarQube pull request analysis.
5. The gate turns green → the pull request becomes mergeable.

The build/test check stays green the whole time. That is deliberate: it proves
the pre-fix block comes from SonarQube alone, and that Gitar's fix does not
change behaviour.

---

## The intentional issue

| | |
|---|---|
| Rule | [`java:S1206`](https://rules.sonarsource.com/java/RSPEC-1206) — `equals(Object)` and `hashCode()` should be overridden in pairs |
| Type / severity | **Bug** / **Blocker** (Reliability · Blocker in Multi-Quality Rule mode) |
| Location | `src/main/java/com/example/demo/StockKeepingUnit.java` (added by the demo branch) |
| Fix | Add `hashCode()` derived from the same fields `equals()` compares |
| Diff size | 1 file, **+5 lines**, one hunk |

**Why this rule was chosen**

- **Deterministic detection.** S1206 is decided purely from the class structure
  ("overrides `equals` but not `hashCode`"). There is no dataflow engine
  involved, so it fires on every analysis — no flaky demos.
- **It fails the built-in `Sonar way` gate on its own.** One new Blocker Bug
  trips *New Reliability Rating worse than A* (Standard Experience) and
  *new Blocker/High issues > 0* (MQR mode). No custom gate needed.
- **SonarQube never rewrites it.** SonarQube analysis is read-only in CI; the
  repository contains no SonarQube autofix/agent hook that would modify the
  source. The fix must come from Gitar (or the documented fallback).
- **The fix is purely additive.** Nothing existing is edited, so functional
  behaviour is provably unchanged and the existing tests pass byte-for-byte
  before and after.
- **It is on new lines.** The demo branch adds a *new* class rather than
  degrading an existing one. If it modified `equals()` in place, the issue
  would sit on an unchanged line and would *not* count as new code — the
  pull-request gate would stay green and the demo would not work.

---

## Prerequisites

**Local**

- JDK 17+ and Maven 3.9+
- `git`, and [`gh`](https://cli.github.com/) (optional, used for the verification commands)

**Remote**

- A GitHub repository (this code pushed to it) with GitHub Actions enabled.
- A SonarQube project — **SonarQube Cloud** or **SonarQube Server** both work.
  The Server must be reachable from the GitHub runner (self-hosted runner or a
  public URL).
- Repository admin rights, to make the check required (step 2).
- Gitar connected to the repository, **or** use the manual fallback in step 4b.

### Repository configuration

No secrets are hard-coded anywhere. Set these under
**Settings → Secrets and variables → Actions**:

| Name | Kind | Required | Value |
|---|---|---|---|
| `SONAR_TOKEN` | **Secret** | yes | User or project analysis token |
| `SONAR_HOST_URL` | Variable | yes | `https://sonarcloud.io` for SonarQube Cloud, or your Server URL, e.g. `https://sonarqube.example.com` |
| `SONAR_PROJECT_KEY` | Variable | yes | The project key, e.g. `my-org_sonar-gitar-demo` |
| `SONAR_ORGANIZATION` | Variable | Cloud only | Your SonarQube Cloud organization key. **Leave unset for SonarQube Server** — the workflow then omits the flag entirely. |

### SonarQube-side configuration

1. Create the project using the same key as `SONAR_PROJECT_KEY`.
2. Leave the quality gate as **Sonar way** and the quality profile as the
   built-in **Sonar way** for Java.
3. **SonarQube Cloud only — turn Automatic Analysis off.** *Project Settings →
   Analysis Method → disable Automatic Analysis*. If it stays on, SonarQube
   rejects the CI analysis and the gate check never gets a result.
4. Set **New Code** for the project to *Reference branch: `main`*
   (*Project Settings → New Code*). Pull requests always scope new code to the
   PR diff, but this keeps the `main` branch consistent.
5. Push `main` once so a baseline analysis exists (the `push` trigger in
   `.github/workflows/ci.yml` does this for you).

---

## Step 1 — Confirm `main` is green

```bash
mvn -B verify
```

Expected: `BUILD SUCCESS`, 6 tests, 100% line and branch coverage.
Push to `main` and confirm both checks pass in the Actions tab.

---

## Step 2 — Make the gate a required check *(administrator, GitHub UI only)*

Branch protection is intentionally **not** configured from code. An
administrator must enable it once. The check must have run at least once before
it becomes selectable, so do Step 1 first.

**Option A — Rulesets (current GitHub UI)**

1. **Settings → Rules → Rulesets → New ruleset → New branch ruleset**
2. **Ruleset Name**: `main protection`  ·  **Enforcement status**: `Active`
3. **Target branches → Add target → Include default branch**
4. Tick **Require status checks to pass**
5. **Add checks** → search for and add:
   - `SonarQube Quality Gate`
   - `Build and Test`
6. (Recommended) tick **Require branches to be up to date before merging**
7. **Create**

**Option B — Classic branch protection**

1. **Settings → Branches → Add branch protection rule**
2. **Branch name pattern**: `main`
3. Tick **Require status checks to pass before merging**
4. In the search box add `SonarQube Quality Gate` and `Build and Test`
5. **Create**

> The check name is the workflow **job name**. `SonarQube Quality Gate` is
> produced by the `sonarqube` job in `.github/workflows/ci.yml`.

> On the GitHub Free plan, branch protection and rulesets require the
> repository to be **public**. For a private demo repo you need Team or
> Enterprise.

---

## Step 3 — Create the intentionally failing pull request

```bash
demo/introduce-issue.sh                 # or: demo/introduce-issue.sh my/branch-name
git push --set-upstream origin demo/missing-hashcode

gh pr create --base main --head demo/missing-hashcode \
  --title "Add StockKeepingUnit value object" \
  --body "Adds an immutable SKU identifier used to key stock records."
```

The script creates the branch and copies two files out of `demo/templates/`
into `src/`, in a single commit:

- `src/main/java/com/example/demo/StockKeepingUnit.java` — `equals()`, no `hashCode()`
- `src/test/java/com/example/demo/StockKeepingUnitTest.java` — its unit tests

### Verify the pull request is blocked (acceptance criterion 1)

```bash
gh pr checks                    # run from the branch, or pass the PR number
gh pr view --json mergeable,mergeStateStatus
```

Expected:

| Check | Result |
|---|---|
| `Build and Test` | ✅ pass — 6 tests green, behaviour is fine |
| `SonarQube Quality Gate` | ❌ **fail** — 1 new Blocker issue |

`mergeStateStatus` is **`BLOCKED`**, and the GitHub merge box reads
*"Required statuses must pass before merging"*. The **Merge** button is
disabled. The Sonar job log ends with
`QUALITY GATE STATUS: FAILED - View details on <your Sonar URL>`.

Confirm SonarQube agrees:

```bash
export SONAR_HOST_URL=...    SONAR_PROJECT_KEY=...    SONAR_TOKEN=...
PR=<pull request number>

curl -sS -u "$SONAR_TOKEN:" \
  "$SONAR_HOST_URL/api/qualitygates/project_status?projectKey=$SONAR_PROJECT_KEY&pullRequest=$PR"
```

Expected `"status":"ERROR"`.

---

## Step 4a — Let Gitar apply the fix

Gitar runs **outside** this repository, so the repository-side prerequisites are:

- The **Gitar GitHub App** installed on this repository with **Read & write**
  on *Contents*, *Pull requests* and *Checks* (write on Contents is what lets
  it push the follow-up commit to the PR head branch).
- The repository enabled/onboarded in your Gitar workspace, with fixing
  enabled for the branch pattern that covers `demo/*` pull requests.
- If your Gitar workspace consumes findings from SonarQube rather than running
  its own analysis, give it read access to the SonarQube project (its own token
  — never this repo's `SONAR_TOKEN`).
- Allow Actions to run on Gitar's pushes: **Settings → Actions → General →**
  ensure the workflow is not restricted from running for that app's commits.

> This repository intentionally ships **no** Gitar configuration file. Gitar's
> repo-level config schema is workspace-specific — add it per your Gitar
> documentation if your tenant requires one. The demo does not depend on it.

Then, in Gitar, trigger a fix pass over the open pull request (or wait for the
automatic pass). Gitar pushes one commit to `demo/missing-hashcode`.

## Step 4b — Manual fallback (simulates Gitar's commit exactly)

Use this when Gitar is not wired up yet. It produces the same one-hunk,
behaviour-preserving commit:

```bash
demo/apply-gitar-fix.sh
git push
```

Or apply the patch by hand:

```bash
git apply --check demo/gitar-fix.patch   # dry run
git apply demo/gitar-fix.patch
git add src/main/java/com/example/demo/StockKeepingUnit.java
git commit -m "fix(java:S1206): override hashCode() alongside equals()"
git push
```

The patch is `demo/gitar-fix.patch`. Its entire effect:

```diff
@@ -33,5 +33,10 @@
         }
         return Objects.equals(code, that.code)
                 && Objects.equals(warehouse, that.warehouse);
     }
+
+    @Override
+    public int hashCode() {
+        return Objects.hash(code, warehouse);
+    }
 }
```

### Verify the fix is small and reviewable (acceptance criterion 2)

```bash
git show --stat HEAD
```

Expected: `1 file changed, 5 insertions(+)` — no deletions, no other file
touched.

---

## Step 5 — Verify a *fresh* analysis ran for the fix commit (acceptance criterion 3)

The workflow listens to `pull_request: [synchronize]`, so Gitar's push starts a
brand-new run. Never read the pre-fix result — tie the result to the fix SHA.

```bash
FIX_SHA=$(git rev-parse HEAD)
echo "fix commit: $FIX_SHA"

# 1. A workflow run exists for exactly this SHA
gh run list --commit "$FIX_SHA" --workflow CI

# 2. Both check runs are attached to this SHA, and the gate is green
gh api "repos/{owner}/{repo}/commits/$FIX_SHA/check-runs" \
  --jq '.check_runs[] | "\(.name): \(.status)/\(.conclusion) head=\(.head_sha[0:7])"'
```

Expected:

```
Build and Test: completed/success head=<first 7 of FIX_SHA>
SonarQube Quality Gate: completed/success head=<first 7 of FIX_SHA>
```

Confirm on the SonarQube side that the analysis is new and points at the fix
commit:

```bash
# analysisDate must be AFTER the pre-fix analysis
curl -sS -u "$SONAR_TOKEN:" \
  "$SONAR_HOST_URL/api/project_pull_requests/list?project=$SONAR_PROJECT_KEY"

# gate for this PR is now OK
curl -sS -u "$SONAR_TOKEN:" \
  "$SONAR_HOST_URL/api/qualitygates/project_status?projectKey=$SONAR_PROJECT_KEY&pullRequest=$PR"

# and there are no new issues left
curl -sS -u "$SONAR_TOKEN:" \
  "$SONAR_HOST_URL/api/measures/component?component=$SONAR_PROJECT_KEY&pullRequest=$PR&metricKeys=new_violations,new_coverage,new_duplicated_lines_density"
```

Expected: `"status":"OK"`, `new_violations` = `0`, `new_coverage` = `100.0`.

In the SonarQube UI: **Pull Requests → your PR** shows a *Passed* badge and a
timestamp matching the fix commit; **Issues** is empty. Cross-check the
"analysed at" timestamp against the fix commit time — that, plus the
`head_sha` above, is what proves the result is not the stale pre-fix one.

Also confirm the fix is real, not suppressed: the log line
`QUALITY GATE STATUS: PASSED` must come from the run whose SHA is `$FIX_SHA`.

---

## Step 6 — Show the pull request become mergeable (acceptance criterion 4)

```bash
gh pr view --json mergeable,mergeStateStatus,statusCheckRollup
```

Expected: `mergeable: MERGEABLE`, `mergeStateStatus: CLEAN` (or `BEHIND` if you
enabled *Require branches to be up to date* and `main` moved — update the
branch and it becomes `CLEAN`).

In the GitHub UI the merge box flips from red *"Required statuses must pass"*
to green *"All checks have passed"* and the **Merge pull request** button
becomes enabled.

```bash
gh pr merge --squash        # optional, completes the story
```

---

## Optional: strengthen the test after the fix

`StockKeepingUnitTest` only asserts that `hashCode()` is *stable for one
instance* — true with the inherited identity hash too. That is on purpose: an
assertion that fails before the fix would make the build red and muddy the
"blocked by SonarQube only" narrative.

Once the fix is merged you can add the assertion that captures the real
contract:

```java
@Test
void equalInstancesShareAHashCode() {
    StockKeepingUnit sku = new StockKeepingUnit("SKU-1", "BER-01");
    StockKeepingUnit sameValues = new StockKeepingUnit("SKU-1", "BER-01");

    assertEquals(sku.hashCode(), sameValues.hashCode());
}
```

This is a good closing beat: it fails on the pre-fix code and passes on
Gitar's.

---

## Resetting the demo

```bash
git switch main
git branch -D demo/missing-hashcode
git push origin --delete demo/missing-hashcode
gh pr close <PR>            # if it is still open
```

Optionally delete the pull request's analysis in SonarQube
(*Project Settings → Branches and Pull Requests*).

---

## Repository-specific assumptions

The repository was empty when this demo was generated, so everything here is
new. The choices worth knowing about:

1. **Java 17 + Maven** — no existing language or build tool to match. Maven has
   the best-supported SonarQube pull-request path (`sonar-maven-plugin` plus
   `sonar.qualitygate.wait`). The `sonar-maven-plugin` version is **pinned** in
   `pom.xml` (`sonar.maven.plugin.version`) for reproducibility; bump it
   deliberately.
2. **JaCoCo is mandatory here, not decoration.** `Sonar way` gates on *Coverage
   on New Code* (≥ 80%). Without `target/site/jacoco/jacoco.xml` the gate would
   fail on coverage even after Gitar's fix, and the demo would not close. The
   tests give the new class 100% line and branch coverage, including the added
   `hashCode()`.
3. **One job per check.** The `sonarqube` job runs `mvn verify` itself rather
   than reusing the `build` job's artifacts. Slightly more CPU, but it avoids
   fragile artifact plumbing and each check is independently reproducible.
4. **`concurrency.cancel-in-progress: true`** — if Gitar pushes while the
   pre-fix run is still going, the older run is cancelled. Let the pre-fix run
   finish before triggering Gitar if you want the red check visible on screen.
5. **`fetch-depth: 0`** in the Sonar job — SonarQube needs full history for
   line attribution and new-code detection. Do not reduce it.
6. **`demo/` is excluded from analysis** (`sonar.exclusions` in `pom.xml`) and
   is outside `src/`, so its templates are neither compiled nor analysed.
7. **Quality gate assumed to be built-in `Sonar way`.** If your instance uses a
   custom gate, confirm it has a new-code condition that a single Blocker Bug
   trips; otherwise the pre-fix state will not be red.

---

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| Sonar job fails with `SONAR_… is not configured` | Set the secret/variables in the table above. Variables live under *Variables*, not *Secrets*. |
| `You are running CI analysis while Automatic Analysis is enabled` | SonarQube Cloud: disable Automatic Analysis for the project. |
| Gate is green before the fix | New-code condition missing from a custom gate, or the issue landed on an unchanged line. Check *Pull Requests → your PR → Issues* in SonarQube. |
| `SonarQube Quality Gate` not listed in branch protection | It has not run yet. Push once to `main` or open a PR, then re-open the setting. |
| Job hangs then fails at the gate | `sonar.qualitygate.wait` timed out (600 s). The server is slow or unreachable; raise `-Dsonar.qualitygate.timeout`. |
| Gitar's push does not start a run | The app lacks *Contents: write*, or Actions is restricted for that app. See step 4a. |
| `git apply` rejects `demo/gitar-fix.patch` | `StockKeepingUnit.java` was edited by hand. Reset the branch and re-run `demo/introduce-issue.sh`. |

---

## Layout

```
.github/workflows/ci.yml                  Build and Test + SonarQube Quality Gate checks
pom.xml                                   Java 17, JUnit 5, JaCoCo, pinned sonar-maven-plugin
src/main/java/com/example/demo/
  Inventory.java                          clean baseline on main
src/test/java/com/example/demo/
  InventoryTest.java
demo/
  templates/StockKeepingUnit.java         the flawed class (copied into src/ by step 3)
  templates/StockKeepingUnitTest.java     its tests — green before and after the fix
  introduce-issue.sh                      step 3: create the failing branch + commit
  gitar-fix.patch                         step 4b: the exact fix, +5 lines
  apply-gitar-fix.sh                      step 4b: apply the patch and commit as Gitar would
DEMO.md                                   this file
```
