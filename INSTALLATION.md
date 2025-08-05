# Инструкция по установке Mining Game

## Шаг 1: Создание нового места в Roblox Studio

1. Откройте Roblox Studio
2. Создайте новое место (Place)
3. Выберите базовый шаблон (например, Baseplate)

## Шаг 2: Настройка структуры папок

В Explorer создайте следующую структуру:

```
Game
├── ReplicatedStorage
│   ├── MiningConfig (ModuleScript)
│   └── MiningDataStore (ModuleScript)
├── ServerScriptService
│   ├── MiningGameServer (Script)
│   └── OreRespawnManager (Script)
└── StarterGui
    └── MiningGameGUI (LocalScript)
```

## Шаг 3: Копирование кода

### ReplicatedStorage/MiningConfig
Скопируйте содержимое файла `ReplicatedStorage/MiningConfig.lua` в ModuleScript MiningConfig.

### ReplicatedStorage/MiningDataStore
Скопируйте содержимое файла `ReplicatedStorage/MiningDataStore.lua` в ModuleScript MiningDataStore.

### ServerScriptService/MiningGameServer
Скопируйте содержимое файла `ServerScripts/MiningGameServer.lua` в Script MiningGameServer.

### ServerScriptService/OreRespawnManager
Скопируйте содержимое файла `ServerScripts/OreRespawnManager.lua` в Script OreRespawnManager.

### StarterGui/MiningGameGUI
Скопируйте содержимое файла `StarterGui/MiningGameGUI.lua` в LocalScript MiningGameGUI.

## Шаг 4: Настройка DataStore

1. В Game Settings включите DataStore API
2. Убедитесь, что у вас есть права на использование DataStore

## Шаг 5: Тестирование

1. Нажмите Play в Roblox Studio
2. Игра должна загрузиться с интерфейсом шахты
3. Проверьте, что можно:
   - Кликать на клетки для добычи руды
   - Покупать новые клетки
   - Продавать руду

## Возможные проблемы

### Ошибка "MiningConfig not found"
Убедитесь, что ModuleScript MiningConfig находится в ReplicatedStorage и имеет правильное имя.

### Ошибка DataStore
Проверьте, что DataStore API включен в настройках игры.

### GUI не отображается
Убедитесь, что LocalScript MiningGameGUI находится в StarterGui.

## Настройка игры

Вы можете изменить параметры игры в файле `MiningConfig.lua`:

- `PLATFORM_SIZE` - размер платформы (по умолчанию 10x10)
- `TILE_PRICE` - цена покупки новой клетки
- `ORE_PRICES` - цены продажи руды
- `ORE_RESPAWN_TIME` - время респауна руды
- `ORE_TYPES` - типы руды и их характеристики

## Публикация

1. Сохраните место
2. Нажмите Publish to Roblox
3. Заполните информацию о игре
4. Опубликуйте

Игра готова к использованию! 