local MiningConfig = {}

-- Настройки платформы
MiningConfig.PLATFORM_SIZE = 10
MiningConfig.INITIAL_TILES = 1

-- Типы руды и их дропы
MiningConfig.ORE_TYPES = {
	Stone = {
		name = "Камень",
		color = Color3.fromRGB(128, 128, 128),
		drop = {
			Stone = 2
		},
		spawnChance = 0.4
	},
	Copper = {
		name = "Медь",
		color = Color3.fromRGB(184, 115, 51),
		drop = {
			Stone = 1,
			Copper = 1
		},
		spawnChance = 0.25
	},
	Tin = {
		name = "Олово",
		color = Color3.fromRGB(192, 192, 192),
		drop = {
			Stone = 1,
			Tin = 2
		},
		spawnChance = 0.15
	},
	Iron = {
		name = "Железо",
		color = Color3.fromRGB(139, 69, 19),
		drop = {
			Stone = 1,
			Iron = 1
		},
		spawnChance = 0.1
	},
	Gold = {
		name = "Золото",
		color = Color3.fromRGB(255, 215, 0),
		drop = {
			Stone = 1,
			Gold = 1
		},
		spawnChance = 0.07
	},
	Diamond = {
		name = "Алмаз",
		color = Color3.fromRGB(185, 242, 255),
		drop = {
			Stone = 1,
			Diamond = 1
		},
		spawnChance = 0.03
	}
}

-- Цены продажи руды
MiningConfig.ORE_PRICES = {
	Stone = 1,
	Copper = 5,
	Tin = 10,
	Iron = 25,
	Gold = 100,
	Diamond = 500
}

-- Цена покупки новой клетки
MiningConfig.TILE_PRICE = 50

-- Время респауна руды (в секундах)
MiningConfig.ORE_RESPAWN_TIME = 30

return MiningConfig 