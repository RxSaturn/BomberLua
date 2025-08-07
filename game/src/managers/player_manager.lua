local grid = require("src.utils.grid")
local Player = require("src.entities.player")
local input_system = require("src.systems.input_system")

local player_manager = {
	players = {},  -- Lista de jogadores ativos
	gameOver = false, -- Flag para indicar fim de jogo
	winner = nil   -- Jogador vencedor
}

-- Inicializa o gerenciador de jogadores
function player_manager:init()
	self.players = {}
	self.gameOver = false
	self.winner = nil

	-- Adiciona o jogador 1 por padrão
	self:addPlayer(1)
end

-- Adiciona um jogador ao jogo
function player_manager:addPlayer(id)
	if id > 4 then
		return nil
	end -- Máximo de 4 jogadores

	-- Verifica se já existe jogador com esse ID
	for _, p in ipairs(self.players) do
		if p.id == id then
			return nil
		end
	end

	-- Cria um novo jogador
	local newPlayer = Player:new(id)
	table.insert(self.players, newPlayer)
	return newPlayer
end

-- Decrementa o contador de bombas de um jogador
function player_manager:decrementBombs(playerId)
	for _, player in ipairs(self.players) do
		if player.id == playerId then
			player.currentBombs = math.max(0, player.currentBombs - 1)
			break
		end
	end
end

-- Verifica se algum jogador foi atingido por explosão
function player_manager:checkExplosionHits(bomb_manager, powerup_manager, map_manager)
	for _, player in ipairs(self.players) do
		if player.isAlive then
			if bomb_manager:isPlayerHit(player.gridX, player.gridY) then
				-- Guarda uma referência do jogador antes de matá-lo
				local deadPlayer = {
					id = player.id,
					maxBombs = player.maxBombs,
					bombPower = player.bombPower,
					speed = player.speed
				}

				-- Mata o jogador
				player:kill()

				-- Redistribui os power-ups
				if powerup_manager then
					powerup_manager:redistributePlayerPowerups(deadPlayer, map_manager, bomb_manager, self)
				end
			end
		end
	end
end

-- Atualiza todos os jogadores
function player_manager:update(dt, map_manager, bomb_manager, powerup_manager)
	-- Atualiza cada jogador
	for _, player in ipairs(self.players) do
		player:update(dt, map_manager, bomb_manager)

		-- Verifica se o jogador coletou algum power-up
		if player.isAlive and not player.isMoving and powerup_manager then
			powerup_manager:collectPowerupAt(player.gridX, player.gridY, player)
		end
	end

	-- Verifica condições de fim de jogo
	self:checkGameOver()
end

-- Verifica se o jogo acabou (apenas um jogador vivo ou todos mortos)
function player_manager:checkGameOver()
	local alivePlayers = 0
	local lastAlivePlayer = nil

	for _, p in ipairs(self.players) do
		if p.isAlive then
			alivePlayers = alivePlayers + 1
			lastAlivePlayer = p
		end
	end

	-- Se só restar um jogador vivo, temos um vencedor
	if #self.players > 1 and alivePlayers == 1 then
		self.gameOver = true
		self.winner = lastAlivePlayer
		-- Se não restar nenhum jogador vivo, é empate
	elseif alivePlayers == 0 and #self.players > 0 then
		self.gameOver = true
		self.winner = nil
	end
end

-- Processa teclas pressionadas para os jogadores
function player_manager:keypressed(key, map_manager, bomb_manager)
	for _, player in ipairs(self.players) do
		player:keypressed(key, map_manager, bomb_manager)
	end
end

-- Desenha todos os jogadores
function player_manager:draw()
	for _, player in ipairs(self.players) do
		player:draw()
	end

	-- Se o jogo acabou, mostra a tela de fim de jogo
	if self.gameOver then
		self:drawGameOverScreen()
	end
end

-- Desenha a tela de fim de jogo
function player_manager:drawGameOverScreen()
	love.graphics.setColor(0, 0, 0, 0.7)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

	love.graphics.setColor(1, 1, 1)
	if self.winner then
		love.graphics.printf("Jogador " .. self.winner.id .. " venceu!", 0,
			love.graphics.getHeight() / 2 - 20,
			love.graphics.getWidth(), "center")
	else
		love.graphics.printf("Empate!", 0, love.graphics.getHeight() / 2 - 20,
			love.graphics.getWidth(), "center")
	end

	love.graphics.printf("Pressione R para reiniciar", 0, love.graphics.getHeight() / 2 + 20,
		love.graphics.getWidth(), "center")
end

-- Reinicia o jogo
function player_manager:restart()
	self.gameOver = false
	self.winner = nil

	for _, player in ipairs(self.players) do
		player:init(player.id)
	end
end

return player_manager
