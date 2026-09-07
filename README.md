# Gitar + SonarQube demo

A minimal Java project showing one loop: a pull request introduces a single
code-quality issue, SonarQube's quality gate blocks the merge, **Gitar** pushes
a small fix, a fresh analysis turns the gate green, and the pull request becomes
mergeable.

**Full walkthrough: [DEMO.md](DEMO.md).**

```bash
mvn -B verify     # BUILD SUCCESS
```

- `src/` — the demo code.
- `demo/templates/` — the flawed class and tests copied in by the demo script.
- `demo/introduce-issue.sh` — creates the branch and commit that opens the demo.
- `.github/workflows/ci.yml` — builds, tests and runs SonarQube analysis on
  every pull request. The gate result is published separately by SonarQube
  Cloud's GitHub App as `SonarCloud Code Analysis`, which is the required check.
