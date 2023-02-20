local global = require("global")
local MainMenu = require("state.mainmenu")
local Board = require("state.board")
local PauseMenu = require("state.pausemenu")

-- red
-- silver 

-- 10x8 board
-- some tiles colored (only those pieces can be there)

-- pharaoh (lose if this gets hit)
-- obelisk (basic blocker)
-- pyramid (single mirror, destroyed if hit from behind)
-- djed (double mirror, can't be destroyed)

-- 2 lasers (in TL / BR corners, facing up/down)
-- turn: move (8 way) OR rotate (90) + check laser
-- djed can swap places with pyramid or obelisk or either color

-- classic
-- imhotep
-- dynasty

color = {
    black = {0.0, 0.0, 0.0},
    laser = {0.7, 0.2, 0.2},
    darkGray = {0.2, 0.2, 0.2},
    lightGray = {0.3, 0.3, 0.3},
    red = {0.6, 0.2, 0.2},
    silver = {0.7, 0.7, 0.7},
}

size = {
    tile = 64,
    border = 12,
    edge = 48,
}
size.box = size.tile + size.border

button = {
    xoff = size.edge + size.border + size.tile / 2,
    yoff = size.edge / 2,
    radius = (size.edge / 2) - 8,
}

board = {
    width = 10,
    height = 8,
    red = {
        {1, 1},
        {1, 2},
        {1, 3},
        {1, 4},
        {1, 5},
        {1, 6},
        {1, 7},
        {1, 8},
        {1, 8},
        {9, 1},
        {9, 8},
    },
    silver = {
        {10, 1},
        {10, 2},
        {10, 3},
        {10, 4},
        {10, 5},
        {10, 6},
        {10, 7},
        {10, 8},
        {10, 8},
        {2, 1},
        {2, 8},
    },
}

-- rotation: 1, 2, 3, 4
-- obelisk: all the same
-- pharaoh: up, right, down, left
-- pyramid: NE, SE, SW, NW (mirror direction)
-- djed:    NE, SE, SW, NW (mirror direction)

-- https://www.ultraboardgames.com/khet-the-laser-game/game-rules.php
classic = {
    {tile = {5, 1}, kind = "obelisk", color = "red", rotation = 1},
    {tile = {6, 1}, kind = "pharoah", color = "red", rotation = 3},
    {tile = {7, 1}, kind = "obelisk", color = "red", rotation = 1},
    {tile = {8, 1}, kind = "pyramid", color = "red", rotation = 2},
    {tile = {3, 2}, kind = "pyramid", color = "red", rotation = 3},
    {tile = {4, 3}, kind = "pyramid", color = "silver", rotation = 4},
    {tile = {1, 4}, kind = "pyramid", color = "red", rotation = 1},
    {tile = {3, 4}, kind = "pyramid", color = "silver", rotation = 3},
    {tile = {5, 4}, kind = "djed", color = "red", rotation = 1},
    {tile = {6, 4}, kind = "djed", color = "red", rotation = 2},
    {tile = {8, 4}, kind = "pyramid", color = "red", rotation = 2},
    {tile = {10, 4}, kind = "pyramid", color = "silver", rotation = 4},
    {tile = {1, 5}, kind = "pyramid", color = "red", rotation = 2},
    {tile = {3, 5}, kind = "pyramid", color = "silver", rotation = 4},
    {tile = {5, 5}, kind = "djed", color = "silver", rotation = 2},
    {tile = {6, 5}, kind = "djed", color = "silver", rotation = 1},
    {tile = {8, 5}, kind = "pyramid", color = "red", rotation = 1},
    {tile = {10, 5}, kind = "pyramid", color = "silver", rotation = 3},
    {tile = {7, 6}, kind = "pyramid", color = "red", rotation = 2},
    {tile = {8, 7}, kind = "pyramid", color = "silver", rotation = 1},
    {tile = {3, 8}, kind = "pyramid", color = "silver", rotation = 4},
    {tile = {4, 8}, kind = "obelisk", color = "silver", rotation = 1},
    {tile = {5, 8}, kind = "pharoah", color = "silver", rotation = 1},
    {tile = {6, 8}, kind = "obelisk", color = "silver", rotation = 1},
}


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
    local mode = classic
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

down = false
function love.update(dt)
    local transition = state:update(dt)
    if transition == "board" then
        state = Board.new()
    elseif transition == "pause" then
        state = PauseMenu.new()
    end

    if not soundtrack:isPlaying() then
        love.audio.play(soundtrack)
    end
end

function love.draw(dt)
    state:draw(dt)
end
