tick = require("libraries.tick")
vector = require("libraries.vector")
anim8 = require("libraries.anim8")
require("game")
require("menu")
require("utils")

local screenWidth
local screenHeight

local tutorial
local menu
local game
local endScreen

local keymap = {
    escape = function()
      love.event.quit()
    end
}

function love.keypressed(key)
  if keymap[key] then
    keymap[key]()
  end
  if tutorial and tutorial.pressed() then 
    enterMainMenu()
  end
end

function love.mousepressed( x, y, button, istouch, presses )
  if menu and menu.mousepressed(x, y, button) == 1 then
    startNewGame(screenWidth, screenHeight)
  elseif menu and menu.mousepressed(x, y, button) == 2 then
    enterTutorial(screenWidth, screenHeight)
  elseif game then
    game.mousepressed(x, y, button)
  elseif (endScreen and endScreen.mousepressed(x, y, button))
        or (tutorial and tutorial.pressed()) then
    enterMainMenu()
  end
end

function love.load()
  gameFont = love.graphics.newFont("assets/ponde.ttf", 30)
  titleFont = love.graphics.newFont("assets/ponde.ttf", 100)

  music = love.audio.newSource("sounds/music.mp3", "stream")
  shipSpawnSound = love.audio.newSource("sounds/spawnShip.wav", "static")
  destroyShipSound = love.audio.newSource("sounds/death.wav", "static")
  bigheadSounds = love.audio.newSource("sounds/Bighead.mp3", "stream")
  tentacleSounds = love.audio.newSource("sounds/Tentacle.mp3", "stream")
  giantSounds = love.audio.newSource("sounds/Giant.mp3", "stream")
  twinsSounds = love.audio.newSource("sounds/Twins.mp3", "stream")
  antennaSpawnSound = love.audio.newSource("sounds/antennaSpawn.wav", "static")
  convertSound = love.audio.newSource("sounds/convert.wav", "static")  
  loseSound = love.audio.newSource("sounds/lose.wav", "static") 
    
  music:setLooping(true)
  bigheadSounds:setLooping(true)
  tentacleSounds:setLooping(true)
  giantSounds:setLooping(true)
  twinsSounds:setLooping(true)
  
  bigheadSounds:setVolume(0.4)
  tentacleSounds:setVolume(0.4)
  giantSounds:setVolume(0.4)
  twinsSounds:setVolume(0.4)
  
  convertSound:setVolume(0.5)
  antennaSpawnSound:setVolume(0.6)
  
  civSounds = {}
  civSounds["BIGHEAD"] = bigheadSounds
  civSounds["TENTACLE"] = tentacleSounds
  civSounds["TWIN"] = twinsSounds
  civSounds["GIANT"] = giantSounds
  
  love.window.setFullscreen(true)
  love.graphics.setFont(gameFont)
  love.graphics.setBackgroundColor(BACKGROUND_COLOR)
  love.graphics.setColor(DRAW_COLOR)
  screenWidth = love.graphics.getWidth()
  screenHeight = love.graphics.getHeight()
  scaleConstants(screenWidth, screenHeight)
  enterMainMenu()
end

function love.update(dt)
  tick.update(dt)
  if menu then
    menu.update(dt)
  elseif endScreen then
    endScreen.update(dt)
  elseif game then
    game.update(dt)
    if game.lost then endGame(true)
    elseif game.won then endGame(false)
    end
  end
end

function love.draw()
  if menu then
    menu.draw()
  elseif game then
    game.draw()
  elseif endScreen then
    endScreen.draw()
  elseif tutorial then
    tutorial.draw()
  end
end

function beginContact(a, b, coll)
  a:getUserData().handleCollision(b, coll)
  b:getUserData().handleCollision(a, coll)
end

function enterMainMenu()
  menu = createMenu(screenWidth, screenHeight)
  game = nil
  endScreen = nil
  tutorial = nil
end

function enterTutorial()
  tutorial = createTutorial(screenWidth, screenHeight)
  menu = nil
  game = nil
  endScreen = nil
end

function startNewGame()
  game = createGame(screenWidth, screenHeight, beginContact, music)
  menu = nil
  endScreen = nil
  tutorial = nil
end

function endGame(isLosing)
  endScreen = createEndScreen(screenWidth, screenHeight, isLosing)
  game = nil
  menu = nil
  tutorial = nil
end
