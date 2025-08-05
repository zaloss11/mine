local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Модули
local MiningConfig = require(ReplicatedStorage:WaitForChild("MiningConfig"))

-- Хранилище руды на платформе (общее для всех игроков)
local PlatformOres = {}

-- Инициализация платформы
local function initializePlatform()
	for x = 1, MiningConfig.PLATFORM_SIZE do
		PlatformOres[x] = {}
		for z = 1, MiningConfig.PLATFORM_SIZE do
			PlatformOres[x][z] = nil
		end
	end
end

-- Спавн руды на клетке
local function spawnOre(x, z)
	local random = math.random()
	local cumulativeChance = 0
	
	for oreType, oreData in pairs(MiningConfig.ORE_TYPES) do
		cumulativeChance = cumulativeChance + oreData.spawnChance
		if random <= cumulativeChance then
			PlatformOres[x][z] = {
				type = oreType,
				spawnTime = tick()
			}
			break
		end
	end
end

-- Проверка и респаун руды
local function checkAndRespawnOres()
	local currentTime = tick()
	
	for x = 1, MiningConfig.PLATFORM_SIZE do
		for z = 1, MiningConfig.PLATFORM_SIZE do
			local oreData = PlatformOres[x][z]
			
			-- Если на клетке нет руды, спавним новую
			if not oreData then
				spawnOre(x, z)
			end
		end
	end
end

-- Получение данных о руде на платформе
local function getPlatformOres()
	return PlatformOres
end

-- Удаление руды с клетки (вызывается при добыче)
local function removeOre(x, z)
	PlatformOres[x][z] = nil
end

-- Инициализация
initializePlatform()

-- Автоматический респаун руды каждые 30 секунд
spawn(function()
	while true do
		wait(MiningConfig.ORE_RESPAWN_TIME)
		checkAndRespawnOres()
		print("Руда респавнена на платформе")
	end
end)

-- Экспортируем функции для использования в других скриптах
return {
	getPlatformOres = getPlatformOres,
	removeOre = removeOre,
	spawnOre = spawnOre
} 