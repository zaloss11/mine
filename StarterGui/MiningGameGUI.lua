local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Модули
local MiningConfig = require(ReplicatedStorage:WaitForChild("MiningConfig"))

-- RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("MiningRemoteEvents")
local MineOreEvent = RemoteEvents:WaitForChild("MineOre")
local BuyTileEvent = RemoteEvents:WaitForChild("BuyTile")
local SellOreEvent = RemoteEvents:WaitForChild("SellOre")

-- Создаем основной GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MiningGameGUI"
screenGui.Parent = playerGui

-- Главный фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Parent = screenGui

-- Платформа для добычи
local platformFrame = Instance.new("Frame")
platformFrame.Name = "PlatformFrame"
platformFrame.Size = UDim2.new(0.6, 0, 0.7, 0)
platformFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
platformFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
platformFrame.BorderSizePixel = 2
platformFrame.BorderColor3 = Color3.fromRGB(120, 120, 120)
platformFrame.Parent = mainFrame

-- Создаем клетки платформы
local tiles = {}
local tileSize = 1 / MiningConfig.PLATFORM_SIZE

for x = 1, MiningConfig.PLATFORM_SIZE do
	tiles[x] = {}
	for z = 1, MiningConfig.PLATFORM_SIZE do
		local tile = Instance.new("TextButton")
		tile.Name = "Tile_" .. x .. "_" .. z
		tile.Size = UDim2.new(tileSize, -2, tileSize, -2)
		tile.Position = UDim2.new((x-1) * tileSize, 1, (z-1) * tileSize, 1)
		tile.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		tile.BorderSizePixel = 1
		tile.BorderColor3 = Color3.fromRGB(60, 60, 60)
		tile.Text = ""
		tile.TextColor3 = Color3.fromRGB(255, 255, 255)
		tile.TextScaled = true
		tile.Font = Enum.Font.GothamBold
		tile.Parent = platformFrame
		
		-- Обработчик клика
		tile.MouseButton1Click:Connect(function()
			MineOreEvent:FireServer(x, z)
		end)
		
		tiles[x][z] = tile
	end
end

-- Панель информации
local infoFrame = Instance.new("Frame")
infoFrame.Name = "InfoFrame"
infoFrame.Size = UDim2.new(0.25, 0, 0.7, 0)
infoFrame.Position = UDim2.new(0.7, 0, 0.15, 0)
infoFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
infoFrame.BorderSizePixel = 2
infoFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
infoFrame.Parent = mainFrame

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
titleLabel.Text = "Шахта"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = infoFrame

-- Монеты
local coinsLabel = Instance.new("TextLabel")
coinsLabel.Name = "CoinsLabel"
coinsLabel.Size = UDim2.new(1, 0, 0.08, 0)
coinsLabel.Position = UDim2.new(0, 0, 0.12, 0)
coinsLabel.BackgroundTransparency = 1
coinsLabel.Text = "Монеты: 0"
coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinsLabel.TextScaled = true
coinsLabel.Font = Enum.Font.Gotham
coinsLabel.Parent = infoFrame

-- Кнопка покупки клетки
local buyTileButton = Instance.new("TextButton")
buyTileButton.Name = "BuyTileButton"
buyTileButton.Size = UDim2.new(0.8, 0, 0.08, 0)
buyTileButton.Position = UDim2.new(0.1, 0, 0.22, 0)
buyTileButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
buyTileButton.Text = "Купить клетку (" .. MiningConfig.TILE_PRICE .. " монет)"
buyTileButton.TextColor3 = Color3.fromRGB(255, 255, 255)
buyTileButton.TextScaled = true
buyTileButton.Font = Enum.Font.GothamBold
buyTileButton.Parent = infoFrame

buyTileButton.MouseButton1Click:Connect(function()
	BuyTileEvent:FireServer()
end)

-- Инвентарь
local inventoryLabel = Instance.new("TextLabel")
inventoryLabel.Name = "InventoryLabel"
inventoryLabel.Size = UDim2.new(1, 0, 0.08, 0)
inventoryLabel.Position = UDim2.new(0, 0, 0.32, 0)
inventoryLabel.BackgroundTransparency = 1
inventoryLabel.Text = "Инвентарь:"
inventoryLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
inventoryLabel.TextScaled = true
inventoryLabel.Font = Enum.Font.GothamBold
inventoryLabel.Parent = infoFrame

