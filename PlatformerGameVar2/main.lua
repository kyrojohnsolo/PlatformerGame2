function love.load()
    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0, 800, false) --creates 'world' for physics objects to exist in. Parameters is x,y value of gravity.
    
    world:addCollisionClass('Platform') -- creates a collision class for platforms
    world:addCollisionClass('Player'--[[, {ignores = {'Platform'}}]]) -- creates a collision class for player
    world:addCollisionClass('Danger')
    

    player = world:newRectangleCollider(360,100, 80, 80, {collision_class = "Player"}) -- creates square for player.
    player:setFixedRotation(true)
    player.speed = 240 --sets the player speed.
    platform = world:newRectangleCollider(250, 400, 300, 100, {collision_class = "Platform"}) -- creates platform.
    platform:setType('static') -- sets platform to 'static' so it's not impacted by gravity.

    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
    dangerZone:setType('static') -- sets platform to 'static' so it's not impacted by gravity.
end

function love.update(dt)
    world:update(dt) -- updates the world to run at dt
    if player.body then
        local px, py = player:getPosition() -- creates local variable that grabs player position.
        --[[
            Player Movement Logic
            -left and right move player on X axis
            -player speed is set as global var
        ]]
        if love.keyboard.isDown('right') then
            player:setX(px + player.speed*dt)
        end
        if love.keyboard.isDown('left') then
            player:setX(px - player.speed*dt)
        end
        if player:enter('Danger') then
            player:destroy()
        end
    end
end

function love.draw()
    world:draw() -- draws world on screen.
end

--[[
    Player Jump Function
    --uses the applyLinearImpulse to make player jump.
]]
function love.keypressed(key)
    if key == 'up' then
        player:applyLinearImpulse(0, -7000)
    end
end