for _, tag in ipairs({"Gag", "Mute"}) do
	local tag_lower = string.lower(tag)
	local tag_plural = tag .. "s"
	local tag_sql = "kate_" .. string.lower(tag_plural)

	kate[tag_plural] = kate[tag_plural] or {}

	kate[tag] = function(id, expire_time, reason, admin_id)
		local db = kate.Data.DB

		if not db then
			return
		end

		id = kate.SteamIDTo64(id)

		local query = db:prepare("SELECT * FROM `" .. tag_sql .. "` WHERE steamid = ? AND expired = ? LIMIT 1")
		query:setString(1, id)
		query:setString(2, "active")

		local now = os.time()
		expire_time = expire_time > 0 and now + expire_time or 0

		kate[tag_plural][id] = {}

		query.onSuccess = function(_, data)
			if not data[1] then
				goto new
			end

			do
				local case_id = data[1].case_id

				local query_update = db:prepare("UPDATE `" .. tag_sql .. "` SET reason = ?, admin_steamid = ?, expire_time = ? WHERE steamid = ? AND case_id = ? LIMIT 1")
				query_update:setString(1, reason)

				if admin_id then
					query_update:setString(2, admin_id)
				else
					query_update:setNull(2)
				end

				query_update:setNumber(3, expire_time)
				query_update:setString(4, id)
				query_update:setNumber(5, case_id)

				query_update:start()

				return
			end

			::new::
			do
				local query_select = db:query("SELECT COUNT(`case_id`) AS `case_id` FROM `" .. tag_sql .. "`")

				query_select.onSuccess = function(_, cases)
					cases = cases[1].case_id or 0

					local case_id = cases + 1

					local query_insert = db:prepare("INSERT INTO `" .. tag_sql .. "` (steamid, reason, " .. (tag_lower .. "_time") .. ", expire_time, admin_steamid, expired, case_id) VALUES (?, ?, ?, ?, ?, ?, ?)")
					query_insert:setString(1, id)
					query_insert:setString(2, reason)
					query_insert:setNumber(3, now)
					query_insert:setNumber(4, expire_time)

					if admin_id then
						query_insert:setString(5, admin_id)
					else
						query_insert:setNull(5)
					end

					query_insert:setString(6, "active")
					query_insert:setNumber(7, case_id)

					query_insert:start()

					kate[tag_plural][id].case_id = case_id
				end

				query_select:start()
			end
		end

		do
			local pl = kate.FindPlayer(id)

			if IsValid(pl) then
				pl:SetNetVar(tag_lower, expire_time)
			end
		end

		do
			kate[tag_plural][id].reason = reason
			kate[tag_plural][id].expire_time = expire_time
			kate[tag_plural][id].admin_id = admin_id
			kate[tag_plural][id][tag_lower .. "_time"] = now
		end

		query:start()
	end

	kate["Un" .. tag_lower] = function(id, reason, admin_id)
		local db = kate.Data.DB

		if not db then
			return
		end

		id = kate.SteamIDTo64(id)

		local query = db:prepare("SELECT * FROM `" .. tag_sql .. "` WHERE steamid = ? AND expired = ? LIMIT 1")
		query:setString(1, id)
		query:setString(2, "active")

		query.onSuccess = function(_, data)
			if not data[1] then
				return
			end

			local query_update = db:prepare("UPDATE `" .. tag_sql .. "` SET expired = ?, admin_steamid = ?, expire_time = ? WHERE steamid = ? AND case_id = ? LIMIT 1")
			query_update:setString(1, reason or "time out")
			query_update:setString(2, admin_id or data[1].admin_steamid)
			query_update:setNumber(3, os.time())
			query_update:setString(4, id)
			query_update:setNumber(5, data[1].case_id)
			query_update:start()

			kate[tag_plural][id] = nil
		end

		do
			local pl = kate.FindPlayer(id)

			if IsValid(pl) then
				pl:SetNetVar(tag_lower, nil)
			end
		end

		query:start()
	end

	kate["Update" .. tag_plural] = function()
		local db = kate.Data.DB

		if not db then
			return
		end

		kate[tag_plural] = {}

		local query = db:prepare("SELECT * FROM `" .. tag_sql .. "` WHERE expired = ? LIMIT 1")
		query:setString(1, "active")

		query.onSuccess = function(_, data)
			for _, punished in ipairs(data) do
				local id = punished.steamid
				local time = punished.expire_time

				do
					kate[tag_plural][id] = {}
					kate[tag_plural][id].expire_time = time
					kate[tag_plural][id].reason = punished.reason
					kate[tag_plural][id].admin_id = punished.admin_id
					kate[tag_plural][id].case_id = punished.case_id
					kate[tag_plural][id][tag_lower .. "_time"] = punished[tag_lower .. "_time"]
				end

				do
					local pl = kate.FindPlayer(kate.SteamIDFrom64(id))

					if IsValid(pl) then
						pl:SetNetVar(tag_lower, time)
					end
				end
			end
		end

		query:start()
	end

	timer.Simple(0, kate["Update" .. tag_plural])
	timer.Create("Kate Update " .. tag_plural, 180, 0, kate["Update" .. tag_plural]) -- in case the database is used on several servers at time
end

hook.Add("PlayerCanHearPlayersVoice", "Kate Gag", function(listener, talker)
	local gag = talker:GetGag()

	if not gag then
		return
	end

	if (gag ~= 0) and (os.time() > gag) then
		kate.Ungag(talker)
		kate.Print(kate.GetTarget(talker), "has been ungagged since the gag time expired")
		return
	end

	return false
end)

hook.Add("PlayerSay", "Kate Mute", function(pl)
	local mute = pl:GetMute()

	if not mute then
		return
	end

	if (mute ~= 0) and (os.time() > mute) then
		kate.Unmute(pl)
		kate.Print(kate.GetTarget(pl), "has been unmuted since the mute time expired")
		return
	end

	return ""
end)