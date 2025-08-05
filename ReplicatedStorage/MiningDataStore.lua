local DataStoreService = game:GetService("DataStoreService")
local MiningDataStore = DataStoreService:GetDataStore("MiningGameData")

local MiningDataStore = {}

-- Структура данных игрока
local function createDefaultPlayerData()
	return {
		coins = 0,
		ores = {
			Stone = 0,
			Copper = 0,
			Tin = 0,
			Iron = 0,
			Gold = 0,
			Diamond = 0
		},
		unlockedTiles = 1, -- Начинаем с 1 клетки
		lastSave = os.time()
	}
end

-- Загрузка данных игрока
function MiningDataStore:LoadPlayerData(player)
	local success, data = pcall(function()
		return MiningDataStore:GetAsync(player.UserId)
	end)
	
	if success and data then
		return data
	else
		return createDefaultPlayerData()
	end
end

-- Сохранение данных игрока
function MiningDataStore:SavePlayerData(player, data)
	local success, err = pcall(function()
		MiningDataStore:SetAsync(player.UserId, data)
	end)
	
	if not success then
		warn("Ошибка сохранения данных для игрока " .. player.Name .. ": " .. tostring(err))
	end
end

-- Обновление данных игрока
function MiningDataStore:UpdatePlayerData(player, data)
	data.lastSave = os.time()
	self:SavePlayerData(player, data)
end

return MiningDataStore 