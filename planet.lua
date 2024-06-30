require("antenna")
require("base")
require("utils")

function createPlanet(world, location, radius)
  local planet = {}
  
  --Attributes
  planet.name = "Planet"
  planet.antennas = {}
  planet.bases = {}
  planet.antennaSpawnParams = {}
  planet.isConverted = false
  planet.civName = chooseCivName(CIVILIZATION_NAMES, TAKEN_NAMES)
  
  planet.rotationSpeed = PLANET_ROTATION_SPEED
  if love.math.random() < 0.5 then planet.rotationDirection = 1 
  else planet.rotationDirection = -1 end
  planet.radius = radius
  planet.body = love.physics.newBody(world, location.x, location.y, 'kinematic')
  planet.shape = love.physics.newCircleShape(planet.radius)
  planet.fixture = love.physics.newFixture(planet.body, planet.shape)
  planet.fixture:setUserData(planet)
  
  --Methods
  planet.update = function(dt)
    rotatePlanet(planet, dt)
  end
  
  planet.draw = function()
    --Draw the antennas
    for i, v in ipairs(planet.antennas) do
      v.draw()
    end
    
    --Draw the bases
    for i, v in ipairs(planet.bases) do
      v.draw()
    end
    
    --Draw the planet
    love.graphics.setColor(BACKGROUND_COLOR)
    love.graphics.circle("fill", planet.body:getX(), planet.body:getY(), planet.radius)
    love.graphics.setColor(DRAW_COLOR)
    love.graphics.circle("line", planet.body:getX(), planet.body:getY(), planet.radius)
  end
  
  planet.handleCollision = function(other, coll)
    if other:getUserData().name ~= "Ship" then return end
    other:getUserData().destroy()
    
    planet.antennaSpawnParams.pos = vector(coll:getPositions())
    planet.antennaSpawnParams.angle = math.atan2(planet.antennaSpawnParams.pos.y - planet.body:getY(),
                                                  planet.antennaSpawnParams.pos.x - planet.body:getX())
    tick.delay(planet.spawnAntenna, ANTENNA_SPAWN_DELAY)
  end
  
  planet.spawnAntenna = function()    
    if planet.isConverted then 
      table.insert(planet.bases, createBase(planet.body:getWorld(), planet.antennaSpawnParams.pos, 
                                          planet.antennaSpawnParams.angle, planet.radius, planet.civName))
    else
      table.insert(planet.antennas, createAntenna(planet.body:getWorld(), planet.antennaSpawnParams.pos, 
                                          planet.antennaSpawnParams.angle, planet.radius, planet.civName))
    end
    planet.antennaSpawnParams = {}
  end
  
  planet.convert = function()
    if planet.isConverted then return end
  
    if convertSound:isPlaying() then convertSound:stop() end
    convertSound:play()
    for i, v in ipairs(planet.antennas) do
      local pos = vector(v.body:getPosition())
      table.insert(planet.bases, createBase(planet.body:getWorld(), pos, v.body:getAngle(), planet.radius, planet.civName))
      v.isValid = false
    end
    planet.antennas = {}
    planet.isConverted = true
  end
  
  return planet
end

function createPlanets(world, screenWidth, screenHeight, count)
  local planets = {}
  local planetMinRadius = PLANET_RADIUS_COUNT_RATIO / count
  local planetMaxRadius = planetMinRadius * 2
  
  for i = 1, count do
    table.insert(planets, createPlanet(world, createSpawnLocation(planets, screenWidth, screenHeight), 
                  love.math.random(planetMinRadius, planetMaxRadius)))
  end
  
  --Choose the player planet
  local i = love.math.random(count - 1)
  planets[i].isConverted = true
  planets[i].civName = PLAYER_CIV_NAME
  createBaseOnPlanet(planets[i])
  planets[i].bases[1].isMain = true
  
  planets.update = function(dt)
    for i, v in ipairs(planets) do
      v.update(dt)
    end
  end
  
  planets.draw = function()
    for i, v in ipairs(planets) do
      v.draw()
    end
  end
  
  return planets
end

function createBaseOnPlanet(planet)
  local basePositionVector = vector.random()
  basePositionVector:setmag(planet.radius)
  basePositionVector:rotate(love.math.random() * math.pi * 2)
  basePositionVector.x = basePositionVector.x + planet.body:getX()
  basePositionVector.y = basePositionVector.y + planet.body:getY()
  table.insert(planet.bases, createBase(planet.body:getWorld(), basePositionVector, basePositionVector:heading(), planet.radius, planet.civName))
end
