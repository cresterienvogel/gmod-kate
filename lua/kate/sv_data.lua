kate.Data = kate.Data or {}

kate.Data.IP = ""
kate.Data.User = ""
kate.Data.Password = ""
kate.Data.Table = ""
kate.Data.Port = 3306

kate.Data.DB = kate.Data.DB or mysqloo.connect(kate.Data.IP, kate.Data.User, kate.Data.Password, kate.Data.Table, kate.Data.Port)

local db = kate.Data.DB

do
	db.onConnected = function()
		kate.Print("Database connection successfully established")
	end

	db.onConnectionFailed = function(d, err)
		kate.Print("Database connection error:", err)
	end
end

if not db:ping() then
	db:connect()
end

hook.Add("Initialize", "Kate DB", function()
	-- mutes
	db:query("CREATE TABLE IF NOT EXISTS kate_mutes (steamid TEXT, reason TEXT, expire_time INT, admin_steamid TEXT)"):start()

	-- gags
	db:query("CREATE TABLE IF NOT EXISTS kate_gags (steamid TEXT, reason TEXT, expire_time INT, admin_steamid TEXT)"):start()

	-- expirations
	db:query("CREATE TABLE IF NOT EXISTS kate_expirations (steamid TEXT, expire_rank TEXT, expire_in TEXT, expire_time INT)"):start()

	-- users
	db:query("CREATE TABLE IF NOT EXISTS kate_users (name TEXT, steamid TEXT, rank TEXT, joined INT, seen INT, playtime INT)"):start()

	-- bans
	db:query("CREATE TABLE IF NOT EXISTS kate_bans (admin_name TEXT, admin_steamid TEXT, steamid TEXT, ip TEXT, ban_time INT, unban_time INT, reason TEXT)"):start()
end)