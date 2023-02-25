local const = require("const")
local global = require("global")

local MainMenu = require("state.mainmenu")
local Board = require("state.board")
local PauseMenu = require("state.pausemenu")


-- states:
-- main menu -> exit, board
--  start game w/ specific mode (classic, etc)
--  exit game
-- pause menu -> exit, board
--  unpause, back to board (escape)
--  exit game
-- game over -> main menu
--  any button takes back to main menu
-- board -> pause, selection, laser
--  pause the game (escape)
--  select a piece (of current player's turn)
--  click the laser button to end turn
-- selection -> board, laser
--  escape to deselect
--  select a piece of your color on your turn
--  move or rotate
-- laser -> board, game over
--  if pharoah hit, game over
--  else do the animation and return to board


local state
function love.load(arg)
    -- init main menu state
    state = MainMenu.new()

    -- load the funky egyptian font
    local font = love.graphics.newFont("font/hieros.ttf", 36)
    love.graphics.setFont(font)

    -- load the music / sfx
    soundtrack = love.audio.newSource("sounds/test.mp3", "stream")

    -- initialize the game state
    global.tiles = {}
    local mode = const.layout.classic
    for _, p in ipairs(mode) do
        -- naive copy to keep game modes unmutated
        table.insert(global.tiles, {
            tile = {p.tile[1], p.tile[2]},
            kind = p.kind,
            color = p.color,
            rotation = p.rotation,
        })
    end
end

function love.update(dt)
    local states = {
        mainmenu = MainMenu,
        pausemenu = PauseMenu,
        board = Board,
        selected = Selected,
        gameover = GameOver,
    }

    local transition = state:update(dt)
    if transition ~= nil then
        state = states[transition].new()
    end

    if not soundtrack:isPlaying() then
        love.audio.play(soundtrack)
    end
end

function love.draw(dt)
    state:draw(dt)
end
