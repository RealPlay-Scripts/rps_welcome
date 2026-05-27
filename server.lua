-- ============================================================
--  CFRP Welcome Resource - Server Script
-- ============================================================

local function Log(msg)
    if Config.Debug then
        print("^3[CFRP-Welcome]^7 " .. tostring(msg))
    end
end

local function ApiHeaders()
    return {
        ["Content-Type"]  = "application/json",
        ["X-API-Key"]     = Config.ApiKey
    }
end

-- ── Heartbeat ────────────────────────────────────────────────
local function SendHeartbeat()
    local players = GetNumPlayerIndices()
    local playerList = {}

    for i = 0, players - 1 do
        local src = GetPlayerFromIndex(i)
        if src then
            table.insert(playerList, {
                id       = tostring(GetPlayerIdentifier(src, 0) or src),
                name     = GetPlayerName(src),
                ping     = GetPlayerPing(src)
            })
        end
    end

    local body = json.encode({
        playerCount = players,
        maxPlayers  = GetConvarInt("sv_maxclients", 32),
        players     = playerList,
        timestamp   = os.time()
    })

    PerformHttpRequest(Config.ApiBaseUrl .. "/api/server/heartbeat", function(status, _, headers)
        Log("Heartbeat → " .. tostring(status))
    end, "POST", body, ApiHeaders())
end

-- Send heartbeat on resource start and then on interval
CreateThread(function()
    Wait(3000) -- slight delay on startup
    SendHeartbeat()
    while true do
        Wait(Config.HeartbeatInterval)
        SendHeartbeat()
    end
end)

-- ── Helpers ──────────────────────────────────────────────────

-- Extract raw Discord ID from the "discord:XXXXXXXXX" identifier
local function GetDiscordId(src)
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if id and id:sub(1, 8) == "discord:" then
            return id:sub(9) -- strip the "discord:" prefix
        end
    end
    return nil
end

-- Check the API for this Discord ID; calls cb(true) if NOT registered, cb(false) if already registered
local function IsNewUser(discordId, cb)
    if not discordId then
        -- No Discord linked — treat as new user so popup always shows
        Log("No Discord identifier found — treating as new user")
        cb(true)
        return
    end

    local url = Config.ApiBaseUrl .. "/api/users/discord/" .. discordId
    Log("Checking API for Discord ID: " .. discordId)

    PerformHttpRequest(url, function(status, body, _)
        Log("User check → HTTP " .. tostring(status) .. " | body: " .. tostring(body))

        if status == 404 then
            -- Not found in the system → definitely a new/unregistered user
            cb(true)
            return
        end

        if status == 200 and body then
            local ok, data = pcall(json.decode, body)
            if ok and data then
                -- If the API returned a user object, they're already registered
                -- Treat as new if the account exists but is not linked/active
                -- Adjust the field check below to match your actual API response shape
                local linked = data.discordId or data.discord_id or data.id
                if linked then
                    Log("User IS registered — suppressing welcome popup")
                    cb(false)
                else
                    Log("User record exists but appears unlinked — showing popup")
                    cb(true)
                end
            else
                -- Malformed response — show popup to be safe
                Log("Could not parse user response — showing popup")
                cb(true)
            end
            return
        end

        -- Any other status (500, timeout, etc.) — show popup to be safe
        Log("Unexpected status " .. tostring(status) .. " — showing popup")
        cb(true)
    end, "GET", "", ApiHeaders())
end

-- ── Player Ready (fired by client after spawn) ─────────────
-- We listen here instead of playerJoining because the client
-- NUI is not ready to receive events until after the player
-- has fully spawned in-game.
RegisterNetEvent("cfrp:playerReady")
AddEventHandler("cfrp:playerReady", function()
    local src       = source
    local name      = GetPlayerName(src)
    local discordId = GetDiscordId(src)

    Log("playerReady from: " .. tostring(name) .. " | Discord: " .. tostring(discordId))

    IsNewUser(discordId, function(isNew)
        if not isNew then
            Log("Registered user — skipping popup: " .. tostring(name))
            return
        end

        Log("New user — showing popup: " .. tostring(name))
        TriggerClientEvent("cfrp:showWelcome", src, {
            playerName  = name,
            discordLink = Config.DiscordLink,
            websiteUrl  = Config.WebsiteUrl,
            serverName  = Config.ServerName,
            autoClose   = Config.AutoCloseDelay
        })
    end)
end)

-- ── Kill / Death Stats ───────────────────────────────────────
RegisterNetEvent("cfrp:reportKill", function(data)
    local src = source
    local killerIdentifier = GetPlayerIdentifier(src, 0) or tostring(src)

    local body = json.encode({
        killer   = killerIdentifier,
        victim   = data.victim or "unknown",
        weapon   = data.weapon or "unknown",
        distance = data.distance or 0,
        timestamp = os.time()
    })

    PerformHttpRequest(Config.ApiBaseUrl .. "/api/server/stats", function(status, _, _)
        Log("Kill stat → " .. tostring(status))
    end, "POST", body, ApiHeaders())
end)

-- ── Player Disconnect ────────────────────────────────────────
AddEventHandler("playerDropped", function(reason)
    local src  = source
    local name = GetPlayerName(src) or "Unknown"
    local id   = GetPlayerIdentifier(src, 0) or tostring(src)

    local body = json.encode({
        playerId  = id,
        name      = name,
        reason    = reason or "Unknown",
        timestamp = os.time()
    })

    PerformHttpRequest(Config.ApiBaseUrl .. "/api/server/disconnect", function(status, _, _)
        Log("Disconnect event → " .. tostring(status))
    end, "POST", body, ApiHeaders())
end)

-- ── Test Welcome Popup Command ───────────────────────────────
RegisterCommand("testwelcome", function(src, args, rawCmd)
    if src == 0 then
        print("[CFRP-Welcome] /testwelcome must be run in-game, not from console.")
        return
    end

    local name = GetPlayerName(src)
    Log("Test welcome triggered by: " .. tostring(name))

    TriggerClientEvent("cfrp:showWelcome", src, {
        playerName  = name,
        discordLink = Config.DiscordLink,
        websiteUrl  = Config.WebsiteUrl,
        serverName  = Config.ServerName,
        autoClose   = Config.AutoCloseDelay
    })
end, false) -- false = any player can use it; set true to restrict to ace perms

-- ── Live Stats Command (admin) ───────────────────────────────
RegisterCommand("cfstats", function(src, args, rawCmd)
    if src ~= 0 then -- console only for safety; change 0 to check admin perms
        TriggerClientEvent("chat:addMessage", src, {
            color   = {255, 100, 0},
            multiline = true,
            args    = {"CFRP", "This command is console-only."}
        })
        return
    end

    PerformHttpRequest(Config.ApiBaseUrl .. "/api/analytics/summary", function(status, body, _)
        Log("Summary response [" .. tostring(status) .. "]: " .. tostring(body))
    end, "GET", "", ApiHeaders())

    PerformHttpRequest(Config.ApiBaseUrl .. "/api/analytics/live", function(status, body, _)
        Log("Live response [" .. tostring(status) .. "]: " .. tostring(body))
    end, "GET", "", ApiHeaders())
end, true)
