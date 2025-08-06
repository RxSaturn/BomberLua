local grid = require("src.utils.grid")
local visual_effects = require("src.utils.visual_effects")

local explosion = {
	gridX = 0,   -- Posição X na grade
	gridY = 0,   -- Posição Y na grade
	timer = 0.5, -- Tempo de duração da explosão (em segundos)
	type = "center" -- Tipo de explosão (centro, horizontal, vertical)
}

-- Cria uma nova explosão
function explosion:new(gridX, gridY, type)
	local newExplosion = {
		gridX = gridX,
		gridY = gridY,
		timer = 0.5,
		type = type or "center"
	}

	-- Aplica efeito de tremor de tela se disponível
	if visual_effects and visual_effects.shakeScreen then
		visual_effects.shakeScreen(4, 0.15)
	end

	setmetatable(newExplosion, self)
	self.__index = self
	return newExplosion
end

-- Atualiza o temporizador da explosão
function explosion:update(dt)
	self.timer = self.timer - dt
	return self.timer <= 0 -- Retorna true quando a explosão acabar
end

-- Desenha a explosão
function explosion:draw()
	local pixelX, pixelY = grid.toPixel(self.gridX, self.gridY)

	-- Método antigo (fallback)
	if not visual_effects or not visual_effects.drawExplosion then
		-- Cor da explosão
		love.graphics.setColor(1, 0.3, 0, 0.8) -- Laranja avermelhado

		-- Desenha a explosão baseada no tipo
		love.graphics.rectangle("fill", pixelX + 4, pixelY + 4, grid.TILE_SIZE - 8, grid.TILE_SIZE - 8, 5, 5)

		-- Brilho central
		love.graphics.setColor(1, 0.8, 0, 0.5) -- Amarelo
		love.graphics.rectangle("fill", pixelX + 16, pixelY + 16, grid.TILE_SIZE - 32, grid.TILE_SIZE - 32, 3, 3)
	else
		-- Usa o novo sistema de efeitos visuais
		visual_effects.drawExplosion(pixelX, pixelY, grid.TILE_SIZE, self.type, self.timer)
	end

	-- Restaura a cor
	love.graphics.setColor(1, 1, 1)
end

return explosion
