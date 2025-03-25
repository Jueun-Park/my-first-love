WindowWidth = 800
WindowHeight = 600
GroundWidth = WindowWidth
GroundHeight = 50

GameOver = false

function love.window()
    love.window.setMode(WindowWidth, WindowHeight)
    love.window.setTitle("My First Love")
end

function love.load()
    Ground = {
        width = GroundWidth,
        height = GroundHeight,
        x = 0,
        y = WindowHeight - GroundHeight,
    }
    Player = {
        width = 20,
        height = 20,
        x = WindowWidth / 2 - 10,
        y = WindowHeight - GroundHeight - 20,
        jumping = false,
        jumpSpeed = 0,
    }
    VerticalBullets = {}
    HorizontalBullets = {}
    GuidedBullets = {}
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.draw()
    if GameOver then
        love.graphics.setColor(255, 255, 255)
        love.graphics.print("Game Over", WindowWidth / 2 - 50, WindowHeight / 2 - 10)
        return
    else
        -- Ground
        love.graphics.setColor(0, 255, 0)
        love.graphics.rectangle("fill", Ground.x, Ground.y, Ground.width, Ground.height)

        -- Player
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle("fill", Player.x, Player.y, Player.width, Player.height)

        -- Bullets
        love.graphics.setColor(255, 0, 0)
        -- VerticalBullets
        if love.math.random(1, 1000) < 8 then
            table.insert(VerticalBullets, {
                width = 10,
                height = 10,
                x = love.math.random(0, WindowWidth - 10),
                y = 0,
                speed = love.math.random(100, 200),
            })
        end

        for i, bullet in ipairs(VerticalBullets) do
            love.graphics.rectangle("fill", bullet.x, bullet.y, bullet.width, bullet.height)
        end

        -- HorizontalBullets left to right
        if love.math.random(1, 1000) < 2 then
            table.insert(HorizontalBullets, {
                width = 10,
                height = 10,
                x = 0,
                y = love.math.random(WindowHeight-GroundHeight-Player.height, WindowHeight - GroundHeight - 10),
                speed = love.math.random(100, 200),
            })
        end

        for i, bullet in ipairs(HorizontalBullets) do
            love.graphics.rectangle("fill", bullet.x, bullet.y, bullet.width, bullet.height)
        end

        -- HorizontalBullets right to left
        if love.math.random(1, 1000) < 2 then
            table.insert(HorizontalBullets, {
                width = 10,
                height = 10,
                x = WindowWidth,
                y = love.math.random(WindowHeight-GroundHeight-Player.height, WindowHeight - GroundHeight - 10),
                speed = -love.math.random(100, 200),
            })
        end

        for i, bullet in ipairs(HorizontalBullets) do
            love.graphics.rectangle("fill", bullet.x, bullet.y, bullet.width, bullet.height)
        end

        -- GuidedBullets
        if love.math.random(1, 1000) < 5 then
            table.insert(GuidedBullets, {
                width = 10,
                height = 10,
                x = love.math.random(0, WindowWidth - 10),
                y = 0,
                speed = 100,
                dx = 0,
                dy = 0,
            })
        end

        for i, bullet in ipairs(GuidedBullets) do
            love.graphics.rectangle("fill", bullet.x, bullet.y, bullet.width, bullet.height)
        end
    end
end

function love.update(dt)
    for i, bullet in ipairs(VerticalBullets) do
        bullet.y = bullet.y + bullet.speed * dt
        if bullet.y > WindowHeight then
            table.remove(VerticalBullets, i)
        end
        if IsCollided(Player, bullet) then
            GameOver = true
        end
    end

    for i, bullet in ipairs(HorizontalBullets) do
        bullet.x = bullet.x + bullet.speed * dt
        if bullet.x > WindowWidth then
            table.remove(HorizontalBullets, i)
        end
        if IsCollided(Player, bullet) then
            GameOver = true
        end
    end

    for i, bullet in ipairs(GuidedBullets) do
        if bullet.dx == 0 and bullet.dy == 0 then
            bullet.dx = Player.x - bullet.x
            bullet.dy = Player.y - bullet.y
            local length = math.sqrt(bullet.dx * bullet.dx + bullet.dy * bullet.dy)
            bullet.dx = bullet.dx / length
            bullet.dy = bullet.dy / length
        end
        bullet.x = bullet.x + bullet.dx * bullet.speed * dt
        bullet.y = bullet.y + bullet.dy * bullet.speed * dt
        if bullet.y > WindowHeight then
            table.remove(GuidedBullets, i)
        end
        if IsCollided(Player, bullet) then
            GameOver = true
        end
    end

    if love.keyboard.isDown("right") then
        Player.x = Player.x + 100 * dt
    end
    if love.keyboard.isDown("left") then
        Player.x = Player.x - 100 * dt
    end
    if love.keyboard.isDown("up") and not Player.jumping then
        Player.jumping = true
        Player.jumpSpeed = -400
    end

    if Player.jumping then
        Player.y = Player.y + Player.jumpSpeed * dt
        Player.jumpSpeed = Player.jumpSpeed + 1000 * dt
        
        if Player.y >= WindowHeight - GroundHeight - Player.height then
            Player.y = WindowHeight - GroundHeight - Player.height
            Player.jumping = false
        end
    end
end

function IsCollided(a, b)
    return a.x < b.x + b.width and
           b.x < a.x + a.width and
           a.y < b.y + b.height and
           b.y < a.y + a.height
end
