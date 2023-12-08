kate.Data = kate.Data or {}

--[[
	use

		kate.Data.IP
		kate.Data.User
		kate.Data.Password
		kate.Data.Table
		kate.Data.Table

	to setup your custom data inside a kate addon
	a tick timer will save you a bit of time to adjust mysqloo.connect
]]

kate.Data.DB = kate.Data.DB or timer.Simple(0, function()
	local db = mysqloo.connect(
		kate.Data.IP or "127.0.0.1",
		kate.Data.User or "root",
		kate.Data.Password or "",
		kate.Data.Table or "kate",
		kate.Data.Port or 3306
	)

	db.onConnected = function(s)
		kate.Print("Database connection successfully established")

		s:query([[CREATE TABLE IF NOT EXISTS `kate_mutes`
			(
				steamid TINYTEXT,
				reason TEXT,
				mute_time INT,
				expire_time INT,
				admin_steamid TINYTEXT,
				expired TEXT,
				case_id INT
			)
		]]):start()

		s:query([[CREATE TABLE IF NOT EXISTS `kate_gags`
			(
				steamid TINYTEXT,
				reason TEXT,
				gag_time INT,
				expire_time INT,
				admin_steamid TINYTEXT,
				expired TEXT,
				case_id INT
			)
		]]):start()

		s:query([[CREATE TABLE IF NOT EXISTS `kate_gags`
			(
				steamid TINYTEXT,
				reason TEXT,
				gag_time INT,
				expire_time INT,
				admin_steamid TINYTEXT,
				expired TEXT,
				case_id INT
			)
		]]):start()

		s:query([[CREATE TABLE IF NOT EXISTS `kate_expirations`
			(
				steamid TINYTEXT,
				expire_rank TINYTEXT,
				expire_in TINYTEXT,
				expire_time INT
			)
		]]):start()

		s:query([[CREATE TABLE IF NOT EXISTS `kate_users`
			(
				name TEXT,
				steamid TINYTEXT,
				rank TINYTEXT,
				joined INT,
				seen INT,
				playtime INT
			)
		]]):start()

		s:query([[CREATE TABLE IF NOT EXISTS `kate_bans`
			(
				admin_name TEXT,
				admin_steamid TINYTEXT,
				steamid TINYTEXT,
				ban_time INT,
				unban_time INT,
				reason TEXT,
				expired TEXT,
				case_id INT
			)
		]]):start()
	end

	db.onConnectionFailed = function(s, err)
		kate.Print("Database connection error:", err)
	end

	-- for changelevel purpose
	if not db:ping() then
		db:connect()
	end

	kate.Data.DB = db
end)