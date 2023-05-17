function kate.IsSteamID(id)
	if not isstring(id) then
		return false
	end

	return tobool(id:match("^STEAM_[0-5]:[0-1]:[0-9]+$"))
end

function kate.IsSteamID64(id)
	if not isstring(id) then
		return false
	end

	return tobool(id:sub(1, 7) == "7656119" and (#id == 17 or #id == 18))
end

function kate.SteamIDTo64(id)
	local pl = kate.FindPlayer(id)
	if IsValid(pl or id) and (pl or id):IsPlayer() then
		return (pl or id):SteamID64()
	end

	if kate.IsSteamID64(id) then
		return id
	end

	if kate.IsSteamID(id) then
		return util.SteamIDTo64(id)
	end

	return nil
end

function kate.SteamIDFrom64(id)
	local pl = kate.FindPlayer(id)
	if IsValid(pl or id) and (pl or id):IsPlayer() then
		return (pl or id):SteamID()
	end

	if kate.IsSteamID(id) then
		return id
	end

	if kate.IsSteamID64(id) then
		return util.SteamIDFrom64(id)
	end

	return nil
end