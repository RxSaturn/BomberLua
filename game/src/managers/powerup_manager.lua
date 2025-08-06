local grid = require("src.utils.grid")
local Powerup = require("src.entities.powerup")
local powerup_utils = require("src.utils.powerup_utils")
local visual_effects = require("src.utils.visual_effects")

local powerup_manager = {
	powerups = {},   -- Lista de power-ups ativos visíveis
	hiddenPowerups = {} -- Mapeamento de power-ups escondidos em paredes destrutíveis
}

-- Inicializa o gerenciador de power-ups
function powerup_manager:init(map_manager)
	self.powerups = {}
	self.hiddenPowerups = {}

	-- Gera power-ups escondidos nas paredes destrutíveis
	self:generateHiddenPowerups(map_manager)
end

-- Gera power-ups escondidos em paredes destrutíveis
function powerup_manager:generateHiddenPowerups(map_manager)
	local destructibleWalls = {}

	-- Encontra todas as paredes destrutíveis
	for y = 1, grid.HEIGHT do
		for x = 1, grid.WIDTH do
			if map_manager.tiles[y][x] == 2 then
				table.insert(destructibleWalls, { x = x, y = y })
			end
		end
	end

	-- Determina quantos power-ups gerar (aproximadamente 30% das paredes destrutíveis)
	local powerupCount = math.floor(#destructibleWalls * 0.3)

	-- Embaralha as paredes para seleção aleatória
	powerup_utils.shuffle(destructibleWalls)

	-- Distribui power-ups uniformemente entre os tipos
	for i = 1, powerupCount do
		if i <= #destructibleWalls then
			local wall = destructibleWalls[i]

			-- Escolhe o tipo de power-up (distribui uniformemente)
			local powerupType = (i % 3) + 1

			-- Armazena usando uma chave única baseada na posição
			local key = wall.y * grid.WIDTH + wall.x
			self.hiddenPowerups[key] = powerupType
		end
	end

	print("Gerados " .. powerupCount .. " power-ups escondidos em paredes destrutíveis")
end

-- Revela um power-up quando uma parede destrutível é destruída
function powerup_manager:revealPowerupAt(gridX, gridY)
	local key = gridY * grid.WIDTH + gridX
	local powerupType = self.hiddenPowerups[key]

	if powerupType then
		-- Cria um novo power-up visível nesta posição
		local newPowerup = Powerup:new(gridX, gridY, powerupType)
		table.insert(self.powerups, newPowerup)

		-- Remove o power-up escondido do mapa
		self.hiddenPowerups[key] = nil

		-- Efeito visual de surgimento
		local pixelX, pixelY = grid.toPixel(gridX, gridY)
		local centerX = pixelX + grid.TILE_SIZE / 2
		local centerY = pixelY + grid.TILE_SIZE / 2

		-- Adiciona luz temporária no local onde o power-up apareceu
		if visual_effects.addLight then
			local color = visual_effects.COLORS.POWERUPS[powerupType] or { 1, 1, 1 }
			visual_effects.addLight(centerX, centerY, grid.TILE_SIZE * 1.5, color[1], color[2], color[3], 0.5)
		end

		return true
	end

	return false
end

-- Verifica se existe um power-up em uma posição
function powerup_manager:hasPowerupAt(gridX, gridY)
	for _, p in ipairs(self.powerups) do
		if p.gridX == gridX and p.gridY == gridY then
			return true
		end
	end
	return false
end

-- Coleta um power-up em uma posição (para jogador)
function powerup_manager:collectPowerupAt(gridX, gridY, player)
	for i, p in ipairs(self.powerups) do
		if p.gridX == gridX and p.gridY == gridY then
			-- Aplica o efeito ao jogador
			if p:applyTo(player) then
				-- Adiciona efeito visual de coleta
				visual_effects.shakeScreen(2, 0.1)

				-- Posição central do power-up para efeitos
				local pixelX, pixelY = grid.toPixel(gridX, gridY)
				local centerX = pixelX + grid.TILE_SIZE / 2
				local centerY = pixelY + grid.TILE_SIZE / 2

				-- Adiciona uma luz brilhante no ponto de coleta
				if visual_effects.addLight then
					local color = visual_effects.COLORS.POWERUPS[p.type] or { 1, 1, 1 }
					visual_effects.addLight(centerX, centerY, grid.TILE_SIZE * 2, color[1], color[2], color[3], 0.3)
				end

				-- Cria partículas para coleta
				if visual_effects.createParticles then
					local color = visual_effects.COLORS.POWERUPS[p.type] or { 1, 1, 1 }
					visual_effects.createParticles("collect", centerX, centerY, color)
				end

				-- Remove o power-up coletado
				table.remove(self.powerups, i)

				-- Feedback para log
				print("Jogador " .. player.id .. " coletou power-up tipo " .. p.type)
				return true
			end
			return false
		end
	end
	return false
end

-- Destrói um power-up em uma posição (por explosão)
function powerup_manager:destroyPowerupAt(gridX, gridY)
	for i, p in ipairs(self.powerups) do
		if p.gridX == gridX and p.gridY == gridY then
			-- Posição central do power-up para efeitos
			local pixelX, pixelY = grid.toPixel(gridX, gridY)
			local centerX = pixelX + grid.TILE_SIZE / 2
			local centerY = pixelY + grid.TILE_SIZE / 2

			-- Cria partículas de destruição
			if visual_effects.createParticles then
				local color = visual_effects.COLORS.POWERUPS[p.type] or { 1, 1, 1 }
				visual_effects.createParticles("destroy", centerX, centerY, color)
			end

			table.remove(self.powerups, i)
			return true
		end
	end
	return false
end

-- Redistribui os power-ups de um jogador quando ele morre
function powerup_manager:redistributePlayerPowerups(player, map_manager, bomb_manager, player_manager)
	if not player then return end

	-- 1. Verifica quais power-ups o jogador tinha
	local powerupCounts = powerup_utils.countPlayerPowerups(player)

	-- Se o jogador não tinha power-ups, não precisa redistribuir
	if powerupCounts.total <= 0 then return end

	-- 2. Encontra todas as células vazias válidas no mapa
	local emptyCells = powerup_utils.findEmptyCells(map_manager, bomb_manager, player_manager, self.powerups)

	-- Se não houver células vazias, não pode redistribuir
	if #emptyCells == 0 then
		print("Não há células válidas para redistribuir power-ups")
		return
	end

	-- 3. Embaralha as células vazias
	powerup_utils.shuffle(emptyCells)

	-- 4. Distribui os power-ups
	local cellIndex = 1
	local redistributed = { bomb = 0, fire = 0, speed = 0 }

	-- Cria power-ups de bomba
	for i = 1, powerupCounts.bombUp do
		if cellIndex <= #emptyCells then
			local cell = emptyCells[cellIndex]
			table.insert(self.powerups, Powerup:new(cell.x, cell.y, Powerup.TYPES.BOMB_UP))

			-- Adiciona efeito visual no local onde o power-up apareceu
			local pixelX, pixelY = grid.toPixel(cell.x, cell.y)
			local centerX = pixelX + grid.TILE_SIZE / 2
			local centerY = pixelY + grid.TILE_SIZE / 2

			if visual_effects.addLight then
				local color = visual_effects.COLORS.POWERUPS[Powerup.TYPES.BOMB_UP] or { 1, 0.3, 0.3 }
				visual_effects.addLight(centerX, centerY, grid.TILE_SIZE, color[1], color[2], color[3], 0.5)
			end

			cellIndex = cellIndex + 1
			redistributed.bomb = redistributed.bomb + 1
		end
	end

	-- Cria power-ups de fogo
	for i = 1, powerupCounts.fireUp do
		if cellIndex <= #emptyCells then
			local cell = emptyCells[cellIndex]
			table.insert(self.powerups, Powerup:new(cell.x, cell.y, Powerup.TYPES.FIRE_UP))

			-- Adiciona efeito visual no local onde o power-up apareceu
			local pixelX, pixelY = grid.toPixel(cell.x, cell.y)
			local centerX = pixelX + grid.TILE_SIZE / 2
			local centerY = pixelY + grid.TILE_SIZE / 2

			if visual_effects.addLight then
				local color = visual_effects.COLORS.POWERUPS[Powerup.TYPES.FIRE_UP] or { 1, 0.6, 0.1 }
				visual_effects.addLight(centerX, centerY, grid.TILE_SIZE, color[1], color[2], color[3], 0.5)
			end

			cellIndex = cellIndex + 1
			redistributed.fire = redistributed.fire + 1
		end
	end

	-- Cria power-ups de velocidade
	for i = 1, powerupCounts.speedUp do
		if cellIndex <= #emptyCells then
			local cell = emptyCells[cellIndex]
			table.insert(self.powerups, Powerup:new(cell.x, cell.y, Powerup.TYPES.SPEED_UP))

			-- Adiciona efeito visual no local onde o power-up apareceu
			local pixelX, pixelY = grid.toPixel(cell.x, cell.y)
			local centerX = pixelX + grid.TILE_SIZE / 2
			local centerY = pixelY + grid.TILE_SIZE / 2

			if visual_effects.addLight then
				local color = visual_effects.COLORS.POWERUPS[Powerup.TYPES.SPEED_UP] or { 0.2, 0.7, 1 }
				visual_effects.addLight(centerX, centerY, grid.TILE_SIZE, color[1], color[2], color[3], 0.5)
			end

			cellIndex = cellIndex + 1
			redistributed.speed = redistributed.speed + 1
		end
	end

	print(string.format("Jogador %d morreu: redistribuídos %d bombas, %d fogo, %d velocidade em %d células",
		player.id, redistributed.bomb, redistributed.fire, redistributed.speed, cellIndex - 1))

	-- Adiciona um efeito de tremor de tela mais suave para redistribuição
	visual_effects.shakeScreen(3, 0.2)
end

-- Atualiza todos os power-ups
function powerup_manager:update(dt)
	for _, p in ipairs(self.powerups) do
		p:update(dt)
	end
end

-- Desenha todos os power-ups
function powerup_manager:draw()
	for _, p in ipairs(self.powerups) do
		local pixelX, pixelY = grid.toPixel(p.gridX, p.gridY)

		-- Calcula o efeito de pulsação baseado no temporizador
		local pulse = math.sin(p.timer * 2) * 0.5

		-- Usa o sistema de efeitos visuais para desenhar o power-up
		if visual_effects.drawPowerup then
			visual_effects.drawPowerup(pixelX, pixelY, grid.TILE_SIZE, p.type, pulse)
		else
			-- Método de fallback se o sistema de efeitos visuais não estiver disponível
			p:draw()
		end
	end
end

-- Limpa todos os power-ups (útil ao reiniciar o jogo)
function powerup_manager:clear()
	self.powerups = {}
	self.hiddenPowerups = {}
end

-- Retorna estatísticas sobre os power-ups (para debug)
function powerup_manager:getStats()
	local stats = {
		visible = #self.powerups,
		hidden = 0,
		byType = { 0, 0, 0 }
	}

	-- Conta power-ups escondidos
	for _ in pairs(self.hiddenPowerups) do
		stats.hidden = stats.hidden + 1
	end

	-- Conta por tipo
	for _, p in ipairs(self.powerups) do
		stats.byType[p.type] = stats.byType[p.type] + 1
	end

	return stats
end

return powerup_manager
