hook.Add("PlayerNoClip", "Kate PlayerNoClip", function(pl)
	return SERVER and pl:IsAdmin() or false
end)