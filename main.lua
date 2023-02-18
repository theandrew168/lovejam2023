debug = true

function love.load(arg)

end

function love.update(dt)

end

function love.draw(dt)
	local mx, my = love.mouse.getPosition()
	local windowWidth, windowHeight = love.graphics.getDimensions()
	love.graphics.line(windowWidth/2, windowHeight/2, mx, my)
end
