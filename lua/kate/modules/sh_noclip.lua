hook.Add( 'PlayerNoClip', 'Kate_HandleNoclip', function( pl )
  if hook.Run( 'Kate_PlayerCanNoclip', pl ) == false then
    return false
  end

  return SERVER and ( pl:GetRelevance() > 0 ) or false
end )