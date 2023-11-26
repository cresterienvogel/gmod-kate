kate.Data = kate.Data or {}

kate.Data.IP = "127.0.0.1"
kate.Data.User = "root"
kate.Data.Password = ""
kate.Data.Table = "kate"
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
	db:query("CREATE TABLE IF NOT EXISTS `kate_mutes` (steamid TINYTEXT, reason TEXT, mute_time INT, expire_time INT, admin_steamid TINYTEXT, expired BOOL, case_id INT)"):start()

	-- gags
	db:query("CREATE TABLE IF NOT EXISTS `kate_gags` (steamid TINYTEXT, reason TEXT, gag_time INT, expire_time INT, admin_steamid TINYTEXT, expired BOOL, case_id INT)"):start()

	-- expirations
	db:query("CREATE TABLE IF NOT EXISTS `kate_expirations` (steamid TINYTEXT, expire_rank TINYTEXT, expire_in TINYTEXT, expire_time INT)"):start()

	-- users
	db:query("CREATE TABLE IF NOT EXISTS `kate_users` (name TEXT, steamid TINYTEXT, rank TINYTEXT, joined INT, seen INT, playtime INT)"):start()

	-- bans
	db:query("CREATE TABLE IF NOT EXISTS `kate_bans` (admin_name TEXT, admin_steamid TINYTEXT, steamid TINYTEXT, ban_time INT, unban_time INT, reason TEXT, expired BOOL, case_id INT)"):start()
end)