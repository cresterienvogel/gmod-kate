local meta = debug.getregistry()["Player"]

function meta:GetImmunity()
	local storedRank = kate.Ranks.Stored[self:GetUserGroup()]
	if not storedRank then
		return 0
	end

	return storedRank:GetImmunity()
end

function meta:GetTitle()
	local userGroup = self:GetUserGroup()

	local storedRank = kate.Ranks.Stored[userGroup]
	if not storedRank then
		return userGroup
	end

	return storedRank:GetTitle()
end

function meta:GetRank() -- comfy
	return self:GetUserGroup()
end