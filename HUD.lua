require("utils")

function createHUD(screenWidth, screenHeight, planets)
  local HUD = {}

  HUD.civNames = {}
  HUD.connectedCivNames = {}
  HUD.civDialAddresses = {}
  HUD.civConvertMeters = {}
  HUD.convertedCivs = {}

  HUD.width = screenWidth
  HUD.height = screenHeight * (1 - GAME_SCREEN_HEIGHT_RATIO)
  HUD.origin = vector(0, screenHeight * GAME_SCREEN_HEIGHT_RATIO)
  HUD.planets = planets
  for i, v in ipairs(HUD.planets) do 
    table.insert(HUD.civNames, v.civName)
    HUD.civConvertMeters[v.civName] = 0
  end
  HUD.currCivConvertMeter = 0
  
  HUD.display = createDisplay(HUD.width, HUD.height)
  HUD.dial = createDial(HUD.width, HUD.height, HUD.origin)
  HUD.resourceBar = createResourceProgressBar(HUD.width, HUD.height)
  HUD.convertBar = createConvertProgressBar(HUD.width, HUD.height)
  HUD.shipButton = createButton(HUD.width, HUD.height, HUD.origin)
  
  HUD.update = function(dt)
    HUD.display.update(dt)
    HUD.dial.update(dt)
    HUD.shipButton.update(dt)
    
    for i, v in ipairs(HUD.civNames) do
      if not HUD.convertedCivs[v] then
        if HUD.civConvertMeters[v] > 0 then
          HUD.civConvertMeters[v] = HUD.civConvertMeters[v] - CONVERSION_DECREASE_RATE * dt
        else
          HUD.civConvertMeters[v] = 0
        end
      end
    end
    
    HUD.convertBar.setFillAmount(0)
    for i, v in ipairs(HUD.connectedCivNames) do
      if math.abs(HUD.dial.value - HUD.civDialAddresses[v]) <= HUD_DIAL_ADDRESS_ERROR then
        HUD.display.setAnim(false, v)
        HUD.convertBar.setFillAmount(HUD.civConvertMeters[v])
        if not HUD.convertedCivs[v] then
          if HUD.civConvertMeters[v] < 1 then
            HUD.civConvertMeters[v] = HUD.civConvertMeters[v] + (CONVERSION_RATE + CONVERSION_DECREASE_RATE) * dt
          elseif not HUD.convertedCivs[v] then
            HUD.convertedCivs[v] = true
          end
        end
      elseif HUD.display.civName == v then
        HUD.display.setAnim(false)
      end
    end
    
    for i, v in ipairs(HUD.civNames) do
        if HUD.convertedCivs[v] and math.abs(HUD.dial.value - HUD.civDialAddresses[v]) <= HUD_DIAL_ADDRESS_ERROR then
          HUD.display.setAnim(false, v)
          HUD.convertBar.setFillAmount(1)
        end
      end
  end

  HUD.draw = function()
    love.graphics.push()
    love.graphics.setColor(NORMAL_COLOR)
    love.graphics.translate(HUD.origin.x, HUD.origin.y)
    love.graphics.rectangle("fill", 0, 0, HUD.width, HUD.height)
    HUD.display.draw()
    HUD.dial.draw()
    HUD.shipButton.draw()
    HUD.resourceBar.draw()
    HUD.convertBar.draw()
    love.graphics.setColor(DRAW_COLOR)
    love.graphics.pop()
  end

  HUD.addConnectedCiv = function(civName)
    if addUnique(HUD.connectedCivNames, civName) then
      HUD.civDialAddresses[civName] = createDialAddress(HUD.connectedCivNames, HUD.civDialAddresses, HUD.dial.value)
      if HUD.display.civName == "" then 
        HUD.display.setAnim(false)
      end
    end
  end
  
  HUD.removeConnectedCiv = function(civName)
    removeElement(HUD.connectedCivNames, civName)
    if table.getn(HUD.connectedCivNames) <= 0 and not HUD.convertedCivs[civName] then
        HUD.display.setAnim(true)
        return
    end
    if HUD.display.civName == civName then
      HUD.display.setAnim(false)
    end
  end

  HUD.setResources = function(res)
    HUD.resourceBar.setFillAmount(res)
  end

  HUD.setConvertMeter = function(amount)
    HUD.convertBar.setFillAmount(amount)
  end

  return HUD
