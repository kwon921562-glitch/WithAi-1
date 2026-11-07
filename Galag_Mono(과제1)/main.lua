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

-- 4단계: 적 랜덤 발사 + 적 총알 아래로 이동
local enemyBullets = {}
local enemyBulletWidth = 6
local enemyBulletHeight = 12
local enemyBulletSpeed = 240
local enemyShotInterval = 0.8 -- 편대에서 0.8초마다 한 발 발사
local enemyShotCooldown = enemyShotInterval

-- 5단계: 사각형 충돌 판정 + 점수 증가 + 라이프 감소
local score = 0
local lives = 3
local scorePerEnemy = 100

-- 6단계: 파괴 파티클 + 피격 flash + 화면 shake
local particles = {}
local particleLifetime = 0.45
local flashDuration = 0.12
local flashTimer = 0
local shakeDuration = 0.25
local shakeTimer = 0
local shakeX, shakeY = 0, 0
local flashOpacity = 0
local shakeStrength = 0
-- 충돌 연출 확장: 폭발 링과 피격 후 1초간 무적/깜빡임
local bursts = {}
local burstLifetime = 0.35
local invincibleTimer = 0
local invincibleDuration = 1

-- 7단계: HUD(점수/라이프) + 게임오버 + R 키 재시작
local gameOver = false

