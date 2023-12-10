local meta = debug.getregistry()["Player"]

function meta:SetRank(newRank, expireTime, expireRank)
	kate.Ranks.SetRank(self:SteamID64(), newRank, expireTime, expireRank)
end