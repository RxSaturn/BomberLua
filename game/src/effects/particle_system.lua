local particle_system = {}

function particle_system.createExplosionParticles(x, y, color)
	local ps = love.graphics.newParticleSystem(love.graphics.newCanvas(4, 4), 100)

	-- Define a imagem do canvas como um pixel branco
	love.graphics.setCanvas(ps:getTexture())
	love.graphics.clear()
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", 0, 0, 4, 4)
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)

	-- Configura o sistema de partículas
	ps:setPosition(x, y)
	ps:setParticleLifetime(0.3, 0.6)
	ps:setEmissionRate(200)
	ps:setSizes(2, 1, 0.5)
	ps:setSizeVariation(0.5)
	ps:setSpeed(50, 150)
	ps:setLinearAcceleration(0, 200)
	ps:setColors(
		color[1], color[2], color[3], 1,
		color[1], color[2], color[3], 0
	)

	ps:setEmissionArea("ellipse", 20, 20, 0, false)

	-- Emite um burst de partículas
	ps:emit(50)

	return ps
end

function particle_system.createPowerupCollectParticles(x, y, color)
	local ps = love.graphics.newParticleSystem(love.graphics.newCanvas(4, 4), 50)

	-- Define a imagem do canvas
	love.graphics.setCanvas(ps:getTexture())
	love.graphics.clear()
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", 0, 0, 4, 4)
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)

	-- Configura o sistema de partículas
	ps:setPosition(x, y)
	ps:setParticleLifetime(0.5, 1.0)
	ps:setEmissionRate(0)
	ps:setSizes(1, 0.5)
	ps:setSizeVariation(0.3)
	ps:setSpeed(30, 80)
	ps:setLinearAcceleration(0, -50)
	ps:setColors(
		color[1], color[2], color[3], 1,
		color[1] * 1.5, color[2] * 1.5, color[3] * 1.5, 0
	)

	ps:setEmissionArea("ellipse", 15, 15, 0, false)

	-- Emite um burst de partículas
	ps:emit(30)

	return ps
end

return particle_system