local function spawnParticles(x, y, isPlayer)
    local color = isPlayer and {0.3, 0.9, 1} or {1, 0.7, 0.2}
    bursts[#bursts + 1] = {x = x, y = y, life = burstLifetime, color = color}
    for i = 1, 24 do
        local angle = love.math.random() * math.pi * 2
        local speed = love.math.random(60, 160)
        particles[#particles + 1] = {
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            life = particleLifetime,
            color = color,
        }
    end
end

-- 적 파괴는 짧고 약하게, 플레이어 피격은 길고 강하게 표현한다.
local function triggerScreenEffect(isPlayer)
    local duration = isPlayer and 0.2 or 0.08
    local opacity = isPlayer and 0.55 or 0.18
    local shakeTime = isPlayer and 0.35 or 0.14
    local strength = isPlayer and 12 or 4
    -- 동시에 여러 충돌이 나도 강한 연출을 약한 연출로 덮어쓰지 않는다.
    if flashTimer <= 0 or opacity >= flashOpacity then
        flashDuration = duration
        flashTimer = duration
        flashOpacity = opacity
    end
    if shakeTimer <= 0 or strength >= shakeStrength then
        shakeDuration = shakeTime
        shakeTimer = shakeTime
        shakeStrength = strength
        -- 충돌한 프레임부터 흔들림을 보이게 한다.
        shakeX = strength
        shakeY = -strength * 0.5
    end
end

local function damagePlayer()
    if invincibleTimer > 0 or lives <= 0 then
        return
    end
    lives = math.max(0, lives - 1)
    invincibleTimer = invincibleDuration
    spawnParticles(player.x + player.width / 2, player.y + player.height / 2, true)
    triggerScreenEffect(true)
end

local function updateEffects(dt)
    invincibleTimer = math.max(0, invincibleTimer - dt)
    for i = #bursts, 1, -1 do
        bursts[i].life = bursts[i].life - dt
        if bursts[i].life <= 0 then
            table.remove(bursts, i)
        end
    end
    for i = #particles, 1, -1 do
        local particle = particles[i]
        particle.life = particle.life - dt
        if particle.life <= 0 then
            table.remove(particles, i)
        else
            particle.x = particle.x + particle.vx * dt
            particle.y = particle.y + particle.vy * dt
        end
    end

    flashTimer = math.max(0, flashTimer - dt)
    shakeTimer = math.max(0, shakeTimer - dt)
    shakeX, shakeY = 0, 0
    if shakeTimer > 0 then
        -- 시간이 지날수록 흔들림을 줄인다. 실제 충돌 좌표는 바꾸지 않는다.
        local strength = shakeStrength * shakeTimer / shakeDuration
        shakeX = (love.math.random() * 2 - 1) * strength
        shakeY = (love.math.random() * 2 - 1) * strength
    end
end

-- 두 사각형이 가로와 세로 방향 모두 겹치면 충돌이다(AABB).
local function overlaps(ax, ay, aw, ah, bx, by, bw, bh)
    return ax < bx + bw and ax + aw > bx
        and ay < by + bh and ay + ah > by
end

local function checkCollisions()
    -- 내 총알 하나는 적 하나만 파괴한다.
    -- 삭제할 때 인덱스가 밀리지 않도록 뒤에서부터 검사한다.
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        for j = #enemies, 1, -1 do
            local enemy = enemies[j]
            if overlaps(bullet.x, bullet.y, bulletWidth, bulletHeight,
                enemy.x, enemy.y, enemyWidth, enemyHeight) then
                -- 6단계: 적을 제거하기 전에 중심에서 파괴 파티클을 만든다.
                spawnParticles(enemy.x + enemyWidth / 2, enemy.y + enemyHeight / 2)
                triggerScreenEffect(false)
                table.remove(bullets, i)
                table.remove(enemies, j)
                score = score + scorePerEnemy
                break -- 이미 제거한 총알로 다른 적을 검사하지 않는다.
            end
        end
    end

    -- 플레이어에 맞은 적 총알은 제거하고 라이프를 1 줄인다.
    for i = #enemyBullets, 1, -1 do
        local bullet = enemyBullets[i]
        if overlaps(bullet.x, bullet.y, enemyBulletWidth, enemyBulletHeight,
            player.x, player.y, player.width, player.height) then
            table.remove(enemyBullets, i)
            damagePlayer()
        end
    end

    -- 적 몸체에 닿아도 피격된다. 무적 중에는 접촉 피해를 받지 않는다.
    for _, enemy in ipairs(enemies) do
        if overlaps(player.x, player.y, player.width, player.height,
            enemy.x, enemy.y, enemyWidth, enemyHeight) then
            damagePlayer()
            break
        end
    end
end

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

local function updateEnemyBullets(dt)
    -- 기존 총알을 먼저 이동하고 화면 아래로 벗어난 총알을 제거한다.
    for i = #enemyBullets, 1, -1 do
        local bullet = enemyBullets[i]
        bullet.y = bullet.y + enemyBulletSpeed * dt
        if bullet.y > love.graphics.getHeight() then
            table.remove(enemyBullets, i)
        end
    end

    enemyShotCooldown = math.max(0, enemyShotCooldown - dt)
    if enemyShotCooldown <= 0 and #enemies > 0 then
        -- 살아 있는 적 중 한 마리를 무작위로 골라 아래쪽 중앙에서 발사한다.
        local shooter = enemies[love.math.random(#enemies)]
        enemyBullets[#enemyBullets + 1] = {
            x = shooter.x + (enemyWidth - enemyBulletWidth) / 2,
            y = shooter.y + enemyHeight,
        }
        enemyShotCooldown = enemyShotInterval
    end
end

-- 처음 시작할 때와 재시작할 때 같은 초기화 함수를 사용한다.
local function resetGame()
    -- 플레이어를 화면 아래쪽 중앙에 배치한다.
    player.x = (love.graphics.getWidth() - player.width) / 2
    player.y = love.graphics.getHeight() - player.height - 30
    bullets = {}
    shotCooldown = 0
    -- 3단계: 화면 위쪽 중앙에 3행 8열 편대를 만든다.
    createEnemies()
    -- 4단계: 적 총알과 발사 대기 시간을 초기화한다.
    enemyBullets = {}
    enemyShotCooldown = enemyShotInterval
    -- 5단계: 점수와 라이프 초기화.
    score = 0
    lives = 3
    -- 6단계: 연출 상태도 처음으로 되돌린다.
    particles = {}
    bursts = {}
    invincibleTimer = 0
    flashTimer, shakeTimer = 0, 0
    flashOpacity, shakeStrength = 0, 0
    shakeX, shakeY = 0, 0
    gameOver = false
end

function love.load()
    -- 창 제목과 크기는 conf.lua의 설정을 사용한다.
    love.graphics.setBackgroundColor(0.05, 0.05, 0.1)
    resetGame()
end

function love.keypressed(key)
    -- 7단계: 게임오버 상태에서 R 키를 한 번 누르면 새 게임을 시작한다.
    if gameOver and key == "r" then
        resetGame()
    end
end

function love.update(dt)
    -- 6단계: 기존 연출을 갱신한 뒤 이번 프레임의 충돌 연출을 생성한다.
    updateEffects(dt)
    -- 7단계: 게임오버 후에는 연출만 갱신하고 이동/발사/충돌을 멈춘다.
    if gameOver then
        return
    end
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
    -- 4단계: 이동한 적의 현재 위치에서 발사하고 적 총알을 갱신한다.
    updateEnemyBullets(dt)
    -- 5단계: 모든 위치를 갱신한 뒤 충돌을 검사한다.
    checkCollisions()
    -- 7단계: 라이프를 모두 잃으면 게임오버로 전환한다.
    if lives <= 0 then
        gameOver = true
    end
end

function love.draw()
    -- 6단계: 게임 화면에만 흔들림을 적용하고 그린 뒤 좌표계를 복원한다.
    love.graphics.push()
    love.graphics.translate(shakeX, shakeY)
    -- draw에서는 현재 상태를 화면에 그리기만 한다.
    -- 무적 시간 동안 밝은색과 반투명 색을 교대로 표시한다.
    local blinking = invincibleTimer > 0 and math.floor(invincibleTimer * 12) % 2 == 0
    if blinking then
        love.graphics.setColor(1, 1, 1, 0.3)
    else
        love.graphics.setColor(0.2, 0.9, 1)
    end
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

    -- 4단계: 적 총알은 플레이어 총알과 구분되는 주황색으로 그린다.
    love.graphics.setColor(1, 0.55, 0.15)
    for _, bullet in ipairs(enemyBullets) do
        love.graphics.rectangle("fill", bullet.x, bullet.y, enemyBulletWidth, enemyBulletHeight)
    end

    -- 6단계: 파티클은 남은 수명에 따라 서서히 투명해진다.
    for _, particle in ipairs(particles) do
        local color = particle.color
        love.graphics.setColor(color[1], color[2], color[3], particle.life / particleLifetime)
        love.graphics.rectangle("fill", particle.x - 2, particle.y - 2, 4, 4)
    end
    -- 충돌 지점에 밝은 중심과 바깥으로 퍼지는 링을 그린다.
    for _, burst in ipairs(bursts) do
        local progress = 1 - burst.life / burstLifetime
        local color = burst.color
        love.graphics.setColor(color[1], color[2], color[3], 1 - progress)
        love.graphics.circle("line", burst.x, burst.y, 4 + progress * 36)
        love.graphics.setColor(1, 1, 1, (1 - progress) * 0.8)
        love.graphics.circle("fill", burst.x, burst.y, 10 * (1 - progress))
    end
    love.graphics.pop()

    -- 흔들림과 관계없이 화면 전체에 반투명 흰색을 덮어 flash를 표현한다.
    if flashTimer > 0 then
        love.graphics.setColor(1, 1, 1, flashOpacity * flashTimer / flashDuration)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end
    love.graphics.setColor(1, 1, 1, 1)

    -- 7단계: HUD는 흔들리지 않는 화면 좌표에 표시한다.
    -- 기본 폰트로 표시할 수 있도록 영문을 사용한다.
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    love.graphics.print("Score: " .. score, 16, 16)
    love.graphics.printf("Lives: " .. lives, 0, 16, screenWidth - 16, "right")

    if gameOver then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("GAME OVER", 0, screenHeight / 2 - 40, screenWidth, "center")
        love.graphics.printf("Final Score: " .. score, 0, screenHeight / 2, screenWidth, "center")
        love.graphics.printf("Press R to restart", 0, screenHeight / 2 + 40, screenWidth, "center")
    end
end
