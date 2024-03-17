kate.Commands.Validators = kate.Commands.Validators or {}

local meta = {}
meta.__index = meta

do
	function meta:GetArg()
		return self.Arg
	end

	function meta:SetFunction(func)
		self.Function = func
	end

	function meta:Validate(...)
		return self.Function(unpack({...}))
	end
end

function kate.Commands:CreateValidator(arg)
	local validator = {
		Arg = arg,
		Function = function() end
	}

	setmetatable(validator, meta)
	kate.Commands.Validators[arg] = validator

	return validator
end

do
	kate.Commands:CreateValidator("Target")
		:SetFunction(function(pl, cmd, index, value, args)
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
		end)

	kate.Commands:CreateValidator("Rank")
		:SetFunction(function(pl, cmd, index, value, args)
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
				return false, "Immunity of rank greater than or equal to yours"
			end

			if not IsValid(targetEntity) then
				goto check
			end

			if pl:GetImmunity() <= targetEntity:GetImmunity() then
				return false, "Targets's immunity is greater or equal to yours"
			end

			::check::
			if not (pl:IsFounder() or pl:IsSupervisor()) then
				return false, "You can't set the rank for offline players"
			end

			::success::
			return value
		end)

	kate.Commands:CreateValidator("Expire Rank")
		:SetFunction(function(pl, cmd, index, value, args)
			local storedExpireRank = kate.Ranks.Stored[value]
			local storedCommand = kate.Commands.Stored[cmd]

			if not storedExpireRank then
				return false, "Invalid expire rank"
			end

			if not IsValid(pl) then
				goto issued
			end

			if pl:GetImmunity() <= storedExpireRank:GetImmunity() then
				return false, "Immunity of expire rank is greater than or equal to yours"
			end

			::issued::
			do
				local issuedRankId = table.KeyFromValue(storedCommand:GetArgs(), "Rank")
				local issuedRankName = args[issuedRankId]
				local issuedRankStored = kate.Ranks.Stored[issuedRankName]

				if issuedRankStored:GetImmunity() <= storedExpireRank:GetImmunity() then
					return false, "The immunity of the issued rank is greater than or equal to the immunity of the expiration rank"
				end
			end

			return value
		end)

	kate.Commands:CreateValidator("Weapon")
		:SetFunction(function(pl, cmd, index, value, args)
			if not weapons.Get(value) then
				return false, "Invalid classname"
			end

			return value
		end)

	kate.Commands:CreateValidator("Amount")
		:SetFunction(function(pl, cmd, index, value, args)
			local info = tonumber(value)
			if info then
				return info
			end

			return false, "Invalid amount"
		end)

	kate.Commands:CreateValidator("Unsigned Amount")
		:SetFunction(function(pl, cmd, index, value, args)
			local info = tonumber(value)
			if info and (info > 0) then
				return info
			end

			return false, "Invalid amount"
		end)

	kate.Commands:CreateValidator("Time")
		:SetFunction(function(pl, cmd, index, value, args)
			local valid, time = kate.FormatTime(value)
			if valid then
				return time
			end

			return false, "Specify a time unit like \"30s\", \"30mi\", \"12h\", \"1d\", \"1mo\" and etc"
		end)

	kate.Commands:CreateValidator("Model")
		:SetFunction(function(pl, cmd, index, value, args)
			if not util.IsValidModel(value) then
				return false, "Model not found or not precached"
			end

			return value
		end)

	kate.Commands:CreateValidator("Map")
		:SetFunction(function(pl, cmd, index, value, args)
			local maps = file.Find("maps/*", "GAME")
			for _, bsp in ipairs(maps) do
				if value == string.StripExtension(bsp) then
					return value
				end
			end

			return false, "Map not found"
		end)

	kate.Commands:CreateValidator("AmmoType")
		:SetFunction(function(pl, cmd, index, value, args)
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
		end)
end