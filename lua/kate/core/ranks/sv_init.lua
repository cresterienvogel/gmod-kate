local meta = debug.getregistry()["Player"]

function meta:SetRank(rank, exp, exp_in)
	exp = (exp and exp > 300) and exp or nil
	exp_in = exp_in or "user"

	kate.Ranks.Set(self:SteamID64(), rank, exp, exp_in)
end

function kate.Ranks.AddExpiration(id, rank, exp, exp_in)
	local db = kate.Data.DB

	if not db then
		return
	end

	local now = os.time()

	exp = (exp and exp > 300) and exp or nil
	exp_in = exp_in or "user"

	local query = db:prepare("SELECT * FROM `kate_expirations` WHERE steamid = ? LIMIT 1")
	query:setString(1, id)

	query.onSuccess = function(_, data)
		if (not exp) then
			goto delete_expiration
		end

		if #data > 0 then
			goto update_expiration
		end

		do
			local query_insert = db:prepare("INSERT INTO `kate_expirations` (steamid, expire_rank, expire_in, expire_time) VALUES (?, ?, ?, ?)")
			query_insert:setString(1, id)
			query_insert:setString(2, rank)
			query_insert:setString(3, exp_in)
			query_insert:setNumber(4, now + exp)
			query_insert:start()

			return
		end

		::update_expiration::
		do
			local query_update = db:prepare("UPDATE `kate_expirations` SET expire_time = ?, expire_rank = ?, expire_in = ? WHERE steamid = ? LIMIT 1")
			query_update:setNumber(1, now + exp)
			query_update:setString(2, rank)
			query_update:setString(3, exp_in)
			query_update:setString(4, id)
			query_update:start()

			return
		end


		::delete_expiration::
		do
			local query_delete = db:prepare("DELETE FROM `kate_expirations` WHERE steamid = ? LIMIT 1")
			query_delete:setString(1, id)
			query_delete:start()
		end
	end

	query:start()
end

function kate.Ranks.Set(id, rank, exp, exp_in)
	local db = kate.Data.DB

	if not db then
		return
	end

	local stored = kate.Ranks.Stored

	if not stored[rank] then
		return
	end

	if not kate.IsSteamID64(id) then
		id = kate.SteamIDTo64(id)
	end

	local now = os.time()
	local pl = kate.FindPlayer(id)

	local query = db:prepare("SELECT * FROM `kate_users` WHERE steamid = ? LIMIT 1")
	query:setString(1, id)

	query.onSuccess = function(_, data)
		if #data <= 0 then
			goto insert_user
		end

		do
			local query_update = db:prepare("UPDATE `kate_users` SET rank = ? WHERE steamid = ? LIMIT 1")
			query_update:setString(1, rank)
			query_update:setString(2, id)
			query_update:start()

			if rank == "user" then
				goto delete_expiration
			end

			kate.Ranks.AddExpiration(id, rank, exp, exp_in)

			goto set_rank
		end

		::delete_expiration::
		do
			local query_delete = db:prepare("DELETE FROM `kate_expirations` WHERE steamid = ? LIMIT 1")
			query_delete:setString(1, id)
			query_delete:start()

			goto set_rank
		end

		::insert_user::
		do
			local query_insert = db:prepare("INSERT INTO `kate_users` (name, steamid, rank, joined, seen, playtime) VALUES (?, ?, ?, ?, ?, ?)")
			query_insert:setString(1, "Unknown")
			query_insert:setString(2, id)
			query_insert:setString(3, rank)
			query_insert:setNumber(4, now)
			query_insert:setNumber(5, now)
			query_insert:setNumber(6, 0)
			query_insert:start()

			kate.Ranks.AddExpiration(id, rank, exp, exp_in)

			return
		end

		::set_rank::
		if IsValid(pl) then
			pl:SetUserGroup(rank)
		end
	end

	query:start()
end