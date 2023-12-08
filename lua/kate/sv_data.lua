local db

kate.Data = kate.Data or {}

--[[
	use

		kate.Data.IP
		kate.Data.User
		kate.Data.Password
		kate.Data.Table
		kate.Data.Table

	to setup your custom data inside a kate addon
]]

timer.Simple(0, function()
	kate.Data.DB = kate.Data.DB or mysqloo.connect(
		kate.Data.IP or "127.0.0.1",
		kate.Data.User or "root",
		kate.Data.Password or "",
		kate.Data.Table or "kate",
		kate.Data.Port or 3306
	)

	db = kate.Data.DB

	db.onConnected = function()
		kate.Print("Database connection successfully established")
	end

	db.onConnectionFailed = function(d, err)
		kate.Print("Database connection error:", err)
	end

	-- for changelevel purpose
	if not db:ping() then
		db:connect()
	end
end)

hook.Add("InitPostEntity", "Kate DB", function()
	if not db then
		kate.Print("Connecting to database...")
		return
	end

	-- mutes
	db:query([[CREATE TABLE IF NOT EXISTS `kate_mutes` (
		steamid TINYTEXT,
		reason TEXT,
		mute_time INT,
		expire_time INT,
		admin_steamid TINYTEXT,
		expired BOOL,
		case_id INT)
	]]):start()

	-- gags
	db:query([[CREATE TABLE IF NOT EXISTS `kate_gags` (
		steamid TINYTEXT,
		reason TEXT,
		gag_time INT,
		expire_time INT,
		admin_steamid TINYTEXT,
		expired BOOL,
		case_id INT)
	]]):start()

	-- expirations
	db:query([[CREATE TABLE IF NOT EXISTS `kate_expirations` (
		steamid TINYTEXT,
		expire_rank TINYTEXT,
		expire_in TINYTEXT,
		expire_time INT)
	]]):start()

	-- users
	db:query([[CREATE TABLE IF NOT EXISTS `kate_users` (
		name TEXT,
		steamid TINYTEXT,
		rank TINYTEXT,
		joined INT,
		seen INT,
		playtime INT)
	]]):start()

	-- bans
	db:query([[CREATE TABLE IF NOT EXISTS `kate_bans` (
		admin_name TEXT,
		admin_steamid TINYTEXT,
		steamid TINYTEXT,
		ban_time INT,
		unban_time INT,
		reason TEXT,
		expired BOOL,
		case_id INT)
	]]):start()
end)