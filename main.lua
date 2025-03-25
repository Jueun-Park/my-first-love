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
    Bullets = {}

    JumpSound = love.audio.newSource("assets/beep.wav", "static")
end

function CreateBullet(x, y, dx, dy)
    table.insert(Bullets, {
        width = 10,
        height = 10,
        x = x,
        y = y,
        dx = dx,
        dy = dy,
    })
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.update(dt)

    -- VerticalBullets
    if love.math.random(1, 1000) < 8 then
        speed = love.math.random(100, 200)
        CreateBullet(love.math.random(0, WindowWidth - 10), 0, 0, speed)
    end

    -- HorizontalBullets
    if love.math.random(1, 1000) < 3 then
        speed = love.math.random(100, 200)
        dx = love.math.random(-1, 1)
        if dx == 0 then
        x = 0
        dx = 1
        else
            x = WindowWidth
        end
        dx = dx * speed
        CreateBullet(x, love.math.random(WindowHeight-GroundHeight-Player.height, WindowHeight - GroundHeight - 10), dx, 0)
    end

    -- GuidedBullets
    if love.math.random(1, 1000) < 5 then
        speed = love.math.random(100, 200)
        x = love.math.random(0, WindowWidth - 10)
        y = 0
        dx = Player.x - x
        dy = Player.y - y
        length = math.sqrt(dx * dx + dy * dy)
        dx = dx / length * speed
        dy = dy / length * speed
        CreateBullet(x, y, dx, dy)
    end

    for i, bullet in ipairs(Bullets) do
        bullet.x = bullet.x + bullet.dx * dt
        bullet.y = bullet.y + bullet.dy * dt
        if bullet.y > WindowHeight or bullet.x < 0 or bullet.x > WindowWidth then
            table.remove(Bullets, i)
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
        love.audio.play(JumpSound)
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
        for i, bullet in ipairs(Bullets) do
            love.graphics.rectangle("fill", bullet.x, bullet.y, bullet.width, bullet.height)
        end
    end
end