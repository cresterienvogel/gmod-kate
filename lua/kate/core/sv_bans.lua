kate.Bans = kate.Bans or {}

function kate.Ban(targetId, unbanTime, banReason, adminName, adminId)
	local db = kate.Data.DB
	if not db then
		return
	end

	targetId = kate.SteamIDTo64(targetId)
	if not targetId then
		return
	end

	adminName = adminName or "Console"

	local curTime = os.time()
	unbanTime = (unbanTime > 0) and (curTime + unbanTime) or 0
	kate.Bans[targetId] = {} -- cache

	do
		local querySelect = db:prepare("SELECT * FROM `kate_bans` WHERE steamid = ? AND expired = ? LIMIT 1")
			querySelect:setString(1, targetId)
			querySelect:setString(2, "active")

			querySelect.onSuccess = function(_, data)
				if not data[1] then
					goto newBan
				end

				do
					local queryUpdate = db:prepare("UPDATE `kate_bans` SET admin_name = ?, admin_steamid = ?, unban_time = ?, reason = ? WHERE steamid = ? AND expired = ? AND case_id = ? LIMIT 1")
						queryUpdate:setString(1, adminName)

						if adminId then
							queryUpdate:setString(2, adminId)
						else
							queryUpdate:setNull(2)
						end

						queryUpdate:setNumber(3, unbanTime)
						queryUpdate:setString(4, banReason)
						queryUpdate:setString(5, targetId)
						queryUpdate:setString(6, "active")
						queryUpdate:setNumber(7, data[1].case_id)
					queryUpdate:start()

					return
				end

				::newBan::
				do
					local queryCase = db:query("SELECT COUNT(`case_id`) AS `case_id` FROM `kate_bans`")

					queryCase.onSuccess = function(_, cases)
						local newCase = (cases[1].case_id or 0) + 1

						local queryInsert = db:prepare("INSERT INTO `kate_bans` (admin_name, admin_steamid, steamid, ban_time, unban_time, reason, expired, case_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)")
							queryInsert:setString(1, adminName)

							if adminId then
								queryInsert:setString(2, adminId)
							else
								queryInsert:setNull(2)
							end

							queryInsert:setString(3, targetId)
							queryInsert:setNumber(4, curTime)
							queryInsert:setNumber(5, unbanTime)
							queryInsert:setString(6, banReason)
							queryInsert:setString(7, "active")
							queryInsert:setNumber(8, newCase)
						queryInsert:start()

						if kate.Bans[targetId] then
							kate.Bans[targetId].case_id = newCase
						end
					end

					queryCase:start()
				end
			end
		querySelect:start()
	end

	game.KickID(kate.SteamIDFrom64(targetId), banReason)

	do
		kate.Bans[targetId].admin_name = adminName
		kate.Bans[targetId].admin_steamid = adminId
		kate.Bans[targetId].ban_time = curTime
		kate.Bans[targetId].unban_time = unbanTime
		kate.Bans[targetId].reason = banReason
	end
end

function kate.Unban(targetId, unbanReason, adminName, adminId)
	local db = kate.Data.DB
	if not db then
		return
	end

	targetId = kate.SteamIDTo64(targetId)
	if not targetId then
		return
	end

	local querySelect = db:prepare("SELECT * FROM `kate_bans` WHERE steamid = ? AND expired = ? LIMIT 1")
		querySelect:setString(1, targetId)
		querySelect:setString(2, "active")

		querySelect.onSuccess = function(_, data)
			if not data[1] then
				return
			end

			data = data[1]

			local queryUpdate = db:prepare("UPDATE `kate_bans` SET expired = ?, admin_name = ?, admin_steamid = ?, unban_time = ? WHERE steamid = ? AND case_id = ? LIMIT 1")
				queryUpdate:setString(1, unbanReason or "time out")
				queryUpdate:setString(2, adminName or data.admin_name)
				queryUpdate:setString(3, adminId or data.admin_steamid)
				queryUpdate:setNumber(4, os.time())
				queryUpdate:setString(5, targetId)
				queryUpdate:setNumber(6, data.case_id)
			queryUpdate:start()

			kate.Bans[targetId] = nil
		end
	querySelect:start()
end

function kate.UpdateBans()
	local db = kate.Data.DB
	if not db then
		return
	end

	kate.Bans = {}

	local querySelect = db:prepare("SELECT * FROM `kate_bans` WHERE expired = ?")
	querySelect:setString(1, "active")

	querySelect.onSuccess = function(_, data)
		for _, banned in ipairs(data) do
			local id = banned.steamid
			local reason = banned.reason

			do
				kate.Bans[id] = {}
				kate.Bans[id].reason = reason
				kate.Bans[id].admin_name = banned.admin_name
				kate.Bans[id].admin_steamid = banned.admin_steamid
				kate.Bans[id].ban_time = banned.ban_time
				kate.Bans[id].unban_time = banned.unban_time
				kate.Bans[id].case_id = banned.case_id
			end

			game.KickID(kate.SteamIDFrom64(id), reason)
		end
	end

	querySelect:start()
end

hook.Add("CheckPassword", "Kate CheckPassword", function(id)
	local cached = kate.Bans[id]
	if not cached then
		return
	end

	local curTime = os.time()

	local banReason = cached.reason
	local unbanTime = cached.unban_time
	local adminName = cached.admin_name
	local adminId = cached.admin_steamid
	local caseId = cached.case_id

	-- if player got banned when he's the only player on the server
	-- the case_id field won't be cached at time due hibernation
	-- sv_hibernate_think 1 can do the trick if you care
	if not caseId then
		return false, "Sorry, but we can't identify your ban details.\nTry join later.\n\n" .. [[¯\_(ツ)_/¯]]
	end

	if (unbanTime ~= 0) and (curTime > unbanTime) then
		kate.Unban(id)
		return
	end

	if unbanTime > 0 then
		local timeLast = unbanTime - curTime

		return false, string.format("You are banned by %s (%s).\nShame on you.\n\nReason: %s\nRemaining: %s\nCase ID: %s",
			adminName,
			adminId,
			banReason,
			timeLast <= 0 and "you should be unbanned right now" or kate.ConvertTime(timeLast),
			caseId
		)
	end

	return false, string.format("You are permabanned.\nShame on you.\n\nReason: %s\nRemaining: ∞\nCase ID: %s",
		banReason,
		caseId
	)
end)

timer.Simple(0, kate.UpdateBans)
timer.Create("Kate Update Bans", 180, 0, kate.UpdateBans) -- in case the database is used on several servers at time