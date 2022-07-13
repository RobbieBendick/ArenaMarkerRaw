--------------------------------------
-- Namespace
--------------------------------------
local _, core = ...;
core.Config = {};
local Config = core.Config;
local UIConfig;
core.removedMarkers = {};
core.translations = {
    ["enUS"] = "Fifteen seconds until the Arena battle begins!",
    ["enGB"] = "The Arena battle has begun!",
    ["frFR"] = "Le combat d'arène commence !",
    ["deDE"] = "Der Arenakampf hat begonnen!",
    ["ptBR"] = "A batalha na Arena começou!",
    ["esES"] = "¡La batalla en arena ha comenzado!",
    ["esMX"] = "¡La batalla en arena ha comenzado!",
    ["ruRU"] = "Бой начался!",
    ["zhCN"] = "竞技场的战斗开始了！",
    ["zhTW"] = "競技場戰鬥開始了!",
    ["koKR"] = "투기장 전투가 시작되었습니다!",
}
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
core.marker_strings = {
    "star",
    "circle",
    "diamond",
    "triangle",
    "moon",
    "square",
    "cross",
    "skull"
}


local UIConfig = CreateFrame("Frame", nil, UIParent);
UIConfig:SetWidth(320);
UIConfig:SetHeight(210);
UIConfig:SetPoint("TOPLEFT", 200, -200);
UIConfig:SetBackdrop({
    --  bgFile = "Interface\\BUTTONS\\WHITE8X8.BLP",
    --  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
});
--UIConfig:SetBackdropColor(0, 0, 0, 0);

UIConfig.name = "|cff33ff99ArenaMarker|r";


UIConfig.title = UIConfig:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
UIConfig.title:SetPoint("TOPLEFT", 16, -16);
UIConfig.title:SetPoint("RIGHT");
UIConfig.title:SetText(UIConfig.name);
UIConfig.title:SetJustifyH("LEFT");


UIConfig.markPlayersButton = CreateFrame("Button", nil, UIConfig, "UIPanelButtonTemplate");
UIConfig.markPlayersButton:SetWidth(130);
UIConfig.markPlayersButton:SetHeight(44);
UIConfig.markPlayersButton:SetText("Mark Players");
UIConfig.markPlayersButton:SetPoint("TOPLEFT", 16, -42);
UIConfig.markPlayersButton:SetFrameStrata("DIALOG");
UIConfig.markPlayersButton:SetScript("OnClick",
    function(self)
        if not GetRaidTargetIndex("player") then
            DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r: Marking the group.");
        end
        -- mark self
        AM:SetRaidTargetByClass("player");
        -- mark party members
        for i = 1, 4 do
            AM:SetRaidTargetByClass("party" .. i);
        end
    end);


UIConfig.unmarkPlayersButton = CreateFrame("Button", nil, UIConfig, "UIPanelButtonTemplate");
UIConfig.unmarkPlayersButton:SetWidth(130);
UIConfig.unmarkPlayersButton:SetHeight(44);
UIConfig.unmarkPlayersButton:SetText("Unmark Players");
UIConfig.unmarkPlayersButton:SetPoint("TOPLEFT", 16, -90);
UIConfig.unmarkPlayersButton:SetFrameStrata("DIALOG");
UIConfig.unmarkPlayersButton:SetScript("OnClick",
    function(self)
        if GetRaidTargetIndex("player") then
            DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r: Unmarking the group.");
            table.insert(core.removed_markers, GetRaidTargetIndex("player"));
            SetRaidTarget("player", 0);
        end
        -- unmark party members
        for i = 1, 4 do
            table.insert(core.removed_markers, GetRaidTargetIndex("party" .. i));
            SetRaidTarget("party" .. i, 0);
        end
        AM:RepopulateUnusedMarkers()
    end);

UIConfig:Hide()

InterfaceOptions_AddCategory(UIConfig);

local function login()
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ArenaMarker|r by |cff69CCF0Mageiden|r: loaded.");
end

enterWorld = CreateFrame("FRAME");
enterWorld:RegisterEvent("PLAYER_LOGIN");
enterWorld:SetScript("OnEvent", login);
