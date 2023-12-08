hook.Add("PlayerAuthed", "Kate PlayerAuthed", function(pl)
	local db = kate.Data.DB

	if not db then
		return
	end

	local id = pl:SteamID64()
	local now = os.time()

	-- find player's data
	do
		local query = db:prepare("SELECT * FROM `kate_users` WHERE steamid = ? LIMIT 1")
		query:setString(1, id)

		query.onSuccess = function(_, data)
			if #data < 0 then
				goto insert
			end

			do
				data = data[1]

				pl:SetUserGroup(data.rank)

				pl:SetJoined(data.joined)
				pl:SetLastSeen(data.seen)
				pl:SetPlaytime(data.playtime)

				kate.Message(pl, 3, string.format("Your last visit was %s, %s ago", os.date("%d %B %Y", data.seen), kate.ConvertTime(now - data.seen)))
				kate.Message(pl, 3, string.format("Your playtime is %s", kate.ConvertTime(data.playtime)))

				local query_update = db:prepare("UPDATE `kate_users` SET name = ?, seen = ? WHERE steamid = ? LIMIT 1")
				query_update:setString(1, pl:Name())
				query_update:setNumber(2, now)
				query_update:setString(3, id)
				query_update:start()

				return
			end

			::insert::
			do
				local query_insert = db:prepare("INSERT INTO `kate_users` (name, steamid, rank, joined, seen, playtime) VALUES (?, ?, ?, ?, ?, ?)")
				query_insert:setString(1, pl:Name())
				query_insert:setString(2, id)
				query_insert:setString(3, "user")
				query_insert:setNumber(4, now)
				query_insert:setNumber(5, now)
				query_insert:setNumber(6, 0)
				query_insert:start()
			end
		end

		query:start()
	end

	-- find player's restrictions
	for _, tag in ipairs({"Gag", "Mute"}) do
		local cached, exp = kate[tag .. "s"][id]

		if not cached then
			continue
		end

		exp = cached.expire_time

		-- check if restriction's time is out
		if (exp ~= 0) and (now > exp) then
			kate["Un" .. tag](pl)
			return
		end

		-- set restriction
		pl:SetNetVar(string.lower(tag), exp)
	end
end)

hook.Add("PlayerDisconnected", "Kate PlayerDisconnected", function(pl)
	local db = kate.Data.DB

	if not db then
		return
	end

	local query = db:prepare("UPDATE `kate_users` SET seen = ? WHERE steamid = ? LIMIT 1")
	query:setNumber(1, os.time())
	query:setString(2, pl:SteamID64())
	query:start()
end)

timer.Create("Kate Players", 300, 0, function()
	local db = kate.Data.DB

	if not db then
		return
	end

	for _, pl in ipairs(player.GetAll()) do
		local id = pl:SteamID64()

		do -- update playtime
			local query = db:prepare("SELECT * FROM `kate_users` WHERE steamid = ? LIMIT 1")
			query:setString(1, id)

			query.onSuccess = function(_, data)
				if #data <= 0 then
					return
				end

				local new = data[1].playtime + 300

				local query_update = db:prepare("UPDATE `kate_users` SET playtime = ? WHERE steamid = ? LIMIT 1")
				query_update:setNumber(1, new)
				query_update:setString(2, id)
				query_update:start()

				pl:SetPlaytime(new)
			end

			query:start()
		end

		do -- check expirations
			local query = db:prepare("SELECT * FROM `kate_expirations` WHERE steamid = ? LIMIT 1")
			query:setString(1, id)

			query.onSuccess = function(_, data)
				if #data <= 0 then
					return
				end

				data = data[1]

				local exp = data.expire_time
				local exp_in = data.expire_in

				if os.time() < exp then
					return
				end

				do
					local query_delete = db:prepare("DELETE FROM `kate_expirations` WHERE steamid = ?")
					query_delete:setString(1, id)
					query_delete:start()
				end

				do
					local query_update = db:prepare("UPDATE `kate_users` SET rank = ? WHERE steamid = ? LIMIT 1")
					query_update:setString(1, exp_in)
					query_update:setString(2, id)
					query_update:start()
				end

				do
					local msg = "%s has got his %s rank expired"

					if exp_in ~= "user" then
						msg = msg .. " in %s"
					end

					msg = string.format(msg,
						pl:Name(),
						kate.Ranks.Stored[pl:GetRank()]:GetTitle(),
						kate.Ranks.Stored[exp_in]:GetTitle()
					)

					kate.Message(player.GetAll(), 3, msg)
					kate.Print(msg)
				end

				pl:SetUserGroup(exp_in)
			end

			query:start()
		end
	end
end)