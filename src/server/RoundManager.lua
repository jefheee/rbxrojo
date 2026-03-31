--!strict
--[[
	RoundManager - Arena do Caos
	
	Gerencia o fluxo principal do jogo em um loop contínuo:
	1. Intermission: Aguarda jogadores suficientes no servidor.
	2. InRound: Teleporta jogadores para os spawns ("ArenaSpawns") e gerencia eliminações.
	3. RoundEnd: Finaliza a rodada e premia o vencedor ou sobreviventes.
	
	Boas práticas aplicadas:
	- Separação de estados usando funções dedicadas.
	- Rastreio de instâncias limpo via dicionário local.
	- Utiliza :PivotTo() recomendado no lugar de SetPrimaryPartCFrame().
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Resgate das Configurações
-- Garantimos os tipos usando assert ou type casting para acomodar o Luau Strict Mode
local ConfigFolder = ReplicatedStorage:WaitForChild("Config")
local GameConfigModule = ConfigFolder:WaitForChild("GameConfig") :: ModuleScript
local GameConfig = require(GameConfigModule) :: any

-- [[ Tipagens de Estado ]]
export type GameState = "Intermission" | "InRound" | "RoundEnd"

-- [[ Variáveis de Estado (Memória Local) ]]
local currentState: GameState = "Intermission"

-- Dicionário indexado por Player, com valor de boolean, rastreando quem ainda vive na arena.
-- O(1) de acesso e deleção, muito mais limpo do que iterar arrays.
local alivePlayers: { [Player]: boolean } = {} 

local RoundManager = {}

-- [[ Métodos de Auxílio (Helpers) ]]

-- Retorna a quantidade de jogadores vivos na rodada
local function getAliveCount(): number
	local count = 0
	for _, _ in pairs(alivePlayers) do
		count += 1
	end
	return count
end

-- Varre a pasta "ArenaSpawns" no Workspace atrás de parts definidoras
local function getArenaSpawns(): {BasePart}
	local spawnsFolder = Workspace:FindFirstChild("ArenaSpawns")
	if not spawnsFolder then return {} end
	
	local spawns: {BasePart} = {}
	for _, child in ipairs(spawnsFolder:GetChildren()) do
		if child:IsA("BasePart") then
			table.insert(spawns, child)
		end
	end
	return spawns
end

-- Teleporta de forma balanceada todos os vivos pros Spawns da Arena
local function teleportPlayersToArena()
	local spawns = getArenaSpawns()
	local totalSpawns = #spawns
	
	if totalSpawns == 0 then
		-- Sem spawns definidos, o jogo não vai travar, apenas avisa o console
		warn("[RoundManager] A pasta 'ArenaSpawns' no Workspace não foi encontrada ou está vazia!")
		return
	end
	
	for player, _ in pairs(alivePlayers) do
		local character = player.Character
		if character and character.PrimaryPart then
			local randomNode = spawns[math.random(1, totalSpawns)]
			-- Método de teleporte Otimizado (Best Practice desde 2021)
			character:PivotTo(randomNode.CFrame + Vector3.new(0, 5, 0))
		else
			-- Se tentar teleportar, mas o player não tem Char ainda, ele é desclassificado
			alivePlayers[player] = nil
		end
	end
end

-- Listeners injetados para ouvir quando um jogador vivo morrer (para ser retirado da lista)
local function linkPlayerDeath(player: Player)
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Died:Connect(function()
				if alivePlayers[player] then
					alivePlayers[player] = nil
					print("[RoundManager]", player.Name, "foi eliminado!")
					-- Aqui entraremos com sons de game over individuais via RemoteEvent depois.
				end
			end)
		end
	end
end

-- [[ Máquina de Estados (State Machine) ]]

-- 1. Intermission
local function runIntermission()
	currentState = "Intermission"
	print("[RoundManager] === INTERMISSION ===")
	
	-- Impede que a contagem inicie caso não tenham jogadores suficientes (Ex: só 1 player na sala)
	while #Players:GetPlayers() < GameConfig.RoundSettings.MinimumPlayers do
		task.wait(1)
	end
	
	print("[RoundManager] Jogadores suficientes prontos!")
	
	-- Contagem regressiva (Geralmente reflete na UI do lobby)
	for timer = GameConfig.RoundSettings.IntermissionTime, 1, -1 do
		-- Disparador eventual de RemoteEvents aqui: UpdateUITimer(timer, "A partida começa em...")
		task.wait(1)
	end
end

-- 2. InRound (Partida Ativa)
local function runInRound()
	currentState = "InRound"
	print("[RoundManager] === IN ROUND ===")
	
	-- Limpa e reavalia quem será considerado "vivo" na rodada
	table.clear(alivePlayers)
	for _, player in ipairs(Players:GetPlayers()) do
		alivePlayers[player] = true
		linkPlayerDeath(player)
	end
	
	teleportPlayersToArena()
	
	-- Loop responsável pelo tempo de vida da rodada
	local timeElapsed = 0
	local maxRoundTime = GameConfig.RoundSettings.RoundTime
	
	while timeElapsed < maxRoundTime do
		-- Fim prematuro: Se sobrar apenas 1 (ou 0), não há motivos para ficar rolando o tempo.
		if getAliveCount() <= 1 then
			break
		end
		
		task.wait(1)
		timeElapsed += 1
	end
end

-- 3. RoundEnd (Premiação e Resete)
local function runRoundEnd()
	currentState = "RoundEnd"
	print("[RoundManager] === ROUND OVER ===")
	
	local aliveCount = getAliveCount()
	
	if aliveCount == 1 then
		-- Um vencedor absoluto da sobrevivência (Last Man Standing)
		-- Como há só um item no dicionário, esse (for) roda só uma vez e encerra
		for player, _ in pairs(alivePlayers) do
			print("[RoundManager] VENCEDOR:", player.Name)
			-- Ex: player.leaderstats.Moedas.Value += GameConfig.Economy.WinReward
		end
	elseif aliveCount > 1 then
		-- O tempo exauriu (ex: os 120s se passaram) e mais de 1 ficaram na plataforma (Sobreviventes)
		print("[RoundManager] FINAL PACÍFICO:", aliveCount, "sobreviventes.")
		for player, _ in pairs(alivePlayers) do
			-- Ex: player.leaderstats.Moedas.Value += GameConfig.Economy.SurvivalReward
		end
	else
		-- Empate absoluto (todos caíram no final da contagem)
		print("[RoundManager] EMPATE. Ninguém ganhou.")
	end
	
	-- Limpeza da memória dos vivos antes de reiniciar o loop inteiro
	table.clear(alivePlayers)
	
	-- Tela temporal para que leiam quem venceu
	task.wait(5)
end

-- [[ Ponto de Entrada / Inicialização ]]

-- Inicia o ciclo sem fim usando multi-thread (task.spawn) para não congelar o servidor principal
function RoundManager.StartCycle()
	task.spawn(function()
		while true do
			runIntermission()
			runInRound()
			runRoundEnd()
		end
	end)
end

return RoundManager
