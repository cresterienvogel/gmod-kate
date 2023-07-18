hook.Add("PlayerNoClip", "Kate PlayerNoClip", function(pl)
	return SERVER and pl:IsModerator() or false
end)