-- ============================================================
--  Rps Welcome Resource - Configuration
-- ============================================================

Config = {}

-- Your API base URL (no trailing slash)
Config.ApiBaseUrl = "https://web.goldenshoresrp.com/api"

-- Your API Key (X-API-Key)
Config.ApiKey = "cfrp_lf2su5uQaGj0SoIGQs7m-Sg7LYahw-4ufoLCf5RKD1fhIQNjl3sUWvm85xy1FkNo"


-- Discord invite link shown in the popup
Config.DiscordLink = "https://discord.gg/P3pBmHtgYP"

-- Website signup/whitelist application URL
Config.WebsiteUrl = "https://web.goldenshoresrp.com/auth/register"

-- How long (ms) before the welcome popup auto-closes (0 = never auto-close)
Config.AutoCloseDelay = 0  -- disabled so users see the signup prompt

-- How often (ms) to send a heartbeat to the API
Config.HeartbeatInterval = 60000  -- every 60 seconds

-- Server name shown in the welcome popup
Config.ServerName = "GSRP"

-- Enable debug prints in server console
Config.Debug = true
