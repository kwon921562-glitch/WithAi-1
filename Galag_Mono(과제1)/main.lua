-- 1단계: 플레이어 사각형 + 좌우 이동 + 화면 경계 제한
-- local로 선언해 불필요한 전역 변수를 만들지 않는다.
local player = {
    x = 0,
    y = 0,
    width = 40,
    height = 24,
    speed = 300, -- 초당 이동 거리(픽셀)
}

-- 2단계: Space 발사(쿨다운) + 총알 위로 이동
local bullets = {}
local bulletWidth = 6
local bulletHeight = 12
local bulletSpeed = 500
local shotInterval = 0.2 -- 발사 사이에 기다리는 시간(초)
local shotCooldown = 0

-- 3단계: 적 편대(그리드) 생성 + 좌우 이동 + 끝에서 한 칸 하강
local enemies = {}
local enemyRows = 3
local enemyColumns = 8
local enemyWidth = 32
local enemyHeight = 24
local enemyGapX = 16
local enemyGapY = 16
local enemySpeed = 70
local enemyDirection = 1 -- 1은 오른쪽, -1은 왼쪽
local enemyDrop = enemyHeight + enemyGapY -- 한 줄 간격만큼 하강

local function createEnemies()
    enemies = {}
    enemyDirection = 1
    local formationWidth = enemyColumns * enemyWidth + (enemyColumns - 1) * enemyGapX
    local startX = (love.graphics.getWidth() - formationWidth) / 2

    for row = 1, enemyRows do
        for column = 1, enemyColumns do
            enemies[#enemies + 1] = {
                x = startX + (column - 1) * (enemyWidth + enemyGapX),
                y = 60 + (row - 1) * (enemyHeight + enemyGapY),
            }
        end
    end
end

local function updateEnemies(dt)
    if #enemies == 0 then
        return
    end

    -- 편대 전체의 양 끝을 찾고, 이번 프레임에 이동할 거리를 계산한다.
    local left = enemies[1].x
    local right = enemies[1].x + enemyWidth
    for _, enemy in ipairs(enemies) do
        left = math.min(left, enemy.x)
        right = math.max(right, enemy.x + enemyWidth)
    end

    local moveX = enemyDirection * enemySpeed * dt
    local reachedEdge = false
    if enemyDirection == 1 and right + moveX >= love.graphics.getWidth() then
        moveX = love.graphics.getWidth() - right
        reachedEdge = true
    elseif enemyDirection == -1 and left + moveX <= 0 then
        moveX = -left
        reachedEdge = true
    end

    -- 모든 적을 같은 거리만큼 이동해 그리드 모양을 유지한다.
    for _, enemy in ipairs(enemies) do
        enemy.x = enemy.x + moveX
        if reachedEdge then
            enemy.y = enemy.y + enemyDrop
        end
    end
    if reachedEdge then
        enemyDirection = -enemyDirection
    end
end

function love.load()
    -- 창 제목과 크기는 conf.lua의 설정을 사용한다.
    love.graphics.setBackgroundColor(0.05, 0.05, 0.1)

    -- 플레이어를 화면 아래쪽 중앙에 배치한다.
    player.x = (love.graphics.getWidth() - player.width) / 2
    player.y = love.graphics.getHeight() - player.height - 30
    bullets = {}
    shotCooldown = 0
    -- 3단계: 화면 위쪽 중앙에 3행 8열 편대를 만든다.
    createEnemies()
end

function love.update(dt)
    -- update에서는 입력을 처리하고 위치를 변경한다.
    local direction = 0
    if love.keyboard.isDown("left", "a") then
        direction = direction - 1
    end
    if love.keyboard.isDown("right", "d") then
        direction = direction + 1
    end

    -- dt를 곱하면 프레임 수와 관계없이 일정한 속도로 이동한다.
    player.x = player.x + direction * player.speed * dt

    -- 사각형 전체가 화면 안에 있도록 x를 제한(클램프)한다.
    local maxX = love.graphics.getWidth() - player.width
    player.x = math.max(0, math.min(player.x, maxX))

    -- 2단계: 기존 총알을 위로 이동하고, 화면 밖으로 나가면 제거한다.
    -- 뒤에서부터 순회하면 제거 후에도 다음 총알을 건너뛰지 않는다.
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet.y = bullet.y - bulletSpeed * dt
        if bullet.y + bulletHeight < 0 then
            table.remove(bullets, i)
        end
    end

    -- Space를 누르고 있으면 쿨다운마다 플레이어 중앙에서 발사한다.
    shotCooldown = math.max(0, shotCooldown - dt)
    if love.keyboard.isDown("space") and shotCooldown <= 0 then
        bullets[#bullets + 1] = {
            x = player.x + (player.width - bulletWidth) / 2,
            y = player.y - bulletHeight,
        }
        shotCooldown = shotInterval
    end

    -- 3단계: 적 편대의 위치와 이동 방향을 갱신한다.
    updateEnemies(dt)
end

function love.draw()
    -- draw에서는 현재 상태를 화면에 그리기만 한다.
    love.graphics.setColor(0.2, 0.9, 1)
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)

    -- 2단계: 총알은 노란색 사각형으로 그린다.
    love.graphics.setColor(1, 0.9, 0.2)
    for _, bullet in ipairs(bullets) do
        love.graphics.rectangle("fill", bullet.x, bullet.y, bulletWidth, bulletHeight)
    end

    -- 3단계: 적은 붉은색 사각형으로 그린다.
    love.graphics.setColor(1, 0.3, 0.4)
    for _, enemy in ipairs(enemies) do
        love.graphics.rectangle("fill", enemy.x, enemy.y, enemyWidth, enemyHeight)
    end
end
