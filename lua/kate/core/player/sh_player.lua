local PLAYER = debug.getregistry()['Player']

function PLAYER:GetPlaytime()
  return ( self:GetNetVar( 'Kate_Playtime' ) or 0 ) + ( CurTime() - ( self:GetSessionStarted() or CurTime() ) )
end