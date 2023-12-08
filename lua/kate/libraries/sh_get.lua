function kate.GetAdmins()
	local tbl = {}

	for _, pl in ipairs(player.GetAll()) do
		if pl:IsModerator() then
			tbl[#tbl + 1] = pl
		end
	end

	return tbl
end

function kate.GetExecuter(pl)
	return IsValid(pl) and (pl:Name() .. " (" .. pl:SteamID() .. ")") or "Console"
end

function kate.GetTarget(target)
	if IsValid(target) then
		return target:Name() .. " (" .. target:SteamID() .. ")"
	end

	local pl = kate.FindPlayer(target)

	if IsValid(pl) then
		return pl:Name() .. " (" .. pl:SteamID() .. ")"
	end

	local id = kate.SteamIDFrom64(target)

	if id then
		return id
	end

	return "Unknown"
end