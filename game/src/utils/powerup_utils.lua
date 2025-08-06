local Powerup = require("src.entities.powerup")

local powerup_utils = {}

-- Encontra células vazias válidas no mapa
function powerup_utils.findEmptyCells(map_manager, bomb_manager, player_manager, existing_powerups)
	local grid = require("src.utils.grid")
	local emptyCells = {}

	for y = 1, grid.HEIGHT do
		for x = 1, grid.WIDTH do
			-- Verifica se é um espaço vazio (sem paredes)
			if map_manager:isEmpty(x, y) then
				local isValid = true

				-- Verifica se não tem bomba
				if bomb_manager:hasBomb(x, y) then
					isValid = false
				end

				-- Verifica se não tem power-up
				if isValid and existing_powerups then
					for _, p in ipairs(existing_powerups) do
						if p.gridX == x and p.gridY == y then
							isValid = false
							break
						end
					end
				end

				-- Verifica se não tem jogador
				if isValid and player_manager then
					for _, p in ipairs(player_manager.players) do
						if p.isAlive and p.gridX == x and p.gridY == y then
							isValid = false
							break
						end
					end
				end

				-- Se a célula é válida, adiciona à lista
				if isValid then
					table.insert(emptyCells, { x = x, y = y })
				end
			end
		end
	end

	return emptyCells
end

-- Embaralha uma lista (in-place)
function powerup_utils.shuffle(list)
	for i = #list, 2, -1 do
		local j = love.math.random(i)
		list[i], list[j] = list[j], list[i]
	end

	return list
end

-- Conta quantos power-ups o jogador tinha
function powerup_utils.countPlayerPowerups(player)
	local bombUpCount = math.max(0, player.maxBombs - 1)                -- Bombas extras (além da inicial)
	local fireUpCount = math.max(0, player.bombPower - 1)               -- Poder de fogo extra (além do inicial)
	local speedUpCount = math.max(0, math.floor((player.speed - 5) / 0.5)) -- Speed ups (velocidade base é 5)

	return {
		bombUp = bombUpCount,
		fireUp = fireUpCount,
		speedUp = speedUpCount,
		total = bombUpCount + fireUpCount + speedUpCount
	}
end

return powerup_utils
