local content_blacklist = {
	[CONTENTS_SOLID] = true,
	[CONTENTS_MOVEABLE] = true,
	[CONTENTS_LADDER] = true,
	[CONTENTS_PLAYERCLIP] = true,
	[CONTENTS_MONSTERCLIP] = true
}

function kate.IsPosEmpty(vector, ignore)
	ignore = ignore or {}

	local point, a = util.PointContents(vector), not content_blacklist[point]
	if not a then
		return false
	end

	local b = true
	for _, pl in ipairs(ents.FindInSphere(vector, 35)) do
		if (pl:IsNPC() or pl:IsPlayer() or pl:GetClass() == "prop_physics" or pl.NotEmptyPos) and not table.HasValue(ignore, pl) then
			b = false
			break
		end
	end

	return a and b
end

function kate.FindEmptyPos(pos, ignore, distance, step, area)
	if kate.IsPosEmpty(pos, ignore) and kate.IsPosEmpty(pos + area, ignore) then
		return pos
	end

	for j = step, distance, step do
		for i = -1, 1, 2 do
			local k = j * i

			if kate.IsPosEmpty(pos + Vector(k, 0, 0), ignore) and kate.IsPosEmpty(pos + Vector(k, 0, 0) + area, ignore) then
				return pos + Vector(k, 0, 0)
			end

			if kate.IsPosEmpty(pos + Vector(0, k, 0), ignore) and kate.IsPosEmpty(pos + Vector(0, k, 0) + area, ignore) then
				return pos + Vector(0, k, 0)
			end

			if kate.IsPosEmpty(pos + Vector(0, 0, k), ignore) and kate.IsPosEmpty(pos + Vector(0, 0, k) + area, ignore) then
				return pos + Vector(0, 0, k)
			end
		end
	end

	return pos
end