kate.Commands.Validators = {
	["Target"] = function(pl, cmd, index, value, args)
		local info = kate.SteamIDTo64(value)
		local targetEntity = kate.FindPlayer(info)
		local storedCommand = kate.Commands.Stored[cmd]

		if not info then
			return false, "Invalid target"
		end

		if (not storedCommand:GetSelfRun()) and IsValid(targetEntity) and (targetEntity == pl) then
			return false, "You can't use " .. storedCommand:GetTitle() .. " on yourself"
		end

		if (storedCommand:GetOnlineTarget() == true) and (not IsValid(targetEntity)) then
			return false, "Target is offline"
		end

		return targetEntity or info
	end,
	["Rank"] = function(pl, cmd, index, value, args)
		local storedRank = kate.Ranks.Stored[value]
		local storedCommand = kate.Commands.Stored[cmd]

		if not storedRank then
			return false, "Invalid rank"
		end

		local targetArgId = table.KeyFromValue(storedCommand:GetArgs(), "Target")
		local targetEntity = kate.FindPlayer(args[targetArgId])

		if not IsValid(pl) then
			goto success
		end

		if pl:GetImmunity() <= storedRank:GetImmunity() then
			return false, "Rank's immunity is higher or equal to yours"
		end

		if not IsValid(targetEntity) then
			goto check
		end

		if pl:GetImmunity() <= targetEntity:GetImmunity() then
			return false, "Targets's immunity is higher or equal to yours"
		end

		::check::
		if not (pl:IsFounder() or pl:IsSupervisor()) then
			return false, "You can't set rank to offline players"
		end

		::success::
		return value
	end,
	["Expire Rank"] = function(pl, cmd, index, value, args)
		local storedExpireRank = kate.Ranks.Stored[value]
		local storedCommand = kate.Commands.Stored[cmd]

		if not storedExpireRank then
			return false, "Invalid expire rank"
		end

		if not IsValid(pl) then
			goto issued
		end

		if pl:GetImmunity() <= storedExpireRank:GetImmunity() then
			return false, "Expire rank's immunity is higher or equal to yours"
		end

		::issued::
		do
			local issuedRankId = table.KeyFromValue(storedCommand:GetArgs(), "Rank")
			local issuedRankName = args[issuedRankId]
			local issuedRankStored = kate.Ranks.Stored[issuedRankName]

			if issuedRankStored:GetImmunity() <= storedExpireRank:GetImmunity() then
				return false, "Currently issued rank's immunity is higher or equal to expire's rank"
			end
		end

		return value
	end,
	["Weapon"] = function(pl, cmd, index, value, args)
		if not weapons.Get(value) then
			return false, "Invalid classname"
		end

		return value
	end,
	["Amount"] = function(pl, cmd, index, value, args)
		local info = tonumber(value)
		if info then
			return info
		end

		return false, "Invalid amount"
	end,
	["Unsigned Amount"] = function(pl, cmd, index, value, args)
		local info = tonumber(value)
		if info and (info > 0) then
			return info
		end

		return false, "Invalid amount"
	end,
	["Time"] = function(pl, cmd, index, value, args)
		local valid, time = kate.FormatTime(value)
		if valid then
			return time
		end

		return false, "Specify a time unit like \"30s\", \"30mi\", \"12h\", \"1d\", \"1mo\" and etc"
	end,
	["Model"] = function(pl, cmd, index, value, args)
		if not util.IsValidModel(value) then
			return false, "Model not found or not precached"
		end

		return value
	end,
	["Map"] = function(pl, cmd, index, value, args)
		local maps = file.Find("maps/*", "GAME")

		for _, bsp in ipairs(maps) do
			if value == string.StripExtension(bsp) then
				return value
			end
		end

		return false, "Map not found"
	end,
	["AmmoType"] = function(pl, cmd, index, value, args)
		local ammoId = tonumber(value)
		local ammoTypes = game.GetAmmoTypes()

		if not ammoId then
			for id, ammoType in ipairs(ammoTypes) do
				if string.find(ammoType, value) then
					return id
				end
			end

			return false, "Invalid ammotype"
		end

		if ammoTypes[ammoId] then
			return ammoId
		end

		return false, "Invalid ammotype"
	end
}