local db = kate.Data.DB

kate.Bans = kate.Bans or {}

function kate.Ban(id, unban_time, reason, admin_name, admin_id)
	id = kate.SteamIDTo64(id)

	local state = "SELECT * FROM kate_bans WHERE steamid = %s"
	local query = db:query(state:format(SQLStr(id)))

	local pl = kate.FindPlayer(id)
	local ip = IsValid(pl) and string.Explode(":", pl:IPAddress())[1] or "Unknown"

	admin_name = admin_name or "Console"
	admin_id = admin_id or "None"
	unban_time = unban_time > 0 and os.time() + unban_time or 0

	query.onSuccess = function(_, data)
		if #data > 0 then
			state = "UPDATE kate_bans SET admin_name = %s, admin_steamid = %s, ip = %s, ban_time = %s, unban_time = %s, reason = %s WHERE steamid = %s"
			db:query(state:format(
				SQLStr(admin_name),
				SQLStr(admin_id),
				SQLStr(ip),
				SQLStr(os.time()),
				SQLStr(unban_time),
				SQLStr(reason),
				SQLStr(id)
			)):start()
		else
			state = "INSERT INTO kate_bans (admin_name, admin_steamid, steamid, ip, ban_time, unban_time, reason) VALUES (%s, %s, %s, %s, %s, %s, %s)"
			db:query(state:format(
				SQLStr(admin_name),
				SQLStr(admin_id),
				SQLStr(id),
				SQLStr(ip),
				SQLStr(os.time()),
				SQLStr(unban_time),
				SQLStr(reason)
			)):start()
		end
	end

	game.KickID(kate.SteamIDFrom64(id), reason)

	kate.Bans[id] = {
		admin_name = admin_name,
		admin_steamid = admin_id,
		ip = ip,
		ban_time = os.time(),
		unban_time = unban_time,
		reason = reason
	}

	query:start()
end

function kate.Unban(id)
	id = kate.SteamIDTo64(id)

	local state = "SELECT * FROM kate_bans WHERE steamid = %s"
	local query = db:query(state:format(SQLStr(id)))

	query.onSuccess = function(_, data)
		if #data <= 0 then
			return
		end

		state = "DELETE FROM kate_bans WHERE steamid = %s"
		query = db:query(state:format(SQLStr(id))):start()

		kate.Bans[id] = nil
	end

	query:start()
end

function kate.UpdateBans()
	table.Empty(kate.Bans)

	local query = db:query("SELECT * FROM kate_bans")

	query.onSuccess = function(_, data)
		for _, banned in ipairs(data) do
			kate.Bans[banned.steamid] = {
				admin_name = banned.admin_name,
				admin_steamid = banned.admin_steamid,
				ip = banned.ip,
				ban_time = banned.ban_time,
				unban_time = banned.unban_time,
				reason = banned.reason
			}
		end
	end

	query:start()
end

hook.Add("CheckPassword", "Kate CheckPassword", function(id)
	local data = kate.Bans[id]
	if not data then
		return
	end

	local reason = data.reason
	local unban_time = data.unban_time
	local admin_name = data.admin_name
	local admin_id = data.admin_steamid

	admin_id = admin_id ~= "None" and " (" .. data.admin_steamid .. ") " or "" -- hide steamid if invalid

	if os.time() > unban_time then
		state = "DELETE FROM kate_bans WHERE steamid = %s"
		query = db:query(state:format(SQLStr(id))):start()
		kate.Bans[id] = nil
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