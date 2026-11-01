-- ============================================================
--  Rps Welcome Resource - Configuration
-- ============================================================

Config = {}

-- Your API base URL (no trailing slash). Set as server convars in
-- server.cfg, never commit real values here:
--   set rps_welcome_api_url "https://yoursite.example/api"
--   set rps_welcome_api_key "your-api-key"   (read + write scope)
Config.ApiBaseUrl = GetConvar('rps_welcome_api_url', 'https://yoursite.example/api')

-- Your API Key (X-API-Key)
Config.ApiKey = GetConvar('rps_welcome_api_key', '')


-- Discord invite link shown in the popup
Config.DiscordLink = "https://discord.gg/P3pBmHtgYP"

-- Website signup/whitelist application URL
Config.WebsiteUrl = GetConvar('rps_welcome_website_url', 'https://yoursite.example/auth/register')

-- How long (ms) before the welcome popup auto-closes (0 = never auto-close)
Config.AutoCloseDelay = 0  -- disabled so users see the signup prompt

-- How often (ms) to send a heartbeat to the API
Config.HeartbeatInterval = 60000  -- every 60 seconds

-- Server name shown in the welcome popup
Config.ServerName = "GSRP"

-- Enable debug prints in server console
Config.Debug = false
