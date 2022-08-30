local _, core = ...
core.Icon = {} -- adds Icon table to addon namespace

local Icon = core.Icon

function Icon.CreateIcon(name, parent)
    local f = CreateFrame("Frame", name, parent)

    f.CdInfo = function()
        return 0,0,0,0
    end

    -- f:SetSize(80, 80)
    -- f:SetPoint("CENTER", 0, 0)

    f.tex = f:CreateTexture()
    f.tex:SetAllPoints(f)
    f.tex:SetTexture(134400)

    local cd = CreateFrame("Cooldown", "cd", f, "CooldownFrameTemplate")
    cd:SetAllPoints()

    cd:SetBlingTexture("", {0,0,0,0}) -- removes the bling after cd finishes
    cd:SetDrawEdge(false)
    cd:SetHideCountdownNumbers(true)

    f:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    f:SetScript("OnEvent", function(self, ...)
        local start, duration, enabled, _ = f.CdInfo()

        if enabled == 1 and duration > 1.5 then -- ignore gcd
          cd:SetCooldown(start, duration)
          --cd:SetCooldownDuration(duration)
        end
    end)

    return f
end

function Icon:SetIconTypeSpell()
    self.data = {GetSpellInfo(self:GetName())}
    self.tex:SetTexture(self.data[3])
    self.CdInfo = function()
        return GetSpellCooldown(self:GetName())
    end
end

function Icon:SetIconTypeItem()
    self.data = {GetItemInfoInstant(self:GetName())}
    self.tex:SetTexture(self.data[5])
    self.CdInfo = function()
        return GetItemCooldown(self.data[1])
    end
end
