kate.Commands.Validators = {
	["Target"] = function(pl, cmd, index, value, args)
		local info = kate.SteamIDTo64(value)
		local target = kate.FindPlayer(info)
		local stored = kate.Commands.Stored[cmd]

		if not info then
			return false, "Invalid target"
		end

		if (not stored:GetSelfRun()) and IsValid(target) and (target == pl) then
			return false, "You can't use " .. stored:GetTitle() .. " on yourself"
		end

		if (stored:GetOnlineTarget() == true) and (not IsValid(target)) then
			return false, "Target is offline"
		end

		return target or info
	end,
	["Rank"] = function(pl, cmd, index, value, args)
		local rank_stored = kate.Ranks.Stored[value]
		local cmd_stored = kate.Commands.Stored[cmd]

		if not rank_stored then
			return false, "Invalid rank"
		end

		local target_index = table.KeyFromValue(cmd_stored:GetArgs(), "Target")
		local target = kate.FindPlayer(args[target_index])

		if not IsValid(pl) then
			goto success
		end

		if pl:GetImmunity() <= rank_stored:GetImmunity() then
			return false, "Rank's immunity is higher or equal to yours"
		end

		if not IsValid(target) then
			goto check
		end

		if pl:GetImmunity() <= target:GetImmunity() then
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
		local expire_rank_stored = kate.Ranks.Stored[value]
		local cmd_stored = kate.Commands.Stored[cmd]

		if not expire_rank_stored then
			return false, "Invalid expire rank"
		end

		if not IsValid(pl) then
			goto issued
		end

		if pl:GetImmunity() <= expire_rank_stored:GetImmunity() then
			return false, "Expire rank's immunity is higher or equal to yours"
		end

		::issued::
		do
			local issued_rank_index = table.KeyFromValue(cmd_stored:GetArgs(), "Rank")
			local issued_rank_name = args[issued_rank_index]
			local issued_rank_stored = kate.Ranks.Stored[issued_rank_name]

			if issued_rank_stored:GetImmunity() <= expire_rank_stored:GetImmunity() then
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
		local stored = kate.Commands.Stored[cmd]

		if table.HasValue(stored:GetArgs(), "Rank") and valid and (time < 300) then
			return false, "Expiration time shouln't be less than 5 minutes"
		end

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
		local ammo_id = tonumber(value)
		local ammo_types = game.GetAmmoTypes()

		if not ammo_id then
			for id, ammotype in ipairs(ammo_types) do
				if string.find(ammotype, value) then
					return id
				end
			end

			return false, "Invalid ammotype"
		end

		if ammo_types[ammo_id] then
			return ammo_id
		end

		return false, "Invalid ammotype"
	end
}