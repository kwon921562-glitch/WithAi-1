# MVC 겔러그 기말 프로젝트

게임시스템설계(2A)와 게임인공지능(3A)에 제출할 공통 프로젝트다. 공지 마감은 **2026년 12월 5일 23:59 KST**이며, 제출 게시판에 표시된 일시를 우선한다.

## 출발 코드와 실행

- 학번 / 이름 —
- 선택 A 또는 B / 원본 경로 / 원본 버전 또는 커밋 —
- Lua 또는 LuaJIT 버전 / LÖVE 버전 —
- 게임 조작법 —
- 실행 및 테스트 — 코드가 들어오면 실제 실행 결과로 확인하고 명령을 확정한다.

출발 코드 후보는 A의 week05 `starter` 직접 완성, B의 week05 `galaga_states`(공지 권장), week06 `galaga_replay`, week07 `galaga_final`이다. 먼저 [week05 README 1~2절](https://github.com/MunGyeongsam/WithAi/blob/main/lua_tuto/mvc/week05/README.md)을 읽는다. 사용한 예제와 수정 범위는 두 보고서의 출처 표에 적는다.

코드와 테스트가 준비되면 이 폴더에서 아래 명령을 검증한다. Lua 5.1 환경이라면 실제 Lua 실행기 이름을 기록한다. 실행 스크립트를 추가하면 해당 플랫폼의 `Run run.sh` 또는 `Run run.bat` task로도 확인한다.

```sh
cd project/tests
luajit layer_check.lua src
# 여기에 새 테스트의 명령을 추가한다.
cd ../..
love project/src
```

## 일정

| 기간 | 작업 | 남길 증거 |
|---|---|---|
| 11/21~11/24 | 출발 코드 결정, week05 학습, 첫 프롬프트 개선, R2 파서와 R1 씬 | 기존 코드 실행 결과, 파서 테스트, 씬 테스트, 세션 로그 |
| 11/25~11/28 | R3 적과 Factory, R4 적 AI | 전이 테스트, 동일 시드 검증, 11/28 점검 전 R1~R4 및 로그 3개 이상 |
| 11/29~12/02 | R5 업적, R6 하이스코어, R7 번짐 측정 | 이벤트·저장 테스트, 기준 태그와 추가 커밋, 변경표 |
| 12/03~12/05 | 보고서 2종, 회고, 최종 검증과 제출 | 실제 코드 줄 번호, Git 이력, 압축 해제 후 테스트·실행 결과 |

## 필수 요건과 확인 방법

| 요건 | 완료 확인 | 상태 |
|---|---|---|
| R1 새 씬 | `scenes/`에 추가, 의존은 `ctx`로 전달, push/switch 선택 이유와 씬 테스트 | 예정 |
| R2 웨이브 파일 | 파일 기반 적 출현, [문법 명세](docs/waves_format.md), 잘못된 줄의 번호와 오류 확인 | 예정 |
| R3 적 3종 이상 | `class.lua` 상속, 문자열 → 생성 함수 등록, 알 수 없는 종류 오류 | 예정 |
| R4 적 AI 상태 3개 이상 | 적별 상태, Model에서만 전이, 주입된 RNG와 동일 시드 테스트 | 예정 |
| R5 업적 3개 이상 | `drainEvents`에서 받은 이벤트로 업적 Model이 판정하고 View가 표시 | 예정 |
| R6 하이스코어 | Model은 문자열 변환, 파일 입출력은 `main.lua`, 깨진 저장 데이터에서 기본값으로 시작 | 예정 |
| R7 번짐 실측 | R1~R6 커밋 후 `before-r7` 태그, 적 1종과 테스트 추가 후 커밋, 계층별 변경 기록 | 예정 |

- 새 테스트 **10개 이상**. 파서 3개 이상(정상·경계·오류), 적 AI 전이 3개 이상, 저장·불러오기 2개 이상, 새 씬 1개 이상을 포함한다.
- `layer_check`와 전역 쓰기 검사 결과를 남긴다. Lua 5.1/LuaJIT 호환, Model에서 `love`·`io`·`print` 금지, `love` 호출은 `main.lua`에서만 처리한다.
- [세션 양식](worklogs/_session_template.md)을 복사해 **3일 이상에 세션 5개 이상**, 원문 프롬프트 10개 이상, 거절 또는 수정 3개 이상을 기록한다. 실제 Lua 오류와 구조 오류 각 1건, 경계 위반 거절 1건, 명세 첨부 프롬프트 1건의 근거를 남긴다.

## 제출 확인

- `project/src/`와 `project/tests/`, [Lua 보고서](docs/report_게임시스템설계.md), [게임 AI 보고서](docs/report_게임인공지능.md), [회고](worklogs/999_retrospective.md), 날짜가 적힌 실제 작업 로그를 담는다.
- 프로젝트 폴더에서 `git log --stat --date=iso > docs/git_log.txt`로 이력을 만들고, 작업 로그의 시작·끝 해시를 대조한다.
- ZIP을 풀어 이 README의 명령으로 테스트와 게임 실행을 재확인한다. 세션 복사용 `_session_template.md`는 개발 중 사용한다.
- 같은 프로젝트 내용을 과목별 이름으로 제출하고, 해당 보고서는 게시판에 별도로 올린다.
  - `학번_이름_게임시스템설계2A_기말.zip` + `report_게임시스템설계.md`
  - `학번_이름_게임인공지능3A_기말.zip` + `report_게임인공지능.md`

[공통 명세](https://github.com/MunGyeongsam/WithAi/blob/main/lua_tuto/exams/%EA%B3%B5%EC%A7%80_%EA%B8%B0%EB%A7%90%EA%B3%BC%EC%A0%9C_%EA%B3%B5%ED%86%B5%EB%AA%85%EC%84%B8_%EB%B0%94%EC%9D%B4%EB%B8%8C%EC%BD%94%EB%94%A9.md) · [게임시스템설계 공지](https://github.com/MunGyeongsam/WithAi/blob/main/lua_tuto/exams/%EA%B3%B5%EC%A7%80_%EA%B2%8C%EC%9E%84%EC%8B%9C%EC%8A%A4%ED%85%9C%EC%84%A4%EA%B3%84%282A%29_%EA%B8%B0%EB%A7%90%EA%B3%BC%EC%A0%9C_%EB%B0%94%EC%9D%B4%EB%B8%8C%EC%BD%94%EB%94%A9.md) · [게임인공지능 공지](https://github.com/MunGyeongsam/WithAi/blob/main/lua_tuto/exams/%EA%B3%B5%EC%A7%80_%EA%B2%8C%EC%9E%84%EC%9D%B8%EA%B3%B5%EC%A7%80%EB%8A%A5%283A%29_%EA%B8%B0%EB%A7%90%EA%B3%BC%EC%A0%9C_%EB%B0%94%EC%9D%B4%EB%B8%8C%EC%BD%94%EB%94%A9.md)
