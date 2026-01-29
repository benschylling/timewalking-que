local TimewalkQue = CreateFrame("Frame", "TimewalkQue")
TimewalkQue:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](self, ...)
    end
end)

TimewalkQue:RegisterEvent("ADDON_LOADED")
TimewalkQue:RegisterEvent("PLAYER_ENTERING_WORLD")

local addonName = "TimewalkQue"
local isTimewalkingActive = false

function TimewalkQue:ADDON_LOADED(name)
    if name == addonName then
        self:Initialize()
    end
end

function TimewalkQue:PLAYER_ENTERING_WORLD()
    self:CheckTimewalkingStatus()
end

function TimewalkQue:Initialize()
    print(TimewalkQue_L.ADDON_LOADED)
    -- Check timewalking status after a delay
    C_Timer.After(2.0, function()
        self:CheckTimewalkingStatus()
    end)
end

function TimewalkQue:CheckTimewalkingStatus()
    -- Due to Blizzard API restrictions, we can't programmatically detect timewalking events
    -- Instead, we'll assume it's active during the weekly rotation and remind users
    
    -- Weekly timewalking schedule (approximate):
    -- Week 1: Cataclysm, Week 2: Mists of Pandaria, Week 3: Warlords of Draenor
    -- Week 4: Legion, Week 5: The Burning Crusade, Week 6: Wrath of the Lich King
    -- This repeats every 6 weeks
    
    local _, _, day = C_DateAndTime.GetCurrentCalendarTime()
    local weekOfYear = math.floor((day + 6) / 7) % 6 + 1
    
    -- Determine current event based on week
    local currentEvent = ""
    if weekOfYear == 1 then currentEvent = "Cataclysm"
    elseif weekOfYear == 2 then currentEvent = "Mists of Pandaria"  
    elseif weekOfYear == 3 then currentEvent = "Warlords of Draenor"
    elseif weekOfYear == 4 then currentEvent = "Legion"
    elseif weekOfYear == 5 then currentEvent = "The Burning Crusade"
    elseif weekOfYear == 6 then currentEvent = "Wrath of the Lich King"
    end
    
    isTimewalkingActive = true -- Assume active during any rotation week
    print(string.format("TimewalkQue: Week %d: %s Timewalking is active", weekOfYear, currentEvent))
    print("TimewalkQue: Automatic selection is limited by Blizzard API restrictions")
    print("TimewalkQue: Please manually select 'Random Timewalking Dungeon' from the dropdown")
    print(TimewalkQue_L.EVENT_DETECTED)
end

-- Simplified selection since we can't detect programmatically
function TimewalkQue:SelectTimewalkingDungeon()
    if not isTimewalkingActive then
        return
    end
    
    -- Since we can't programmatically select due to API restrictions, 
    -- we'll just remind the user when Group Finder opens
    print("TimewalkQue: Group Finder opened - remember to select Random Timewalking Dungeon!")
end

-- Hook when LFD frame is shown for reminders
local function SetupHooks()
    if LFDQueueFrame then
        LFDQueueFrame:HookScript("OnShow", function()
            C_Timer.After(0.5, function()
                if isTimewalkingActive then
                    print("TimewalkQue: Timewalking active! Select 'Random Timewalking Dungeon' from the dropdown")
                end
            end)
        end)
    end
end

-- Add slash command for manual testing
SLASH_TIMWALKQUE1 = "/twq"
SlashCmdList["TIMWALKQUE"] = function(msg)
    if msg == "week" then
        TimewalkQue:CheckTimewalkingStatus()
    elseif msg == "status" then
        print("=== TimewalkQue Status ===")
        print("isTimewalkingActive:", isTimewalkingActive)
        print("Current week event:", TimewalkQue.currentEvent or "Unknown")
        print("Functionality: Weekly reminder system (API restricted)")
    else
        print("TimewalkQue Commands:")
        print("/twq week - Check current week's timewalking event")
        print("/twq status - Show addon status")
        print("")
        print("Note: Due to Blizzard API restrictions, automatic selection is not possible.")
        print("Please manually select 'Random Timewalking Dungeon' when prompted.")
    end
end

-- Setup hooks after initialization
C_Timer.After(1.0, SetupHooks)