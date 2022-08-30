local _, core = ...
core.Menu = {} -- adds Config table to addon namespace

local Menu = core.Menu
local TeleportUI
local buttons = {}

local teleportTable = {
    ["spells"] = {},
    ["items"] = {},
}

local function generateTeleportItemList()
    for ii, val in pairs(core.Data.itemTable) do
        for b = 0, 4 do
            for s = 1, GetContainerNumSlots(b) do
                local _, itemCount, _, _, _, _, _, _, _, itemID = GetContainerItemInfo(b, s)

                -- this is really strange, but somehow necessary x_x
                if itemID then
                    if itemID == GetItemInfoInstant(val)
                    and itemCount > 0 then
                        -- code block goes here
                        teleportTable["items"][val] = itemID
                    end
                end
            end
        end
    end
    --[[
    local itemID = GetItemInfoInstant(val)

    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(function()
        local desc = item:GetItemName()
        if desc then
            teleportTable[val] = desc
        end
    end)
    ]]
end

function generateTeleportSpellList()
    for ii, val in pairs(core.Data.spellTable) do
        local _, _, _, _, _, _, spellID = GetSpellInfo(val)--IsSpellKnown(spellID))
        if spellID then
            if IsSpellKnown(spellID) then
                local spell = Spell:CreateFromSpellID(spellID)
                spell:ContinueOnSpellLoad(function()
                    local desc = spell:GetSpellDescription()
                    teleportTable["spells"][val] = desc
                end)
            end
        end
    end
end

local function generateTeleportList()
    -- runs whenever the UI is toggled
    generateTeleportSpellList()
    generateTeleportItemList()
end

local function searchTeleports(searchString, teleports)
    -- finds and returns table of matches
    local t = {}

    if searchString == "" then
        for name, desc in pairs(teleports) do
            table.insert(t, name)
        end
    else
        for name, desc in pairs(teleports) do
            local n1, n2 = string.find(name:lower(), searchString)
            local d1, d2 = string.find(tostring(desc):lower(), searchString)

            if n1 or n2 or d1 or d2 then
                table.insert(t, name)
            end
        end
    end

    return t
end

local function deleteButtons()
    for ii, val in pairs(buttons) do
        val["button"]:Hide()
        val["icon"]:Hide()
    end
    buttons = {}
end

function Menu:Toggle()
    local UI = TeleportUI or Menu:CreateMenu();
	UI:SetShown(not UI:IsShown());
    generateTeleportList()
    EditBoxFrame:SetText("")
    EditBoxFrame:SetFocus()
end

local function CreateButton(name, ii)
    local iconSize = 35
    local btnWidth = 300
    local spacing = 6

    local btn = CreateFrame("Button", nil, TeleportUI.ScrollFrame:GetScrollChild(), "SecureActionButtonTemplate")
    btn:SetSize(btnWidth, iconSize+6)
    btn:SetPoint("TOP", 0, ii*(-spacing-iconSize)+spacing+iconSize)--ii*(-spacing-iconSize)+spacing+iconSize)

    btn:SetAttribute("unit", "player")
    btn:SetAttribute("type","macro")
    btn:SetAttribute("macrotext", "/use " .. name .."\n/tpm")

    btn.highlightTop = btn:CreateTexture(nil, "BACKGROUND")
    btn.highlightTop:SetPoint("TOP", 0, 3)
    btn.highlightTop:SetSize(btnWidth, 6)
    btn.highlightTop:SetAtlas("AftLevelup-GlowLine", false)
    btn.highlightTop:Hide()

    btn.highlightBottom = btn:CreateTexture(nil, "BACKGROUND")
    btn.highlightBottom:SetPoint("BOTTOM", 0, -3)
    btn.highlightBottom:SetSize(btnWidth, 6)
    btn.highlightBottom:SetAtlas("AftLevelup-GlowLine", false)
    btn.highlightBottom:Hide()

    btn:SetScript("OnEnter", function()
        btn.highlightTop:Show()
        btn.highlightBottom:Show()
    end)

    btn:SetScript("OnLeave", function()
        btn.highlightTop:Hide()
        btn.highlightBottom:Hide()
    end)

    local icon = core.Icon.CreateIcon(name, btn)
    icon:SetSize(iconSize, iconSize)
    icon:SetPoint("LEFT")
    --core.Icon.SetIconTypeItem(icon)

    icon.text = icon:CreateFontString(nil, "OVERLAY")
    icon.text:SetFontObject("GameFontHighlight")
    icon.text:SetPoint("LEFT", icon, "RIGHT", 20, 0)
    icon.text:SetText(name)

    local t = {}
    t["button"] = btn
    t["icon"] = icon

    return t
