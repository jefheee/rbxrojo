--!strict
--[[
	GameConfig
	
	Módulo de configurações gerais do jogo. Centraliza variáveis globais,
	configurações de jogador, economia inicial e itens de loja consumíveis.
	Desenvolvido de acordo com as melhores práticas de Arquitetura de Software no Roblox.
	Utiliza tipagem (type checking) do Luau para garantir consistência dos dados.
]]

-- Tipagem da estrutura de um item consumível da loja
export type ConsumableItem = {
	id: number,
	name: string,
	price: number,
	benefitMultiplier: number,
}

-- Tipagem principal das configurações do jogo
export type GameConfiguration = {
	PlayerSettings: {
		BaseSpeed: number,
		MaxHealth: number,
	},
	Economy: {
		StartingCoins: number,
		StartingGems: number,
	},
	-- Dicionário indexado pelo ID do item para busca instantânea O(1)
	ShopItems: { 
		[number]: ConsumableItem 
	}
}

local GameConfig: GameConfiguration = {
	
	-- Configurações base do personagem do jogador
	PlayerSettings = {
		BaseSpeed = 16,  -- Velocidade de movimento padrão do personagem (WalkSpeed)
		MaxHealth = 100, -- Vida máxima padrão (MaxHealth)
	},

	-- Configurações da economia inicial concedida a novos jogadores
	Economy = {
		StartingCoins = 150, -- Dinheiro comum inicial
		StartingGems = 10,   -- Moeda premium/rara inicial
	},

	-- Tabela de itens da loja (Itens Consumíveis)
	ShopItems = {
		[1] = {
			id = 1,
			name = "Poção de Vida Menor",
			price = 50,
			benefitMultiplier = 1.25, -- Aumenta temporariamente a vida máxima em 25%
		},
		[2] = {
			id = 2,
			name = "Bebida Energética",
			price = 120,
			benefitMultiplier = 1.5, -- Aumenta a velocidade de movimento em 50%
		},
		[3] = {
			id = 3,
			name = "Elixir da Fortuna",
			price = 300,
			benefitMultiplier = 2.0, -- Dobra o ganho temporário de moedas (200%)
		}
	}
}

-- Retorna a tabela completa de configurações. 
-- Sendo um ModuleScript, o valor retornado é cacheado (singleton) na mesma fronteira (Client ou Server),
-- o que é ideal para configurações de leitura apenas.
return GameConfig
