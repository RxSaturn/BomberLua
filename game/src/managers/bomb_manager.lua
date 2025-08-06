local grid = require("src.utils.grid")
local Bomb = require("src.entities.bomb")
local Explosion = require("src.entities.explosion")
local visual_effects = require("src.utils.visual_effects")

local bomb_manager = {
	bombs = {},  -- Lista de bombas ativas
	explosions = {} -- Lista de explosões ativas
}

-- Inicializa o gerenciador de bombas
function bomb_manager:init()
	self.bombs = {}
	self.explosions = {}
end

-- Verifica se há uma bomba em uma posição
function bomb_manager:hasBomb(gridX, gridY)
	for _, bomb in ipairs(self.bombs) do
		if bomb.gridX == gridX and bomb.gridY == gridY then
			return true
		end
	end
	return false
end

-- Adiciona uma bomba ao mapa
function bomb_manager:placeBomb(gridX, gridY, power, owner)
	-- Verifica se já existe uma bomba nessa posição
	if self:hasBomb(gridX, gridY) then
		return false
	end

	-- Cria e adiciona uma nova bomba
	local newBomb = Bomb:new(gridX, gridY, power, owner)
	table.insert(self.bombs, newBomb)
	return true
end

-- Cria uma explosão na posição especificada
function bomb_manager:createExplosion(gridX, gridY, power, owner, map_manager, powerup_manager)
	-- Adiciona efeito de tremor de tela
	visual_effects.shakeScreen(5, 0.2)

	-- Adiciona o centro da explosão
	local centerExplosion = Explosion:new(gridX, gridY, "center")
	table.insert(self.explosions, centerExplosion)

	-- Verifica se há um power-up no centro da explosão
	if powerup_manager then
		powerup_manager:destroyPowerupAt(gridX, gridY)
	end

	-- Direções da explosão: cima, direita, baixo, esquerda
	local directions = {
		{ 0, -1, "vertical" }, { 1, 0, "horizontal" },
		{ 0, 1,  "vertical" }, { -1, 0, "horizontal" }
	}

	-- Propaga a explosão em cada direção
	for _, dir in ipairs(directions) do
		local dx, dy, explosionType = unpack(dir)

		-- Propaga até o alcance máximo ou atingir uma parede
		for i = 1, power do
			local newX, newY = gridX + dx * i, gridY + dy * i

			-- Verifica se saiu dos limites
			if not grid.isWithinBounds(newX, newY) then
				break
			end

			-- Verifica se é uma parede indestrutível
			if map_manager:isWall(newX, newY) then
				-- É uma parede indestrutível?
				if map_manager.tiles[newY][newX] == 1 then
					-- Parede indestrutível, a explosão para
					break
				else
					-- Parede destrutível, a explosão a destrói e para
					map_manager:destroyWall(newX, newY, powerup_manager)

					-- Adiciona explosão neste ponto
					local wallExplosion = Explosion:new(newX, newY, explosionType)
					table.insert(self.explosions, wallExplosion)
					break
				end
			else
				-- Espaço vazio, a explosão continua
				local pathExplosion = Explosion:new(newX, newY, explosionType)
				table.insert(self.explosions, pathExplosion)

				-- Verifica se há um power-up nesta posição
				if powerup_manager then
					powerup_manager:destroyPowerupAt(newX, newY)
				end

				-- Verifica se há bombas nessa posição para causar reação em cadeia
				for i, bomb in ipairs(self.bombs) do
					if bomb.gridX == newX and bomb.gridY == newY then
						bomb.timer = 0 -- Faz a bomba explodir imediatamente
					end
				end
			end
		end
	end
end

-- Verifica se um jogador foi atingido por uma explosão
function bomb_manager:isPlayerHit(gridX, gridY)
	for _, explosion in ipairs(self.explosions) do
		if explosion.gridX == gridX and explosion.gridY == gridY then
			return true
		end
	end
	return false
end

-- Atualiza bombas e explosões
function bomb_manager:update(dt, map_manager, player_manager, powerup_manager)
	-- Atualiza as bombas
	for i = #self.bombs, 1, -1 do
		local bomb = self.bombs[i]
		local shouldExplode = bomb:update(dt)

		if shouldExplode then
			-- Explode a bomba
			self:createExplosion(bomb.gridX, bomb.gridY, bomb.power, bomb.owner, map_manager, powerup_manager)

			-- Remove a bomba
			table.remove(self.bombs, i)

			-- Decrementa o contador de bombas do jogador
			player_manager:decrementBombs(bomb.owner)
		end
	end

	-- Atualiza as explosões
	for i = #self.explosions, 1, -1 do
		local explosion = self.explosions[i]
		local isFinished = explosion:update(dt)

		if isFinished then
			table.remove(self.explosions, i)
		end
	end
end

-- Desenha bombas e explosões
function bomb_manager:draw()
	-- Desenha as bombas
	for _, bomb in ipairs(self.bombs) do
		function bomb:draw()
			local pixelX, pixelY = grid.toPixel(self.gridX, self.gridY)
			visual_effects.drawBomb(pixelX, pixelY, grid.TILE_SIZE, self.timer, true)
		end
	end

	-- Desenha as explosões
	for _, explosion in ipairs(self.explosions) do
		function explosion:draw()
			local pixelX, pixelY = grid.toPixel(self.gridX, self.gridY)
			visual_effects.drawExplosion(pixelX, pixelY, grid.TILE_SIZE, self.type, self.timer)
		end
	end
end

return bomb_manager