end

local function updateResults(searchString, teleports)
    deleteButtons()

    local counter = 0
    for ii, name in pairs(teleports["spells"]) do
        counter = counter + 1
        local newBtn = CreateButton(name, counter)
        core.Icon.SetIconTypeSpell(newBtn["icon"])
        table.insert(buttons, newBtn)
    end
    for ii, name in pairs(teleports["items"]) do
        counter = counter + 1
        local newBtn = CreateButton(name, counter)
        core.Icon.SetIconTypeItem(newBtn["icon"])
        table.insert(buttons, newBtn)
    end
end

local function ScrollFrame_OnMouseWheel(self, delta)
	local newValue = self:GetVerticalScroll() - (delta * 20);

	if (newValue < 0) then
		newValue = 0;
	elseif (newValue > self:GetVerticalScrollRange()) then
		newValue = self:GetVerticalScrollRange();
	end

	self:SetVerticalScroll(newValue);
end

function Menu:CreateMenu()
    TeleportUI = CreateFrame("Frame", "TeleportUIFrame", UIParent)--, "UIPanelDialogTemplate");
    TeleportUI:SetSize(300, 300);
    TeleportUI:SetPoint("CENTER"); -- Doesn't need to be ("CENTER", UIParent, "CENTER")

    TeleportUI.ScrollFrame = CreateFrame("ScrollFrame", nil, TeleportUI, "UIPanelScrollFrameTemplate");
    TeleportUI.ScrollFrame:SetPoint("TOPLEFT", 0, -30);
	TeleportUI.ScrollFrame:SetPoint("BOTTOMRIGHT", 0, 0);
	TeleportUI.ScrollFrame:SetClipsChildren(true);
	TeleportUI.ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);

    local child = CreateFrame("Frame", nil, TeleportUI.ScrollFrame);
	child:SetSize(300, 1);
    child:SetAllPoints()
    child.bg = child:CreateTexture(nil, "BACKGROUND")
    child.bg:SetAllPoints()
    child.bg:SetAtlas("BossBanner-BgBanner-Mid", false)
    TeleportUI.ScrollFrame:SetScrollChild(child);

    local editBox = CreateFrame("EditBox", "EditBoxFrame", TeleportUI, "SearchBoxTemplate")
    editBox:SetSize(300,20)
    editBox:SetPoint("TOP")

    editBox.tex = editBox:CreateTexture(nil, "BACKGROUND")
    editBox.tex:SetAllPoints()
    editBox.tex:SetAtlas("BossBanner-BgBanner-Mid", false)

    -- show # results in search
    editBox.results = editBox:CreateFontString(nil, "OVERLAY")
    editBox.results:SetFontObject("GameFontHighlight")
    editBox.results:SetPoint("RIGHT", EditBoxFrameClearButton, "LEFT", 0, 1)
    editBox.results:SetText(0)

    EditBoxFrame["Left"]:Hide()
    EditBoxFrame["Right"]:Hide()
    EditBoxFrame["Middle"]:Hide()
    --EditBoxFrame["Bottom"]:Hide()
    editBox:SetScript("OnTextChanged", function(self, button)
        -- Fixing the search bar to remove default text when writing in field
        if editBox:GetText() == "" then
            self.Instructions:SetText("Search Teleports")
        else
            self.Instructions:SetText("") -- remove default text
        end

        local availTeleports = {
            ["spells"] = searchTeleports(editBox:GetText():lower(), teleportTable["spells"]),
            ["items"] = searchTeleports(editBox:GetText():lower(), teleportTable["items"])
        }

        local numIcons = #availTeleports["spells"] + #availTeleports["items"]
        editBox.results:SetText(numIcons)
        child:SetSize(300, numIcons*41) --iconSize + spacing

        updateResults(editBox:GetText():lower(), availTeleports)
    end)

    TeleportUI:Hide()
    tinsert(UISpecialFrames, TeleportUI:GetName())
    return TeleportUI
end
