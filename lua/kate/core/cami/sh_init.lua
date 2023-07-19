hook.Add("PostGamemodeLoaded", "Kate CAMI", function()
	for rank, data in pairs(kate.Ranks.Stored) do
		CAMI.RegisterUsergroup({
			Name = rank,
			Inherits = data:GetImmunity() >= 25000 and "superadmin" or "admin"
		}, "Kate")
	end
end)

hook.Add("CAMI.OnUsergroupRegistered", "Kate CAMI", function(group, source)
	local name = group.Name
	if (source and source == "Kate") or kate.Ranks.Stored[name] then
		return
	end

	kate.Ranks.Register(name)
		:SetImmunity(5000)

	kate.Ranks.RegisterMeta(name)
end)

hook.Add("CAMI.OnUsergroupUnregistered", "Kate CAMI", function(group, source)
	local name = group.Name
	if (source and source == "Kate") or not kate.Ranks.Stored[name] then
		return
	end

	kate.Ranks.Stored[name] = nil
	FindMetaTable("Player")["Is" .. name] = nil
end)

hook.Add("CAMI.PlayerUsergroupChanged", "Kate CAMI", function(pl, old, new, source)
	if (source and source == "Kate") or not IsValid(pl) then
		return
	end

	if SERVER then
		pl:SetUserGroup(new)
	end
end)

hook.Add("CAMI.PlayerHasAccess", "Kate CAMI", function(pl, privilege, callback, target)
	if not IsValid(pl) or not IsValid(target) then
		return
	end

	if pl:GetImmunity() > target:GetImmunity() then
		return true
	end
end)