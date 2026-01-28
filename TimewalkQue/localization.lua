-- Localization file for TimewalkQue
local L = {}

L["enUS"] = {
    ADDON_LOADED = "TimewalkQue loaded. Automatically selects Timewalking dungeons when event is active.",
    EVENT_DETECTED = "TimewalkQue: Timewalking event detected!",
    DUNGEON_SELECTED = "TimewalkQue: Selected Random Timewalking Dungeon"
}

L["zhCN"] = {
    ADDON_LOADED = "TimewalkQue 已加载。时光漫游事件激活时自动选择时光漫游地下城。",
    EVENT_DETECTED = "TimewalkQue: 检测到时光漫游事件！",
    DUNGEON_SELECTED = "TimewalkQue: 已选择随机时光漫游地下城"
}

L["zhTW"] = {
    ADDON_LOADED = "TimewalkQue 已載入。時光漫遊事件啟用時自動選擇時光漫遊地城。",
    EVENT_DETECTED = "TimewalkQue: 偵測到時光漫遊事件！",
    DUNGEON_SELECTED = "TimewalkQue: 已選擇隨機時光漫遊地城"
}

-- Set the localization based on client locale
local locale = GetLocale()
TimewalkQue_L = L[locale] or L["enUS"]