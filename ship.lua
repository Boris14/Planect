

function createShip(world, position)
  local ship = {}
  
  --Attributes
  ship.name = "Ship"
  ship.body = love.physics.newBody(world, position.x, position.y, 'dynamic')
  shipSpawnSound:play()
  local triangleHeight = math.sqrt(3)/2 * SHIP_SIZE
  local leftVector = vector(-triangleHeight/3, -SHIP_SIZE/2)
  local rightVector = vector(-triangleHeight/3, SHIP_SIZE/2) 
  local forwardVector = vector(triangleHeight, 0)
  ship.shape = love.physics.newPolygonShape(leftVector.x, leftVector.y, forwardVector.x, forwardVector.y, rightVector.x, rightVector.y)
  ship.fixture = love.physics.newFixture(ship.body, ship.shape)
  ship.fixture:setUserData(ship)
  
  --Methods
  ship.update = function(dt)
    if not ship then return end
    
    local newVelocity = vector(0, 0)
    if love.keyboard.isDown("w") then
      newVelocity.y = newVelocity.y - SHIP_MAX_SPEED
    end
    if love.keyboard.isDown("a") then
      newVelocity.x = newVelocity.x - SHIP_MAX_SPEED
    end
    if love.keyboard.isDown("s") then
      newVelocity.y = newVelocity.y + SHIP_MAX_SPEED
    end
    if love.keyboard.isDown("d") then
      newVelocity.x = newVelocity.x + SHIP_MAX_SPEED
    end
    
    ship.body:setInertia(0)
    ship.body:setLinearVelocity(newVelocity.x, newVelocity.y)
    local angleX = love.mouse.getX() - ship.body:getX()
    local angleY = love.mouse.getY() - ship.body:getY()
    ship.body:setAngle(math.atan2(angleY, angleX))
  end
  
  ship.draw = function()
    if not ship then return end
    
    love.graphics.polygon('fill', ship.body:getWorldPoints(ship.shape:getPoints()))
  end
  
  ship.destroy = function()
    ship.body:destroy()
    ship = nil
  end
  
  ship.handleCollision = function(other, coll)
    --Empty
  end
  
  return ship
end