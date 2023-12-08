local meta = debug.getregistry()["Player"]

function meta:GetImmunity()
	local data = kate.Ranks.Stored[self:GetUserGroup()]

	if not data then
		return 0
	end

	return data:GetImmunity()
end

function meta:GetTitle()
	local data = kate.Ranks.Stored[self:GetUserGroup()]

	if not data then
		return "User"
	end

	return data:GetTitle()
end

function meta:GetRank() -- comfy
	return self:GetUserGroup()
end