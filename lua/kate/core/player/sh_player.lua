local PLAYER = FindMetaTable( 'Player' )

function PLAYER:GetPlaytime()
  return ( self:GetNetVar( 'Kate_Playtime' ) or 0 ) + ( CurTime() - ( self:GetNetVar( 'Kate_SessionStarted' ) or CurTime() ) )
end