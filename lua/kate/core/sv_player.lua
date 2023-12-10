hook.Add("PlayerAuthed", "Kate PlayerAuthed", function(pl)
	local db = kate.Data.DB

	if not db then
		return
	end

	local id = pl:SteamID64()
	local unixNow = os.time()

	-- find player's data
	do
		local querySelect = db:prepare("SELECT * FROM `kate_users` WHERE steamid = ? LIMIT 1")
		querySelect:setString(1, id)

		querySelect.onSuccess = function(_, data)
			if #data < 0 then
				goto insert
			end

			do
				data = data[1]

				pl:SetUserGroup(data.rank)

				pl:SetJoined(data.joined)
				pl:SetLastSeen(data.seen)
				pl:SetPlaytime(data.playtime)

				kate.Message(pl, 3, string.format("Your last visit was %s, %s ago", os.date("%d %B %Y", data.seen), kate.ConvertTime(unixNow - data.seen)))
				kate.Message(pl, 3, string.format("Your playtime is %s", kate.ConvertTime(data.playtime)))

				local queryUpdate = db:prepare("UPDATE `kate_users` SET name = ?, seen = ? WHERE steamid = ? LIMIT 1")
				queryUpdate:setString(1, pl:Name())
				queryUpdate:setNumber(2, unixNow)
				queryUpdate:setString(3, id)
				queryUpdate:start()

				return
			end

			::insert::
			do
				local queryInsert = db:prepare("INSERT INTO `kate_users` (name, steamid, rank, joined, seen, playtime) VALUES (?, ?, ?, ?, ?, ?)")
				queryInsert:setString(1, pl:Name())
				queryInsert:setString(2, id)
				queryInsert:setString(3, "user")
				queryInsert:setNumber(4, unixNow)
				queryInsert:setNumber(5, unixNow)
				queryInsert:setNumber(6, 0)
				queryInsert:start()
			end
		end

		querySelect:start()
	end

	-- find player's restrictions
	for _, tag in ipairs({"Gag", "Mute"}) do
		local tagLower = string.lower(tag)
		local cached, expireTime = kate[tag .. "s"][id]

		if not cached then
			continue
		end

		expireTime = cached.expire_time

		-- check if restriction's time is out
		if (expireTime ~= 0) and (unixNow > expireTime) then
			kate["Un" .. tag](pl)
			return
		end

		-- set restriction
		pl:SetNetVar(tagLower, expireTime)

		-- message
		kate.Message(pl, 3, string.format("Your %s will end in %s", tagLower, kate.ConvertTime(expireTime - unixNow)))
	end
end)

hook.Add("PlayerDisconnected", "Kate PlayerDisconnected", function(pl)
	local db = kate.Data.DB

	if not db then
		return
	end

	local querySelect = db:prepare("UPDATE `kate_users` SET seen = ? WHERE steamid = ? LIMIT 1")
	querySelect:setNumber(1, os.time())
	querySelect:setString(2, pl:SteamID64())
	querySelect:start()
end)

timer.Create("Kate Players", 300, 0, function()
	local db = kate.Data.DB

	if not db then
		return
	end

	for _, pl in ipairs(player.GetAll()) do
		local id = pl:SteamID64()

		do -- update playtime
			local querySelect = db:prepare("SELECT * FROM `kate_users` WHERE steamid = ? LIMIT 1")
			querySelect:setString(1, id)

			querySelect.onSuccess = function(_, data)
				if #data <= 0 then
					return
				end

				local new = data[1].playtime + 300

				local queryUpdate = db:prepare("UPDATE `kate_users` SET playtime = ? WHERE steamid = ? LIMIT 1")
				queryUpdate:setNumber(1, new)
				queryUpdate:setString(2, id)
				queryUpdate:start()

				pl:SetPlaytime(new)
			end

			querySelect:start()
		end

		do -- check expirations
			local querySelect = db:prepare("SELECT * FROM `kate_expirations` WHERE steamid = ? LIMIT 1")
			querySelect:setString(1, id)

			querySelect.onSuccess = function(_, data)
				if #data <= 0 then
					return
				end

				data = data[1]

				local expireTime = data.expire_time
				local expireRank = data.expire_in

				if os.time() < expireTime then
					return
				end

				do
					local queryDelete = db:prepare("DELETE FROM `kate_expirations` WHERE steamid = ?")
					queryDelete:setString(1, id)
					queryDelete:start()
				end

				do
					local queryUpdate = db:prepare("UPDATE `kate_users` SET rank = ? WHERE steamid = ? LIMIT 1")
					queryUpdate:setString(1, expireRank)
					queryUpdate:setString(2, id)
					queryUpdate:start()
				end

				do
					local msg = "%s has got his %s rank expired"

					if expireRank ~= "user" then
						msg = msg .. " in %s"
					end

					msg = string.format(msg,
						pl:Name(),
						kate.Ranks.Stored[pl:GetRank()]:GetTitle(),
						kate.Ranks.Stored[expireRank]:GetTitle()
					)

					kate.Message(player.GetAll(), 3, msg)
					kate.Print(msg)
				end

				pl:SetUserGroup(expireRank)
			end

			querySelect:start()
		end
	end
end)