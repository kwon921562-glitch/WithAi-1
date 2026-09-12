--[[-- string.find
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
print(string.find(s2, "cat", 2))    -- 9 11 ]]--

------------------------------------------------------------------------------------------------------------------------------------------

--string.match - 첫 번째 매치 추출
-- 숫자 추출
--[[ local year, month, day = string.match("2024-01-15", "(%d+)-(%d+)-(%d+)")
print(year, month, day)   -- 2024  01  15

-- 파일 이름/확장자 분리
local name, ext = string.match("sprite.png", "(.+)%.(%w+)") -- .+는 문자를 1개 이상 의미, %w는 알파벳/숫자/언더스코어 의미
print(name, ext)          -- sprite  png

-- 캡처가 없으면 "매치된 전체 문자열" 반환
local whole = string.match("id=AB-12", "%u%u%-%d%d") --캡처는 ()로 묶은 부분만 반환, 캡처가 없으면 전체 문자열 반환
print(whole)              -- "AB-12"

-- 캡처가 있으면 캡처들만 반환
local left, right = string.match("id=AB-12", "(%u%u)%-(%d%d)")
print(left, right)        -- AB  12

-- 매치 실패 시 nil
local v = string.match("hello", "%d+") -- %d+는 숫자를 1개 이상 의미
print(v)                  -- nil --]]

-------------------------------------------------------------------------------------------------------------------------------------

--string.gmatch - 모든 매치 반복 추출 (iterator)

