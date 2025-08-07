local grid = {}

grid.TILE_SIZE = 64 -- Tamanho de um bloco em pixels
grid.WIDTH = 15     -- Largura da grid em blocos
grid.HEIGHT = 13    -- Altura da grid em blocos

-- Converte a posição da grid em posição de pixels
function grid.toPixel(gridX, gridY)
	return (gridX - 1) * grid.TILE_SIZE, (gridY - 1) * grid.TILE_SIZE
end

-- Converte a posição do pixel em posição da grid
function grid.toGrid(pixelX, pixelY)
	return math.floor(pixelX / grid.TILE_SIZE) + 1, math.floor(pixelY / grid.TILE_SIZE) + 1
end

-- Verifica se a posição da grid está dentro dos limites
function grid.isWithinBounds(gridX, gridY)
	return gridX >= 1 and gridX <= grid.WIDTH and gridY >= 1 and gridY <= grid.HEIGHT
end

return grid
