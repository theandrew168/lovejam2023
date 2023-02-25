local const = require("const")

function love.conf(t)
    local windowWidth = (const.size.box * const.board.width) + const.size.border + (2 * const.size.edge)
    local windowHeight = (const.size.box * const.board.height) + const.size.border + (2 * const.size.edge)

    t.title = "Khet"
    t.version = "11.4"
    t.window.width = windowWidth
    t.window.height = windowHeight
    t.window.resizable = false
end
