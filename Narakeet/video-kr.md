---
size: 1080p
transition: crossfade 0.2
background: corporate-1 fade-in fade-out
theme: light
subtitles: embed
voice: Min-ho
---

(pause: 1)

![](0_Sonar_Background.jpg)

(font-size: 40)

```
 <Gitar 데모>
 Gitar가 SonarQube 이슈를 해결하여 PR 병합 차단을 해제하는 방법
```

이 데모에서는 하나의 이슈로 인해 SonarQube의 Quality Gate를 통과하지 못해 PR 병합이 차단됩니다. Gitar가 이를 수정하여 Quality Gate를 통과시키고 성공적으로 병합되는 과정을 보여드리겠습니다.

---

(pause: 1)

![](01_confirm_QG_PJ.jpg)
먼저 Quality Gate 설정을 확인해 보겠습니다. 새 코드에서 하나 이상의 이슈가 감지되면 실패하게 됩니다.
이 Quality Gate는 프로젝트에서 활성화되어 있으며, 페이지 하단에 표시됩니다.

---

(pause: 1)

![](02_GH_OpenPR.mp4)
GitHub에서는 다른 브랜치에서 master로 향하는 PR을 생성해 보겠습니다.

---

(pause: 1)

![](03_GH_analysising.mp4)

PR이 생성되면 SonarQube와 Gitar가 모두 분석을 시작합니다.

---

(pause: 1)

![](04_GH_analysis_QG_failed.mp4)

잠시 후 SonarQube 분석이 완료되고 새로운 이슈가 발견됩니다. 그 결과 Quality Gate가 실패하여 병합이 차단됩니다.

---

(pause: 1)

![](05_SQ_Confirm_Issue.mp4)

SonarQube GUI에서도 확인해 보겠습니다.

---

(pause: 1)

![](06_GH_Gitar_analysis.mp4)

Gitar도 이 PR에 대한 분석을 완료하고 몇 가지 이슈를 발견합니다. Quality Gate를 차단했던 이슈도 함께 감지됩니다.

---

(pause: 1)

![](07_GH_Gitar_Fix.mp4)

Gitar의 각 댓글에는 "Fix me" 체크박스가 있어 Gitar를 통해 수정할지 선택할 수 있습니다.
이 데모에서는 Gitar에게 수정을 요청하겠습니다.
---

(pause: 1)

![](08_GH_QG_rescan.mp4)
수정 사항이 반영되면 이 PR에 새로운 커밋이 생성되어 새로운 SonarQube 스캔이 시작됩니다.
Quality Gate를 통과하기 전까지 이 PR은 계속 병합이 차단된 상태로 유지됩니다.

---

(pause: 1)

![](09_GH_Merge.mp4)
Gitar의 커밋으로 이슈가 수정되었기 때문에 이번에는 Quality Gate를 통과하여 이제 PR을 병합할 수 있습니다.

---

(pause: 1)

![](10_GH_Summary.mp4)
이번 데모에서는 Gitar와 SonarQube가 함께 협력하여 코드를 검사하고, 이슈를 수정하며, 코드베이스의 품질을 보장하는 워크플로우를 보여드렸습니다. 엔지니어에게 남은 작업은 Gitar의 수정 사항을 검토하는 것뿐이며, 이를 통해 이슈 수정에 소요되는 시간을 줄일 수 있습니다.

이상으로 데모를 마칩니다. 도움이 되었기를 바라며, 다음에 또 뵙겠습니다!
