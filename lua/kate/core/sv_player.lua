hook.Add("PlayerAuthed", "Kate PlayerAuthed", function(pl)
	local db = kate.Data.DB
	if not db then
		return
	end

	local id = pl:SteamID64()
	local name = pl:Name()

	local curTime = os.time()

	-- find player's data
	local querySelect = db:prepare("SELECT * FROM `kate_users` WHERE steamid = ? LIMIT 1")
		querySelect:setString(1, id)

		querySelect.onSuccess = function(_, data)
			if #data <= 0 then
				goto insert
			end

			do
				data = data[1]

				local curRank = data.rank
				local firstJoin = data.first_join
				local lastSeen = data.last_seen
				local playTime = data.play_time

				do
					pl:SetUserGroup(curRank)
					pl:SetFirstJoin(firstJoin)
					pl:SetLastSeen(lastSeen)
					pl:SetPlayTime(playTime)
				end

				do
					if firstJoin then
						kate.Message(pl, 3, string.format("Your first visit was %s, %s ago", os.date("%d %B %Y", firstJoin), kate.ConvertTime(curTime - firstJoin, 3)))
					end

					if lastSeen then
						kate.Message(pl, 3, string.format("Your last visit was %s, %s ago", os.date("%d %B %Y", lastSeen), kate.ConvertTime(curTime - lastSeen, 3)))
					end

					if playTime then
						kate.Message(pl, 3, string.format("Your playtime since first join is %s", kate.ConvertTime(playTime)))
					end

					if curRank ~= "user" then
						kate.Message(pl, 3, string.format("Your current rank is %s", kate.Ranks.Stored[curRank]:GetTitle()))
					end
				end

				local queryUpdate = db:prepare("UPDATE `kate_users` SET name = ?, last_seen = ? WHERE steamid = ? LIMIT 1")
					queryUpdate:setString(1, name)
					queryUpdate:setNumber(2, curTime)
					queryUpdate:setString(3, id)
				queryUpdate:start()

				return
			end

			::insert::
			do
				local queryInsert = db:prepare("INSERT INTO `kate_users` (name, steamid, rank, first_join, last_seen, play_time) VALUES (?, ?, ?, ?, ?, ?)")
					queryInsert:setString(1, name)
					queryInsert:setString(2, id)
					queryInsert:setString(3, "user")
					queryInsert:setNumber(4, curTime)
					queryInsert:setNumber(5, curTime)
					queryInsert:setNumber(6, 0)
				queryInsert:start()

				do
					pl:SetUserGroup("user")
					pl:SetFirstJoin(curTime)
					pl:SetLastSeen(curTime)
					pl:SetPlayTime(0)
				end
			end
		end
	querySelect:start()

	-- find player's restrictions
	for _, tag in ipairs({"Gag", "Mute"}) do
		local tagLower = string.lower(tag)

		local cached, expireTime = kate[tag .. "s"][id]
		if not cached then
			continue
		end

		expireTime = cached.expire_time
		if (expireTime ~= 0) and (curTime > expireTime) then
			kate["Un" .. tag](pl)
			return
		end

		pl:SetNetVar(tagLower, expireTime)

		kate.Message(pl, 3, string.format("Your %s will end in %s", tagLower, kate.ConvertTime(expireTime - curTime)))
	end

	-- check expirations
	kate.Ranks.CheckExpirations(id)
end)

hook.Add("PlayerDisconnected", "Kate PlayerDisconnected", function(pl)
	local db = kate.Data.DB
	if not db then
		return
	end

	local queryUpdate = db:prepare("UPDATE `kate_users` SET last_seen = ? WHERE steamid = ? LIMIT 1")
		queryUpdate:setNumber(1, os.time())
		queryUpdate:setString(2, pl:SteamID64())
	queryUpdate:start()
end)

timer.Create("Kate Players", 60, 0, function()
	local db = kate.Data.DB
	if not db then
		return
	end

	for _, pl in ipairs(player.GetHumans()) do
		if pl:TimeConnected() < 60 then
			continue
		end

		local id = pl:SteamID64()
		local playtime = pl:GetPlayTime() + 60

		local queryUpdate = db:prepare("UPDATE `kate_users` SET play_time = ? WHERE steamid = ? LIMIT 1")
			queryUpdate:setNumber(1, playtime)
			queryUpdate:setString(2, id)
		queryUpdate:start()

		pl:SetPlayTime(playtime)
	end
end)