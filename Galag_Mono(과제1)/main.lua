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

function love.load()
    love.window.setTitle("Galaga - Step 2")
    love.window.setMode(800, 600)
    love.graphics.setBackgroundColor(0.05, 0.05, 0.1)

    -- 플레이어를 화면 아래쪽 중앙에 배치한다.
    player.x = (love.graphics.getWidth() - player.width) / 2
    player.y = love.graphics.getHeight() - player.height - 30
    bullets = {}
    shotCooldown = 0
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
end
