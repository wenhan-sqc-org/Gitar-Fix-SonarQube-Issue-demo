# sonar-gitar-demo

A minimal, deterministic Java project used to demonstrate one loop:

> a pull request introduces one code-quality issue → the required
> **`SonarQube Quality Gate`** check fails → **Gitar** pushes a small
> behaviour-preserving fix → a **fresh** SonarQube pull request analysis runs →
> the gate passes → the pull request becomes mergeable.

**Start here: [DEMO.md](DEMO.md).**

## Quick check

```bash
mvn -B verify
```

`BUILD SUCCESS`, 6 tests, 100% line and branch coverage.

## What is in here

- `src/` — a tiny `Inventory` class and its tests. Sonar-clean; this is the
  green baseline on `master`.
- `demo/` — the scripts, templates and patch that drive the demo. Not part of
  the product code and excluded from analysis.
- `.github/workflows/ci.yml` — publishes two pull-request checks,
  `Build and Test` and `SonarQube Quality Gate`.

## Configuration

Nothing is hard-coded. The workflow reads `SONAR_TOKEN` (secret) plus the
`SONAR_HOST_URL`, `SONAR_PROJECT_KEY` and (SonarQube Cloud only)
`SONAR_ORGANIZATION` repository variables. Works against both SonarQube Cloud
and SonarQube Server. See [DEMO.md](DEMO.md#repository-configuration).

Branch protection is **not** configured from code — see
[DEMO.md step 2](DEMO.md#step-2--make-the-gate-a-required-check-administrator-github-ui-only)
for the exact GitHub UI settings an administrator must enable.
