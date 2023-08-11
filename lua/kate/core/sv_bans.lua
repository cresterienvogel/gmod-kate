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

	kate.Bans[id] = {}

	local should_hibernate, hibernate

	do
		should_hibernate = #player.GetAll() <= 1

		if should_hibernate then
			hibernate = GetConVar("sv_hibernate_think"):GetInt()
			RunConsoleCommand("sv_hibernate_think", 1) -- to make sure we won't lose our query
		end
	end

	query.onSuccess = function(_, data)
		if #data > 0 then
			local case_id = data[1].case_id

			local query_update = db:prepare("UPDATE `kate_bans` SET admin_name = ?, admin_steamid = ?, unban_time = ?, reason = ? WHERE steamid = ? AND expired = ? AND case_id = ? LIMIT 1")
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
			query_update:setNumber(7, case_id)

			query_update:start()
		else
			local query_select = db:query("SELECT COALESCE(SUM(`case_id`), 0) AS `case_id` FROM `kate_bans`")

			query_select.onSuccess = function(_, cases)
				cases = cases[1].case_id
				local case_id = cases + 1

				local query_insert = db:prepare("INSERT INTO `kate_bans` (admin_name, admin_steamid, steamid, ban_time, unban_time, reason, expired, case_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)")
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
				query_insert:setNumber(8, case_id)

				query_insert:start()

				kate.Bans[id].case_id = case_id
			end

			query_select:start()
		end

		if should_hibernate then
			RunConsoleCommand("sv_hibernate_think", hibernate) -- we're done
		end
	end

	game.KickID(kate.SteamIDFrom64(id), reason)

	do
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

	local should_hibernate, hibernate

	do
		should_hibernate = #player.GetAll() <= 1

		if should_hibernate then
			hibernate = GetConVar("sv_hibernate_think"):GetInt()
			RunConsoleCommand("sv_hibernate_think", 1)
		end
	end

	query.onSuccess = function(_, data)
		if #data <= 0 then
			return
		end

		data = data[1]

		local query_update = db:prepare("UPDATE `kate_bans` SET expired = ? WHERE steamid = ? AND expired = ? AND case_id = ? LIMIT 1")
		query_update:setBoolean(1, true)
		query_update:setString(2, id)
		query_update:setBoolean(3, false)
		query_update:setNumber(4, data.case_id)
		query_update:start()

		kate.Bans[id] = nil

		if should_hibernate then
			RunConsoleCommand("sv_hibernate_think", hibernate)
		end
	end

	query:start()
end

function kate.UpdateBans()
	table.Empty(kate.Bans)

	local query = db:prepare("SELECT * FROM `kate_bans` WHERE expired = ? LIMIT 1")
	query:setBoolean(1, false)

	query.onSuccess = function(_, data)
		for _, banned in ipairs(data) do
			local id = banned.steamid
			local reason = banned.reason

			do
				kate.Bans[id] = {}
				kate.Bans[id].reason = reason
				kate.Bans[id].admin_name = banned.admin_name
				kate.Bans[id].admin_steamid = banned.admin_steamid
				kate.Bans[id].ban_time = banned.ban_time
				kate.Bans[id].unban_time = banned.unban_time
				kate.Bans[id].case_id = banned.case_id
			end

			game.KickID(kate.SteamIDFrom64(id), reason)
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
	local case_id = cached.case_id

	admin_id = admin_id and " (" .. cached.admin_steamid .. ") " or "" -- hide steamid if invalid

	if unban_time ~= 0 and os.time() > unban_time then
		kate.Unban(id)
	else
		if unban_time > 0 then
			return false, "You are banned by " .. admin_name .. admin_id .. ".\nShame on you.\n\nReason: " .. reason .. "\nRemaining: " .. kate.ConvertTime(unban_time - os.time()) .. "\nCase ID: " .. case_id
		else
			return false, "You are permabanned.\nShame on you.\n\nReason: " .. reason .. "\nRemaining: ∞\nCase ID: " .. case_id
		end
	end
end)

timer.Create("Kate Update Bans", 180, 0, kate.UpdateBans) -- in case the database is used on several servers at time
hook.Add("Initialize", "Kate Bans", kate.UpdateBans)