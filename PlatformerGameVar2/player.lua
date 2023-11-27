player = world:newRectangleCollider(360,100, 40, 100, {collision_class = "Player"}) -- creates square for player.
    player:setFixedRotation(true) -- prevents the player object from rotating.
    player.speed = 240 --sets the player speed.
    player.animation = animations.idle -- creates an animation property we can change
    player.isMoving = false --used for animations. when true player is running, false is idle
    player.direction = 1 -- used for direction. flips the player in the draw.update function
    player.grounded = true -- detects if player is on the ground
    player.maxJumpCount = 1 -- used for double jumping
    player.jumpCount = 1 -- used for double jumping.

    function playerUpdate(dt)
        if player.body then -- this if statement checks to see if the player object is still in play.
        
            --[[
                This is a collider that checks if player is on the ground.
            ]]
            local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 50, 40, 2, {'Platform'})
            if #colliders > 0 then
                player.grounded = true
            else
                player.grounded = false
            end
            
            player.isMoving = false -- sets the player.isMoving to false by default (if no buttons are being pressed).
            local px, py = player:getPosition() -- creates local variable that grabs player position.
            --[[
                Player Movement Logic
                -left and right move player on X axis
                -player speed is set as global var
            ]]
            if love.keyboard.isDown('right') then
                player:setX(px + player.speed*dt)
                player.isMoving = true
                player.direction = 1
            end
            if love.keyboard.isDown('left') then
                player:setX(px - player.speed*dt)
                player.isMoving = true
                player.direction = -1
            end
            if player:enter('Danger') then
                player:destroy()
            end
        end
    
        --[[
            Cycles through run, idle or jump depending on user actions.
        ]]
        if player.grounded then
            if player.isMoving then
                player.animation = animations.run
            else
                player.animation = animations.idle
            end
        else
            player.animation = animations.jump
        end
        player.animation:update(dt) -- cycles animation with dt
    end

    function drawPlayer()
        local px, py = player:getPosition() -- creates a local variable for the player position
        player.animation:draw(sprites.playerSheet, px, py, nil, 0.25 * player.direction, 0.25, 130, 300) -- draws playersheet to screen.
    end