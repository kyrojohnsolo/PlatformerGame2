function love.load()
    anim8 = require 'libraries/anim8/anim8' -- requires anim8 library which is used for animations.

    sprites = {} -- creates a sprites table
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png') -- creates the playersheet

    --[[
        this creates a grid from the PNG file
        the sheet is 9210 width 1692 height
        15 colums wide
        3 rows tall.
        9210 / 15 = 614
        1692 / 3 = 564
        those are plugged into anim8.newgrid below
        use the sprites.playerSheet:getWidth() and ..:getHeight() to calculate the width/height rather then used fixed number. 
    ]]
    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

    animations = {} -- creates animation table
    animations.idle = anim8.newAnimation(grid('1-15',1), 0.05) -- specifies column 1-15, row 1 for idle animation. cycles at 0.05
    animations.jump = anim8.newAnimation(grid('1-7',2), 0.05) -- specifies column 1-7, row 2 for idle animation. cycles at 0.05
    animations.run = anim8.newAnimation(grid('1-5',3), 0.05) -- specifies column 1-15, row 3 for idle animation. cycles at 0.05

    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0, 800, false) --creates 'world' for physics objects to exist in. Parameters is x,y value of gravity.
    world:setQueryDebugDrawing(true) -- draws debug colliders
    
    world:addCollisionClass('Platform') -- creates a collision class for platforms
    world:addCollisionClass('Player'--[[, {ignores = {'Platform'}}]]) -- creates a collision class for player
    world:addCollisionClass('Danger') -- creates a Danger Collision class
    

    player = world:newRectangleCollider(360,100, 80, 80, {collision_class = "Player"}) -- creates square for player.
    player:setFixedRotation(true) -- prevents the player object from rotating.
    player.speed = 240 --sets the player speed.
    player.animation = animations.run -- creates an animation property we can change
    player.maxJumpCount = 1
    player.jumpCount = 1
    platform = world:newRectangleCollider(250, 400, 300, 100, {collision_class = "Platform"}) -- creates platform.
    platform:setType('static') -- sets platform to 'static' so it's not impacted by gravity.

    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"}) -- creates the danger collion object
    dangerZone:setType('static') -- sets platform to 'static' so it's not impacted by gravity.
end

function love.update(dt)
    world:update(dt) -- updates the world to run at dt
    if player.body then -- this if statement checks to see if the player object is still in play.
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

    player.animation:update(dt) -- cycles animation with dt
end

function love.draw()
    world:draw() -- draws world on screen.
    player.animation:draw(sprites.playerSheet, 0, 0) -- draws playersheet to screen.
end

--[[
    Player Jump Function
    --uses the applyLinearImpulse to make player jump.
    --uses the queryRectangleArea to query the space below the player. 
    -- if any colliders are detected, then the player can jump.
    -- if now colliders are detected, the player cannot jump.
    -- CUSTOM WHOOOOO HOOOOO
    -- implemented double jump.
]]
function love.keypressed(key)
    if key == 'up' then
        local colliders = world:queryRectangleArea(player:getX() - 40, player:getY() + 40, 80, 2, {'Platform'})
        if #colliders > 0 and player.jumpCount > 0 then
            player:applyLinearImpulse(0, -7000)            
        end
        if #colliders > 0 and player.jumpCount == 0 then
            player:applyLinearImpulse(0, -7000)
            player.jumpCount = player.maxJumpCount            
        end
        if #colliders == 0 and player.jumpCount > 0 then
            player.jumpCount = player.jumpCount - 1
            player:applyLinearImpulse(0, -7000)
        end
    end
end

--[[
    This is just a debugging function that helps show how to query for colliders.
    when the user clicks the mouse, it will query a circle area for Platform and Danger colliders and destroy them.
]]

function love.mousepressed(x,y, button) 
    if button == 1 then
        local colliders = world:queryCircleArea(x,y, 200, {'Platform', 'Danger'})
        for i,c in ipairs(colliders) do
            c:destroy()
        end
    end
end