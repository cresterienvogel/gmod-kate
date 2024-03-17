local function addUser(db, targetId, newRank)
	local curTime = os.time()

	local queryInsert = db:prepare("INSERT INTO `kate_users` (name, steamid, rank, joined, seen, playtime) VALUES (?, ?, ?, ?, ?, ?)")
		queryInsert:setString(1, "Unknown")
		queryInsert:setString(2, targetId)
		queryInsert:setString(3, newRank)
		queryInsert:setNumber(4, curTime)
		queryInsert:setNumber(5, curTime)
		queryInsert:setNumber(6, 0)
	queryInsert:start()
end

local function updateUser(db, targetId, newRank)
	local foundPlayer = kate.FindPlayer(targetId)

	local queryUpdate = db:prepare("UPDATE `kate_users` SET rank = ? WHERE steamid = ? LIMIT 1")
		queryUpdate:setString(1, newRank)
		queryUpdate:setString(2, targetId)
	queryUpdate:start()

	if IsValid(foundPlayer) then
		foundPlayer:SetUserGroup(newRank)
	end
end

function kate.Ranks.SetRank(targetId, newRank, expireTime, expireRank)
	local db = kate.Data.DB
	if not db then
		return
	end

	targetId = kate.SteamIDTo64(targetId)
	if not targetId then
		return
	end

	local stored = kate.Ranks.Stored
	local storedNewRank = stored[newRank]
	local storedExpireRank = stored[expireRank]

	newRank = ((newRank and storedNewRank) and newRank) or "user"
	expireRank = ((expireRank and storedExpireRank) and expireRank) or "user"

	local querySelect = db:prepare("SELECT * FROM `kate_users` WHERE steamid = ? LIMIT 1")
	querySelect:setString(1, targetId)

	querySelect.onSuccess = function(_, data)
		if #data <= 0 then
			addUser(db, targetId, newRank)
		else
			updateUser(db, targetId, newRank)
		end

		kate.Ranks.SetExpiration(targetId, newRank, expireTime, expireRank)
	end

	querySelect:start()
end