-- Создаем лейблы для каждого типа руды
local oreLabels = {}
local yOffset = 0.42

for oreType, oreData in pairs(MiningConfig.ORE_TYPES) do
	local oreLabel = Instance.new("TextLabel")
	oreLabel.Name = oreType .. "Label"
	oreLabel.Size = UDim2.new(1, 0, 0.06, 0)
	oreLabel.Position = UDim2.new(0, 0, yOffset, 0)
	oreLabel.BackgroundTransparency = 1
	oreLabel.Text = oreData.name .. ": 0"
	oreLabel.TextColor3 = oreData.color
	oreLabel.TextScaled = true
	oreLabel.Font = Enum.Font.Gotham
	oreLabel.Parent = infoFrame
	
	oreLabels[oreType] = oreLabel
	yOffset = yOffset + 0.08
end

-- Кнопки продажи
yOffset = yOffset + 0.02
for oreType, oreData in pairs(MiningConfig.ORE_TYPES) do
	local sellButton = Instance.new("TextButton")
	sellButton.Name = oreType .. "SellButton"
	sellButton.Size = UDim2.new(0.4, 0, 0.05, 0)
	sellButton.Position = UDim2.new(0.05, 0, yOffset, 0)
	sellButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	sellButton.Text = "Продать 1"
	sellButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	sellButton.TextScaled = true
	sellButton.Font = Enum.Font.Gotham
	sellButton.Parent = infoFrame
	
	sellButton.MouseButton1Click:Connect(function()
		SellOreEvent:FireServer(oreType, 1)
	end)
	
	local sellAllButton = Instance.new("TextButton")
	sellAllButton.Name = oreType .. "SellAllButton"
	sellAllButton.Size = UDim2.new(0.4, 0, 0.05, 0)
	sellAllButton.Position = UDim2.new(0.55, 0, yOffset, 0)
	sellAllButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	sellAllButton.Text = "Продать все"
	sellAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	sellAllButton.TextScaled = true
	sellAllButton.Font = Enum.Font.Gotham
	sellAllButton.Parent = infoFrame
	
	sellAllButton.MouseButton1Click:Connect(function()
		-- Получаем количество руды из лейбла
		local currentAmount = tonumber(string.match(oreLabels[oreType].Text, "%d+") or 0)
		if currentAmount > 0 then
			SellOreEvent:FireServer(oreType, currentAmount)
		end
	end)
	
	yOffset = yOffset + 0.07
end

-- Функция обновления GUI
local function updateGUI(playerData)
	-- Обновляем монеты
	coinsLabel.Text = "Монеты: " .. playerData.coins
	
	-- Обновляем инвентарь
	for oreType, amount in pairs(playerData.ores) do
		if oreLabels[oreType] then
			oreLabels[oreType].Text = MiningConfig.ORE_TYPES[oreType].name .. ": " .. amount
		end
	end
	
	-- Обновляем доступные клетки
	for x = 1, MiningConfig.PLATFORM_SIZE do
		for z = 1, MiningConfig.PLATFORM_SIZE do
			local tile = tiles[x][z]
			if x <= playerData.unlockedTiles and z <= playerData.unlockedTiles then
				tile.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
				tile.Text = ""
			else
				tile.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				tile.Text = "🔒"
			end
		end
	end
end

-- Функция обновления руды на платформе
local function updatePlatformOres(oreData)
	for x = 1, MiningConfig.PLATFORM_SIZE do
		for z = 1, MiningConfig.PLATFORM_SIZE do
			local tile = tiles[x][z]
			if oreData[x] and oreData[x][z] then
				local oreType = oreData[x][z].type
				local oreConfig = MiningConfig.ORE_TYPES[oreType]
				tile.BackgroundColor3 = oreConfig.color
				tile.Text = "💎"
			else
				tile.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
				tile.Text = ""
			end
		end
	end
end

