local db = kate.Data.DB

for _, tag in ipairs({"Gag", "Mute"}) do
	local low_tag = tag:lower()
	local s_tag = tag .. "s"
	local tbl = "kate_" .. s_tag:lower()

	kate[s_tag] = kate[s_tag] or {}

	kate[tag] = function(id, expire_time, reason, admin_id)
		id = kate.SteamIDTo64(id)

		local query = db:prepare("SELECT * FROM `" .. tbl .. "` WHERE steamid = ? AND expired = ? LIMIT 1")
		query:setString(1, id)
		query:setBoolean(2, false)

		local moment = os.time()
		local pl = kate.FindPlayer(id)
		expire_time = expire_time > 0 and moment + expire_time or 0

		local hibernate = GetConVar("sv_hibernate_think"):GetInt()
		RunConsoleCommand("sv_hibernate_think", 1)

		query.onSuccess = function(_, data)
			if #data > 0 then
				local query_update = db:prepare("UPDATE `" .. tbl .. "` SET reason = ?, admin_steamid = ?, expire_time = ? WHERE steamid = ? AND expired = ? LIMIT 1")
				query_update:setString(1, reason)

				if admin_id then
					query_update:setString(2, admin_id)
				else
					query_update:setNull(2)
				end

				query_update:setNumber(3, expire_time)
				query_update:setString(4, id)
				query_update:setBoolean(5, false)

				query_update:start()
			else
				local query_insert = db:prepare("INSERT INTO `" .. tbl .. "` (steamid, reason, " .. (low_tag .. "_time") .. ", expire_time, admin_steamid, expired) VALUES (?, ?, ?, ?, ?, ?)")
				query_insert:setString(1, id)
				query_insert:setString(2, reason)
				query_insert:setNumber(3, moment)
				query_insert:setNumber(4, expire_time)

				if admin_id then
					query_insert:setString(5, admin_id)
				else
					query_insert:setNull(5)
				end

				query_insert:setBoolean(6, false)

				query_insert:start()
			end

			RunConsoleCommand("sv_hibernate_think", hibernate)
		end

		if IsValid(pl) then
			pl:SetKateVar(tag, expire_time)
		end

		do
			kate[s_tag][id] = {}
			kate[s_tag][id].reason = reason
			kate[s_tag][id].expire_time = expire_time
			kate[s_tag][id].admin_id = admin_id
			kate[s_tag][id][low_tag .. "_time"] = moment
		end

		query:start()
	end

	kate["Un" .. low_tag] = function(id)
		id = kate.SteamIDTo64(id)

		local query = db:prepare("SELECT * FROM `" .. tbl .. "` WHERE steamid = ? AND expired = ? LIMIT 1")
		query:setString(1, id)
		query:setBoolean(2, false)

		local pl = kate.FindPlayer(id)

		local hibernate = GetConVar("sv_hibernate_think"):GetInt()
		RunConsoleCommand("sv_hibernate_think", 1)

		query.onSuccess = function(_, data)
			if #data <= 0 then
				return
			end

			data = data[1]

			local query_update = db:prepare("UPDATE `" .. tbl .. "` SET expired = ? WHERE steamid = ? AND expired = ? LIMIT 1")
			query_update:setBoolean(1, true)
			query_update:setString(2, id)
			query_update:setBoolean(3, false)
			query_update:start()

			kate[s_tag][id] = nil

			RunConsoleCommand("sv_hibernate_think", hibernate)
		end

		if IsValid(pl) then
			pl:SetKateVar(tag, nil)
		end

		query:start()
	end

	kate["Update" .. s_tag] = function()
		table.Empty(kate[s_tag])

		local query = db:prepare("SELECT * FROM `" .. tbl .. "` WHERE expired = ?")
		query:setBoolean(1, false)

		query.onSuccess = function(_, data)
			for _, punished in ipairs(data) do
				local id = punished.steamid

				do
					kate[s_tag][id] = {}
					kate[s_tag][id].reason = punished.reason
					kate[s_tag][id].expire_time = punished.expire_time
					kate[s_tag][id].admin_id = punished.admin_id
					kate[s_tag][id][low_tag .. "_time"] = punished[low_tag .. "_time"]
				end
			end
		end

		query:start()
	end

	timer.Create("Kate Update " .. s_tag, 180, 0, kate["Update" .. s_tag]) -- in case the database is used on several servers at time
	hook.Add("Initialize", "Kate " .. s_tag, kate["Update" .. s_tag])
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