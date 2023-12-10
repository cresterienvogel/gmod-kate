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
	return IsValid(pl) and string.format("%s (%s)", pl:Name(), pl:SteamID()) or "Console"
end

function kate.GetTarget(target)
	if IsValid(target) then
		return string.format("%s (%s)", target:Name(), target:SteamID())
	end

	local foundTarget = kate.FindPlayer(target)
	if IsValid(foundTarget) then
		return string.format("%s (%s)", foundTarget:Name(), foundTarget:SteamID())
	end

	local id = kate.SteamIDFrom64(target)
	if id then
		return id
	end

	return "Unknown"
end