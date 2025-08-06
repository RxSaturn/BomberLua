local grid = require("src.utils.grid")

local powerup = {
	gridX = 0, -- Posição X na grade
	gridY = 0, -- Posição Y na grade
	type = 1, -- Tipo de power-up (1-3)
	timer = 0, -- Temporizador para animação
}

-- Tipos de power-ups
powerup.TYPES = {
	BOMB_UP = 1, -- Aumenta o número máximo de bombas
	FIRE_UP = 2, -- Aumenta o alcance da explosão
	SPEED_UP = 3 -- Aumenta a velocidade de movimento
}

-- Cores para cada tipo de power-up
powerup.COLORS = {
	[1] = { 1, 0.2, 0.2 }, -- Vermelho (Bomba)
	[2] = { 1, 0.6, 0 }, -- Laranja (Fogo)
	[3] = { 0, 0.7, 1 } -- Azul (Velocidade)
}

-- Cria um novo power-up
function powerup:new(gridX, gridY, type)
	local newPowerup = {
		gridX = gridX,
		gridY = gridY,
		type = type or love.math.random(1, 3),
		timer = 0
	}

	setmetatable(newPowerup, self)
	self.__index = self
	return newPowerup
end

-- Atualiza a animação do power-up
function powerup:update(dt)
	self.timer = self.timer + dt * 2
end

-- Aplica o efeito do power-up ao jogador
function powerup:applyTo(player)
	if self.type == self.TYPES.BOMB_UP then
		player.maxBombs = player.maxBombs + 1
		return true
	elseif self.type == self.TYPES.FIRE_UP then
		player.bombPower = player.bombPower + 1
		return true
	elseif self.type == self.TYPES.SPEED_UP then
		player.speed = player.speed + 0.5
		return true
	end
	return false
end

-- Desenha o power-up na tela
function powerup:draw()
	local pixelX, pixelY = grid.toPixel(self.gridX, self.gridY)
	local centerX = pixelX + grid.TILE_SIZE / 2
	local centerY = pixelY + grid.TILE_SIZE / 2

	-- Tamanho base do power-up
	local baseSize = grid.TILE_SIZE * 0.35

	-- Efeito de pulsar
	local pulseEffect = math.sin(self.timer) * 0.2
	local size = baseSize * (1 + pulseEffect)

	-- Desenha o círculo do power-up com a cor correspondente ao tipo
	love.graphics.setColor(self.COLORS[self.type])
	love.graphics.circle("fill", centerX, centerY, size)

	-- Desenha o contorno branco
	love.graphics.setColor(1, 1, 1)
	love.graphics.circle("line", centerX, centerY, size)

	-- Desenha um símbolo interno baseado no tipo
	love.graphics.setColor(1, 1, 1)
	local symbolSize = size * 0.6

	if self.type == self.TYPES.BOMB_UP then
		-- Símbolo de bomba extra (cruz)
		love.graphics.line(centerX - symbolSize / 2, centerY, centerX + symbolSize / 2, centerY)
		love.graphics.line(centerX, centerY - symbolSize / 2, centerX, centerY + symbolSize / 2)
	elseif self.type == self.TYPES.FIRE_UP then
		-- Símbolo de fogo (triângulo)
		love.graphics.polygon("fill",
			centerX, centerY - symbolSize / 2,
			centerX + symbolSize / 2, centerY + symbolSize / 2,
			centerX - symbolSize / 2, centerY + symbolSize / 2
		)
	elseif self.type == self.TYPES.SPEED_UP then
		-- Símbolo de velocidade (seta)
		love.graphics.polygon("fill",
			centerX - symbolSize / 2, centerY - symbolSize / 2,
			centerX - symbolSize / 2, centerY + symbolSize / 2,
			centerX + symbolSize / 2, centerY
		)
	end

	-- Restaura a cor
	love.graphics.setColor(1, 1, 1)
end

return powerup
