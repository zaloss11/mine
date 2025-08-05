local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Модули
local MiningConfig = require(ReplicatedStorage:WaitForChild("MiningConfig"))
local MiningDataStore = require(ReplicatedStorage:WaitForChild("MiningDataStore"))

-- Создаем RemoteEvents
local RemoteEvents = Instance.new("Folder")
RemoteEvents.Name = "MiningRemoteEvents"
RemoteEvents.Parent = ReplicatedStorage

local MineOreEvent = Instance.new("RemoteEvent")
MineOreEvent.Name = "MineOre"
MineOreEvent.Parent = RemoteEvents

local BuyTileEvent = Instance.new("RemoteEvent")
BuyTileEvent.Name = "BuyTile"
BuyTileEvent.Parent = RemoteEvents

local SellOreEvent = Instance.new("RemoteEvent")
SellOreEvent.Name = "SellOre"
SellOreEvent.Parent = RemoteEvents

-- Хранилище данных игроков
local PlayerData = {}

-- Хранилище руды на платформе
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

-- Спавн руды на всех доступных клетках
local function spawnOresOnAvailableTiles(player)
	local playerData = PlayerData[player.UserId]
	if not playerData then return end
	
	for x = 1, MiningConfig.PLATFORM_SIZE do
		for z = 1, MiningConfig.PLATFORM_SIZE do
			-- Проверяем, доступна ли клетка игроку
			if x <= playerData.unlockedTiles and z <= playerData.unlockedTiles then
				if not PlatformOres[x][z] then
					spawnOre(x, z)
				end
			end
		end
	end
end

-- Добыча руды
local function mineOre(player, x, z)
	local playerData = PlayerData[player.UserId]
	if not playerData then return end
	
	-- Проверяем, доступна ли клетка игроку
	if x > playerData.unlockedTiles or z > playerData.unlockedTiles then
		return false, "Клетка не разблокирована"
	end
	
	-- Проверяем, есть ли руда на клетке
	local oreData = PlatformOres[x][z]
	if not oreData then
		return false, "На этой клетке нет руды"
	end
	
	-- Получаем данные о типе руды
	local oreTypeData = MiningConfig.ORE_TYPES[oreData.type]
	if not oreTypeData then
		return false, "Неизвестный тип руды"
	end
	
	-- Добавляем дроп в инвентарь игрока
	for oreType, amount in pairs(oreTypeData.drop) do
		playerData.ores[oreType] = (playerData.ores[oreType] or 0) + amount
	end
	
	-- Удаляем руду с платформы
	PlatformOres[x][z] = nil
	
	-- Сохраняем данные
	MiningDataStore:UpdatePlayerData(player, playerData)
	
	return true, oreTypeData.name, oreTypeData.drop
end

-- Покупка новой клетки
local function buyTile(player)
	local playerData = PlayerData[player.UserId]
	if not playerData then return false, "Ошибка данных игрока" end
	
	-- Проверяем, можно ли купить еще клетки
	if playerData.unlockedTiles >= MiningConfig.PLATFORM_SIZE then
		return false, "Достигнут максимум клеток"
	end
	
	-- Проверяем, хватает ли монет
	if playerData.coins < MiningConfig.TILE_PRICE then
		return false, "Недостаточно монет"
	end
	
	-- Покупаем клетку
	playerData.coins = playerData.coins - MiningConfig.TILE_PRICE
	playerData.unlockedTiles = playerData.unlockedTiles + 1
	
	-- Спавним руду на новой клетке
	spawnOresOnAvailableTiles(player)
	
	-- Сохраняем данные
	MiningDataStore:UpdatePlayerData(player, playerData)
	
	return true, playerData.unlockedTiles
end

-- Продажа руды
local function sellOre(player, oreType, amount)
	local playerData = PlayerData[player.UserId]
	if not playerData then return false, "Ошибка данных игрока" end
	
	-- Проверяем, есть ли такая руда у игрока
	if not playerData.ores[oreType] or playerData.ores[oreType] < amount then
		return false, "Недостаточно руды"
	end
	
	-- Проверяем, есть ли цена для этой руды
	local price = MiningConfig.ORE_PRICES[oreType]
	if not price then
		return false, "Неизвестный тип руды"
	end
	
	-- Продаем руду
	playerData.ores[oreType] = playerData.ores[oreType] - amount
	playerData.coins = playerData.coins + (price * amount)
	
	-- Сохраняем данные
	MiningDataStore:UpdatePlayerData(player, playerData)
	
	return true, price * amount
end

-- Обработчики RemoteEvents
MineOreEvent.OnServerEvent:Connect(function(player, x, z)
	local success, result = mineOre(player, x, z)
	MineOreEvent:FireClient(player, success, result, x, z)
end)

BuyTileEvent.OnServerEvent:Connect(function(player)
	local success, result = buyTile(player)
	BuyTileEvent:FireClient(player, success, result)
end)

SellOreEvent.OnServerEvent:Connect(function(player, oreType, amount)
	local success, result = sellOre(player, oreType, amount)
	SellOreEvent:FireClient(player, success, result, oreType, amount)
end)

-- Обработка подключения игрока
Players.PlayerAdded:Connect(function(player)
	-- Загружаем данные игрока
	local playerData = MiningDataStore:LoadPlayerData(player)
	PlayerData[player.UserId] = playerData
	
	-- Спавним руду на доступных клетках
	spawnOresOnAvailableTiles(player)
	
	-- Отправляем начальные данные клиенту
	wait(1) -- Ждем загрузки клиента
	MineOreEvent:FireClient(player, "INIT", playerData)
end)

-- Обработка отключения игрока
Players.PlayerRemoving:Connect(function(player)
	local playerData = PlayerData[player.UserId]
	if playerData then
		MiningDataStore:UpdatePlayerData(player, playerData)
		PlayerData[player.UserId] = nil
	end
end)

-- Автосохранение каждые 5 минут
spawn(function()
	while true do
		wait(300) -- 5 минут
		for userId, playerData in pairs(PlayerData) do
			local player = Players:GetPlayerByUserId(userId)
			if player then
				MiningDataStore:UpdatePlayerData(player, playerData)
			end
		end
	end
end)

-- Инициализация
initializePlatform()
print("Mining Game Server запущен!") 