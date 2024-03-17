local meta = debug.getregistry()["Player"]

hook.Add("PostGamemodeLoaded", "Kate CAMI", function()
	for rank, info in pairs(kate.Ranks.Stored) do
		CAMI.RegisterUsergroup({
			Name = rank,
			Inherits = info:GetImmunity() >= 25000 and "superadmin" or "admin"
		}, "Kate")
	end
end)

hook.Add("CAMI.OnUsergroupRegistered", "Kate CAMI", function(group, source)
	local name = group.Name
	if (source and source == "Kate") or kate.Ranks.Stored[name] then
		return
	end

	local rank = kate.Ranks.Register(name)
	if rank == nil then
		return
	end

	rank:SetImmunity(5000)
	kate.Ranks.RegisterMeta(name)
end)

hook.Add("CAMI.OnUsergroupUnregistered", "Kate CAMI", function(group, source)
	local name = group.Name
	if (source and source == "Kate") or (not kate.Ranks.Stored[name]) then
		return
	end

	kate.Ranks.Stored[name] = nil
	meta["Is" .. name] = nil
end)

hook.Add("CAMI.PlayerUsergroupChanged", "Kate CAMI", function(pl, old, new, source)
	if (source and source == "Kate") or (not IsValid(pl)) then
		return
	end

	if SERVER then
		pl:SetUserGroup(new)
	end
end)

hook.Add("CAMI.PlayerHasAccess", "Kate CAMI", function(pl, privilege, callback, extra)
	local bool, reason = false, "Not enough info"

	if not IsValid(pl) then
		reason = "Player not found"
		goto done
	end

	if extra and extra.target then
		if not IsValid(target) then
			reason = "Target not found"
			goto done
		end

		if pl:GetImmunity() < target:GetImmunity() then
			reason = "Target's immunity is higher"
			goto done
		end

		bool, reason = true, "Everything is ok"
		goto done
	end

	if privilege then
		-- check founder
		if privilege == "superadmin" then
			if pl:IsFounder() then
				bool, reason = true, "Everything is ok"
				goto done
			end

			reason = "User is not a Founder"
			goto done
		end

		-- check admin
		if privilege == "admin" then
			if pl:IsAdmin() then
				bool, reason = true, "Everything is ok"
				goto done
			end

			reason = "User is not an Admin"
			goto done
		end

		-- check other
		do
			local stored = kate.Ranks.Stored[privilege]
			if not stored then
				reason = "Rank not found"
				goto done
			end

			if pl:GetImmunity() >= stored:GetImmunity() then
				bool, reason = true, "Everything is ok"
				goto done
			end
		end
	end

	::done::
	if callback then
		callback(bool, reason)
	end

	return bool, reason
end)