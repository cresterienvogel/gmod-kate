local meta = FindMetaTable("Player")

local db = kate.Data.DB

function meta:SetRank(rank, exp, exp_in)
	if exp and exp <= 0 then
		exp, exp_in = nil, nil
	end

	kate.Ranks.Set(self:SteamID64(), rank, exp, exp_in)
end

function kate.Ranks.AddExpiration(id, rank, exp, exp_in)
	local moment = os.time()

	local query = db:prepare("SELECT * FROM `kate_expirations` WHERE steamid = ? LIMIT 1")
	query:setString(1, id)

	query.onSuccess = function(_, expirations)
		if exp and (exp_in == "user" or kate.Ranks.Stored[exp_in]) then
			if #expirations > 0 then
				local query_update = db:prepare("UPDATE `kate_expirations` SET expire_time = ?, expire_rank = ?, expire_in = ? WHERE steamid = ? LIMIT 1")
				query_update:setNumber(1, moment + exp)
				query_update:setString(2, rank)
				query_update:setString(3, exp_in)
				query_update:setString(4, id)
				query_update:start()
			else
				local query_insert = db:prepare("INSERT INTO `kate_expirations` (steamid, expire_rank, expire_in, expire_time) VALUES (?, ?, ?, ?)")
				query_insert:setString(1, id)
				query_insert:setString(2, rank)
				query_insert:setString(3, exp_in)
				query_insert:setNumber(4, moment + exp)
				query_insert:start()
			end
		else
			if #expirations > 0 then
				local query_delete = db:prepare("DELETE FROM `kate_expirations` WHERE steamid = ? LIMIT 1")
				query_delete:setString(1, id)
				query_delete:start()
			end
		end
	end

	query:start()
end

function kate.Ranks.Set(id, rank, exp, exp_in)
	if not kate.IsSteamID64() then
		id = kate.SteamIDTo64(id)
	end

	local moment = os.time()
	local pl = kate.FindPlayer(id)
	local stored = kate.Ranks.Stored

	local query = db:prepare("SELECT * FROM `kate_users` WHERE steamid = ? LIMIT 1")
	query:setString(1, id)

	if exp then
		exp_in = exp_in or "user"
	end

	query.onSuccess = function(_, users)
		-- add a completely new row
		if #users <= 0 then
			if rank == "user" or not stored[rank] then
				return
			end

			local query_insert = db:prepare("INSERT INTO kate_users (name, steamid, rank, joined, seen, playtime) VALUES (?, ?, ?, ?, ?, ?)")
			query_insert:setString(1, "Unknown")
			query_insert:setString(2, id)
			query_insert:setString(3, rank)
			query_insert:setNumber(4, moment)
			query_insert:setNumber(5, moment)
			query_insert:setNumber(6, 0)
			query_insert:start()

			kate.Ranks.AddExpiration(id, rank, exp, exp_in)

			return
		end

		-- remove
		if rank == "user" then
			local query_update = db:prepare("UPDATE kate_users SET rank = ? WHERE steamid = ? LIMIT 1")
			query_update:setString(1, rank)
			query_update:setString(2, id)
			query_update:start()

			local query_delete = db:prepare("DELETE FROM kate_expirations WHERE steamid = ? LIMIT 1")
			query_delete:setString(1, id)
			query_delete:start()

			if IsValid(pl) then
				pl:SetUserGroup(rank)
			end

			return
		end

		-- add
		if stored[rank] then
			local query_update = db:prepare("UPDATE kate_users SET rank = ? WHERE steamid = ? LIMIT 1")
			query_update:setString(1, rank)
			query_update:setString(2, id)
			query_update:start()

			kate.Ranks.AddExpiration(id, rank, exp, exp_in)

			if IsValid(pl) then
				pl:SetUserGroup(rank)
			end
		end
	end

	query:start()
end