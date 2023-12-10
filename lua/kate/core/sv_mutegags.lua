for _, tag in ipairs({"Gag", "Mute"}) do
	local tagLower = string.lower(tag)
	local tagPlural = tag .. "s"
	local tagSQL = "kate_" .. string.lower(tagPlural)

	kate[tagPlural] = kate[tagPlural] or {}

	kate[tag] = function(targetId, expireTime, blockReason, adminId)
		local db = kate.Data.DB
		if not db then
			return
		end

		targetId = kate.SteamIDTo64(targetId)
		if not targetId then
			return
		end

		local unixNow = os.time()
		expireTime = (expireTime > 0) and (unixNow + expireTime) or 0
		kate[tagPlural][targetId] = {} -- cache

		local foundPlayer = kate.FindPlayer(targetId)

		local querySelect = db:prepare(string.format("SELECT * FROM `%s` WHERE steamid = ? AND expired = ? LIMIT 1"), tagSQL)
			querySelect:setString(1, targetId)
			querySelect:setString(2, "active")

			querySelect.onSuccess = function(_, data)
				if not data[1] then
					goto newPunish
				end

				do
					local caseId = data[1].case_id

					local queryUpdate = db:prepare(string.format("UPDATE `%s` SET reason = ?, admin_steamid = ?, expire_time = ? WHERE steamid = ? AND case_id = ? LIMIT 1", tagSQL))
						queryUpdate:setString(1, blockReason)

						if adminId then
							queryUpdate:setString(2, adminId)
						else
							queryUpdate:setNull(2)
						end

						queryUpdate:setNumber(3, expireTime)
						queryUpdate:setString(4, targetId)
						queryUpdate:setNumber(5, caseId)
					queryUpdate:start()

					return
				end

				::newPunish::
				do
					local query_select = db:querySelect(string.format("SELECT COUNT(`case_id`) AS `case_id` FROM `%s`", tagSQL))

					query_select.onSuccess = function(_, cases)
						cases = cases[1].case_id or 0

						local caseId = cases + 1

						local queryInsert = db:prepare(string.format("INSERT INTO `%s` (steamid, reason, %s_time, expire_time, admin_steamid, expired, case_id) VALUES (?, ?, ?, ?, ?, ?, ?)", tagSQL, tagLower))
							queryInsert:setString(1, targetId)
							queryInsert:setString(2, blockReason)
							queryInsert:setNumber(3, unixNow)
							queryInsert:setNumber(4, expireTime)

							if adminId then
								queryInsert:setString(5, adminId)
							else
								queryInsert:setNull(5)
							end

							queryInsert:setString(6, "active")
							queryInsert:setNumber(7, caseId)
						queryInsert:start()

						kate[tagPlural][targetId].case_id = caseId
					end

					query_select:start()
				end
			end
		querySelect:start()

		if IsValid(foundPlayer) then
			foundPlayer:SetNetVar(tagLower, expireTime)
		end

		do
			kate[tagPlural][targetId].reason = blockReason
			kate[tagPlural][targetId].expire_time = expireTime
			kate[tagPlural][targetId].admin_id = adminId
			kate[tagPlural][targetId][tagLower .. "_time"] = unixNow
		end
	end

	kate["Un" .. tagLower] = function(targetId, unblockReason, adminId)
		local db = kate.Data.DB
		if not db then
			return
		end

		targetId = kate.SteamIDTo64(targetId)
		if not targetId then
			return
		end

		local foundPlayer = kate.FindPlayer(targetId)

		local querySelect = db:prepare(string.format("SELECT * FROM `%s` WHERE steamid = ? AND expired = ? LIMIT 1", tagSQL))
			querySelect:setString(1, targetId)
			querySelect:setString(2, "active")

			querySelect.onSuccess = function(_, data)
				if not data[1] then
					return
				end

				data = data[1]

				local queryUpdate = db:prepare(string.format("UPDATE `%s` SET expired = ?, admin_steamid = ?, expire_time = ? WHERE steamid = ? AND case_id = ? LIMIT 1", tagSQL))
					queryUpdate:setString(1, unblockReason or "time out")
					queryUpdate:setString(2, adminId or data.admin_steamid)
					queryUpdate:setNumber(3, os.time())
					queryUpdate:setString(4, targetId)
					queryUpdate:setNumber(5, data.case_id)
				queryUpdate:start()

				kate[tagPlural][targetId] = nil
			end
		querySelect:start()

		if IsValid(foundPlayer) then
			foundPlayer:SetNetVar(tagLower, nil)
		end
	end

	kate["Update" .. tagPlural] = function()
		local db = kate.Data.DB
		if not db then
			return
		end

		kate[tagPlural] = {}

		local querySelect = db:prepare(string.format("SELECT * FROM `%s` WHERE expired = ?", tagSQL))
			querySelect:setString(1, "active")

			querySelect.onSuccess = function(_, data)
				for _, punished in ipairs(data) do
					local id = punished.steamid
					local time = punished.expire_time

					local foundPlayer = kate.FindPlayer(kate.SteamIDFrom64(id))

					do
						kate[tagPlural][id] = {}
						kate[tagPlural][id].expire_time = time
						kate[tagPlural][id].reason = punished.reason
						kate[tagPlural][id].admin_id = punished.admin_id
						kate[tagPlural][id].case_id = punished.case_id
						kate[tagPlural][id][tagLower .. "_time"] = punished[tagLower .. "_time"]
					end

					if IsValid(foundPlayer) then
						foundPlayer:SetNetVar(tagLower, time)
					end
				end
			end
		querySelect:start()
	end

	timer.Simple(0, kate["Update" .. tagPlural])
	timer.Create("Kate Update " .. tagPlural, 180, 0, kate["Update" .. tagPlural]) -- in case the database is used on several servers at time
end

hook.Add("PlayerCanHearPlayersVoice", "Kate Gag", function(listener, talker)
	local gag = talker:GetGag()
	if not gag then
		return
	end

	if (gag ~= 0) and (os.time() > gag) then
		kate.Ungag(talker)
		kate.Print(kate.GetTarget(talker), "has been ungagged since the gag time expired")
		return
	end

	return false
end)

hook.Add("PlayerSay", "Kate Mute", function(pl)
	local mute = pl:GetMute()
	if not mute then
		return
	end

	if (mute ~= 0) and (os.time() > mute) then
		kate.Unmute(pl)
		kate.Print(kate.GetTarget(pl), "has been unmuted since the mute time expired")
		return
	end

	return ""
end)