end

function createDisplay(HUDWidth, HUDHeight)
  local display = {}
  display.position = vector(HUDWidth * HUD_DISPLAY_POSITION_X, HUDHeight * HUD_DISPLAY_POSITION_Y)
  display.height = HUD_DISPLAY_HEIGHT * HUDHeight
  display.width = display.height * HUD_DISPLAY_RATIO 
  display.civName = ""
  display.scaleX = display.width / DISPLAY_IMAGE_WIDTH
  display.scaleY = display.height / DISPLAY_IMAGE_HEIGHT
  
  display.images = {}
  display.images["LOST"] = love.graphics.newImage('assets/lost.png')
  display.images["BIGHEAD"] = love.graphics.newImage('assets/bighead.png')
  display.images["TENTACLE"] = love.graphics.newImage('assets/tentacle.png')
  display.images["GIANT"] = love.graphics.newImage('assets/giant.png')
  display.images["TWIN"]  = love.graphics.newImage('assets/twin.png')
  
  display.lostConnectionG = anim8.newGrid(384, 216, display.images["LOST"]:getWidth(), display.images["LOST"]:getHeight())
  display.bigHeadG = anim8.newGrid(384, 216, display.images["BIGHEAD"]:getWidth(), display.images["BIGHEAD"]:getHeight())
  display.tentacleG = anim8.newGrid(384, 216, display.images["TENTACLE"]:getWidth(), display.images["TENTACLE"]:getHeight())
  display.giantG = anim8.newGrid(384, 216, display.images["GIANT"]:getWidth(), display.images["GIANT"]:getHeight())
  display.twinG = anim8.newGrid(384, 216, display.images["TWIN"]:getWidth(), display.images["TWIN"]:getHeight())
  
  display.animations = {}
  display.animations["LOST"] = anim8.newAnimation(display.lostConnectionG('1-3', 1), 0.1) 
  display.animations["BIGHEAD"] = anim8.newAnimation(display.bigHeadG('1-4', 1), 0.3) 
  display.animations["TENTACLE"] = anim8.newAnimation(display.tentacleG('1-4', 1), 0.3)
  display.animations["GIANT"] = anim8.newAnimation(display.giantG('1-4', 1), 0.3)
  display.animations["TWIN"] = anim8.newAnimation(display.twinG('1-4', 1), 0.3)
  
  display.update = function(dt)
    if display.animation then
      display.animation:update(dt)
    end
  end
  
  display.draw = function()
    love.graphics.setColor(1,1,1)
    love.graphics.push()
    love.graphics.translate(-display.width / 2, -display.height / 2)
    if display.animation then display.animation:draw(display.image, display.position.x, display.position.y, 0, display.scaleX, display.scaleY) 
    else
      love.graphics.setColor(BACKGROUND_COLOR)
      love.graphics.rectangle("fill", display.position.x, display.position.y, display.width, display.height)
    end
    
    love.graphics.pop()
    love.graphics.setColor(DRAW_COLOR)
  end
  
  display.setAnim = function(turnedOff, civName)
    if display.civName ~= "" then
      if civSounds[display.civName]:isPlaying() then 
        civSounds[display.civName]:pause()
      end
    end
    if civName then
      display.civName = civName
      display.animation = display.animations[civName]
      display.image = display.images[civName]
      civSounds[civName]:play()
    else
      display.civName = ""
      display.animation = display.animations["LOST"]
      display.image = display.images["LOST"]
    end
  end
  
  return display
end

