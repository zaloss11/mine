local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Модули
local MiningConfig = require(ReplicatedStorage:WaitForChild("MiningConfig"))

-- Получаем GUI
local screenGui = playerGui:WaitForChild("MiningGameGUI")
local mainFrame = screenGui:WaitForChild("MainFrame")
local platformFrame = mainFrame:WaitForChild("PlatformFrame")

-- Создаем визуальные объекты руды
local oreVisuals = {}

-- Функция создания визуального объекта руды
local function createOreVisual(oreType, x, z)
	local oreConfig = MiningConfig.ORE_TYPES[oreType]
	if not oreConfig then return end
	
	-- Создаем визуальный объект
	local oreVisual = Instance.new("Frame")
	oreVisual.Name = "OreVisual_" .. x .. "_" .. z
	oreVisual.Size = UDim2.new(0.8, 0, 0.8, 0)
	oreVisual.Position = UDim2.new(0.1, 0, 0.1, 0)
	oreVisual.BackgroundColor3 = oreConfig.color
	oreVisual.BorderSizePixel = 2
	oreVisual.BorderColor3 = Color3.fromRGB(255, 255, 255)
	oreVisual.Parent = platformFrame
	
	-- Добавляем текст с названием руды
	local oreLabel = Instance.new("TextLabel")
	oreLabel.Size = UDim2.new(1, 0, 1, 0)
	oreLabel.Position = UDim2.new(0, 0, 0, 0)
	oreLabel.BackgroundTransparency = 1
	oreLabel.Text = oreConfig.name
	oreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	oreLabel.TextScaled = true
	oreLabel.Font = Enum.Font.GothamBold
	oreLabel.Parent = oreVisual
	
	-- Добавляем анимацию появления
	local tween = TweenService:Create(oreVisual, TweenInfo.new(0.5), {
		Size = UDim2.new(0.9, 0, 0.9, 0),
		Position = UDim2.new(0.05, 0, 0.05, 0)
	})
	tween:Play()
	
	oreVisuals[x .. "_" .. z] = oreVisual
end

-- Функция удаления визуального объекта руды
local function removeOreVisual(x, z)
	local key = x .. "_" .. z
	local oreVisual = oreVisuals[key]
	
	if oreVisual then
		-- Анимация исчезновения
		local tween = TweenService:Create(oreVisual, TweenInfo.new(0.3), {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0)
		})
		tween:Play()
		tween.Completed:Connect(function()
			oreVisual:Destroy()
			oreVisuals[key] = nil
		end)
	end
end

-- Функция обновления всех визуальных объектов
local function updateAllOreVisuals(oreData)
	-- Удаляем все существующие визуальные объекты
	for key, visual in pairs(oreVisuals) do
		visual:Destroy()
	end
	oreVisuals = {}
	
	-- Создаем новые визуальные объекты
	for x = 1, MiningConfig.PLATFORM_SIZE do
		for z = 1, MiningConfig.PLATFORM_SIZE do
			if oreData[x] and oreData[x][z] then
				createOreVisual(oreData[x][z].type, x, z)
			end
		end
	end
end

-- Экспортируем функции для использования в основном GUI
return {
	createOreVisual = createOreVisual,
	removeOreVisual = removeOreVisual,
	updateAllOreVisuals = updateAllOreVisuals
} 