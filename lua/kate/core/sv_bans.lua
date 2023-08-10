local db = kate.Data.DB

kate.Bans = kate.Bans or {}

function kate.Ban(id, unban_time, reason, admin_name, admin_id)
	id = kate.SteamIDTo64(id)

	local query = db:prepare("SELECT * FROM `kate_bans` WHERE steamid = ? AND expired = ? LIMIT 1")
	query:setString(1, id)
	query:setBoolean(2, false)

	local moment = os.time()
	admin_name = admin_name or "Console"
	unban_time = unban_time > 0 and moment + unban_time or 0

	local hibernate = GetConVar("sv_hibernate_think"):GetInt()
	RunConsoleCommand("sv_hibernate_think", 1) -- to make sure we won't lose our query

	query.onSuccess = function(_, data)
		if #data > 0 then
			local query_update = db:prepare("UPDATE `kate_bans` SET admin_name = ?, admin_steamid = ?, unban_time = ?, reason = ? WHERE steamid = ? AND expired = ? LIMIT 1")
			query_update:setString(1, admin_name)

			if admin_id then
				query_update:setString(2, admin_id)
			else
				query_update:setNull(2)
			end

			query_update:setNumber(3, unban_time)
			query_update:setString(4, reason)
			query_update:setString(5, id)
			query_update:setBoolean(6, false)

			query_update:start()
		else
			local query_insert = db:prepare("INSERT INTO `kate_bans` (admin_name, admin_steamid, steamid, ban_time, unban_time, reason, expired) VALUES (?, ?, ?, ?, ?, ?, ?)")
			query_insert:setString(1, admin_name)

			if admin_id then
				query_insert:setString(2, admin_id)
			else
				query_insert:setNull(2)
			end

			query_insert:setString(3, id)
			query_insert:setNumber(4, moment)
			query_insert:setNumber(5, unban_time)
			query_insert:setString(6, reason)
			query_insert:setBoolean(7, false)

			query_insert:start()
		end

		RunConsoleCommand("sv_hibernate_think", hibernate) -- we're done
	end

	game.KickID(kate.SteamIDFrom64(id), reason)

	do
		kate.Bans[id] = {}
		kate.Bans[id].admin_name = admin_name
		kate.Bans[id].admin_steamid = admin_steamid
		kate.Bans[id].ban_time = ban_time
		kate.Bans[id].unban_time = unban_time
		kate.Bans[id].reason = reason
	end

	query:start()
end

function kate.Unban(id)
	id = kate.SteamIDTo64(id)

	local query = db:prepare("SELECT * FROM `kate_bans` WHERE steamid = ? AND expired = ? LIMIT 1")
	query:setString(1, id)
	query:setBoolean(2, false)

	local hibernate = GetConVar("sv_hibernate_think"):GetInt()
	RunConsoleCommand("sv_hibernate_think", 1)

	query.onSuccess = function(_, data)
		if #data <= 0 then
			return
		end

		data = data[1]

		local query_update = db:prepare("UPDATE `kate_bans` SET expired = ? WHERE steamid = ? AND expired = ? LIMIT 1")
		query_update:setBoolean(1, true)
		query_update:setString(2, id)
		query_update:setBoolean(3, false)
		query_update:start()

		kate.Bans[id] = nil

		RunConsoleCommand("sv_hibernate_think", hibernate)
	end

	query:start()
end

function kate.UpdateBans()
	table.Empty(kate.Bans)

	local query = db:prepare("SELECT * FROM `kate_bans` WHERE expired = ?")
	query:setBoolean(1, false)

	query.onSuccess = function(_, data)
		for _, banned in ipairs(data) do
			local id = banned.steamid

			do
				kate.Bans[id] = {}
				kate.Bans[id].admin_name = banned.admin_name
				kate.Bans[id].admin_steamid = banned.admin_steamid
				kate.Bans[id].ban_time = banned.ban_time
				kate.Bans[id].unban_time = banned.unban_time
				kate.Bans[id].reason = banned.reason
			end
		end
	end

	query:start()
end

hook.Add("CheckPassword", "Kate CheckPassword", function(id)
	local cached = kate.Bans[id]
	if not cached then
		return
	end

	local reason = cached.reason
	local unban_time = cached.unban_time
	local admin_name = cached.admin_name
	local admin_id = cached.admin_steamid

	admin_id = admin_id and " (" .. cached.admin_steamid .. ") " or "" -- hide steamid if invalid

	if unban_time ~= 0 and os.time() > unban_time then
		kate.Unban(id)
	else
		if unban_time > 0 then
			return false, "You are banned by " .. admin_name .. admin_id .. ".\nShame on you.\n\nReason: " .. reason .. "\nRemaining: " .. kate.ConvertTime(unban_time - os.time())
		else
			return false, "You are permabanned.\nShame on you.\n\nReason: " .. reason .. "\nRemaining: ∞"
		end
	end
end)

timer.Create("Kate Update Bans", 180, 0, kate.UpdateBans) -- in case the database is used on several servers at time
hook.Add("Initialize", "Kate Bans", kate.UpdateBans)