local _, core = ...

-- idk why, but i gotta do it like this -_-
function toggle()
    core.Menu.Toggle()
end

function core:init(event, name)
    if (name ~= "TeleportMenu") then return end
    print(name.." Loaded")

    core.Menu.CreateMenu()
end

local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:SetScript("OnEvent", core.init);

SLASH_SHOWTELEPORTUI1 = "/tpm"
function SlashCmdList.SHOWTELEPORTUI(msg)
    core.Menu.Toggle()
end
