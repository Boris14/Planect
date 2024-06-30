

function createMenu(screenWidth, screenHeight)
  local menu = {}
  
  menu.width = screenWidth
  menu.height = screenHeight
  menu.startButton = createTextButton(menu, "PLAY")
  menu.tutorialButton = createTextButton(menu, "INFO", true)
  
  menu.update = function(dt)
    menu.startButton.update(dt)
  end

  menu.draw = function()
    love.graphics.setFont(titleFont)
    love.graphics.printf("PLANECT", menu.width/2 - titleFont:getWidth("PLANECT")/2, menu.height * 0.3 - titleFont:getHeight()/2, menu.width, "left")
    love.graphics.setFont(gameFont)
    menu.startButton.draw()
    menu.tutorialButton.draw()
  end
  
  menu.mousepressed = function(x, y, index)
    if menu.startButton.pressed(x, y, index) then
      return 1
    elseif menu.tutorialButton.pressed(x, y, index) then
      return 2
    else
      return 0
    end
  end
  
  return menu
end

function createEndScreen(screenWidth, screenHeight, isLosing)
  local screen = {}
  
  screen.width = screenWidth
  screen.height = screenHeight
  if isLosing then screen.title = "YOU LOSE!"
  else screen.title = "YOU WIN!" end
  screen.returnButton = createTextButton(screen, "RETURN")
  
  screen.mousepressed = function(x, y, index)
    return screen.returnButton.pressed(x, y, index)
  end
  
  screen.update = function(dt)
    screen.returnButton.update(dt)
  end
  
  screen.draw = function()
    love.graphics.setFont(titleFont)
    love.graphics.printf(screen.title, screen.width/2 - titleFont:getWidth(screen.title)/2,
                                        screen.height * 0.3 - titleFont:getHeight()/2, screen.width, "left")
    love.graphics.setFont(gameFont)
    screen.returnButton.draw()
  end
  
  return screen
end

function createTextButton(menu, text, isTutorial)
  local button = {}
  
  if isTutorial then
    button.position = vector(MENU_START_BUTTON_POSITION_X * menu.width, MENU_TUTORIAL_BUTTON_POSITION_Y * menu.height) 
  else
    button.position = vector(MENU_START_BUTTON_POSITION_X * menu.width, MENU_START_BUTTON_POSITION_Y * menu.height) 
  end
  button.width = MENU_START_BUTTON_WIDTH * menu.width
  button.height = MENU_START_BUTTON_HEIGHT * menu.height
  button.shape = love.physics.newRectangleShape(button.width, button.height)
  button.text = text
  
  button.update = function(dt)
    
  end
  
  button.draw = function()
    love.graphics.push()
    love.graphics.setColor(NORMAL_COLOR)
    love.graphics.translate(-button.width/2, -button.height/2)
    love.graphics.rectangle("fill", button.position.x, button.position.y, button.width, button.height)
    love.graphics.setColor(DRAW_COLOR)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", button.position.x, button.position.y, button.width, button.height)
    love.graphics.translate(button.width/2, button.height/2)
    love.graphics.setLineWidth(2)
    love.graphics.printf(button.text, button.position.x - gameFont:getWidth(button.text)/2, 
                          button.position.y - gameFont:getHeight()/2, button.width, "left")
    love.graphics.pop()
  end
  
  button.pressed = function(x, y, index)
    return button.shape:testPoint(button.position.x, button.position.y, 0, x, y)
  end
  
  return button
end

function createTutorial(screenWidth, screenHeight)
  local tutorial = {}
  
  tutorial.images = {}
  table.insert(tutorial.images, love.graphics.newImage("tutorial/1.png"))
  table.insert(tutorial.images, love.graphics.newImage("tutorial/2.png"))
  table.insert(tutorial.images, love.graphics.newImage("tutorial/3.png"))
  table.insert(tutorial.images, love.graphics.newImage("tutorial/4.png"))
  table.insert(tutorial.images, love.graphics.newImage("tutorial/5.png"))
  table.insert(tutorial.images, love.graphics.newImage("tutorial/6.png"))
  tutorial.index = 1
  tutorial.scaleX = screenWidth / tutorial.images[1]:getWidth()
  tutorial.scaleY = screenHeight / tutorial.images[1]:getHeight()
  
  tutorial.pressed = function()
    if tutorial.index < 6 then
      tutorial.index = tutorial.index + 1
      return false
    else return true end
  end

  tutorial.draw = function()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(tutorial.images[tutorial.index], 0, 0, 0, tutorial.scaleX, tutorial.scaleY)
    love.graphics.setColor(DRAW_COLOR)
  end
  
  return tutorial
end