-- ============================================================
--  CFRP Welcome Resource - Client Script
-- ============================================================

local nuiOpen  = false
local hasFired = false

-- Use the raw native hash — more reliable than the Lua wrapper
-- across different FiveM server builds
local function OpenUrl(url)
    print("^2[CFRP]^7 OpenUrl called: " .. tostring(url))
    -- 0xEB49E36C1F1B2FA0 = SHELL_EXECUTE
    Citizen.InvokeNative(0xEB49E36C1F1B2FA0, url)
end

-- ── Tell the server we are ready ─────────────────────────────
AddEventHandler("playerSpawned", function()
    if hasFired then return end
    hasFired = true
    TriggerServerEvent("cfrp:playerReady")
end)

AddEventHandler("onClientResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    hasFired = false
end)

-- ── Receive welcome popup ─────────────────────────────────────
RegisterNetEvent("cfrp:showWelcome")
AddEventHandler("cfrp:showWelcome", function(data)
    if nuiOpen then return end
    nuiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action     = "showWelcome",
        playerName = data.playerName,
        serverName = data.serverName,
        discord    = data.discordLink,
        website    = data.websiteUrl,
        autoClose  = data.autoClose
    })
end)

-- ── NUI Callbacks ─────────────────────────────────────────────
RegisterNUICallback("closeWelcome", function(data, cb)
    nuiOpen = false
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("openWebsite", function(data, cb)
    print("^2[CFRP]^7 openWebsite callback hit")
    nuiOpen = false
    SetNuiFocus(false, false)
    OpenUrl(Config.WebsiteUrl)
    cb("ok")
end)

RegisterNUICallback("openDiscord", function(data, cb)
    print("^2[CFRP]^7 openDiscord callback hit")
    nuiOpen = false
    SetNuiFocus(false, false)
    OpenUrl(Config.DiscordLink)
    cb("ok")
end)

-- ── ESC to close ──────────────────────────────────────────────
CreateThread(function()
    while true do
        Wait(0)
        if nuiOpen and IsControlJustPressed(0, 200) then
            nuiOpen = false
            SetNuiFocus(false, false)
            SendNUIMessage({ action = "hide" })
        end
    end
end)
