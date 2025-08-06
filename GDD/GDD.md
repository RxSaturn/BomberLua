# Documento de Design de Jogo (GDD) - Bomberman Clone em Lua/LÖVE

## Sumário

1. [Visão Geral](#1-visão-geral)
2. [Mecânicas de Jogo](#2-mecânicas-de-jogo)
3. [Arquitetura do Sistema](#3-arquitetura-do-sistema)
4. [Módulos e Componentes](#4-módulos-e-componentes)
5. [Implementação Detalhada](#5-implementação-detalhada)
6. [Sistemas Visuais e de Feedback](#6-sistemas-visuais-e-de-feedback)
7. [Recursos e Otimizações](#7-recursos-e-otimizações)
8. [Próximas Etapas](#8-próximas-etapas)

---

## 1. Visão Geral

### 1.1 Conceito do Jogo

Bomberman é um jogo de ação e estratégia onde os jogadores navegam por um labirinto em grade, colocando bombas para destruir obstáculos e eliminar oponentes. Este projeto visa recriar essa experiência clássica utilizando Lua com o framework LÖVE2D.

### 1.2 Objetivos do Projeto

- Criar uma experiência fiel ao Bomberman clássico
- Suportar de 2 a 4 jogadores em modo local
- Implementar todas as mecânicas essenciais (bombas, explosões, power-ups)
- Criar uma estrutura de código modular e extensível

### 1.3 Escopo Atual

O projeto implementou:
- Sistema de grade para o mapa
- Geração procedural de mapas com paredes destrutíveis e indestrutíveis
- Movimentação avançada dos jogadores com transições suaves
- Sistema de colocação e explosão de bombas com efeitos visuais
- Detecção de colisões precisa
- Sistema completo de power-ups
- Efeitos visuais e feedback aprimorado
- Sistema de múltiplos jogadores com controles distintos

---

## 2. Mecânicas de Jogo

### 2.1 Sistema de Grade

O jogo é construído em torno de uma grade retangular, normalmente de 15x13 células. Cada célula pode conter:

- **Espaço vazio**: Onde os jogadores podem se movimentar
- **Parede indestrutível**: Delimita o mapa e cria o padrão do labirinto
- **Parede destrutível**: Pode ser destruída por explosões e potencialmente liberar power-ups
- **Jogadores**: Controlados pelos usuários
- **Bombas**: Colocadas pelos jogadores
- **Explosões**: Resultado da detonação de bombas
- **Power-ups**: Itens que melhoram as capacidades dos jogadores

### 2.2 Movimentação dos Jogadores

Os jogadores se movem de célula em célula na grade. O movimento é implementado com uma transição suave entre células, utilizando a posição atual e uma posição alvo.

- **Movimento Fluido**: Transição suave entre células para movimento natural
- **Curvas Inteligentes**: Sistema de detecção de curvas de 90° para navegação fluida
- **Controles Responsivos**: Priorização de inputs recentes para controle preciso

#### Controles de Jogo:
- **Jogador 1**: Teclas de seta + Espaço (bomba)
- **Jogador 2**: WASD + Shift esquerdo (bomba)
- **Jogador 3**: IJKL + Shift direito (bomba)
- **Jogador 4**: Teclado numérico + 0 (bomba)

### 2.3 Sistema de Bombas

Cada jogador pode colocar bombas que explodem após um tempo determinado. As características principais são:

- **Temporizador**: Bombas explodem após 3 segundos
- **Alcance**: A explosão se propaga em quatro direções (cima, baixo, esquerda, direita)
- **Limite por jogador**: Inicialmente, cada jogador pode colocar apenas 1 bomba por vez
- **Reação em cadeia**: Explosões podem detonar outras bombas
- **Feedback Visual**: Pavio animado e pulsação quando próxima de explodir

### 2.4 Sistema de Explosões

As explosões:
- Se propagam nas quatro direções cardeais
- Param ao encontrar paredes indestrutíveis
- Destroem paredes destrutíveis
- Eliminam jogadores que são atingidos
- Têm duração limitada (0.5 segundos)
- Incluem efeitos visuais aprimorados (partículas, luz, tremor de tela)

### 2.5 Sistema de Power-ups

Os power-ups aparecem aleatoriamente quando paredes destrutíveis são destruídas:

- **Bomba Extra**: Aumenta o número máximo de bombas que o jogador pode colocar simultaneamente
- **Aumento de Alcance**: Incrementa o raio de explosão das bombas do jogador
- **Aumento de Velocidade**: Torna o movimento do jogador mais rápido

Os power-ups são redistribuídos pelo mapa quando um jogador é eliminado, mantendo o equilíbrio do jogo.

### 2.6 Condições de Vitória

- O último jogador vivo vence
- Se todos os jogadores morrerem simultaneamente, é considerado empate
- Uma tela de fim de jogo mostra o resultado e oferece a opção de reiniciar

---

## 3. Arquitetura do Sistema

### 3.1 Estrutura Modular

O projeto utiliza uma arquitetura modular baseada em componentes, onde diferentes aspectos do jogo são gerenciados por módulos específicos. Este design facilita a manutenção, extensibilidade e testabilidade do código.

```
game/
├── src/
│   ├── managers/
│   │   ├── map_manager.lua       # Gerencia o layout e os elementos do mapa
│   │   ├── bomb_manager.lua      # Gerencia as bombas e explosões
│   │   ├── player_manager.lua    # Gerencia os jogadores
│   │   ├── powerup_manager.lua   # Gerencia os power-ups
│   ├── entities/
│   │   ├── player.lua            # Entidade do jogador
│   │   ├── bomb.lua              # Entidade da bomba
│   │   ├── explosion.lua         # Entidade da explosão
│   │   ├── powerup.lua           # Entidade do power-up
│   ├── systems/
│   │   ├── input_system.lua      # Sistema de controle e input
│   ├── effects/
│   │   ├── particle_system.lua   # Sistema de partículas
│   │   ├── lighting.lua          # Efeitos de iluminação
│   └── utils/
│       ├── grid.lua              # Utilitários para a grade do jogo
│       ├── visual_effects.lua    # Efeitos visuais
│       └── powerup_utils.lua     # Utilidades para power-ups
```

### 3.2 Padrão de Gerenciadores (Manager Pattern)

O sistema emprega um padrão de design onde cada aspecto do jogo é gerenciado por um "manager" dedicado:

- **map_manager**: Gerencia o estado e renderização do mapa
- **bomb_manager**: Gerencia a criação, atualização e remoção de bombas e explosões
- **player_manager**: Gerencia os jogadores, seus estados e interações
- **powerup_manager**: Gerencia os power-ups, sua geração e coleta

### 3.3 Sistema de Entidades

As entidades principais (Player, Bomb, Explosion, Powerup) são implementadas como objetos independentes com seus próprios métodos e estados:

- **Criação**: Através de métodos construtores (`:new()`)
- **Atualização**: Através de métodos de atualização (`:update()`)
- **Renderização**: Através de métodos de desenho (`:draw()`)
- **Interação**: Métodos específicos para interagir com outras entidades

### 3.4 Sistemas Auxiliares

Além dos gerenciadores e entidades, o jogo utiliza sistemas auxiliares para funcionalidades específicas:

- **input_system**: Gerencia a entrada do jogador com buffer de inputs e detecção de curvas
- **particle_system**: Sistema de partículas para efeitos visuais
- **visual_effects**: Gerencia efeitos visuais como tremor de tela, iluminação e renderização aprimorada

---

## 4. Módulos e Componentes

### 4.1 Utilitários (`grid.lua`)

Este módulo fornece funções para converter entre coordenadas de grade (lógicas) e coordenadas de pixel (renderização), além de verificar limites da grade.

#### Conceitos de Lua: Tabelas como Módulos

Em Lua, os módulos são implementados como tabelas que são retornadas ao final do arquivo. Isso permite encapsular funcionalidade relacionada e expor apenas o que é necessário para outros módulos.

```lua
local grid = {
    WIDTH = 15,       -- Largura do mapa em células
    HEIGHT = 13,      -- Altura do mapa em células
    TILE_SIZE = 64,   -- Tamanho de cada célula em pixels
}

-- Converte posição na grade para pixels
function grid.toPixel(gridX, gridY)
    return (gridX - 1) * grid.TILE_SIZE, (gridY - 1) * grid.TILE_SIZE
end

-- Converte posição em pixels para posição na grade
function grid.toGrid(pixelX, pixelY)
    return math.floor(pixelX / grid.TILE_SIZE) + 1, math.floor(pixelY / grid.TILE_SIZE) + 1
end

-- Verifica se uma posição na grade está dentro dos limites
function grid.isWithinBounds(gridX, gridY)
    return gridX >= 1 and gridX <= grid.WIDTH and gridY >= 1 and gridY <= grid.HEIGHT
end

return grid
```

### 4.2 Gerenciador de Mapa (`map_manager.lua`)

#### Principais Responsabilidades:
- Inicializar o mapa com paredes destrutíveis e indestrutíveis
- Verificar disponibilidade de células para movimento
- Lidar com a destruição de paredes
- Desenhar o mapa com efeitos visuais aprimorados

#### Métodos Principais:

**`map_manager:init()`**
- **Propósito**: Inicializa o mapa com um padrão específico de paredes
- **Funcionamento**: Cria uma matriz 2D com diferentes valores para cada tipo de célula (0: vazio, 1: parede indestrutível, 2: parede destrutível)
- **Algoritmo**: 
  - Cria paredes indestrutíveis nas bordas
  - Coloca paredes indestrutíveis em posições ímpares (x,y) para criar o padrão clássico do Bomberman
  - Distribui paredes destrutíveis aleatoriamente nas células restantes com 70% de probabilidade
  - Limpa as áreas de spawn para os jogadores

**`map_manager:clearSpawnAreas()`**
- **Propósito**: Garante que os jogadores tenham espaço para se movimentar quando o jogo começa
- **Funcionamento**: Define células específicas como vazias (0) para cada posição inicial de jogador

**`map_manager:isWall(gridX, gridY)`**
- **Propósito**: Verifica se uma posição contém uma parede
- **Parâmetros**: Coordenadas da grade
- **Retorno**: Boolean indicando se há uma parede na posição

**`map_manager:isEmpty(gridX, gridY)`**
- **Propósito**: Verifica se uma posição está vazia
- **Parâmetros**: Coordenadas da grade
- **Retorno**: Boolean indicando se a célula está vazia

**`map_manager:isDestructibleWall(gridX, gridY)`**
- **Propósito**: Verifica se uma posição contém uma parede destrutível
- **Parâmetros**: Coordenadas da grade
- **Retorno**: Boolean indicando se é uma parede destrutível

**`map_manager:destroyWall(gridX, gridY, powerup_manager)`**
- **Propósito**: Destrói uma parede destrutível e potencialmente revela um power-up
- **Parâmetros**: 
  - `gridX, gridY`: Coordenadas da grade
  - `powerup_manager`: Gerenciador de power-ups para revelar um item (opcional)
- **Funcionamento**: Converte paredes destrutíveis (2) em espaços vazios (0) e notifica o gerenciador de power-ups
- **Retorno**: Boolean indicando sucesso da operação

**`map_manager:draw()`**
- **Propósito**: Renderiza o mapa na tela com efeitos visuais aprimorados
- **Funcionamento**: 
  - Desenha o fundo com padrão de grade
  - Para cada célula, desenha o tipo correto de parede com detalhes visuais
  - Aplica efeitos de iluminação e sombras para dar profundidade

### 4.3 Gerenciador de Bombas (`bomb_manager.lua`)

#### Principais Responsabilidades:
- Gerenciar a colocação, atualização e explosão de bombas
- Criar e gerenciar explosões com efeitos visuais
- Verificar colisões entre explosões e jogadores/paredes/power-ups

#### Métodos Principais:

**`bomb_manager:init()`**
- **Propósito**: Inicializa as listas de bombas e explosões

**`bomb_manager:hasBomb(gridX, gridY)`**
- **Propósito**: Verifica se já existe uma bomba na posição especificada
- **Parâmetros**: Coordenadas da grade
- **Retorno**: Boolean indicando a presença de uma bomba

**`bomb_manager:placeBomb(gridX, gridY, power, owner)`**
- **Propósito**: Coloca uma nova bomba no mapa
- **Parâmetros**: 
  - `gridX, gridY`: Posição na grade
  - `power`: Alcance da explosão
  - `owner`: ID do jogador que colocou a bomba
- **Retorno**: Boolean indicando sucesso da operação

**`bomb_manager:createExplosion(gridX, gridY, power, owner, map_manager, powerup_manager)`**
- **Propósito**: Cria uma explosão e a propaga nas quatro direções
- **Parâmetros**: 
  - `gridX, gridY`: Origem da explosão
  - `power`: Alcance da explosão
  - `owner`: ID do jogador que causou a explosão
  - `map_manager`: Referência ao gerenciador de mapa para interagir com paredes
  - `powerup_manager`: Referência ao gerenciador de power-ups para destruir power-ups na área da explosão
- **Funcionamento**: 
  - Inicia efeito de tremor de tela para feedback visual
  - Cria explosão central
  - Para cada direção, propaga a explosão conforme o algoritmo

**`bomb_manager:propagateExplosion(x, y, dx, dy, power, type, map_manager, powerup_manager)`**
- **Propósito**: Propaga a explosão em uma única direção específica
- **Parâmetros**: 
  - `x, y`: Posição inicial 
  - `dx, dy`: Direção da propagação
  - `power`: Alcance da explosão
  - `type`: Tipo visual da explosão ("vertical" ou "horizontal")
  - `map_manager`: Referência ao gerenciador de mapa
  - `powerup_manager`: Referência ao gerenciador de power-ups
- **Funcionamento**: Propaga a explosão célula a célula até atingir o alcance máximo ou um obstáculo

**`bomb_manager:isPlayerHit(gridX, gridY)`**
- **Propósito**: Verifica se um jogador na posição especificada seria atingido por explosão
- **Parâmetros**: Coordenadas da grade
- **Retorno**: Boolean indicando se há explosão na posição

**`bomb_manager:update(dt, map_manager, player_manager, powerup_manager)`**
- **Propósito**: Atualiza todas as bombas e explosões no mapa
- **Parâmetros**:
  - `dt`: Delta time (tempo desde último frame)
  - `map_manager`: Referência ao gerenciador de mapa
  - `player_manager`: Referência ao gerenciador de jogadores
  - `powerup_manager`: Referência ao gerenciador de power-ups
- **Funcionamento**:
  1. Atualiza cada bomba (reduz timer)
  2. Detona bombas com timer <= 0, criando explosões
  3. Atualiza cada explosão (reduz timer)
  4. Remove explosões com timer <= 0

**`bomb_manager:draw()`**
- **Propósito**: Renderiza todas as bombas e explosões com efeitos visuais aprimorados

### 4.4 Gerenciador de Power-ups (`powerup_manager.lua`)

#### Principais Responsabilidades:
- Gerenciar o ciclo de vida dos power-ups (geração, coleta, destruição)
- Alocar power-ups ocultos em paredes destrutíveis
- Aplicar efeitos de power-ups aos jogadores
- Redistribuir power-ups quando um jogador é eliminado

#### Conceitos de Lua: Tabelas para Armazenamento Associativo

Em Lua, tabelas podem ser usadas como arrays indexados numericamente ou como mapas associativos (hash maps), permitindo armazenar valores com chaves personalizadas. O `powerup_manager` utiliza essa funcionalidade para mapear posições da grade para tipos de power-ups escondidos.

```lua
-- Armazena power-ups escondidos usando chaves baseadas na posição
self.hiddenPowerups[gridY * grid.WIDTH + gridX] = powerupType
```

#### Métodos Principais:

**`powerup_manager:init(map_manager)`**
- **Propósito**: Inicializa o gerenciador de power-ups e gera os power-ups escondidos
- **Parâmetros**: Referência ao gerenciador de mapa
- **Funcionamento**: 
  - Inicializa listas vazias para power-ups visíveis e escondidos
  - Chama o método para gerar power-ups escondidos

**`powerup_manager:generateHiddenPowerups(map_manager)`**
- **Propósito**: Distribui power-ups escondidos em paredes destrutíveis
- **Parâmetros**: Referência ao gerenciador de mapa
- **Funcionamento**:
  - Localiza todas as paredes destrutíveis no mapa
  - Seleciona aproximadamente 30% delas aleatoriamente
  - Distribui os três tipos de power-ups uniformemente
  - Armazena usando um sistema de chaves baseado na posição

**`powerup_manager:revealPowerupAt(gridX, gridY)`**
- **Propósito**: Revela um power-up quando uma parede destrutível é destruída
- **Parâmetros**: Coordenadas da grade
- **Funcionamento**: 
  - Verifica se há um power-up escondido na posição
  - Se houver, cria um power-up visível e adiciona efeitos visuais
  - Remove o power-up do mapa de itens escondidos
- **Retorno**: Boolean indicando se um power-up foi revelado

**`powerup_manager:collectPowerupAt(gridX, gridY, player)`**
- **Propósito**: Permite que um jogador colete um power-up
- **Parâmetros**: 
  - `gridX, gridY`: Posição da coleta
  - `player`: Jogador que está coletando
- **Funcionamento**:
  - Verifica se há um power-up na posição
  - Aplica o efeito ao jogador
  - Adiciona feedback visual (tremor de tela, partículas)
  - Remove o power-up da lista de itens visíveis
- **Retorno**: Boolean indicando se um power-up foi coletado

**`powerup_manager:destroyPowerupAt(gridX, gridY)`**
- **Propósito**: Destrói um power-up devido a uma explosão
- **Parâmetros**: Coordenadas da grade
- **Funcionamento**: 
  - Verifica se há um power-up na posição
  - Adiciona efeitos visuais de destruição
  - Remove o power-up da lista
- **Retorno**: Boolean indicando se um power-up foi destruído

**`powerup_manager:redistributePlayerPowerups(player, map_manager, bomb_manager, player_manager)`**
- **Propósito**: Redistribui os power-ups de um jogador quando ele é eliminado
- **Parâmetros**:
  - `player`: Dados do jogador eliminado
  - `map_manager`: Referência ao gerenciador de mapa
  - `bomb_manager`: Referência ao gerenciador de bombas
  - `player_manager`: Referência ao gerenciador de jogadores
- **Funcionamento**:
  - Conta quantos power-ups o jogador tinha de cada tipo
  - Encontra células vazias adequadas no mapa
  - Distribui os power-ups pelo mapa com efeitos visuais

**`powerup_manager:update(dt)`**
- **Propósito**: Atualiza todos os power-ups visíveis
- **Parâmetros**: Delta time
- **Funcionamento**: Atualiza a animação de cada power-up

**`powerup_manager:draw()`**
- **Propósito**: Renderiza todos os power-ups com efeitos visuais
- **Funcionamento**: 
  - Para cada power-up, calcula efeitos de pulsação e brilho
  - Desenha com aparência distinta baseada no tipo

### 4.5 Gerenciador de Jogadores (`player_manager.lua`)

#### Principais Responsabilidades:
- Gerenciar a criação e estado de todos os jogadores
- Processar entrada para controlar jogadores
- Verificar condições de fim de jogo
- Gerenciar colisões entre jogadores e explosões

#### Conceitos de Lua: Passagem de Referência

Em Lua, as tabelas (como nossos gerenciadores) são passadas por referência, não por valor. Isso permite que diferentes módulos compartilhem e modifiquem o mesmo objeto sem duplicação de dados.

```lua
-- O bomb_manager original é passado, não uma cópia
player_manager:update(dt, map_manager, bomb_manager, powerup_manager)
```

#### Métodos Principais:

**`player_manager:init()`**
- **Propósito**: Inicializa o gerenciador de jogadores
- **Funcionamento**: Cria o primeiro jogador por padrão

**`player_manager:addPlayer(id)`**
- **Propósito**: Adiciona um novo jogador ao jogo
- **Parâmetros**: ID do jogador (1-4)
- **Retorno**: Referência ao novo jogador ou nil se falhar

**`player_manager:decrementBombs(playerId)`**
- **Propósito**: Decrementa o contador de bombas ativas de um jogador
- **Parâmetros**: ID do jogador
- **Funcionamento**: Permite que o jogador coloque mais bombas quando as anteriores explodem

**`player_manager:checkExplosionHits(bomb_manager, powerup_manager, map_manager)`**
- **Propósito**: Verifica se algum jogador foi atingido por explosões
- **Parâmetros**: 
  - `bomb_manager`: Referência ao gerenciador de bombas
  - `powerup_manager`: Referência ao gerenciador de power-ups
  - `map_manager`: Referência ao gerenciador de mapa
- **Funcionamento**: 
  - Para cada jogador vivo, verifica se sua posição coincide com alguma explosão
  - Se um jogador for atingido, o elimina e redistribui seus power-ups

**`player_manager:update(dt, map_manager, bomb_manager, powerup_manager)`**
- **Propósito**: Atualiza todos os jogadores e verifica condições de fim de jogo
- **Parâmetros**:
  - `dt`: Delta time
  - `map_manager`: Referência ao gerenciador de mapa
  - `bomb_manager`: Referência ao gerenciador de bombas
  - `powerup_manager`: Referência ao gerenciador de power-ups
- **Funcionamento**:
  - Atualiza cada jogador
  - Verifica coleta de power-ups
  - Verifica condições de fim de jogo

**`player_manager:checkGameOver()`**
- **Propósito**: Verifica se o jogo acabou
- **Funcionamento**: 
  - Se restar apenas um jogador vivo, ele é declarado vencedor
  - Se todos os jogadores morrerem, é declarado empate

**`player_manager:keypressed(key, map_manager, bomb_manager)`**
- **Propósito**: Processa teclas pressionadas para todos os jogadores
- **Parâmetros**:
  - `key`: Tecla pressionada
  - `map_manager`: Referência ao gerenciador de mapa
  - `bomb_manager`: Referência ao gerenciador de bombas

**`player_manager:restart()`**
- **Propósito**: Reinicia todos os jogadores para uma nova partida
- **Funcionamento**: Redefine o estado de cada jogador para suas condições iniciais

**`player_manager:drawGameOverScreen()`**
- **Propósito**: Desenha a tela de fim de jogo
- **Funcionamento**:
  - Escurece a tela com sobreposição translúcida
  - Mostra mensagem de vitória ou empate
  - Exibe instruções para reiniciar

### 4.6 Sistema de Input (`input_system.lua`)

#### Principais Responsabilidades:
- Gerenciar a entrada do usuário com buffer de inputs
- Facilitar curvas fluidas durante o movimento
- Priorizar os comandos mais recentes para responsividade

#### Conceitos de Lua: Closures e Funções como Valores de Primeira Classe

Em Lua, funções são valores de primeira classe e podem ser passadas como argumentos, retornadas de outras funções e atribuídas a variáveis. Closures são funções que "capturam" variáveis do escopo externo.

```lua
-- Verificação de função opcional com fallback usando closure
local removeInput = input_system.removeInput or function() end
```

#### Métodos Principais:

**`input_system.createController()`**
- **Propósito**: Cria um novo controlador de input para um jogador
- **Retorno**: Tabela com estado do controlador
- **Funcionamento**:
  - Inicializa buffer de inputs, fila de inputs, timers e cooldowns
  - Cada jogador tem seu próprio controlador independente

**`input_system.bufferInput(controller, input, dt)`**
- **Propósito**: Adiciona um input ao buffer com prioridade baseada na recência
- **Parâmetros**:
  - `controller`: Controlador do jogador
  - `input`: Comando (up, down, left, right)
  - `dt`: Delta time
- **Funcionamento**:
  - Adiciona o input ao buffer se não estiver em cooldown
  - Atualiza o timestamp do input se já existir
  - Adiciona à fila de teclas pressionadas

**`input_system.removeInput(controller, input)`**
- **Propósito**: Remove um input da fila quando a tecla é solta
- **Parâmetros**:
  - `controller`: Controlador do jogador
  - `input`: Comando a remover
- **Funcionamento**: Remove o input específico da fila

**`input_system.update(controller, dt)`**
- **Propósito**: Atualiza o estado do controlador de input
- **Parâmetros**:
  - `controller`: Controlador do jogador
  - `dt`: Delta time
- **Funcionamento**:
  - Atualiza timers e cooldowns
  - Remove inputs expirados do buffer
  - Limpa o buffer completamente se não houver teclas pressionadas

**`input_system.getNextMove(controller, gridX, gridY, map_manager, bomb_manager)`**
- **Propósito**: Determina o próximo movimento com base nos inputs e colisões
- **Parâmetros**:
  - `controller`: Controlador do jogador
  - `gridX, gridY`: Posição atual do jogador
  - `map_manager`: Referência ao gerenciador de mapa
  - `bomb_manager`: Referência ao gerenciador de bombas
- **Retorno**: Próxima posição (x,y) e direção, ou nil se não houver movimento válido
- **Funcionamento**:
  - Prioriza o input mais recente para maior responsividade
  - Verifica se o movimento é possível (sem colisões)

**`input_system.checkCornerTurn(controller, gridX, gridY, targetX, targetY, pixelX, pixelY, currentDirection, map_manager, bomb_manager)`**
- **Propósito**: Verifica se o jogador pode fazer uma curva fluida durante o movimento
- **Parâmetros**:
  - Informações sobre a posição e movimento atual
  - Controlador de input do jogador
  - Gerenciadores para verificação de colisão
- **Retorno**: Nova posição alvo e direção se uma curva for possível, ou nil caso contrário
- **Funcionamento**:
  - Calcula o progresso do movimento atual (0.0 a 1.0)
  - Só permite curvas se o jogador já percorreu 80% do caminho atual
  - Verifica inputs perpendiculares à direção atual
  - Verifica se a célula na direção da curva está livre

### 4.7 Entidade Jogador (`player.lua`)

#### Conceitos de Lua: Metatables e Herança

Lua implementa herança usando metatables. A função `setmetatable(objeto, {__index = classe})` permite que o `objeto` herde métodos e propriedades da `classe`. O campo `__index` da metatable define onde procurar métodos quando não são encontrados no objeto principal.

```lua
function player:new(id)
    local newPlayer = {
        id = id,
        -- Outras propriedades...
    }
    
    setmetatable(newPlayer, self)
    self.__index = self
    
    return newPlayer
end
```

#### Atributos Principais:
- `id`: Identifica o jogador (1-4)
- `gridX, gridY`: Posição atual na grade
- `targetX, targetY`: Posição alvo para movimento
- `pixelX, pixelY`: Posição exata em pixels para renderização suave
- `isMoving`: Indica se o jogador está em movimento
- `direction`: Direção atual que o jogador está olhando
- `isAlive`: Estado do jogador
- `speed`: Velocidade de movimento (células por segundo)
- `maxBombs`: Número máximo de bombas que o jogador pode colocar
- `currentBombs`: Número de bombas atualmente ativas
- `bombPower`: Alcance da explosão das bombas do jogador
- `inputController`: Controlador de input específico deste jogador

#### Métodos Principais:

**`player:new(id)`**
- **Propósito**: Construtor para criar um novo jogador
- **Parâmetros**: ID do jogador
- **Retorno**: Nova instância de jogador
- **Funcionamento**: 
  - Inicializa atributos com valores padrão
  - Configura a herança usando metatabelas
  - Chama o método de inicialização

**`player:init(id)`**
- **Propósito**: Inicializa ou reinicia o jogador
- **Parâmetros**: ID do jogador
- **Funcionamento**: 
  - Define atributos iniciais
  - Cria um novo controlador de input
  - Define posição inicial baseada no ID

**`player:setStartPosition()`**
- **Propósito**: Define a posição inicial do jogador baseada em seu ID
- **Funcionamento**:
  - Jogador 1: Topo-esquerda
  - Jogador 2: Topo-direita
  - Jogador 3: Baixo-esquerda
  - Jogador 4: Baixo-direita

**`player:kill()`**
- **Propósito**: Mata o jogador
- **Funcionamento**: 
  - Define isAlive como false
  - Adiciona efeito de tremor de tela para feedback

**`player:placeBomb(map_manager, bomb_manager)`**
- **Propósito**: Tenta colocar uma bomba na posição atual do jogador
- **Parâmetros**: Referências aos gerenciadores necessários
- **Retorno**: Boolean indicando sucesso da operação
- **Funcionamento**:
  - Verifica se o jogador está vivo
  - Verifica se o jogador ainda pode colocar mais bombas
  - Tenta colocar a bomba usando o bomb_manager
  - Incrementa o contador de bombas ativas

**`player:processMovement(dt, map_manager, bomb_manager)`**
- **Propósito**: Processa o movimento do jogador
- **Parâmetros**:
  - `dt`: Delta time
  - `map_manager`: Referência ao gerenciador de mapa
  - `bomb_manager`: Referência ao gerenciador de bombas
- **Funcionamento**:
  - Se já estiver em movimento, continua o movimento atual
  - Verifica possíveis curvas automáticas
  - Se não estiver em movimento, tenta iniciar um novo

**`player:continueMovement(dt)`**
- **Propósito**: Continua um movimento em progresso
- **Parâmetros**: Delta time
- **Funcionamento**:
  - Calcula distância até o destino
  - Move o jogador com base em sua velocidade
  - Quando chega ao destino, atualiza as coordenadas da grade
  - Adiciona pequeno cooldown entre movimentos

**`player:checkCornerTurn(map_manager, bomb_manager)`**
- **Propósito**: Verifica e executa curvas automáticas durante o movimento
- **Parâmetros**: Gerenciadores para verificação de colisão
- **Funcionamento**:
  - Determina direção atual de movimento
  - Usa o sistema de input para verificar possibilidade de curva
  - Se possível fazer uma curva, ajusta a posição atual e define novo alvo
  - Implementa transição suave para evitar efeito de "teleporte"

**`player:tryNewMovement(map_manager, bomb_manager)`**
- **Propósito**: Tenta iniciar um novo movimento
- **Parâmetros**: Gerenciadores para verificação de colisão
- **Funcionamento**:
  - Obtém próximo movimento do sistema de input
  - Se houver um movimento válido, atualiza alvo e ativa flag de movimento

**`player:update(dt, map_manager, bomb_manager)`**
- **Propósito**: Atualiza o estado do jogador
- **Parâmetros**:
  - `dt`: Delta time
  - `map_manager`: Referência ao gerenciador de mapa
  - `bomb_manager`: Referência ao gerenciador de bombas
- **Funcionamento**:
  - Atualiza o buffer de input
  - Processa teclas pressionadas
  - Processa movimento do jogador

**`player:processInput(dt)`**
- **Propósito**: Processa teclas pressionadas pelo jogador
- **Parâmetros**: Delta time
- **Funcionamento**:
  - Obtém mapeamento de teclas para este jogador
  - Verifica cada tecla de direção
  - Adiciona ou remove inputs do controlador
  - Limpa o buffer se nenhuma tecla estiver pressionada

**`player:getPlayerKeys()`**
- **Propósito**: Retorna o mapeamento de teclas para este jogador
- **Retorno**: Tabela com mapeamentos de direções e ação de bomba
- **Funcionamento**: Define controles diferentes para cada jogador

**`player:keypressed(key, map_manager, bomb_manager)`**
- **Propósito**: Processa tecla pressionada específica para este jogador
- **Parâmetros**:
  - `key`: Tecla pressionada
  - `map_manager`: Referência ao gerenciador de mapa
  - `bomb_manager`: Referência ao gerenciador de bombas
- **Funcionamento**: Verifica se é tecla de bomba e tenta colocar uma bomba

**`player:draw()`**
- **Propósito**: Renderiza o jogador na tela com efeitos visuais aprimorados
- **Funcionamento**:
  - Desenha o jogador com cor baseada no ID
  - Adiciona indicação visual da direção
  - Implementa animações sutis de movimento e respiração

### 4.8 Entidade Bomba (`bomb.lua`)

#### Atributos Principais:
- `gridX, gridY`: Posição na grade
- `timer`: Tempo até explosão (em segundos)
- `power`: Alcance da explosão
- `owner`: ID do jogador que colocou a bomba

#### Métodos Principais:

**`bomb:new(gridX, gridY, power, owner)`**
- **Propósito**: Construtor para criar uma nova bomba
- **Parâmetros**:
  - `gridX, gridY`: Posição na grade
  - `power`: Alcance da explosão
  - `owner`: ID do jogador que colocou a bomba
- **Retorno**: Nova instância de bomba
- **Funcionamento**: Inicializa a bomba com timer de 3 segundos

**`bomb:update(dt)`**
- **Propósito**: Atualiza o temporizador da bomba
- **Parâmetros**: Delta time
- **Retorno**: Boolean indicando se a bomba deve explodir
- **Funcionamento**: Decrementa o timer e retorna true quando chega a zero

**`bomb:draw()`**
- **Propósito**: Renderiza a bomba na tela
- **Funcionamento**: 
  - Desenha o corpo da bomba em preto
  - Adiciona detalhes como pavio animado
  - Implementa efeito piscante quando próxima de explodir
  - Usa efeitos visuais aprimorados quando disponíveis

### 4.9 Entidade Explosão (`explosion.lua`)

#### Atributos Principais:
- `gridX, gridY`: Posição na grade
- `timer`: Duração da explosão (em segundos)
- `type`: Tipo de explosão (centro, horizontal, vertical)

#### Métodos Principais:

**`explosion:new(gridX, gridY, type)`**
- **Propósito**: Construtor para criar uma nova explosão
- **Parâmetros**:
  - `gridX, gridY`: Posição na grade
  - `type`: Tipo de explosão (determina aparência)
- **Retorno**: Nova instância de explosão
- **Funcionamento**: 
  - Inicializa a explosão com timer de 0.5 segundos
  - Adiciona efeito de tremor de tela se disponível

**`explosion:update(dt)`**
- **Propósito**: Atualiza o temporizador da explosão
- **Parâmetros**: Delta time
- **Retorno**: Boolean indicando se a explosão acabou
- **Funcionamento**: Decrementa o timer e retorna true quando chega a zero

**`explosion:draw()`**
- **Propósito**: Renderiza a explosão na tela
- **Funcionamento**: 
  - Desenha a explosão com cor laranja/vermelha
  - Adiciona brilho central amarelo
  - Adapta a forma baseada no tipo (centro, horizontal, vertical)
  - Usa efeitos visuais aprimorados quando disponíveis

### 4.10 Entidade Power-up (`powerup.lua`)

#### Atributos Principais:
- `gridX, gridY`: Posição na grade
- `type`: Tipo de power-up (1: bomba extra, 2: aumento de alcance, 3: aumento de velocidade)
- `timer`: Usado para efeitos visuais como pulsação

#### Métodos Principais:

**`powerup:new(gridX, gridY, type)`**
- **Propósito**: Construtor para criar um novo power-up
- **Parâmetros**:
  - `gridX, gridY`: Posição na grade
  - `type`: Tipo de power-up
- **Retorno**: Nova instância de power-up
- **Funcionamento**: Inicializa o power-up no local especificado

**`powerup:update(dt)`**
- **Propósito**: Atualiza efeitos visuais do power-up
- **Parâmetros**: Delta time
- **Funcionamento**: Incrementa o timer para animações de pulsação

**`powerup:applyTo(player)`**
- **Propósito**: Aplica o efeito do power-up ao jogador
- **Parâmetros**: Jogador que coletou o power-up
- **Retorno**: Boolean indicando sucesso
- **Funcionamento**:
  - Para bomba extra: incrementa maxBombs
  - Para aumento de alcance: incrementa bombPower
  - Para aumento de velocidade: aumenta speed

**`powerup:draw()`**
- **Propósito**: Renderiza o power-up na tela
- **Funcionamento**: 
  - Desenha o power-up com cor baseada no tipo
  - Adiciona ícone ou símbolo que indica sua função
  - Implementa efeito de pulsação usando o timer

---

## 5. Implementação Detalhada

### 5.1 Ciclo de Vida do Jogo

O ciclo de vida é gerenciado pelo LÖVE framework através das funções de callback:

- **`love.load()`**: Inicializa os gerenciadores e estados iniciais
- **`love.update(dt)`**: Atualiza o estado do jogo a cada frame
- **`love.draw()`**: Renderiza o jogo na tela
- **`love.keypressed(key)`**: Processa teclas pressionadas
- **`love.keyreleased(key)`**: Processa teclas liberadas

### 5.2 Sistema de Movimento

#### Conceitos de Lua: Delta Time

Em Lua e LÖVE, o parâmetro `dt` (delta time) representa o tempo decorrido desde o último frame. Multiplicar velocidades por `dt` garante um movimento consistente independente da taxa de quadros, garantindo que o jogo rode na mesma velocidade em qualquer computador.

```lua
local moveAmount = self.speed * grid.TILE_SIZE * dt
```

O movimento do jogador é implementado com uma transição suave:

1. O jogador tem uma posição atual (`gridX`, `gridY`) e uma posição alvo (`targetX`, `targetY`)
2. Quando um movimento é solicitado, verifica-se a viabilidade (sem colisões)
3. Se possível, a posição alvo é atualizada e a flag `isMoving` é ativada
4. Durante o estado de movimento, a posição em pixels (`pixelX`, `pixelY`) é interpolada em direção à posição alvo
5. Quando o jogador chega ao destino, as coordenadas de grade são atualizadas e `isMoving` é desativada

#### Sistema de Curvas Aprimorado

O sistema de curvas permite que o jogador mude de direção durante um movimento, sem precisar esperar que o movimento atual termine completamente:

1. Durante um movimento, o sistema monitora inputs perpendiculares à direção atual
2. Quando o jogador está a pelo menos 80% do caminho até o próximo tile, o sistema permite uma curva
3. Se um input perpendicular é detectado e a célula adjacente está livre, o movimento é redirecionado
4. A transição é suavizada para evitar o efeito "teleporte" que existia na implementação anterior
5. Um pequeno cooldown é aplicado para prevenir curvas acidentais ou muito rápidas

### 5.3 Sistema de Colisão

As colisões são verificadas em vários níveis:

1. **Colisão com paredes**: Verifica se uma célula contém uma parede
   ```lua
   if map_manager:isWall(newTargetX, newTargetY) then
       return false
   end
   ```

2. **Colisão com bombas**: Verifica se uma célula contém uma bomba
   ```lua
   if bomb_manager:hasBomb(newTargetX, newTargetY) then
       return false
   end
   ```

3. **Colisão com explosões**: Verifica se um jogador está em uma célula com explosão
   ```lua
   if bomb_manager:isPlayerHit(player.gridX, player.gridY) then
       player:kill()
   end
   ```

4. **Coleta de power-ups**: Verifica se um jogador está em uma célula com power-up
   ```lua
   powerup_manager:collectPowerupAt(player.gridX, player.gridY, player)
   ```

### 5.4 Sistema de Propagação de Explosões

A propagação de explosões é implementada usando um algoritmo de "flood fill" direcionado:

1. A explosão começa no centro (posição da bomba)
2. Para cada uma das quatro direções cardeais (cima, baixo, esquerda, direita):
   - A explosão se propaga até o alcance máximo ou até encontrar um obstáculo
   - Se encontrar uma parede indestrutível, para naquela direção
   - Se encontrar uma parede destrutível, destrói a parede, possivelmente revela um power-up, e para naquela direção
   - Se encontrar outra bomba, aciona a detonação imediata dela (reação em cadeia)
   - Se encontrar um power-up visível, o destrói

3. Cada segmento de explosão é criado com um tipo visual apropriado:
   - "center" para o ponto de origem
   - "horizontal" para propagação lateral
   - "vertical" para propagação vertical

4. Cada explosão tem um timer de 0.5 segundos antes de desaparecer

5. Efeitos visuais são adicionados para melhorar o feedback:
   - Tremor de tela
   - Partículas
   - Iluminação dinâmica

### 5.5 Sistema de Power-ups

O sistema de power-ups adiciona profundidade estratégica ao jogo:

1. **Geração**: Aproximadamente 30% das paredes destrutíveis escondem power-ups
2. **Distribuição**: Os três tipos de power-ups são distribuídos uniformemente
3. **Revelação**: Power-ups são revelados quando uma parede destrutível é destruída
4. **Coleta**: Jogadores coletam power-ups ao passar sobre eles
5. **Efeitos**:
   - Bomba Extra: Permite colocar mais bombas simultaneamente
   - Aumento de Alcance: Aumenta o raio de explosão das bombas
   - Aumento de Velocidade: Torna o jogador mais rápido
6. **Redistribuição**: Quando um jogador é eliminado, seus power-ups são redistribuídos pelo mapa para manter o equilíbrio do jogo

### 5.6 Geração de Mapa

O mapa é gerado com um padrão específico que é característico do Bomberman:

1. **Borda externa**: Paredes indestrutíveis
2. **Padrão interno**: Paredes indestrutíveis em coordenadas (x,y) onde ambas são ímpares
3. **Paredes destrutíveis**: Distribuídas aleatoriamente com 70% de chance
4. **Áreas de spawn**: Células vazias garantidas nas posições iniciais dos jogadores e células adjacentes

---

## 6. Sistemas Visuais e de Feedback

### 6.1 Sistema de Efeitos Visuais

O `visual_effects.lua` implementa vários efeitos visuais para melhorar a aparência do jogo:

- **Tremor de tela**: Adiciona impacto a explosões e morte de jogadores
- **Paleta de cores aprimorada**: Cores mais vibrantes e harmônicas para todos os elementos
- **Animações suaves**: Transições e efeitos para movimentos e ações
- **Detalhes visuais**: Sombreamento, brilhos e elementos decorativos
- **Feedback visual**: Indicações claras para ações e eventos importantes

#### Métodos Principais:

**`visual_effects.shakeScreen(intensity, duration)`**
- **Propósito**: Inicia efeito de tremor de tela
- **Parâmetros**: Intensidade e duração do tremor

**`visual_effects.drawBomb(x, y, size, timer, isFlashing)`**
- **Propósito**: Desenha uma bomba com efeitos visuais
- **Funcionamento**: Inclui corpo da bomba, pavio animado e efeito de piscagem

**`visual_effects.drawExplosion(x, y, size, type, lifetime)`**
- **Propósito**: Desenha uma explosão com efeitos
- **Funcionamento**: Adapta a aparência baseada no tipo e adiciona partículas

**`visual_effects.drawPowerup(x, y, size, type, pulse)`**
- **Propósito**: Desenha um power-up com efeitos visuais
- **Funcionamento**: Inclui efeitos de pulsação e símbolos indicativos

**`visual_effects.drawPlayer(x, y, size, id, direction, isMoving)`**
- **Propósito**: Desenha um jogador com detalhes visuais
- **Funcionamento**: Inclui cor por ID, indicação de direção e animação de movimento

### 6.2 Sistema de Partículas

O sistema de partículas adiciona efeitos dinâmicos para explosões, coletas de power-ups e outros eventos:

**`particle_system.createExplosionParticles(x, y, color)`**
- **Propósito**: Cria partículas para explosões
- **Funcionamento**: Configura partículas que se expandem a partir do ponto de explosão

**`particle_system.createPowerupCollectParticles(x, y, color)`**
- **Propósito**: Cria partículas para coleta de power-ups
- **Funcionamento**: Configura partículas que sobem a partir do ponto de coleta

### 6.3 Sistema de Iluminação

O sistema de iluminação adiciona profundidade e atmosfera ao jogo:

**`lighting.addLight(x, y, radius, r, g, b, duration)`**
- **Propósito**: Adiciona uma fonte de luz temporária
- **Funcionamento**: Cria uma luz que diminui gradualmente

**`lighting.draw()`**
- **Propósito**: Renderiza todas as luzes ativas
- **Funcionamento**: Desenha gradientes de luz com modo de blend aditivo

---

## 7. Recursos e Otimizações

### 7.1 Gerenciamento de Memória

O jogo implementa várias técnicas para otimizar o uso de memória:

- **Remoção de Entidades**: Bombas, explosões e power-ups são removidos quando não são mais necessários
- **Reutilização de Objetos**: Quando possível, objetos são reutilizados em vez de criar novos
- **Ciclo de Vida Gerenciado**: Cada entidade tem um ciclo de vida claro e bem definido

### 7.2 Otimização de Desempenho

Para garantir desempenho suave em diferentes dispositivos:

- **Uso de Delta Time**: Movimento consistente independente da taxa de quadros
- **Verificações de Colisão Eficientes**: Algoritmos otimizados para verificação de colisões
- **Renderização Condicional**: Elementos fora da tela não são renderizados
- **Priorização de Atualizações**: Elementos mais importantes são atualizados primeiro

### 7.3 Código Modular e Reutilizável

O código é estruturado para facilitar manutenção e extensão:

- **Separação de Responsabilidades**: Cada módulo tem um propósito claro
- **Encapsulamento**: Os detalhes de implementação são escondidos dentro de cada módulo
- **Interfaces Bem Definidas**: Comunicação clara entre módulos
- **Baixo Acoplamento**: Minimiza dependências entre componentes

---

## 8. Próximas Etapas

### 8.1 Recursos Adicionais de Gameplay

- **Power-ups Especiais**: Chute de bomba, passe através de bombas, escudo temporário
- **Modos de Jogo**: Battle Royale, captura de bandeira, sobrevivência
- **Monstros/NPCs**: Inimigos controlados pelo computador
- **Mapas Temáticos**: Diferentes ambientes com mecânicas únicas

### 8.2 Melhoria Visual

- **Sprites Detalhados**: Substituir formas geométricas por sprites completos
- **Animações Avançadas**: Adicionar frames de animação para todas as ações
- **Efeitos Ambientais**: Clima, tempo do dia, condições especiais
- **Iluminação Dinâmica**: Sistema de iluminação completo com sombras

### 8.3 Menu e Interface

- **Tela de Título**: Menu inicial completo
- **Seleção de Personagens**: Personagens diferentes com estatísticas únicas
- **Seleção de Mapa**: Escolha entre vários layouts de mapa
- **HUD Personalizado**: Interface do usuário com estilo temático
- **Opções e Configurações**: Ajustes de áudio, controles e gráficos

### 8.4 Áudio

- **Efeitos Sonoros**: Para todas as ações (movimento, bombas, explosões, power-ups)
- **Música Temática**: Trilha sonora para diferentes estágios e situações
- **Sons Ambientais**: Adicionar atmosfera ao jogo
- **Feedback Auditivo**: Sons específicos para eventos importantes

### 8.5 Multijogador Online

- **Modo Online**: Suporte para jogos pela internet
- **Matchmaking**: Sistema para encontrar oponentes
- **Ranqueamento**: Sistema de classificação competitivo
- **Estatísticas do Jogador**: Acompanhamento de desempenho

---

## Conclusão

Este documento descreve o design e a implementação atual de um clone do Bomberman em Lua/LÖVE, detalhando as mecânicas principais, a arquitetura modular do sistema, os componentes individuais e os sistemas visuais implementados. A estrutura modular adotada facilita a extensão e manutenção do código, permitindo adicionar novas funcionalidades e refinar as existentes.

O projeto implementou com sucesso as mecânicas fundamentais do Bomberman, incluindo movimento em grade com curvas fluidas, colocação de bombas, propagação de explosões, sistema completo de power-ups e suporte a múltiplos jogadores. Além disso, foram adicionados efeitos visuais aprimorados e sistemas de feedback para melhorar a experiência do usuário.

As próximas etapas focarão em expandir essas funcionalidades, adicionar mais conteúdo e refinar a experiência geral do jogo.
