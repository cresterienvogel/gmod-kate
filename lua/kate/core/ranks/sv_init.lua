local meta = FindMetaTable("Player")

local db = kate.Data.DB

function meta:SetRank(rank, exp, exp_in)
	if exp and exp <= 0 then
		exp, exp_in = nil, nil
	end

	kate.Ranks.Set(self:SteamID64(), rank, exp, exp_in)
end

function kate.Ranks.AddExpiration(id, rank, exp, exp_in)
	local state = "SELECT * FROM kate_expirations WHERE steamid = %s"
	local query = db:query(state:format(SQLStr(id)))

	query.onSuccess = function(_, expirations)
		if exp and (exp_in == "user" or kate.Ranks.Stored[exp_in]) then
			if #expirations > 0 then
				state = "UPDATE kate_expirations SET expire_time = %s, expire_rank = %s, expire_in = %s WHERE steamid = %s"
				db:query(state:format(SQLStr(os.time() + exp), SQLStr(rank), SQLStr(exp_in), SQLStr(id))):start()
			else
				state = "INSERT INTO kate_expirations (steamid, expire_rank, expire_in, expire_time) VALUES (%s, %s, %s, %s)"
				db:query(state:format(SQLStr(id), SQLStr(rank), SQLStr(exp_in), SQLStr(os.time() + exp))):start()
			end
		else
			if #expirations > 0 then
				state = "DELETE FROM kate_expirations WHERE steamid = %s"
				db:query(state:format(SQLStr(id))):start()
			end
		end
	end

	query:start()
end

function kate.Ranks.Set(id, rank, exp, exp_in)
	if not kate.IsSteamID64() then
		id = kate.SteamIDTo64(id)
	end

	local stored = kate.Ranks.Stored
	local state = "SELECT * FROM kate_users WHERE steamid = %s"
	local query = db:query(state:format(SQLStr(id)))
	local pl = kate.FindPlayer(id)

	if exp then
		exp_in = exp_in or "user"
	end

	query.onSuccess = function(_, users)
		-- add a completely new row
		if #users <= 0 then
			if rank == "user" or not stored[rank] then
				return
			end

			state = "INSERT INTO kate_users (name, steamid, rank, joined, seen, playtime) VALUES (%s, %s, %s, %s, %s, %s)"
			db:query(state:format(SQLStr("Unknown"), SQLStr(id), SQLStr(rank), SQLStr(os.time()), SQLStr(os.time()), SQLStr(0))):start()
			kate.Ranks.AddExpiration(id, rank, exp, exp_in)

			return
		end

		-- remove
		if rank == "user" then
			state = "UPDATE kate_users SET rank = %s WHERE steamid = %s"
			db:query(state:format(SQLStr(rank), SQLStr(id))):start()

			state = "DELETE FROM kate_expirations WHERE steamid = %s"
			db:query(state:format(SQLStr(id))):start()

			if IsValid(pl) then
				pl:SetUserGroup(rank)
			end

			return
		end

		-- add
		if stored[rank] then
			state = "UPDATE kate_users SET rank = %s WHERE steamid = %s"
			db:query(state:format(SQLStr(rank), SQLStr(id))):start()
			kate.Ranks.AddExpiration(id, rank, exp, exp_in)

			if IsValid(pl) then
				pl:SetUserGroup(rank)
			end
		end
	end

	query:start()
end