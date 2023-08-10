local db = kate.Data.DB

hook.Add("PlayerAuthed", "Kate PlayerAuthed", function(pl)
	local id = pl:SteamID64()
	local moment = os.time()

	do
		local query = db:prepare("SELECT * FROM `kate_users` WHERE steamid = ? LIMIT 1")
		query:setString(1, id)

		query.onSuccess = function(_, data)
			if #data > 0 then
				data = data[1]

				pl:SetUserGroup(data.rank)

				pl:SetKateVar("Joined", data.joined)
				pl:SetKateVar("Seen", data.seen)
				pl:SetKateVar("Playtime", data.playtime)

				local query_update = db:prepare("UPDATE `kate_users` SET seen = ? WHERE steamid = ? LIMIT 1")
				query_update:setNumber(1, moment)
				query_update:setString(2, id)
				query_update:start()
			else
				local query_insert = db:prepare("INSERT INTO `kate_users` (name, steamid, rank, joined, seen, playtime) VALUES (?, ?, ?, ?, ?, ?)")
				query_insert:setString(1, pl:Name())
				query_insert:setString(2, id)
				query_insert:setString(3, "user")
				query_insert:setNumber(4, moment)
				query_insert:setNumber(5, moment)
				query_insert:setNumber(6, 0)
				query_insert:start()
			end
		end

		query:start()
	end

	for _, tag in ipairs({"Gag", "Mute"}) do
		local low_tag = tag:lower()
		local s_tag = tag .. "s"

		local cached = kate[s_tag][id]
		if not cached then
			continue
		end

		local exp = cached.expire_time
		if exp ~= 0 and moment > exp then
			kate["Un" .. low_tag](pl)
		else
			pl:SetKateVar(tag, exp)
		end
	end
end)

timer.Create("Kate Players", 300, 0, function()
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

				pl:SetKateVar("Playtime", new)
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
				local exp_in = data.expire_in or "user"

				if os.time() < exp then
					return
				end

				local query_delete = db:prepare("DELETE FROM `kate_expirations` WHERE steamid = ?")
				query_delete:setString(1, id)
				query_delete:start()

				local query_update = db:prepare("UPDATE `kate_users` SET rank = ? WHERE steamid = ? LIMIT 1")
				query_update:setString(1, exp_in)
				query_update:setString(2, id)
				query_update:start()

				do
					local text = pl:Name() .. " has got his " .. kate.Ranks.Stored[pl:GetRank()]:GetTitle() .. " rank expired"

					if exp_in ~= "user" then
						text = text .. " in " .. kate.Ranks.Stored[exp_in]:GetTitle()
					end

					kate.Message(player.GetAll(), 3, text)
					kate.Print(text)
				end

				pl:SetUserGroup(exp_in)
			end

			query:start()
		end
	end
end)