function createDial(HUDWidth, HUDHeight, HUDOrigin)
  local dial = {}
  
  dial.HUDOffset = HUDOrigin
  dial.position = vector(HUDWidth * HUD_DIAL_POSITION_X, HUDHeight * HUD_DIAL_POSITION_Y)
  dial.width = HUD_DIAL_WIDTH * HUDWidth
  dial.buttonShape = love.physics.newCircleShape(dial.width * HUD_DIAL_BUTTON_SIZE)
  dial.value = 0.2 -- [0;1]
  dial.buttonPosition = dial.position + vector(dial.width * (dial.value - 0.5), 0)
  dial.minButtonX = dial.position.x - dial.width/2
  dial.maxButtonX = dial.position.x + dial.width/2
  dial.isGrabbed = false
  dial.sepWidth = dial.width / HUD_DIAL_SEP_COUNT
  dial.sepHeight = dial.buttonShape:getRadius() / 1.5
  
  dial.update = function(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    local realDialPos = dial.buttonPosition + dial.HUDOffset
    local isUnderMouse = dial.buttonShape:testPoint(realDialPos.x, realDialPos.y, 0, mouseX, mouseY)
    
    if isUnderMouse and love.mouse.isDown(1) then
      dial.isGrabbed = true
    elseif not love.mouse.isDown(1) then
      dial.isGrabbed = false
    end
    
    if dial.isGrabbed then
      dial.buttonPosition.x = mouseX
      if dial.buttonPosition.x < dial.minButtonX then
        dial.buttonPosition.x = dial.minButtonX
      elseif dial.buttonPosition.x > dial.maxButtonX then
        dial.buttonPosition.x = dial.maxButtonX
      end
    end
    
    --Calculate the value
    dial.value = (dial.buttonPosition.x - dial.position.x)/dial.width + 0.5
  end
  
  dial.draw = function()
    love.graphics.push()
    love.graphics.setColor(BACKGROUND_COLOR)
    love.graphics.translate(dial.position.x, dial.position.y)
    love.graphics.line(-dial.width/2, 0, dial.width/2, 0)
    love.graphics.translate(-dial.width/2, 0)
    for i = 1, HUD_DIAL_SEP_COUNT - 1 do
      love.graphics.line(i * dial.sepWidth, -dial.sepHeight / 2, i * dial.sepWidth, dial.sepHeight / 2)
    end
    love.graphics.translate(dial.width/2, 0)
    love.graphics.setColor(DARK_COLOR)
    love.graphics.circle("fill", (dial.width * dial.value) - dial.width/2, 0, dial.buttonShape:getRadius())
    love.graphics.pop()
  end
  
  return dial
end

function createResourceProgressBar(HUDWidth, HUDHeight)
  local bar = {}
  
  bar.position = vector(HUD_RESOURCE_BAR_POSITION_X * HUDWidth, HUD_RESOURCE_BAR_POSITION_Y * HUDHeight) 
  bar.width = HUD_RESOURCE_BAR_WIDTH * HUDWidth
  bar.height = HUD_RESOURCE_BAR_HEIGHT * HUDHeight
  bar.maxAmount = MAX_RESOURCES
  bar.currFill = 0.5
  bar.sepWidth = bar.width / HUD_RESOURCE_BAR_SEP_COUNT
  
  bar.update = function(dt)
    
  end
  
  bar.draw = function()
    love.graphics.push()
    love.graphics.translate(-gameFont:getWidth("RESOURCES:"), -gameFont:getHeight()/2)
    love.graphics.printf("RESOURCES:", bar.position.x, bar.position.y - bar.height, 500, "center")
    love.graphics.setColor(BACKGROUND_COLOR)
    love.graphics.pop()
    love.graphics.push()
    love.graphics.translate(-bar.width / 2, -bar.height / 2)
    love.graphics.rectangle("fill", bar.position.x, bar.position.y, bar.width, bar.height)
    love.graphics.setColor(DRAW_COLOR)
    love.graphics.rectangle("fill", bar.position.x, bar.position.y, bar.width * bar.currFill, bar.height)
    love.graphics.setColor(BACKGROUND_COLOR)
    for i = 0, HUD_RESOURCE_BAR_SEP_COUNT - 1 do
      love.graphics.rectangle("line", bar.position.x + i * bar.sepWidth, bar.position.y, bar.sepWidth, bar.height)
    end
    love.graphics.pop()
  end
  
  bar.setFillAmount = function(amount)
    if amount < 0 then amount = 0 end
    if amount > bar.maxAmount then amount = bar.maxAmount end
    bar.currFill = amount / bar.maxAmount
  end
  
  return bar
end

function createConvertProgressBar(HUDWidth, HUDHeight)
  local bar = {}
  
  bar.position = vector(HUD_CONVERT_BAR_POSITION_X * HUDWidth, HUD_CONVERT_BAR_POSITION_Y * HUDHeight) 
  bar.width = HUD_CONVERT_BAR_WIDTH * HUDWidth
  bar.height = HUD_CONVERT_BAR_HEIGHT * HUDHeight
  bar.currFill = 0.5
  bar.sepHeight = bar.height / HUD_CONVERT_BAR_SEP_COUNT
  
  bar.update = function(dt)
    
  end
  
  bar.draw = function()
    love.graphics.push()
    love.graphics.setColor(BACKGROUND_COLOR)
    love.graphics.translate(-bar.width / 2, -bar.height / 2)
    love.graphics.rectangle("fill", bar.position.x, bar.position.y, bar.width, bar.height)
    love.graphics.setColor(DRAW_COLOR)
    love.graphics.rectangle("fill", bar.position.x, bar.position.y + bar.height * (1 - bar.currFill), bar.width, bar.height * bar.currFill)
    love.graphics.setColor(BACKGROUND_COLOR)
    for i = 0, HUD_CONVERT_BAR_SEP_COUNT - 1 do
      love.graphics.rectangle("line", bar.position.x, bar.position.y + i * bar.sepHeight, bar.width, bar.sepHeight)
    end
    love.graphics.pop()
  end
  
  bar.setFillAmount = function(amount)
    if amount < 0 then amount = 0 end
    if amount > 1 then amount = 1 end
    bar.currFill = amount / 1
  end
  
  return bar
end

function createButton(HUDWidth, HUDHeight, HUDOffset)
  local button = {}
  
  button.position = vector(HUD_SHIP_BUTTON_POSITION_X * HUDWidth, HUD_SHIP_BUTTON_POSITION_Y * HUDHeight) 
  button.shape = love.physics.newCircleShape(HUD_SHIP_BUTTON_SIZE * HUDWidth)
  button.HUDOffset = HUDOffset
  button.image = love.graphics.newImage("assets/shipIcon.png")
  button.scale = button.shape:getRadius() / (button.image:getWidth() / 2) 
  button.text = ""
  
  button.update = function(dt)
    local realButtonPos = button.position + button.HUDOffset
    
    if button.shape:testPoint(realButtonPos.x, realButtonPos.y, 0, love.mouse.getPosition()) then
      button.text = "Spawn ship"
    else
      button.text = ""
    end
  end
  
  button.draw = function()
    love.graphics.push()
    love.graphics.setColor(1,1,1)
    love.graphics.translate(-button.shape:getRadius(), -button.shape:getRadius())
    love.graphics.draw(button.image, button.position.x, button.position.y, 0, button.scale, button.scale)
    love.graphics.setColor(DRAW_COLOR)
    love.graphics.pop()
    love.graphics.translate(-gameFont:getWidth(button.text), -gameFont:getHeight()/2)
    love.graphics.printf(button.text, button.position.x - (button.shape:getRadius() + gameFont:getWidth(button.text)/2), button.position.y, 500, "center")
    love.graphics.translate(gameFont:getWidth(button.text), gameFont:getHeight()/2)
  end
  
  button.pressed = function(x, y, index)
    if index ~= 1 then return false end
    local realButtonPos = button.position + button.HUDOffset
    return button.shape:testPoint(realButtonPos.x, realButtonPos.y, 0, x, y)
  end
  
  return button
end