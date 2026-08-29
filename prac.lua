--예시
local a

print(type(a))

a = 10
print(a)


--루아는 정수가 없다.
--하지만 math.floor()를 이용해 정수처럼 사용할 수 있다.

-- 테이블에서 nil 대입 = 키 삭제
local t = {a = 1, b = 2}
t.b = nil          -- b 키가 테이블에서 사라짐

-- false와 nil만 거짓, 나머지는 전부 참

-- 전역 변수 (local 없이 선언)
x = 10              -- 전역! 어디서든 접근 가능

-- 지역 변수
local y = 20        -- 이 스코프에서만 유효

-- Lua는 다중 할당을 지원한다 (C/C#에는 없음)
local a, b, c = 1, 2, 3

-- 값이 부족하면 nil로 채움
local x, y = 1       -- x=1, y=nil

-- 값이 넘치면 버림
local x, y = 1, 2, 3 -- x=1, y=2, 3은 버려짐

-- 변수 교환 (temp 필요 없음!)
a, b = b, a           -- C에서는 temp 변수 필요

-- 블록 스코프 (C/C#과 유사)
do
    local x = 10
    print(x)           -- 10
end
print(x)               -- nil (블록 밖)

-- if 블록
if true then
    local msg = "hello"
    print(msg)         -- "hello"
end
print(msg)             -- nil

-- for 루프
for i = 1, 5 do
    local temp = i * 2
end
print(i)               -- nil (C#의 for 루프 변수와 동일)
print(temp)            -- nil

--중요****
-- 함수가 외부 local 변수를 캡처한다 (C#의 클로저와 동일)
function makeCounter()
    local count = 0          -- upvalue
    return function()
        count = count + 1    -- 캡처된 변수에 접근
        return count
    end
end

local counter = makeCounter()
print(counter())   -- 1
print(counter())   -- 2
print(counter())   -- 3

-- C# 비교:
-- Func<int> MakeCounter() {
--     int count = 0;
--     return () => ++count;
-- }

-- 자동 변환 (coercion)
print("10" + 5)        -- 15 (문자열이 숫자로 자동 변환)
print("10" .. 5)       -- "105" (숫자가 문자열로 자동 변환)

--***중요
-- ⚠️ 자동 변환에 의존하지 마라! 명시적 변환 사용
local n = tonumber("42")   -- 문자열 → 숫자
local s = tostring(42)     -- 숫자 → 문자열

-- 변환 실패 시 nil 반환 (에러가 아님 ⚠️)
local x = tonumber("abc")  -- nil (C#의 int.TryParse와 유사)

--table에서 문자열 이외에 숫자나 함수로 바꾸게 하고 싶으면 []를 사용

------------------------------------------------------------------------------------------------------------------------------------

local hp = 30

if hp <= 0 then
    print("Dead")
elseif hp < 30 then
    print("Danger")
else
    print("OK")
end

-- ⚠️ "else if"가 아니라 "elseif" (붙여 쓴다)
-- ⚠️ 중괄호 {} 없음 → then ... end 구조

-- 루아에는 switch/case 문이 없다. 대신 if/elseif/else를 사용하거나 테이블을 이용한 패턴 매칭을 사용할 수 있다.

-- for 변수 = 시작, 끝, 증감
for i = 1, 10 do        -- 1부터 10까지 (10 포함! ⚠️)
    print(i)
end

for i = 10, 1, -1 do    -- 10부터 1까지 역순
    print(i)
end

for i = 0, 1, 0.1 do    -- 0.0, 0.1, 0.2, ..., 1.0
    print(i)
end

--3번째 부분에는 step을 정할 수 있다. 생략하면 기본값은 1이다.

-- ⚠️ C와 다른 점:
-- 1. 끝 값이 포함된다 (C는 < 조건이 일반적)
-- 2. 루프 변수 i는 루프 내부에서만 유효 (local 자동)
-- 3. 루프 변수를 루프 안에서 수정해도 반복 횟수에 영향 없음

-- ipairs: 배열 부분 순회 (1, 2, 3, ... 연속 정수 키)
local fruits = {"apple", "banana", "cherry"}
for i, v in ipairs(fruits) do
    print(i, v)    -- 1 apple, 2 banana, 3 cherry
end

-- pairs: 전체 테이블 순회 (순서 보장 안 됨 ⚠️)
local player = {name = "Hero", hp = 100, mp = 50}
for k, v in pairs(player) do
    print(k, v)    -- 순서가 매번 다를 수 있음
end

--대부분은 ipairs를 사용하고, 키가 연속적이지 않거나 순서가 중요하지 않은 경우 pairs를 사용한다.
--and 연산자는 처음 false를 만나면 그 값을 반환하고, 모두 true이면 마지막 값을 반환한다.
--or 연산자는 처음 true를 만나면 그 값을 반환하고, 모두 false이면 마지막 값을 반환한다.

local full = "Player" .. " " .. "One"   -- "Player One"

-- ⚠️ 루프에서 .. 반복 사용은 느리다! (매번 새 문자열 생성)
-- ㄴ이유는 ..로 붙이면 문자열이 새로 만들어지기 때문에 메모리 할당이 반복된다. 따라서 문자열을 반복적으로 붙일 때는 table.concat()를 사용하는 것이 좋다.

local s = "Hello, World!"

-- 길이
print(#s)                        -- 13
print(string.len(s))             -- 13

-- 대소문자
print(string.upper(s))           -- "HELLO, WORLD!"
print(string.lower(s))           -- "hello, world!"

-- 부분 문자열 (1-based 인덱스! ⚠️)
print(string.sub(s, 1, 5))      -- "Hello" -- 1부터 5까지 (5 포함, 인덱스) 예: string.sub("Hello", 2, 5) → "ello"
print(string.sub(s, 8))         -- "World!" -- 3번째 인자는 끝을 정하는 의미인데 생략하게 되면 제일 끝까지 출력하게 됨
print(string.sub(s, -6))        -- "World!" (뒤에서 6번째부터) -- 음수 인덱스는 뒤에서부터 센다.
--*예외
-- string.sub(s, 2, 1) → "" (빈 문자열) -- 시작 인덱스가 끝 인덱스보다 크면 빈 문자열 반환

-- 반복
print(string.rep("ab", 3))      -- "ababab"

-- 뒤집기
print(string.reverse(s))        -- "!dlroW ,olleH"

-- 바이트 / 문자
print(string.byte("A"))         -- 65
print(string.char(65))          -- "A"

local s = "Hello, World!"

-- 단순 검색: 시작/끝 인덱스 반환
local start, finish = string.find(s, "World")
print(start, finish)   -- 8  12

-- 패턴 검색
local start, finish = string.find(s, "%a+")   -- 첫 번째 단어
print(start, finish)   -- 1  5

-- plain 모드 (패턴 해석 안 함)
-- 패턴 특수문자를 "문자 그대로" 찾고 싶을 때 사용
local text = "price = 9.99"
local dotPos = string.find(text, ".", 1, true)  -- 4번째 인자 = plain
print(dotPos)         -- 10

-- 시작 위치 지정 (3번째 인자)
local s2 = "cat dog cat"
print(string.find(s2, "cat"))       -- 1 3
print(string.find(s2, "cat", 2))    -- 9 11