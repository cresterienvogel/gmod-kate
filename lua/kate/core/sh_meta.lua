local meta = FindMetaTable("Player")

function meta:IsMuted()
	return tobool(self:GetKateVar("Mute"))
end

function meta:IsGagged()
	return tobool(self:GetKateVar("Gag"))
end