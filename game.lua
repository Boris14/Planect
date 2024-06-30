require("planet")
require("connection")
require("ship")
require("HUD")

local connectionPossible = false
local isSpawningShip = false

function connectionRayCastCallback(fixture, x, y, xn, yn, fraction)
  if fixture:getUserData().name == "Planet" then 
    connectionPossible = false
    return 0
  end
  return 1
end

function createGame(screenWidth, screenHeight, beginContact)
  local game = {}
  
  --Attributes
  game.world = love.physics.newWorld()
  game.world:setCallbacks(beginContact, endContact, preSolve, postSolve)
  music:play()
  game.stars = createStars(screenWidth, screenHeight * GAME_SCREEN_HEIGHT_RATIO)
  TAKEN_NAMES = {}
  game.planets = createPlanets(game.world, screenWidth, screenHeight * GAME_SCREEN_HEIGHT_RATIO, PLANETS_COUNT)
  for i, v in ipairs(game.planets) do
    if v.isConverted then
      game.mainBase = v.bases[1]
      break
    end
  end
  game.connections = populateConnections(game.planets)
  game.resources = MAX_RESOURCES
  game.resourceConsumption = RESOURCE_CONSUMPTION
  game.bounds = createBounds(game.world, screenWidth, screenHeight * GAME_SCREEN_HEIGHT_RATIO)
  game.HUD = createHUD(screenWidth, screenHeight, game.planets)
  
  --Methods
  game.update = function(dt)
    game.resources = game.resources - game.resourceConsumption * dt
    game.resourceConsumption = game.resourceConsumption + RESOURCE_CONSUMPTION_INCREASE_RATE * dt
    game.HUD.setResources(game.resources)
    game.world:update(dt)
    game.HUD.update(dt)
    game.planets.update(dt)
    
    if game.ship then
      game.ship.update(dt)
    end
    
    for i, v in ipairs(game.planets) do
      if game.HUD.convertedCivs[v.civName] and not v.isConverted then
        v.convert()
        game.resources = game.resources + CONVERT_RESOURCES
        if game.resources > MAX_RESOURCES then
          game.resources = MAX_RESOURCES
        end 
      end
    end
    
    if game.resources <= 0 then
      game.lost = true
      music:stop()
      loseSound:play()
      bigheadSounds:pause()
      tentacleSounds:pause()
      giantSounds:pause()
      twinsSounds:pause()
    elseif checkWinCondition(game.planets) then
      game.won = true
      music:stop()
      bigheadSounds:pause()
      tentacleSounds:pause()
      giantSounds:pause()
      twinsSounds:pause()
    end
    
    --Get antennas and bases
    local bases = {}
    local antennas = {}
    for i, v in ipairs(game.planets) do
      for k, l in ipairs(v.bases) do
        table.insert(bases, l)
      end
      for j, p in ipairs(v.antennas) do
        if p.isValid then
          table.insert(antennas, p)
        end
      end
    end
    
    --Manage connections
    for i, v in ipairs(bases) do
      for j, p in ipairs(antennas) do
        connectionPossible = true
        game.world:rayCast(v.endPoint.x, v.endPoint.y, p.endPoint.x, p.endPoint.y, connectionRayCastCallback)
        if connectionPossible and not isConnectionEnabled(game.connections[p.civName], p, v) and v.civName ~= p.civName then
          table.insert(game.connections[p.civName], createConnection(v, p))
        elseif not connectionPossible and isConnectionEnabled(game.connections[p.civName], p, v) then
          removeConnection(game.connections[p.civName], p, v)
        end
      end
    end
    
    for i, v in ipairs(game.planets) do
      if table.getn(game.connections[v.civName]) > 0 then
        game.HUD.addConnectedCiv(v.civName)
      elseif not v.isConverted then
        game.HUD.removeConnectedCiv(v.civName)
      end
    end
    
    updateConnections(game.connections, game.planets, dt)
  end
  
  game.draw = function()
    game.stars.draw()
    game.HUD.draw()
    game.planets.draw()
    
    if game.ship then 
      game.ship.draw()
    end
    
    drawConnections(game.connections, game.planets)
    
  end
  
  game.spawnShip = function()
    if (not game.ship or game.ship.body:isDestroyed()) and game.resources > SHIP_LAUNCH_RESOURCES then
      game.ship = createShip(game.world, game.mainBase.getSpawnPosition())
      game.resources = game.resources - SHIP_LAUNCH_RESOURCES
    end
  end
  
  game.mousepressed = function(x, y, index)
    if game.HUD.shipButton.pressed(x, y, index) then
      game.spawnShip()
    end
  end
  
  return game
end