function love.load()
    love.window.setMode(1000, 768)
    anim8 = require 'libraries/anim8/anim8' -- requires anim8 library which is used for animations.
    sti = require 'libraries/Simple-Tiled-Implementation/sti' -- requires the titled implementation library

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

    wf = require 'libraries/windfield/windfield' -- requires windfall library (physics)
    world = wf.newWorld(0, 800, false) --creates 'world' for physics objects to exist in. Parameters is x,y value of gravity.
    world:setQueryDebugDrawing(true) -- draws debug colliders
    
    world:addCollisionClass('Platform') -- creates a collision class for platforms
    world:addCollisionClass('Player'--[[, {ignores = {'Platform'}}]]) -- creates a collision class for player
    world:addCollisionClass('Danger') -- creates a Danger Collision class

    require('player') -- requires the player.lua file containing player-based information
    
    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"}) -- creates the danger collion object
    dangerZone:setType('static') -- sets platform to 'static' so it's not impacted by gravity.

    platforms = {} -- creates a table for platform data

    loadMap() --loads map
end

function love.update(dt)
    world:update(dt) -- updates the world to run at dt
    gameMap:update(dt) -- updates map with dt
    playerUpdate(dt) -- runs the player update in player.lua file
end

function love.draw()
    gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
    world:draw() -- draws world on screen.
    drawPlayer() -- runs the drawplayer function in the player.lua file
   
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
        if player.grounded and player.jumpCount > 0 then
            player:applyLinearImpulse(0, -4000)
            player.animation = animations.jump            
        end
        if player.grounded and player.jumpCount == 0 then
            player:applyLinearImpulse(0, -4000)
            player.jumpCount = player.maxJumpCount
            player.animation = animations.jump            
        end
        if player.grounded == false and player.jumpCount > 0 then
            player.jumpCount = player.jumpCount - 1
            player:applyLinearImpulse(0, -4000)
            player.animation = animations.jump
        end
    end
end


--[[ This is the default jumping from the tutorial.
function love.keypressed(key)
    if key == 'up' then
        if player.grounded then
            player:applyLinearImpulse(0,-4000)
        end
    end
end
]]

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


--[[
    This function spawns the platform with the data provided by Tiled and inserts into platforms table
]]
function spawnPlatform(x, y, width, height)
    if width > 0 and height > 0 then
        local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"}) -- creates platform.
        platform:setType('static') -- sets platform to 'static' so it's not impacted by gravity.
        table.insert(platforms, platform)
    end
end

--[[
    this function loads the mapa and loops through all platforms to spawn the platform data
]]
function loadMap(mapName)
    gameMap = sti("maps/level1.lua")
    for i, obj in pairs(gameMap.layers["Platforms"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end
end