-- 모든 단어 추출
--[[ for word in string.gmatch("Hello World Lua", "%a+") do --%a+는 알파벳을 1개 이상 의미
    print(word)    -- Hello, World, Lua
end

-- CSV 파싱
local csv = "100,200,300"
local values = {}
for num in string.gmatch(csv, "(%d+)") do
    values[#values + 1] = tonumber(num) --#values + 1는 배열의 마지막 인덱스 + 1, 즉 새 요소를 추가하는 의미, tonumber(num)는 문자열을 숫자로 변환
    print(values[#values]) -- 100, 200, 300
end

-- 로그에서 key=value 쌍 추출
local logLine = "stage=3 wave=12 hp=85 score=10900"
local kv = {}
for k, v in string.gmatch(logLine, "(%a+)=(%w+)") do
    kv[k] = v
    print(k, v)    -- stage 3, wave 12, hp 85, score 10900
end
-- kv.stage == "3", kv.wave == "12", kv.hp == "85"

-- 좌표 목록 파싱: "(10,20) (30,40)"
local points = {}
for x, y in string.gmatch("(10,20) (30,40)", "%((%-?%d+),(%-?%d+)%)") do --%-?는 마이너스 부호가 있어도 되고 없어도 된다”는 뜻
    points[#points + 1] = { x = tonumber(x), y = tonumber(y) } --#points + 1는 배열의 마지막 인덱스 + 1, 즉 새 요소를 추가하는 의미
    print(points[#points].x, points[#points].y)
end ]]--

--------------------------------------------------------------------------------------------------------------------------------------

-- 단순 치환
--[[local result = string.gsub("Hello World", "World", "Lua")
print(result)   -- "Hello Lua"

-- 패턴 치환
local result = string.gsub("hp:100 mp:50", "(%a+):(%d+)", "%1=%2") -- %1, %2는 캡처된 그룹을 의미
print(result)   -- "hp=100 mp=50"

-- 함수로 치환
local result = string.gsub("damage: 100", "%d+", function(n)
    return tostring(tonumber(n) * 2)
end)
print(result)   -- "damage: 200"

-- 치환 횟수 제한
local result, count = string.gsub("aaa", "a", "b", 2) --단순 치환에서 2번째 인자 = 치환 횟수 제한
print(result, count)   -- "bba"  2 --]]

--------------------------------------------------------------------------------------------------------------------------------------

--연습 문제

-- 출력: "[Wave 03] Enemy spawned at (12.50, -8.30) — HP: 100"
--[[ local wave = 3
local x, y = 12.5, -8.3
local hp = 100
-- 여기에 string.format 작성
print(string.format("[Wave %02d] Enemy spawned at (%.2f, %.2f) — HP: %d", wave, x, y, hp) ) --]]

--2번째
--[[local text = "Background: #FF0000, Text: #00FF00, Border: #0000FF"
-- 힌트: %x는 16진수 문자
for color in string.gmatch(text, "#(%x%x%x%x%x%x)") do
    print(color)   -- FF0000, 00FF00, 0000FF
end--]]

--3번째
--[[local parts = {}
for i = 1, 100 do
    parts[i] = tostring(i)
end
local result = table.concat(parts, ", ")
print(result) --]]

--4번째
--[[local status = "Player[Lv.15] HP:80/100"
local name, level, hp, maxHp = string.match(status, "(%a+)%[Lv.(%d+)%] HP:(%d+)/(%d+)")

print(string.format("이름: %s, 레벨: %d, 현재 HP: %d, 최대 HP: %d", name, tonumber(level), tonumber(hp), tonumber(maxHp))) --]]

--[[
-- Lv.1 기초 찾기 (1-20) 
1
local text = "I like apple pathfinder."
local s, e = string.find(text, "apple")

print(s ~= nil)
print(s, e)

2
local text = "A small game starts today"
local startpos = string.find(text, "game")
print(startpos)

3
local text = "Lua lua LUA"
local startPos = string.find(text, "lua")
print(startPos)

4
local text = "hello world"
local firstempty = string.find(text, " ")
print(firstempty)

5
local text = "red, green, blue"
local firstComma = string.find(text, ",")
print(firstComma)

6
local text = "banana"
local pos = 1
local lasta = nil

while true do
    local found = string.find(text, "a", pos)

    if found == nil then
        break
    end

    lasta = found
    pos = found + 1
end

print(lasta) -- 6

7
local text = "ID: player-01"
print(string.find(text, "^ID:") ~= nil)

8
local text = "sprite/player.png"
print(string.find(text, "%.png$") ~= nil)

9
local text = "ERROR: file not found"
print(string.find(text, "error")

10
local text = "Visit https://example.com now"
print(string.find(text, "://", 1, true))

11
local text = "ha ha ha"
local first = string.find(text, "ha")
local second = string.find(text, "ha", first + 1)

print(second)

12
local text = "ab--ab--ab"
local pos = 1
local s, e

for i = 1, 3 do
    s, e = string.find(text, "ab", pos)
    pos = e + 1
end

print(s)

13
local text = "12345 cat 678"
print(string.find(text, "cat", 6))

14
local text = "This is a simple island."

local pos = 1

while true do
    locel s, e = string.find(text, "is", pos)
    
    if s == nil then break end
    
    print(s, e)
    s = e + 1
end

15
local text = "name [player] score"
local first = string.find(text, "%[")
local last = string.find(text, "%]")
print(first, last)

16
local text = "player level 42"
local number = string.find(text, "%d+")
print(number)

17
local text = "123456"
local word = string.find(text, "%D+")
print(word)

18
local text = "level Up"
local Upper = string.find(text, "%u")
print(Upper)

19
local text = "1234abcDEF"
local Lower = string.find(text, "%l", 5)
print(Lower)

20
local text = "price = 9.99"
local dotPos = string.find(text, ".", 1, true)
print(dotPos)
--]]

--Lv.2 find 패턴 확장
--[[
21
local text = "cat scatter catapult cat"
for s, word in string.gmatch(text, "()(%f[%w]cat%f[%W])") do
    print(s)
end

22
local text = "one  two   three"
local pos = 1

while true do
    local s, e = string.find(text, "%s%s+", pos)

    if s == nil then
        break
    end

    print(s, e)

    pos = e + 1
end

23
local text = "Servers: 10.0.0.1 and 192.168.1.20"
local first, last = string.find(text, "%d+%.%d+%.%d+%.%d+")
print(first, last)

24
local text = "Events: 2026-09-05 and 2026-12-25"
local first, last = string.find(text, "%d%d%d%d%-%d%d%-%d%d")
print(first, last)
--]]

--[=[25
local text = [[say "hello world" then "bye"]]
local first, last = string.find(text, '".-"')
print(first, last)
--]=]

--[[
26
local text ="<div>content</div> <span>text</span>"
local first, last = string.find(text, "<(.-)>")
print(first, last)

27
local text = "draw(player, 10, 20)"
local first = string.find(text, "draw%(")
print(first, last)

28
local text = "flags: 0xFF and 0x10"
local first, last = string.find(text, "0x(%x+)")
print(first, last)

29
local text = "local hp = 100 -- player health"
local straw = string.find(text, "--", 1, true)
print(straw)

30
local text = "move(10, 20) then wait()"
local first, last = string.find(text, "%((.-)%)")
print(first, last)

31
local text = "Contact dev@example.com for help"
local first, last = string.find(text, "%w+@%w+%.%w+")
print(first, last)

32
local text = "Values: 3.14, 10.0, 7"
local first, last = string.find(text, "%d+%.%d+")
print(first, last)

33
local text = "name\tvalue"
local first, last = string.find(text, "%s")
print(first, last)

34
local text = "HP=120 MP=35"
local first, last = string.find(text, "%d+")
print(first, last)

35
local text = "Load /assets/images/player.png now"
local first, last = string.find(text, "/%w+")
print(first, last)
--]]

--Lv.3 match 기초 추출
--[[36
local text = "There are 24 enemies."
local number = string.match(text, "%d+")
print(number)

37
local text = "Email: knight@example.com"
local username = string.match(text, "(%w+)%@")
print(username)

38
local text = "Email: knight@example.com"
local domain = string.match(text, "%@(%w+%.%w+)")
print(domain)

39
local text = "Save file: player.stats.json"
local extension = string.match(text, "%.([%w_]+)$")
print(extension)

40
local text = "https://game.example.com/start"
local protocol = string.match(text, "^(%w+)://")
print(protocol)

41
local text = "Release date: 2026/09/05"
local year, month, day = string.match(text, "(%d+)/(%d+)/(%d+)")
print(year, month, day)

42
local text = "Start at 08:35 sharp"
local hour, minute = string.match(text, "(%d+):(%d+)")
print(hour, minute) 

43
local text = "name=kim"
local key, value = string.match(text, "(%w+)=(%w+)")
print(key, value)

44
local text = "Hello brave player"
local firstWord = string.match(text, "(%a+)")
print(firstWord)

45
local text = "The final score"
local lastWord = string.match(text, "(%a+)$")
print(lastWord)

46
local text = "color = rgb(12,34,56)"
local r, g, b = string.match(text, "%((%d+),(%d+),(%d+)%)")
print(r, g, b)

47
local text = "position: x=10,y=20"
local x, y = string.match(text, "x=(%d+),y=(%d+)")
print(x, y)

48
local text = "Changes: +42 -7 0"
local plus, number = string.match(text, "([%+%-]?)(%d+)")
print(plus, number)

49
local text = "price=12.50"
local integer, decimal = string.match(text, "(%d+)%.(%d+)")
print(integer, decimal)

50
local text = "bookkeeper"
local continuous = string.match(text, "(.)%1")
print(continuous)
--]]

--Lv.4 match 중급 파싱
--[[51
local text = "player_01"
local result = string.match(text, "^[%a_][%w_]*$")
print(result)

local text = "1player"
local result = string.match(text, "^[%a_][%w_]*$")
print(result ~= nil)
--]]

-- 52
local text = "score = 1234"
local name, value = string.match(text, "^%s*([%a_][%w_]*)%s*=%s*(%d+)%s*$")
print(name, value)

-- 53
local text = "local hp = 100"
local name, value = string.match(text, "^local%s+([%a_][%w_]*)%s*=%s*(%d+)%s*$")
print(name, value)

-- 54
local text = "move(player, 10, 20)"
local name, arguments = string.match(text, "([%a_][%w_]*)%s*(%b())")
print(name, arguments)

-- 55
local text = "user:'tom'"
local key, value = string.match(text, "(%w+):'([^']*)'")
print(key, value)

-- 56
local text = "[INFO] init done"
local level, message = string.match(text, "^%[([%u]+)%]%s*(.*)$")
print(level, message)

-- 57
local text = "[2026-09-05 10:30:15] hello"
local date, time, message = string.match(text, "^%[(%d%d%d%d%-%d%d%-%d%d)%s(%d%d:%d%d:%d%d)%]%s*(.*)$")
print(date, time, message)

-- 58
local text = "version v1.2.3"
local major, minor, patch = string.match(text, "v(%d+)%.(%d+)%.(%d+)")
print(major, minor, patch)

-- 59
local text = "accent color: #FFA07A"
local red, green, blue = string.match(text, "#(%x%x)(%x%x)(%x%x)")
print(red, green, blue)

-- 60
local text = "report.final.txt"
local base = string.match(text, "^(.+)%.[%w]+$")
print(base)

-- 61
local text = "### Intro to Lua"
local hashes, title = string.match(text, "^(#+)%s+(.+)$")
print(#hashes, title)

-- 62
local text = "  key_name : some value  "
local key, value = string.match(text, "^%s*([%w_]+)%s*:%s*(.-)%s*$")
print(key, value)

-- 63
local text = "updated 2026-09-05T14:30"
local date, time = string.match(text, "(%d%d%d%d%-%d%d%-%d%d)T(%d%d:%d%d)")
print(date, time)

-- 64
local text = "function foo_bar123(a, b)"
print(string.match(text, "^function%s+([%a_][%w_]*)%s*%("))

-- 65
local text = "game.core.player"
print(string.match(text, "([%w_]+)$"))

