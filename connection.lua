require("utils")

function createConnection(base, antenna)
  local connection = {}
  
  connection.base = base
  connection.antenna = antenna
  connection.startPoint = base.endPoint
  connection.endPoint = antenna.endPoint
  connection.animationValue = 0

  connection.update = function(dt)
    if not connection.antenna.isValid then return end
    
    connection.startPoint = connection.base.endPoint
    connection.endPoint = connection.antenna.endPoint
    
    connection.animationValue = connection.animationValue + dt * 40
    if connection.animationValue >= CONNECTION_LINE_STRIPE_LENGTH - 1 then
      connection.animationValue = 0
    end
  end
  
  connection.draw = function()
    drawLine(connection.startPoint.x, connection.startPoint.y, connection.endPoint.x, connection.endPoint.y, connection.animationValue)
  end
  
  return connection
end

function populateConnections(planets)
  local connections = {}
  for i, v in ipairs(planets) do
    connections[v.civName] = {}
  end
  return connections
end

function isConnectionEnabled(civConnections, antenna, base)
  if not civConnections then return false end
  
  for i, v in ipairs(civConnections) do
    if v.antenna == antenna and v.base == base then
      return true
    end
  end
  return false
end

function removeConnection(civConnections, antenna, base)
  if not civConnections then return end
  
  for i, v in ipairs(civConnections) do
    if v.antenna == antenna and v.base == base then
      table.remove(civConnections, i)
      return
    end
  end
end

function updateConnections(connections, planets, dt)
  for i, v in ipairs(planets) do
    if connections[v.civName] then
      for j, p in ipairs(connections[v.civName]) do
        if not p.antenna.isValid then 
          table.remove(connections[v.civName], j)
        else
          p.update(dt)
        end
      end
    end
  end
end

function drawConnections(connections, planets)
  for i, v in ipairs(planets) do
    if connections[v.civName] then
      for j, p in ipairs(connections[v.civName]) do
        p.draw()
      end
    end
  end
end

