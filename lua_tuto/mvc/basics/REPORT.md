# MVC 퀴즈 REPORT

학번·이름을 기입하고, 5절의 답안 초안을 본인이 이해한 문장으로 수정한 뒤 제출한다.

## 1. 파일 변경표

게임 파일 경로는 `06_dungeon/` 기준이다.

| 문제 | 새 파일 | 수정 파일 | 확인할 내용 |
|---|---|---|---|
| 1. 아이템 사용 퀘스트 | | `data/dungeon_data.lua` | `item_used`를 두 번 기다리는 퀘스트 정의 추가 |
| 2. 처치 목록 | `models/kill_list_model.lua`, `views/kill_list_view.lua` | `models/game_model.lua`, `main.lua` | 생성자에서 모델 연결, 화면 레이아웃에 패널 등록 |
| 3. 누적 처치 골드 업적 | `models/achievement_model.lua` | `models/game_model.lua`, `views/log_view.lua` | 생성자에서 구독 연결, 로그 포맷에 업적 문구 등록 |
| 4. 상점 | `controllers/shop_controller.lua` | `data/dungeon_data.lua`, `models/game_model.lua`, `views/command_view.lua`, `views/log_view.lua`, `main.lua` | 상점 데이터, 모드 연결, 구매·퇴장 메서드, 안내 및 시연 입력 추가 |
| 공통 검증 | `REPORT.md` | `tests/dungeon_test.lua` | 기존 검사 유지, 신규 21개 검사 추가 |

## 2. 핵심 프롬프트

아래 세 항목은 최초 요청을 검증 기준별로 요약한 것이다.

1. 퀘스트 데이터만 추가해서 아이템을 두 번 사용하면 완료되게 해줘.
2. 처치 목록은 모델과 뷰로 만들고, 누적 처치 골드 15 이상에서 업적을 한 번 기록해줘. 업적 모델은 GameModel과 PlayerModel에 의존하면 안 돼.
3. 출구 앞 상점에서 `b`로 5골드짜리 물약을 사고 `l`로 나가게 해줘. 실패 원인을 출력하고, 기존 메서드와 전역 변수 규칙을 diff로 확인해줘.

## 3. AI 실수 사례

AI가 처음 작성한 업적 테스트는 가짜 처치 이벤트에 적 이름을 넣지 않았다.

```lua
bus:emit("enemy_killed", { gold = 14 })
```

이벤트 형식에서 `name`이 빠지면 누적 자체는 동작해도 로그 뷰가 기존 처치 문구를 만들 때 오류가 난다. 첫 구현 후 테스트에서 `log_view.lua`의 포맷 오류가 발생했다. `attack()`의 실제 이벤트 데이터를 확인하고 테스트의 세 이벤트에 이름을 추가했다. 기존 로그 변환 메서드의 본문을 유지했다.

```lua
bus:emit("enemy_killed", { name = "늑대", gold = 14 })
```

## 4) 테스트 결과

구현 전

```text
결과: 56 통과, 0 실패
출구를 찾았다! 총 골드 18
VICTORY — 아무 키나 입력하면 종료
```

확장 테스트를 먼저 추가했을 때는 아이템 사용 퀘스트 검사 4개가 실패했고, 처치 목록 뷰 파일을 불러오는 단계에서 실행이 중단됐다.

구현 후

```text
결과: 77 통과, 0 실패
[v] 아이템 2번 사용 (2/2)
★ 업적 달성: 처치 골드 15 이상 획득
회복 물약 구매 (골드 -5)
출구를 찾았다! 총 골드 13
VICTORY — 아무 키나 입력하면 종료
```

자동 시연에서 처치 목록에 슬라임·고블린·오크가 표시됐고, 8/8번 방에서 승리했다.

`tests/dungeon_test.lua`와 `06_dungeon/main.lua`를 각각 열고 **Lua: Run current file** task를 실행한다. 직접 조작할 때는 학생 환경의 Lua 실행기로 `main.lua`에 `-i`를 전달한다.

Lua 실행기가 `lua`인 환경에서는 압축을 푼 폴더에서 다음 명령을 사용할 수 있다.

```sh
lua tests/dungeon_test.lua
lua 06_dungeon/main.lua
lua 06_dungeon/main.lua -i
```

구현에서 생성자를 제외한 기존 함수 41개의 본문을 변경 전 버전과 비교했다. `git diff --check`도 통과했다. 새 전역 이름에 대한 대입을 오류로 처리한 상태에서 테스트와 자동 시연을 다시 실행해 통과했다.

```sh
git diff --check
git diff -- lua_tuto/mvc/basics/06_dungeon lua_tuto/mvc/basics/tests/dungeon_test.lua
git ls-files --others --exclude-standard -- lua_tuto/mvc/basics
```

업적 검사는 14골드에서 미달, 15골드에서 달성, 이후 처치에도 이벤트가 한 번만 발행되는지 확인한다. 화면을 다시 그릴 때 최근 기록에 남아 있는 같은 업적 항목은 다시 보일 수 있다. 상점에서 지갑 잔액이 줄어도 처치 보상 누적은 유지되는지 따로 검사했다.

## 5. 설명 문항 답안 초안

**Q1. 퀘스트 진행도가 오르는 원리**

퀘스트 데이터에 적힌 `event`를 QuestModel이 생성될 때 구독한다.  
물약을 쓰거나 무기를 장착하면 기존 `useItem()`이 `item_used`를 발행하므로 진행도가 1 증가한다.  
두 번째 이벤트에서 목표치에 도달하면 완료 상태를 기록하고 `quest_completed`를 한 번 발행한다.

**Q2. `attack()`을 안 고쳐도 되는 이유**

기존 `attack()`은 적을 처치한 순간 이름과 보상 골드를 담은 `enemy_killed`를 이미 발행한다.  
처치 목록은 이 이벤트의 이름을 저장하고, 업적 모델은 같은 이벤트의 보상 골드를 더한다.  
두 모델이 필요한 정보를 각자 구독하므로 공격의 처리 순서나 코드를 바꿀 필요가 없다.

**Q3. 업적 기준을 30으로 변경할 때 고칠 파일**

`06_dungeon/models/achievement_model.lua`의 `TARGET_GOLD`를 30으로 바꾼다.  
로그 문구는 이벤트에 담긴 기준을 사용하므로 새 숫자가 자동으로 표시된다.  
기준값 변경을 검증하려면 `tests/dungeon_test.lua`의 업적 경계와 전투 보상 예시도 새 기준에 맞춰 조정한다.
