local _, core = ...;  -- Namespace
core.AM = {};
AM = core.AM;
members = GetNumGroupMembers;
local frame = CreateFrame("FRAME", "ArenaMarker")
frame:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
frame:RegisterEvent("CHAT_MSG_SYSTEM");
core.removed_markers = {};

--[[
    Marker numbers:
        1 = Yellow 4-point Star; Rogue
        2 = Orange Circle; Druid
        3 = Purple Diamond; Lock, Paladin
        4 = Green Triangle; Hunter
        5 = White Crescent Moon; Mage
        6 = Blue Square; Shaman
        7 = Red "X" Cross; Warrior
        8 = White Skull; Priest
--]]

-- HERE IS WHERE YOU WOULD CHANGE THE CLASS MARKER COMBINATIONS
core.relatives = {
    ["ROGUE"] = "star",
    ["DRUID"] = "circle",
    ["WARLOCK"] = "diamond",
    ["PALADIN"] = "diamond",
    ["HUNTER"] = "triangle",
    ["MAGE"] = "moon",
    ["SHAMAN"] = "square",
    ["WARRIOR"] = "cross",
    ["PRIEST"] = "skull",
    ["DEATHKNIGHT"] = "skull"
}

function removeValue(table, value)
    local key = table[value]
    table[value] = nil
    return key
end

function contains(table, x)
    for _, v in pairs(table) do
        if v == x then return true end
    end
    return false
end

function AM:RepopulateUnusedMarkers()
    -- re-populate table if user clicks remove_mark button(s)
    for i, v in pairs(core.removed_markers) do
        if not contains(core.unused_markers, v) then
            for j = 1, #core.marker_strings do
                if v == j then
                    core.unused_markers[core.marker_strings[j]] = j;
                    removeValue(core.removed_markers, i);
                end
            end
        end
    end
end

function AM:SetMarkerAndRemove(unit, marker_string)
    if not unit or not core.unused_markers[marker_string] then return end
    SetRaidTarget(unit, core.unused_markers[marker_string]);
    removeValue(core.unused_markers, marker_string);
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function AM:FindUsableMark(target)
    local marker = ""
    for k, v in pairs(core.unused_markers) do
        if v ~= nil then
            marker = k
            break
        end
    end
    SetRaidTarget(target, core.unused_markers[marker])
    removeValue(core.unused_markers, marker)
end

function AM:SetRaidTargetByClass(unit, ...)
    if not unit or GetRaidTargetIndex(unit) then return end
    local _, englishClass, _ = UnitClass(unit);
    for k, v in pairs(core.relatives) do
        if k == englishClass then
            if core.unused_markers[v] then
                AM:SetMarkerAndRemove(unit, v);
            else
                AM:FindUsableMark(unit);
            end
            break
        end
    end
end

function AM:MarkPlayers()
    if UnitIsPartyLeader("player") == nil then return end
    -- if members() > 5 then return end
    -- mark self
    if not GetRaidTargetIndex("player") then
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r: Marking the group.")
        AM:SetRaidTargetByClass("player")
    end
    -- mark party members
    for i = 1, 4 do
        if not GetRaidTargetIndex("party" .. i) then
            AM:SetRaidTargetByClass("party" .. i)
        end
    end
end

function AM:MarkPets()
    if UnitIsPartyLeader("player") == nil then return end
    -- if members() > 5 then return end
    if UnitExists("pet") then
        if not GetRaidTargetIndex("pet") then
            AM:FindUsableMark("pet")
        end
    end
    for i = 1, 4 do
        if UnitExists("party" .. i .. "pet") then
            if not GetRaidTargetIndex("party" .. i .. "pet") then
                AM:FindUsableMark("party" .. i .. "pet")
            end
        end
    end
end

function AM:CheckExistingMarksOnPlayers()
    -- reset table
    core.unused_markers = {
        ["star"] = 1,
        ["circle"] = 2,
        ["diamond"] = 3,
        ["triangle"] = 4,
        ["moon"] = 5,
        ["square"] = 6,
        ["cross"] = 7,
        ["skull"] = 8
    }
    --update which marks are currently being used on players(not pets)
    if GetRaidTargetIndex("player") then
        local marker = core.marker_strings[GetRaidTargetIndex("player")]
        if core.unused_markers[marker] then
            core.unused_markers[marker] = nil;
        end
    end
    for i = 1, 4 do
        if GetRaidTargetIndex("party" .. i) then
            local marker = core.marker_strings[GetRaidTargetIndex("party" .. i)]
            if core.unused_markers[marker] then
                core.unused_markers[marker] = nil;
            end
        end
    end
end

function AM:MarkPetsWhenGatesOpen()
    -- if not ArenaMarkerDB.allowPets then return end
    for k, v in pairs(core.translations) do
        if GetLocale() == k then
            if string.find(a1, v) then
                AM.MarkPets();
            end
        end
    end
end

function inArena(self, event, ...)
    local inInstance, instanceType = IsInInstance()
    if instanceType ~= "arena" then return end
    if UnitIsPartyLeader("player") == nil then return end
    -- if members() <= 1 then return end
    if event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" then
        a1 = ...;
        AM.CheckExistingMarksOnPlayers()
        AM.MarkPlayers()
        AM.MarkPetsWhenGatesOpen()
    end
end

frame:SetScript("OnEvent", inArena)

-- move Target Frame Target of Target slightly to the right; personal implementation reason
-- TargetFrameToT:SetPoint("RIGHT", TargetFrame, "RIGHT", -20, 0);
