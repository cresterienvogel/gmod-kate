local meta = FindMetaTable("Player")

function meta:GetImmunity()
	local data = kate.Ranks.Stored[self:GetUserGroup()]
	if not data then
		return 0
	end

	return data.Immunity
end

function meta:GetTitle()
	local data = kate.Ranks.Stored[self:GetUserGroup()]
	if not data then
		return "User"
	end

	return data.Title
end

function meta:GetRank() -- comfy
	return self:GetUserGroup()
end