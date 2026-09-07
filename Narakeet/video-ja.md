---
size: 1080p
transition: crossfade 0.2
background: corporate-1 0.3 fade-in fade-out
theme: light
subtitles: embed
voice: Yuriko
---

(pause: 1)

![](0_Sonar_Background.jpg)

(font-size: 40)

```
 <Gitar demo>
 Gitar が SonarQube の問題を解決し、PRのマージをブロック解除する方法
```

このデモでは、あるIssueがSonarQubeのQuality Gateに失敗し、PRのマージがブロックされます。Gitarがそれを修正し、Quality Gateを通過させて無事マージされるまでの流れをご紹介します。

---

(pause: 1)

![](01_confirm_QG_PJ.jpg)
まず、Quality Gateの設定を確認しましょう。新しいコードで1つ以上のIssueが検出されると失敗します。
このQuality Gateはプロジェクトで有効になっており、ページ下部に表示されています。

---

(pause: 1)

![](02_GH_OpenPR.mp4)
GitHub側では、別のブランチからmasterへのPRを作成しましょう。
---

(pause: 1)

![](03_GH_analysising.mp4)

PRが作成されると、SonarQubeとGitarの両方が解析を開始します。

---

(pause: 1)

![](04_GH_analysis_QG_failed.mp4)

しばらくすると、SonarQubeの解析が完了し、新しいIssueが検出されます。その結果、Quality Gateが失敗し、マージがブロックされます。

---

(pause: 1)

![](05_SQ_Confirm_Issue.mp4)

SonarQubeのGUIからも確認してみましょう。

---

(pause: 1)

![](06_GH_Gitar_analysis.mp4)
GitarもこのPRの解析を完了し、いくつかのIssueを見つけます。Quality Gateをブロックしていた問題も検出されています。
---


(pause: 1)

![](07_GH_Gitar_Fix.mp4)
Gitarからの各コメントには「Fix me」チェックボックスがあり、Gitarで修正するかどうかを選択できます。
このデモでは、Gitarに修正を依頼します。

---

(pause: 1)

![](08_GH_QG_rescan.mp4)
修正によってこのPRに新しいコミットが生成され、新たなSonarQubeスキャンが開始されます。
Quality Gateを通過するまで、PRはマージがブロックされたままです。

---

(pause: 1)

![](09_GH_Merge.mp4)
Gitarのコミットによって問題が修正されたため、今回はQuality Gateを通過し、PRをマージできるようになりました。

---

(pause: 1)

![](10_GH_Summary.mp4)
このデモでは、GitarとSonarQubeが連携してコードをチェックし、問題を修正し、コードベースの品質を確保するワークフローを紹介しました。エンジニアに残された作業はGitarの修正をレビューするだけであり、問題修正にかかる時間を削減できます。

以上でデモは終了です。参考になれば幸いです。それでは、また次回お会いしましょう!
