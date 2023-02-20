local PauseMenu = {}
PauseMenu.__index = PauseMenu

function PauseMenu.new()
  local pauseMenu = {}
  setmetatable(pauseMenu, PauseMenu)

  return pauseMenu
end

function PauseMenu:update(dt)
    if love.keyboard.isDown("space") then
        return "board"
    end
end

function PauseMenu:draw(dt)
    local windowWidth, windowHeight = love.graphics.getDimensions()
    love.graphics.clear(0, 0, 0)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Game Paused!", windowWidth / 2 - 48, windowHeight/4)
end

return PauseMenu
