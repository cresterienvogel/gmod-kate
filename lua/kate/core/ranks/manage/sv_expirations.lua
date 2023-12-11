local function removeExpiration(db, targetId)
	local queryDelete = db:prepare("DELETE FROM `kate_expirations` WHERE steamid = ? LIMIT 1")
		queryDelete:setString(1, targetId)
	queryDelete:start()

	timer.Remove(string.format("Kate Expiration [%s]", targetId))
end

local function checkExpiration(db, targetId)
	local stored = kate.Ranks.Stored
	local foundPlayer = kate.FindPlayer(targetId)

	local querySelect = db:prepare("SELECT * FROM `kate_expirations` WHERE steamid = ?")
		querySelect:setString(1, targetId)

		querySelect.onSuccess = function(_, data)
			if #data <= 0 then
				return
			end

			data = data[1]

			local expireTime = data.expire_time
			local expireRank = data.expire_rank

			if os.time() < expireTime then
				return
			end

			removeExpiration(db, targetId)

			if IsValid(foundPlayer) then
				foundPlayer:SetCloak(false)
				foundPlayer:Spawn()

				do
					local msg = "%s has got his %s rank expired"

					if expireRank ~= "user" then
						msg = msg .. " in %s"
					end

					msg = string.format(msg,
						foundPlayer:Name(),
						stored[foundPlayer:GetRank()]:GetTitle(),
						stored[expireRank]:GetTitle()
					)

					kate.Print(3, msg)
					kate.Message(player.GetAll(), 3, msg)
				end
			end

			kate.Ranks.SetRank(targetId, expireRank)
		end
	querySelect:start()
end

local function addExpiration(db, targetId, tempRank, expireTime, expireRank)
	local queryInsert = db:prepare("INSERT INTO `kate_expirations` (steamid, temp_rank, expire_rank, expire_time) VALUES (?, ?, ?, ?)")
		queryInsert:setString(1, targetId)
		queryInsert:setString(2, tempRank)
		queryInsert:setString(3, expireRank)
		queryInsert:setNumber(4, os.time() + expireTime)
	queryInsert:start()

	timer.Create(string.format("Kate Expiration [%s]", targetId), expireTime + 10, 1, function()
		checkExpiration(db, targetId)
	end)
end

local function updateExpiration(db, targetId, tempRank, expireTime, expireRank)
	local queryUpdate = db:prepare("UPDATE `kate_expirations` SET expire_time = ?, temp_rank = ?, expire_rank = ? WHERE steamid = ? LIMIT 1")
		queryUpdate:setNumber(1, os.time() + expireTime)
		queryUpdate:setString(2, tempRank)
		queryUpdate:setString(3, expireRank)
		queryUpdate:setString(4, targetId)
	queryUpdate:start()

	timer.Create(string.format("Kate Expiration [%s]", targetId), expireTime + 10, 1, function()
		checkExpiration(db, targetId)
	end)
end

function kate.Ranks.SetExpiration(targetId, tempRank, expireTime, expireRank)
	local db = kate.Data.DB
	if not db then
		return
	end

	local storedExpireRank = kate.Ranks.Stored[expireRank]

	local querySelect = db:prepare("SELECT * FROM `kate_expirations` WHERE steamid = ?")
		querySelect:setString(1, targetId)

		querySelect.onSuccess = function(_, data)
			if not storedExpireRank then
				removeExpiration(db, targetId)
				return
			end

			if (storedExpireRank:GetImmunity() <= 0) and ((#data >= 0) and (not expireTime)) then
				removeExpiration(db, targetId)
				return
			end

			if #data <= 0 then
				addExpiration(db, targetId, tempRank, expireTime, expireRank)
				return
			end

			updateExpiration(db, targetId, tempRank, expireTime, expireRank)
		end
	querySelect:start()
end

function kate.Ranks.CheckExpirations(targetId)
	local db = kate.Data.DB
	if not db then
		return
	end

	if not targetId then
		goto checkEveryone
	end

	checkExpiration(db, targetId)

	::checkEveryone::
	for _, pl in ipairs(player.GetHumans()) do
		checkExpiration(db, pl:SteamID64())
	end
end