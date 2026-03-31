--!strict
--[[
	GameConfig - Arena do Caos
	
	Módulo de configurações centrais do jogo.
	Define as regras de rodada, recompensas de economia e os itens de loja (arremessáveis).
	Utiliza table.freeze para proteger a configuração contra modificações acidentais em tempo de execução.
]]

-- Tipagem para os objetos arremessáveis
export type ThrowableItem = {
	Id: number,
	Name: string,
	Price: number,
	Damage: number,   -- Força do empurrão/knockback
	Cooldown: number, -- Tempo de recarga entre arremessos (segundos)
}

-- Tipagem principal das configurações
export type GameConfiguration = {
	RoundSettings: {
		IntermissionTime: number,
		RoundTime: number,
		MinimumPlayers: number,
	},
	Economy: {
		WinReward: number,
		SurvivalReward: number,
	},
	-- Dicionário indexado por Id numérico
	ShopItems: {
		[number]: ThrowableItem
	}
}

local GameConfig: GameConfiguration = {
	
	-- Configurações base das rodadas
	RoundSettings = {
		IntermissionTime = 15, -- Tempo de espera no lobby (segundos)
		RoundTime = 120,       -- Duração máxima de combate na arena (segundos)
		MinimumPlayers = 2,    -- Mínimo de jogadores para iniciar a rodada
	},

	-- Configurações de recompensas na economia do jogo
	Economy = {
		WinReward = 50,      -- Recompensa para o grande vencedor (último na plataforma)
		SurvivalReward = 10, -- Recompensa de participação/sobrevivência parcial
	},

	-- Tabela de itens da loja com foco em acesso rápido via ID O(1)
	ShopItems = {
		[1] = {
			Id = 1,
			Name = "Cadeira",
			Price = 0,         -- Arma desbloqueada por padrão
			Damage = 25,       -- Força de empurrão leve
			Cooldown = 1.5,    -- Arremesso rápido
		},
		[2] = {
			Id = 2,
			Name = "Geladeira",
			Price = 500,       -- Item intermediário
			Damage = 85,       -- Empurrão forte, área de colisão maior
			Cooldown = 4.0,    -- Demora mais para levantar e arremessar
		},
		[3] = {
			Id = 3,
			Name = "Piano",
			Price = 1500,      -- Item de end-game
			Damage = 200,      -- Empurrão avassalador
			Cooldown = 7.0,    -- Tempo de recarga muito longo para compensar o desbalanceamento intencional
		}
	}
}

-- Converte a tabela pra "Read-Only". Isso garante que nenhum código do jogo
-- vai aleatoriamente alterar os tempos, recompensas ou danos durante a gameplay.
return table.freeze(GameConfig)
