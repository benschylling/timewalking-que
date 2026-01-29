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

-- Constants for LFG types in 12.0.0
local LFG_CATEGORY_DUNGEON = 1
local LFG_TYPEID_RANDOM_DUNGEON = 2

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
    -- Set up hooks after frames are loaded
    C_Timer.After(1.0, HookLFDQueueFrame)
    -- Check timewalking status after a delay
    C_Timer.After(2.0, function()
        self:CheckTimewalkingStatus()
    end)
end

function TimewalkQue:CheckTimewalkingStatus()
    local isActive = false
    
    print("=== Checking Timewalking Status ===")
    
    -- Method 1: Check all random dungeons with detailed info
    local totalDungeons = GetNumRandomDungeons()
    print(string.format("Total random dungeons: %d", totalDungeons))
    
    for i = 1, totalDungeons do
        local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureName, difficulty, maxPlayers, description, isHoliday, isSeasonal = GetRandomDungeonInfo(i)
        
        print(string.format("Dungeon %d: %s | type: %d | subtype: %d | expansion: %d | holiday: %s | seasonal: %s", 
            i, tostring(name), typeID or 0, subtypeID or 0, expansionLevel or 0, tostring(isHoliday), tostring(isSeasonal)))
        
        -- Look for timewalking dungeons with exact text patterns
        if (name and (string.find(name, "Random Timewalking Dungeon") or 
                     string.find(name, "Timewalking Dungeon(Wrath of the Lich King)"))) or
           subtypeID == 1152 or 
           isSeasonal or
           (isHoliday and textureName and string.find(textureName, "Timewalking")) then
            isActive = true
            print(string.format("*** FOUND TIMWALKING: %s (subtype: %d, seasonal: %s, holiday: %s)***", 
                tostring(name), subtypeID or 0, tostring(isSeasonal), tostring(isHoliday)))
            break
        end
    end
    
    -- Method 2: Check LFG rewards for timewalking bonuses
    if not isActive then
        print("Checking LFG rewards...")
        local rewards = C_LFGInfo.GetAllEntriesForCategory(LFG_CATEGORY_DUNGEON)
        if rewards and #rewards > 0 then
            print(string.format("Found %d LFG entries", #rewards))
            for i, reward in ipairs(rewards) do
                if reward and reward.name then
                    print(string.format("LFG Entry %d: %s", i, tostring(reward.name)))
                    if string.find(reward.name, "Random Timewalking Dungeon") or 
                       string.find(reward.name, "Timewalking Dungeon(Wrath of the Lich King)") or
                       reward.isTimewalking then
                        isActive = true
                        print(string.format("*** FOUND TIMWALKING IN LFG: %s ***", tostring(reward.name)))
                        break
                    end
                end
            end
        else
            print("No LFG rewards found")
        end
    end
    
    -- Method 3: Check calendar for timewalking events
    if not isActive then
        print("Checking calendar...")
        local month, day, weekday = C_DateAndTime.GetCurrentCalendarTime()
        local numEvents = CalendarGetNumDayEvents(month, day)
        print(string.format("Calendar events today: %d", numEvents))
        
        for i = 1, numEvents do
            local title, hour, minute, calendarType, texture, modStatus, inviteStatus = CalendarGetDayEvent(month, day, i)
            print(string.format("Calendar Event %d: %s", i, tostring(title)))
            if title and (string.find(string.lower(title), "timewalking") or string.find(title, "时空漫游")) then
                isActive = true
                print(string.format("*** FOUND TIMWALKING IN CALENDAR: %s ***", tostring(title)))
                break
            end
        end
    end
    
    isTimewalkingActive = isActive
    print(string.format("Final timewalking status: %s", tostring(isActive)))
    if isActive then
        print(TimewalkQue_L.EVENT_DETECTED)
    else
        print("No timewalking event detected")
    end
    print("=== End Timewalking Check ===")
end

function TimewalkQue:SelectTimewalkingDungeon()
    if not isTimewalkingActive then
        return
    end
    
    print("TimewalkQue: Group Finder detected, looking for timewalking options...")
    
    -- Work with the actual LFD (Dungeon Finder) window
    if LFDQueueFrame and LFDQueueFrame:IsShown() then
        -- Method 0: Try the most direct approach first
        print("Trying direct LFDQueueFrame_SetType with known timewalking IDs...")
        -- Try some known timewalking IDs
        local timewalkingIDs = {1166, 1180, 1181, 1182, 1183, 1184, 1185} -- Various timewalking dungeon IDs
        for _, id in ipairs(timewalkingIDs) do
            if id <= GetNumRandomDungeons() then
                local name, _, _, _, _, _, _, _, _, _, _, _, _, _, isTimeWalker = GetRandomDungeonInfo(id)
                print(string.format("Trying ID %d: %s, isTimeWalker: %s", id, tostring(name), tostring(isTimeWalker)))
                if isTimeWalker or (name and string.find(name, "Timewalking")) then
                    print(string.format("Found timewalking: %s at index %d", tostring(name), id))
                    LFDQueueFrame_SetType(id)
                    print(TimewalkQue_L.DUNGEON_SELECTED)
                    return
                end
            end
        end
        
        -- Method 1: Try to find timewalking in the random dungeons list
        local timewalkingFound = false
        for i = 1, GetNumRandomDungeons() do
            local name, typeID, subtypeID, _, _, _, _, _, _, _, _, _, _, _, isTimeWalker = GetRandomDungeonInfo(i)
            print(string.format("Checking dungeon %d: %s, isTimeWalker: %s", i, tostring(name), tostring(isTimeWalker)))
            
            if isTimeWalker or (name and (string.find(name, "Random Timewalking Dungeon") or string.find(name, "Timewalking Dungeon(Wrath of the Lich King)"))) then
                print(string.format("Found timewalking: %s at index %d", tostring(name), i))
                -- Select this type in the LFD frame
                LFDQueueFrame_SetType(i)
                print(TimewalkQue_L.DUNGEON_SELECTED)
                timewalkingFound = true
                break
            end
        end
        
        if timewalkingFound then
            return
        end
        
        -- Method 2: Try to find and click the dropdown item directly
        if LFDQueueFrameTypeDropdown then
            print("Trying dropdown method...")
            local dropdown = LFDQueueFrameTypeDropdown
            
            -- Open the dropdown to populate items
            ToggleDropDownMenu(1, nil, dropdown, LFDQueueFrameTypeDropdown, 0, 0)
            C_Timer.After(0.3, function()
                TimewalkQue:FindAndClickDropdownItem()
            end)
        else
            print("TypeDropdown not found")
        end
    else
        print("LFDQueueFrame not shown")
    end
end

function TimewalkQue:FindAndClickDropdownItem()
    print("Searching dropdown items for timewalking...")
    
    -- Look through the dropdown buttons for timewalking option
    local found = false
    for i = 1, 50 do -- reasonable limit to prevent infinite loops
        local button = _G["DropDownList1Button" .. i]
        if button and button:IsShown() and button.GetText then
            local text = button:GetText()
            print(string.format("Dropdown item %d: %s", i, tostring(text)))
            if text and (string.find(text, "Random Timewalking Dungeon") or string.find(text, "Timewalking Dungeon(Wrath of the Lich King)") or string.find(text, "时光漫游") or string.find(text, "時光漫遊")) then
                print(string.format("Found timewalking in dropdown: %s", text))
                button:Click()
                print(TimewalkQue_L.DUNGEON_SELECTED)
                found = true
                break
            end
        end
    end
    
    if not found then
        print("No timewalking option found in dropdown")
    end
    
    -- Close the dropdown after selection
    CloseDropDownMenus()
end

-- Updated hook system for 12.0.0 - Focus on LFDQueueFrame
local function HookLFDQueueFrame()
    print("Setting up LFD hooks...")
    
    -- Create a simple frame that just reports what's available
    local testFrame = CreateFrame("Frame")
    local updateCount = 0
    testFrame:SetScript("OnUpdate", function()
        updateCount = updateCount + 1
        if updateCount % 180 == 0 then -- Every 3 seconds at 60fps
            print("Frame check - PVEFrame exists:", PVEFrame ~= nil, "LFDQueueFrame exists:", LFDQueueFrame ~= nil)
            if PVEFrame then
                print("PVEFrame shown:", PVEFrame:IsShown())
                print("PVEFrame Tab2 exists:", PVEFrame.Tab2 ~= nil)
            end
            if LFDQueueFrame then
                print("LFDQueueFrame shown:", LFDQueueFrame:IsShown())
            end
        end
    end)
    
    -- Try to hook PVEFrame when it's available
    if PVEFrame then
        print("PVEFrame found immediately, hooking...")
        PVEFrame:HookScript("OnShow", function()
            print("PVEFrame OnShow fired!")
        end)
        
        if PVEFrame.Tab2 then
            print("PVEFrame.Tab2 found, hooking...")
            PVEFrame.Tab2:HookScript("OnClick", function()
                print("Dungeon Finder tab clicked!")
            end)
        end
    else
        print("PVEFrame not found at hook time")
    end
    
    -- Try to hook LFDQueueFrame when it's available
    if LFDQueueFrame then
        print("LFDQueueFrame found immediately, hooking...")
        LFDQueueFrame:HookScript("OnShow", function()
            print("LFDQueueFrame OnShow fired!")
        end)
    else
        print("LFDQueueFrame not found at hook time")
    end
end

-- Add slash command for manual testing
SLASH_TIMWALKQUE1 = "/twq"
SlashCmdList["TIMWALKQUE"] = function(msg)
    if msg == "ids" then
        print("Testing dungeon IDs 1-10:")
        for i = 1, 10 do
            local name = GetRandomDungeonInfo(i)
            if name then
                print("ID " .. i .. ": " .. name)
            else
                print("ID " .. i .. ": [no name returned]")
            end
        end
        
    elseif msg == "force" then
        print("Force setting isTimewalkingActive = true...")
        isTimewalkingActive = true
        print("Now try opening Group Finder")
        
    elseif msg == "ui" then
        print("Testing UI interaction...")
        if LFDQueueFrameTypeDropdown then
            print("Found dropdown, attempting to click it...")
            LFDQueueFrameTypeDropdown:Click()
            print("Dropdown clicked!")
        else
            print("Dropdown not found")
        end
        
    else
        print("=== TimewalkQue Debug ===")
        print("isTimewalkingActive:", isTimewalkingActive)
        print("PVEFrame exists:", PVEFrame ~= nil)
        print("LFDQueueFrame exists:", LFDQueueFrame ~= nil)
        print("PVEFrame shown:", PVEFrame and PVEFrame:IsShown())
        print("LFDQueueFrame shown:", LFDQueueFrame and LFDQueueFrame:IsShown())
        
        if LFDQueueFrame and LFDQueueFrameTypeDropdown then
            print("TypeDropdown found:", LFDQueueFrameTypeDropdown ~= nil)
        else
            print("TypeDropdown not found - LFDQueueFrame exists:", LFDQueueFrame ~= nil)
        end
        
        local numDungeons = GetNumRandomDungeons()
        print("Total random dungeons:", numDungeons)
        print("Available commands: ids, force, ui")
    end
end