local db = kate.Data.DB

hook.Add("PlayerAuthed", "Kate PlayerAuthed", function(pl)
	local id = pl:SteamID64()

	do
		local state = "SELECT * FROM kate_users WHERE steamid = %s"
		local query = db:query(state:format(SQLStr(id)))

		query.onSuccess = function(_, data)
			if #data > 0 then
				data = data[1]

				pl:SetUserGroup(data.rank)

				pl:SetKateVar("Joined", data.joined)
				pl:SetKateVar("Seen", data.seen)
				pl:SetKateVar("Playtime", data.playtime)

				state = "UPDATE kate_users SET seen = %s WHERE steamid = %s"
				db:query(state:format(SQLStr(os.time()), SQLStr(id))):start()
			else
				state = "INSERT INTO kate_users (name, steamid, rank, joined, seen, playtime) VALUES (%s, %s, %s, %s, %s, %s)"
				db:query(state:format(SQLStr(pl:Name()), SQLStr(id), SQLStr("user"), SQLStr(os.time()), SQLStr(os.time()), SQLStr(0))):start()
			end
		end

		query:start()
	end

	for _, tag in ipairs({"Gag", "Mute"}) do
		local tbl = "kate_" .. tag:lower() .. "s"

		local state = "SELECT * FROM " .. tbl .. " WHERE steamid = %s"
		local query = db:query(state:format(SQLStr(id)))

		query.onSuccess = function(_, data)
			if #data <= 0 then
				return
			end

			local exp = data[1].expire_time
			if exp ~= 0 and os.time() > exp then
				state = "DELETE FROM " .. tbl .. " WHERE steamid = %s"
				db:query(state:format(SQLStr(id))):start()
				pl:SetKateVar(tag, nil)
			else
				pl:SetKateVar(tag, exp)
			end
		end

		query:start()
	end
end)

timer.Create("Kate Players", 300, 0, function()
	for _, pl in ipairs(player.GetAll()) do
		local id = pl:SteamID64()

		do -- update playtime
			local state = "SELECT * FROM kate_users WHERE steamid = %s"
			local query = db:query(state:format(SQLStr(id)))

			query.onSuccess = function(_, data)
				if #data <= 0 then
					return
				end

				local new = data[1].playtime + 300

				state = "UPDATE kate_users SET playtime = %s WHERE steamid = %s"
				db:query(state:format(SQLStr(new), SQLStr(id))):start()

				pl:SetKateVar("Playtime", new)
			end

			query:start()
		end

		do -- check expirations
			local state = "SELECT * FROM kate_expirations WHERE steamid = %s"
			local query = db:query(state:format(SQLStr(id)))

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

				state = "DELETE FROM kate_expirations WHERE steamid = %s"
				db:query(state:format(SQLStr(id))):start()

				state = "UPDATE kate_users SET rank = %s WHERE steamid = %s"
				db:query(state:format(SQLStr(exp_in), SQLStr(id))):start()

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