-- 1단계: 플레이어 사각형 + 좌우 이동 + 화면 경계 제한
-- local로 선언해 불필요한 전역 변수를 만들지 않는다.
local player = {
    x = 0,
    y = 0,
    width = 40,
    height = 24,
    speed = 300, -- 초당 이동 거리(픽셀)
}

function love.load()
    love.window.setTitle("Galaga - Step 1")
    love.window.setMode(800, 600)
    love.graphics.setBackgroundColor(0.05, 0.05, 0.1)

    -- 플레이어를 화면 아래쪽 중앙에 배치한다.
    player.x = (love.graphics.getWidth() - player.width) / 2
    player.y = love.graphics.getHeight() - player.height - 30
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
end

function love.draw()
    -- draw에서는 현재 상태를 화면에 그리기만 한다.
    love.graphics.setColor(0.2, 0.9, 1)
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
end
