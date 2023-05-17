local db = kate.Data.DB

for _, tag in ipairs({"Gag", "Mute"}) do
	local low_tag = tag:lower()
	local tbl = "kate_" .. low_tag .. "s"

	kate[tag] = function(id, expire_time, reason, admin_id)
		id = kate.SteamIDTo64(id)

		local state = "SELECT * FROM " .. tbl .. " WHERE steamid = %s"
		local query = db:query(state:format(SQLStr(id)))

		local pl = kate.FindPlayer(id)

		expire_time = expire_time > 0 and os.time() + expire_time or 0
		admin_id = admin_id or "Console"

		query.onSuccess = function(_, data)
			if #data > 0 then
				state = "UPDATE " .. tbl .. " SET reason = %s, admin_steamid = %s, expire_time = %s WHERE steamid = %s"
				db:query(state:format(
					SQLStr(reason),
					SQLStr(admin_id),
					SQLStr(expire_time),
					SQLStr(id)
				)):start()
			else
				state = "INSERT INTO " .. tbl .. " (steamid, reason, expire_time, admin_steamid) VALUES (%s, %s, %s, %s)"
				db:query(state:format(
					SQLStr(id),
					SQLStr(reason),
					SQLStr(expire_time),
					SQLStr(admin_id)
				)):start()
			end
		end

		if IsValid(pl) then
			pl:SetKateVar(tag, expire_time)
		end

		query:start()
	end

	kate["Un" .. low_tag] = function(id)
		id = kate.SteamIDTo64(id)

		local state = "SELECT * FROM " .. tbl .. " WHERE steamid = %s"
		local query = db:query(state:format(SQLStr(id)))

		local pl = kate.FindPlayer(id)

		query.onSuccess = function(_, data)
			if #data <= 0 then
				return
			end

			state = "DELETE FROM " .. tbl .. " WHERE steamid = %s"
			query = db:query(state:format(SQLStr(id))):start()
		end

		if IsValid(pl) then
			pl:SetKateVar(tag, nil)
		end

		query:start()
	end
end

hook.Add("PlayerCanHearPlayersVoice", "Kate Gag", function(listener, talker)
	local gag = talker:GetKateVar("Gag")
	if not gag then
		return
	end

	if gag ~= 0 and os.time() > gag then
		kate.Ungag(talker)
		kate.Print(kate.GetTarget(talker) .. " has been ungagged since the mute time expired")
		return
	end

	return false
end)

hook.Add("PlayerSay", "Kate Mute", function(pl)
	local mute = pl:GetKateVar("Mute")
	if not mute then
		return
	end

	if mute ~= 0 and os.time() > mute then
		kate.Unmute(pl)
		kate.Print(kate.GetTarget(pl) .. " has been unmuted since the mute time expired")
		return
	end

	return ""
end)