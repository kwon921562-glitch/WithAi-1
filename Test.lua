-- 1
local text = "Lua is fun"

local startPos, endPos = string.find(text, "fun", 1, true)

print(startPos ~= nil, startPos, endPos)


-- 2
local text = "player.png"

print(string.find(text, "%.png$") ~= nil)


-- 3
local text = "score = 3500"

local number = string.match(text, "%d+")

print(number)


-- 4
local text = "Email: hero@example.com"

local user, domain = string.match(text, "(%w+)@([%w%.]+)")

print(user)
print(domain)


-- 5
local text = "red,green,blue,yellow"

for color in string.gmatch(text, "[^,]+") do
    print(color)
end


-- 6
local text = "x=10 y=25 z=7"

for name, value in string.gmatch(text, "(%w+)=(%d+)") do
    print(name, value)
end


-- 7
local text = "[WARN] low hp"

local level, message = string.match(text, "%[(%w+)%]%s+(.+)")

print(level)
print(message)


-- 8
local text = "items: sword(2), potion(10), key(1)"

for item, count in string.gmatch(text, "(%w+)%((%d+)%)") do
    print(item, count)
end


-- 9
local text = "path/to/player_idle_01.png"

local filename, extension = string.match(text, "([^/]+)%.(%w+)$")

print(filename)
print(extension)


-- 10
local text = [[move(player, 10) wait() attack(enemy_boss)]]

for functionName in string.gmatch(text, "(%w+)%b()") do
    print(functionName)
end