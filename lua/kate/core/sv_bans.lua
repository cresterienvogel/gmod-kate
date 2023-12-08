kate.Bans = kate.Bans or {}

function kate.Ban(id, unban_time, reason, admin_name, admin_id)
	local db = kate.Data.DB

	if not db then
		return
	end

	id = kate.SteamIDTo64(id)

	local now = os.time()
	admin_name = admin_name or "Console"
	unban_time = unban_time > 0 and now + unban_time or 0

	kate.Bans[id] = {}

	local query = db:prepare("SELECT * FROM `kate_bans` WHERE steamid = ? AND expired = ? LIMIT 1")
	query:setString(1, id)
	query:setString(2, "active")

	query.onSuccess = function(_, data)
		if not data[1] then
			goto new_ban
		end

		do
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
			query_update:setString(6, "active")
			query_update:setNumber(7, case_id)

			query_update:start()

			return
		end

		::new_ban::
		do
			local query_select = db:query("SELECT COUNT(`case_id`) AS `case_id` FROM `kate_bans`")

			query_select.onSuccess = function(_, cases)
				cases = cases[1].case_id or 0

				local case_id = cases + 1

				local query_insert = db:prepare("INSERT INTO `kate_bans` (admin_name, admin_steamid, steamid, ban_time, unban_time, reason, expired, case_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)")
				query_insert:setString(1, admin_name)

				if admin_id then
					query_insert:setString(2, admin_id)
				else
					query_insert:setNull(2)
				end

				query_insert:setString(3, id)
				query_insert:setNumber(4, now)
				query_insert:setNumber(5, unban_time)
				query_insert:setString(6, reason)
				query_insert:setString(7, "active")
				query_insert:setNumber(8, case_id)

				query_insert:start()

				kate.Bans[id].case_id = case_id
			end

			query_select:start()
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

function kate.Unban(id, reason, admin_id)
	local db = kate.Data.DB

	if not db then
		return
	end

	id = kate.SteamIDTo64(id)

	local query = db:prepare("SELECT * FROM `kate_bans` WHERE steamid = ? AND expired = ? LIMIT 1")
	query:setString(1, id)
	query:setString(2, "active")

	query.onSuccess = function(_, data)
		if not data[1] then
			return
		end

		local query_update = db:prepare("UPDATE `kate_bans` SET expired = ?, admin_steamid = ?, unban_time = ? WHERE steamid = ? AND case_id = ? LIMIT 1")
		query_update:setString(1, reason or "time out")
		query_update:setString(2, admin_id or data[1].admin_steamid)
		query_update:setNumber(3, os.time())
		query_update:setString(4, id)
		query_update:setNumber(5, data[1].case_id)
		query_update:start()

		kate.Bans[id] = nil
	end

	query:start()
end

function kate.UpdateBans()
	local db = kate.Data.DB

	if not db then
		return
	end

	kate.Bans = {}

	local query = db:prepare("SELECT * FROM `kate_bans` WHERE expired = ? LIMIT 1")
	query:setString(1, "active")

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

	-- if player got banned when he's the only player on the server
	-- the case_id field won't be cached at time due hibernation
	-- sv_hibernate_think 1 can do the trick if you care
	if not case_id then
		local message = "Sorry, but we can't identify your ban details.\nTry join later.\n\n"
		message = message .. [[¯\_(ツ)_/¯]]

		return false, message
	end

	admin_id = admin_id and " (" .. cached.admin_steamid .. ") " or "" -- hide steamid if invalid

	if (unban_time ~= 0) and (os.time() > unban_time) then
		kate.Unban(id)
		return
	end

	if unban_time > 0 then
		return false, "You are banned by " .. admin_name .. admin_id .. ".\nShame on you.\n\nReason: " .. reason .. "\nRemaining: " .. kate.ConvertTime(unban_time - os.time()) .. "\nCase ID: " .. case_id
	end

	return false, "You are permabanned.\nShame on you.\n\nReason: " .. reason .. "\nRemaining: ∞\nCase ID: " .. case_id
end)

timer.Create("Kate Update Bans", 180, 0, kate.UpdateBans) -- in case the database is used on several servers at time
hook.Add("Initialize", "Kate Bans", kate.UpdateBans)