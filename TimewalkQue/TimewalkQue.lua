local TimewalkQue = CreateFrame("Frame", "TimewalkQue")
TimewalkQue:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](self, ...)
    end
end)

TimewalkQue:RegisterEvent("ADDON_LOADED")
TimewalkQue:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
TimewalkQue:RegisterEvent("PLAYER_ENTERING_WORLD")

local addonName = "TimewalkQue"
local isTimewalkingActive = false

local TIMWALKING_DUNGEON_ID = 1166  -- Random Timewalking Dungeon
local RANDOM_HEROIC_ID = 1193      -- Random Heroic (The War Within: Season 3) - this may need adjustment

function TimewalkQue:ADDON_LOADED(name)
    if name == addonName then
        self:Initialize()
    end
end

function TimewalkQue:PLAYER_ENTERING_WORLD()
    self:CheckTimewalkingStatus()
end

function TimewalkQue:LFG_UPDATE_RANDOM_INFO()
    self:CheckTimewalkingStatus()
end

function TimewalkQue:Initialize()
    print(TimewalkQue_L.ADDON_LOADED)
    self:CheckTimewalkingStatus()
end

function TimewalkQue:CheckTimewalkingStatus()
    local isActive = false
    
    -- Check if any timewalking bonus is active
    for i = 1, GetNumRandomDungeons() do
        local id, name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureName, difficulty, maxPlayers, description, isHoliday, bonusRepAmount, isSeasonal = GetRandomDungeonInfo(i)
        
        -- Look for timewalking dungeons (subtypeID 1152 is timewalking)
        if subtypeID == 1152 or isSeasonal then
            isActive = true
            break
        end
    end
    
    -- Also check calendar for timewalking events
    if not isActive then
        local month, day, weekday = C_DateAndTime.GetCurrentCalendarTime()
        local numEvents = CalendarGetNumDayEvents(month, day)
        
        for i = 1, numEvents do
            local title, hour, minute, calendarType, texture, modStatus, inviteStatus = CalendarGetDayEvent(month, day, i)
            if title and (string.find(title, "Timewalking") or string.find(title, "时空漫游")) then
                isActive = true
                break
            end
        end
    end
    
    isTimewalkingActive = isActive
    if isActive then
        print(TimewalkQue_L.EVENT_DETECTED)
    end
end

function TimewalkQue:SelectTimewalkingDungeon()
    if not isTimewalkingActive then
        return
    end
    
    -- Hook into LFD frame when it opens
    if LFDQueueFrame and LFDQueueFrame:IsShown() then
        local available = GetLFDChoiceInfo(LFDQueueFrame.type)
        
        -- Try to find and select Timewalking dungeon
        for i = 1, #available do
            local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureName, difficulty, maxPlayers, description, isHoliday, isTimeWalker = available[i]
            
            if isTimeWalker or (subtypeID == 1152) then
                -- Select the timewalking option
                LFDQueueFrame_SetType(i)
                print(TimewalkQue_L.DUNGEON_SELECTED)
                return
            end
        end
    end
end

-- Hook for when LFD frame is shown
local originalLFDQueueFrame_Show = LFDQueueFrame_Show
LFDQueueFrame_Show = function(...)
    originalLFDQueueFrame_Show(...)
    
    -- Schedule the selection to happen after frame is fully loaded
    C_Timer.After(0.1, function()
        TimewalkQue:SelectTimewalkingDungeon()
    end)
end

-- Hook for when LFD frame updates
hooksecurefunc("LFDQueueFrame_Update", function()
    if LFDQueueFrame and LFDQueueFrame:IsShown() then
        C_Timer.After(0.1, function()
            TimewalkQue:SelectTimewalkingDungeon()
        end)
    end
end)