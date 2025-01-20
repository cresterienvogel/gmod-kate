hook.Add( 'PlayerNoClip', 'Kate::HandleNoclip', function( pl, desired )
  if hook.Run( 'Kate::PlayerCanNoclip', pl, desired ) == false then
    return false
  end

  if SERVER and ( pl:GetRelevance() > 0 ) then
    return true
  end
end )