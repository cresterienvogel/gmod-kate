hook.Add("PlayerNoClip", "Kate PlayerNoClip", function(pl)
	if pl:GetCloak() then
		return false
	end

	return SERVER and pl:IsModerator() or false
end)