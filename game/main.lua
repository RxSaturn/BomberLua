if arg[2] == "debug" then
    require("lldebugger").start()
end

-- Requisita dependências
local grid = require("src.utils.grid")
local map_manager = require("src.managers.map_manager")
local bomb_manager = require("src.managers.bomb_manager")
local player_manager = require("src.managers.player_manager")

-- Inicialização do jogo
function love.load()
    -- Define a semente aleatória baseada no tempo
    math.randomseed(os.time())
    
    -- Inicializa os gerenciadores
    map_manager:init()
    bomb_manager:init()
    player_manager:init()
end

-- Lógica de atualização do jogo
function love.update(dt)
    -- Atualiza os gerenciadores
    player_manager:update(dt, map_manager, bomb_manager)
    bomb_manager:update(dt, map_manager, player_manager)
end

-- Renderização do jogo
function love.draw()
    -- Desenha o mapa primeiro (fundo)
    map_manager:draw()
    
    -- Desenha bombas e explosões (meio)
    bomb_manager:draw()
    
    -- Desenha os jogadores (frente)
    player_manager:draw()
    
    -- Desenha informações de depuração
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    
    -- Mostra informações do jogador 1 se existir
    if #player_manager.players > 0 then
        local p = player_manager.players[1]
        if p.isAlive then
            love.graphics.print("Posição: " .. p.gridX .. ", " .. p.gridY, 10, 30)
            love.graphics.print("Bombas: " .. (p.maxBombs - p.currentBombs) .. "/" .. p.maxBombs, 10, 50)
        else
            love.graphics.print("Jogador Morto!", 10, 30)
        end
    end
end

-- Processa teclas pressionadas
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "r" then
        -- Reinicia o jogo
        map_manager:init()
        bomb_manager:init()
        player_manager:restart()
    else
        -- Passa as teclas para os jogadores
        player_manager:keypressed(key, map_manager, bomb_manager)
    end
end

-- Adiciona jogadores adicionais (para testes)
function love.keyreleased(key)
    if key == "2" and #player_manager.players < 2 then
        -- Adiciona o segundo jogador
        player_manager:addPlayer(2)
    elseif key == "3" and #player_manager.players < 3 then
        -- Adiciona o terceiro jogador
        player_manager:addPlayer(3)
    elseif key == "4" and #player_manager.players < 4 then
        -- Adiciona o quarto jogador
        player_manager:addPlayer(4)
    end
end

local love_errorhandler = love.errorhandler

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end