-- Обработчики событий
MineOreEvent.OnClientEvent:Connect(function(success, result, x, z)
	if success == "INIT" then
		-- Инициализация данных игрока
		updateGUI(result)
	elseif success then
		-- Успешная добыча
		local tile = tiles[x][z]
		tile.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		tile.Text = ""
		
		-- Показываем уведомление
		local notification = Instance.new("TextLabel")
		notification.Size = UDim2.new(0.2, 0, 0.05, 0)
		notification.Position = UDim2.new(0.4, 0, 0.4, 0)
		notification.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
		notification.Text = "Добыто: " .. result
		notification.TextColor3 = Color3.fromRGB(255, 255, 255)
		notification.TextScaled = true
		notification.Font = Enum.Font.GothamBold
		notification.Parent = mainFrame
		
		-- Анимация исчезновения
		local tween = TweenService:Create(notification, TweenInfo.new(2), {BackgroundTransparency = 1, TextTransparency = 1})
		tween:Play()
		tween.Completed:Connect(function()
			notification:Destroy()
		end)
	end
end)

BuyTileEvent.OnClientEvent:Connect(function(success, result)
	if success then
		-- Показываем уведомление
		local notification = Instance.new("TextLabel")
		notification.Size = UDim2.new(0.2, 0, 0.05, 0)
		notification.Position = UDim2.new(0.4, 0, 0.4, 0)
		notification.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
		notification.Text = "Куплена новая клетка!"
		notification.TextColor3 = Color3.fromRGB(255, 255, 255)
		notification.TextScaled = true
		notification.Font = Enum.Font.GothamBold
		notification.Parent = mainFrame
		
		local tween = TweenService:Create(notification, TweenInfo.new(2), {BackgroundTransparency = 1, TextTransparency = 1})
		tween:Play()
		tween.Completed:Connect(function()
			notification:Destroy()
		end)
	else
		-- Показываем ошибку
		local notification = Instance.new("TextLabel")
		notification.Size = UDim2.new(0.2, 0, 0.05, 0)
		notification.Position = UDim2.new(0.4, 0, 0.4, 0)
		notification.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
		notification.Text = result
		notification.TextColor3 = Color3.fromRGB(255, 255, 255)
		notification.TextScaled = true
		notification.Font = Enum.Font.GothamBold
		notification.Parent = mainFrame
		
		local tween = TweenService:Create(notification, TweenInfo.new(2), {BackgroundTransparency = 1, TextTransparency = 1})
		tween:Play()
		tween.Completed:Connect(function()
			notification:Destroy()
		end)
	end
end)

SellOreEvent.OnClientEvent:Connect(function(success, result, oreType, amount)
	if success then
		-- Показываем уведомление
		local notification = Instance.new("TextLabel")
		notification.Size = UDim2.new(0.2, 0, 0.05, 0)
		notification.Position = UDim2.new(0.4, 0, 0.4, 0)
		notification.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
		notification.Text = "Продано за " .. result .. " монет!"
		notification.TextColor3 = Color3.fromRGB(255, 255, 255)
		notification.TextScaled = true
		notification.Font = Enum.Font.GothamBold
		notification.Parent = mainFrame
		
		local tween = TweenService:Create(notification, TweenInfo.new(2), {BackgroundTransparency = 1, TextTransparency = 1})
		tween:Play()
		tween.Completed:Connect(function()
			notification:Destroy()
		end)
	else
		-- Показываем ошибку
		local notification = Instance.new("TextLabel")
		notification.Size = UDim2.new(0.2, 0, 0.05, 0)
		notification.Position = UDim2.new(0.4, 0, 0.4, 0)
		notification.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
		notification.Text = result
		notification.TextColor3 = Color3.fromRGB(255, 255, 255)
		notification.TextScaled = true
		notification.Font = Enum.Font.GothamBold
		notification.Parent = mainFrame
		
		local tween = TweenService:Create(notification, TweenInfo.new(2), {BackgroundTransparency = 1, TextTransparency = 1})
		tween:Play()
		tween.Completed:Connect(function()
			notification:Destroy()
		end)
	end
end)

print("Mining Game GUI загружен!") 