
function createBase(world, position, angle, planetRadius, civName)
  local base = {}
  
  --Attributes
  base.name = "Base"
  base.isMain = false
  base.size = BASE_SIZE_TO_PLANET * planetRadius
  base.civName = civName
  base.body = love.physics.newBody(world, position.x, position.y, 'kinematic')
  base.shape = love.physics.newCircleShape(base.size)
  base.fixture = love.physics.newFixture(base.body, base.shape)
  base.body:setAngle(angle)
  base.fixture:setUserData(base)
  
  if antennaSpawnSound:isPlaying() then antennaSpawnSound:stop() end
  antennaSpawnSound:play()
  
  local angleVector = vector(1, 0):setmag(base.size):rotate(angle)
  base.endPoint = vector(base.body:getPosition()) + angleVector
  
  
  --Methods
  base.update = function(dt)
    
  end
  
  base.draw = function()
    love.graphics.circle("fill", base.endPoint.x, base.endPoint.y, BASE_POINT_SIZE)
    love.graphics.setColor(NORMAL_COLOR)
    love.graphics.circle("fill", base.body:getX(), base.body:getY(), base.size)
    love.graphics.setColor(DRAW_COLOR)
    love.graphics.circle("line", base.body:getX(), base.body:getY(), base.size)
    if base.isMain then
      love.graphics.circle("fill", base.body:getX(), base.body:getY(), BASE_POINT_SIZE * 1.3)
    end
  end
  
  base.handleCollision = function(other, coll)
    --Empty
  end
  
  base.getSpawnPosition = function()
    local basePos = vector(base.body:getPosition())
    local forwardVec = base.endPoint - basePos 
    forwardVec:setmag(base.size + SHIP_SIZE * 1.5)
    return basePos + forwardVec
  end
  
  return base
end