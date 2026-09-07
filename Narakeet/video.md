---
size: 1080p
transition: crossfade 0.2
background: corporate-1 0.3 fade-in fade-out
theme: light
subtitles: embed
---

(pause: 1)

![](0_Sonar_Background.jpg)

(font-size: 30)

```
 <Gitar demo>
 How Gitar resolves a SonarQube issue to unblock a PR merge
```

In this demo, an issue fails SonarQube's Quality Gate and blocks the PR from merging. I will show how Gitar fixes it, letting it pass the Quality Gate and get merged successfully.

---

(pause: 1)

![](01_confirm_QG_PJ.jpg)
First, let's confirm the Quality Gate setting. It will fail if one or more issues are detected in the new code.
This Quality Gate is enabled in the project, as shown at the bottom of the page.

---

(pause: 1)

![](02_GH_OpenPR.mp4)
On the GitHub side, let's create a PR to master from another branch.

---

(pause: 1)

![](03_GH_analysising.mp4)

After the PR is created, both SonarQube and Gitar start analysing it.

---

(pause: 1)

![](04_GH_analysis_QG_failed.mp4)

After a while, SonarQube finishes the analysis and a new issue is detected. As a result, the Quality Gate fails, which blocks the merge.

---

(pause: 1)

![](05_SQ_Confirm_Issue.mp4)

Let's also confirm this from the SonarQube GUI.

---

(pause: 1)

![](06_GH_Gitar_analysis.mp4)

Gitar also finishes analysing this PR and finds some issues. The issue that blocked the Quality Gate is also detected.

---

(pause: 1)

![](07_GH_Gitar_Fix.mp4)

There is a "Fix me" checkbox on each comment from Gitar. It lets you choose whether you want to fix it via Gitar.
In this demo, I'm going to ask Gitar to fix it.
---

(pause: 1)

![](08_GH_QG_rescan.mp4)
The fix generates a new commit on this PR, so a new SonarQube scan is kicked off.
Until the Quality Gate passes, the PR remains blocked from merging.

---

(pause: 1)

![](09_GH_Merge.mp4)
Because the commit from Gitar fixes the issue, the Quality Gate passes this time, and we can merge the PR now.

---

(pause: 1)

![](10_GH_Summary.mp4)
This demo shows a workflow where Gitar and SonarQube work together to check the code, fix issues, and ensure the quality of the codebase. The only thing left for the engineer is to review Gitar's fix, which reduces the time spent fixing issues.

This concludes our demonstration. I hope you found it insightful, and I look forward to seeing you next time!
