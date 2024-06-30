local vector = require("libraries.vector")

function createAntenna(world, position, angle, planetRadius, civName)
  local antenna = {}
  
  --Attributes
  antenna.name = "Antenna"
  antenna.civName = civName
  antenna.isValid = true
  antenna.size = ANTENNA_SIZE_TO_PLANET * planetRadius
  antenna.body = love.physics.newBody(world, position.x, position.y, 'kinematic')
  antenna.shape = love.physics.newEdgeShape(0, 0, antenna.size, 0)
  antenna.fixture = love.physics.newFixture(antenna.body, antenna.shape)
  antenna.body:setAngle(angle)
  antenna.fixture:setUserData(antenna)
  if antennaSpawnSound:isPlaying() then antennaSpawnSound:stop() end
  antennaSpawnSound:play()
  local x1, y1, x2, y2 = antenna.shape:getPoints()
  antenna.endPoint = vector(antenna.body:getX() + x2, antenna.body:getY() + y2)
  
  --Methods
  antenna.update = function(dt)
    
  end
  
  antenna.draw = function()
    love.graphics.circle("fill", antenna.endPoint.x, antenna.endPoint.y, 3)
    love.graphics.line(antenna.body:getWorldPoints(antenna.shape:getPoints()))
  end
  
  antenna.handleCollision = function(other, coll)
    --Empty
  end
  
  return antenna
end