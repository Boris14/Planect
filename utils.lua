
function chooseCivName(names, takenNames)
  local name = names[love.math.random(#names)]
  while takenNames[name] ~= nil do
    name = names[love.math.random(#names)]
  end
  takenNames[name] = true
  return name
end

function hasElement(t, element)
  for i, v in ipairs(t) do
    if v == element then return true end
  end
  return false
end

function addUnique(t, element)
  local found = false
  for i, v in ipairs(t) do
    if element == v then 
      found = true 
      break
    end
  end
  if not found then
    table.insert(t, element)
  end
  return not found
end

function removeElement(t, element)
  for i, v in ipairs(t) do
    if element == v then 
      table.remove(t, i)
      return
    end
  end
end

function convertPlanetCiv(planets, civName)
  for i, v in ipairs(planets) do
    if v.civName == civName and not v.isConverted then
      v.convert()
      return
    end
  end
end

function createDialAddress(connectedCivNames, civDialAddresses, currentDialValue)
  local newAddress
  local isValid = false
  while not isValid do
    newAddress = love.math.random()
    isValid = true
    for i, v in ipairs(connectedCivNames) do
      if civDialAddresses[v] then
        if math.abs(newAddress - civDialAddresses[v]) < HUD_DIAL_ADDRESS_ERROR or 
            math.abs(newAddress - currentDialValue) < HUD_DIAL_ADDRESS_ERROR then
          isValid = false
          break
        end
      end
    end
  end
  return newAddress
end

function scaleConstants(screenWidth, screenHeight)
	local widthScale = screenWidth / 1000
	local heightScale = screenHeight / 1000
  
  SHIP_SIZE = SHIP_SIZE * (widthScale + heightScale) / 2
  SHIP_MAX_SPEED = SHIP_MAX_SPEED * (widthScale + heightScale) / 2
  PLANET_RADIUS_COUNT_RATIO = PLANET_RADIUS_COUNT_RATIO * (widthScale + heightScale) / 2
  BASE_POINT_SIZE = BASE_POINT_SIZE * (widthScale + heightScale) / 2
end

--Planet
function isSpawnLocationOk(planets, spawnLocation, boundsDist)
  local minDist = 10000
  for i, v in ipairs(planets) do
    local loc = vector(v.body:getX(), v.body:getY())
    if minDist > spawnLocation:dist(loc) then 
      minDist = spawnLocation:dist(loc)
    end
  end
  if minDist >= boundsDist * 2 then return true 
  else return false end
end

function createSpawnLocation(planets, screenWidth, screenHeight)
  local boundsDistance = (PLANET_RADIUS_COUNT_RATIO / PLANETS_COUNT) * 2.5
  local spawnLocation = vector(love.math.random(boundsDistance, screenWidth - boundsDistance), 
                                  love.math.random(boundsDistance, screenHeight - boundsDistance))
  while not isSpawnLocationOk(planets, spawnLocation, boundsDistance) do
    spawnLocation = vector(love.math.random(boundsDistance, screenWidth - boundsDistance), 
                                love.math.random(boundsDistance, screenHeight - boundsDistance))
  end
  return spawnLocation
end

function rotatePlanet(planet, dt)
  --Rotate the antennas
  for i, v in ipairs(planet.antennas) do
      rotateAroundPlanet(planet, v, dt)
    end
    
    --Rotate the bases
    for i, v in ipairs(planet.bases) do
      rotateAroundPlanet(planet,v, dt)
    end
end

function rotateAroundPlanet(planet, obj, dt)
  local planetCenter = vector(planet.body:getPosition())
  local antennaPos = vector(obj.body:getPosition())
  local angleVector = antennaPos - planetCenter
  local angleDelta = planet.rotationDirection * planet.rotationSpeed * dt
  angleVector:rotate(angleDelta)
  local newPosition = planetCenter + angleVector
  angleVector:setmag(planet.radius + obj.size)
  obj.endPoint = planetCenter + angleVector
  obj.body:setPosition(newPosition.x, newPosition.y)
  obj.body:setAngle(obj.body:getAngle() - angleDelta)
end

function createBounds(world, screenWidth, screenHeight)
  local bounds = {}
  table.insert(bounds, createBound(world, 0, 0, screenWidth, 0)) --top
  table.insert(bounds, createBound(world, screenWidth, 0, 0, screenHeight)) --right
  table.insert(bounds, createBound(world, 0, screenHeight, screenWidth, 0)) --bottom
  table.insert(bounds, createBound(world, 0, 0, 0, screenHeight)) --left
  
  bounds.update = function(dt)
    for i,v in ipairs(bounds) do
      v.update(dt)
    end
  end
  
  bounds.draw = function()
    for i, v in ipairs(bounds) do
      v.draw()
    end
  end
  
  return bounds
end

function createBound(world, bodyX, bodyY, shapeX2, shapeY2)
  local bound = {}
  
  bound.name = "Bound"
  bound.body = love.physics.newBody(world, bodyX, bodyY, "static")
  bound.shape = love.physics.newEdgeShape(0, 0, shapeX2, shapeY2)
  bound.fixture = love.physics.newFixture(bound.body, bound.shape)
  bound.fixture:setUserData(bound)
  
  bound.handleCollision = function(other, coll)
    if other:getUserData().name ~= "Ship" then return end
    other:getUserData().destroy()
    destroyShipSound:play()
  end
  
  bound.draw = function()
    love.graphics.line(bound.body:getWorldPoints(bound.shape:getPoints()))
  end
  
  return bound
end

function checkWinCondition(planets)
  local hasWon = true
  for i, v in ipairs(planets) do
    if not v.isConverted then
      hasWon = false
      break
    end
  end
  return hasWon
end

function drawLine(x1, y1, x2, y2, d)
  local x, y = x2 - x1, y2 - y1
  local len = math.sqrt(x^2 + y^2)
  local stepx, stepy = x / len, y / len
  x = x1
  y = y1
  
  d = 0
  
  local show = true
  for i = 1, len do
    if((i + math.floor(d)) % CONNECTION_LINE_STRIPE_LENGTH == 0) then
      show = not show
    end
    if show then
      love.graphics.points(x, y)
    end
    x = x + stepx
    y = y + stepy
  end
end

function createStars(screenWidth, screenHeight)
  local stars = {}
  
  for i = 1, STARS_COUNT do
    local star = {}
    star.x = love.math.random() * screenWidth
    star.y = love.math.random() * screenHeight
  
    star.draw = function()
      love.graphics.points(star.x, star.y)
    end
    
    table.insert(stars, star)
  end
  
  stars.draw = function()
    love.graphics.setPointSize(2)
    for i, v in ipairs(stars) do
      v.draw()
    end
  end
  
  return stars
end