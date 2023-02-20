local MainMenu = {}
MainMenu.__index = MainMenu

function MainMenu.new()
  local mainmenu = {}
  setmetatable(mainmenu, MainMenu)

  return mainmenu
end

function MainMenu:update(dt)
    if love.keyboard.isDown("space") then
        return "board"
    end
end

function MainMenu:draw(dt)
    love.graphics.clear(0, 0, 0)
end

return MainMenu
