timer.Create( 'Kate::CheckExpirations', 120, 0, function()
  for _, pl in player.Iterator() do
    local steamId64 = pl:SteamID64()
    local expireTime = pl:GetNetVar( 'Kate_ExpireUserGroupTime' )
    local expireGroup = pl:GetNetVar( 'Kate_ExpireUserGroup' )

    if ( expireTime ~= nil ) and ( expireTime ~= 0 ) and ( os.time() > expireTime ) then
      kate.SetUserGroup( steamId64, expireGroup or 'user' )
      kate.UserGroups.Cache[steamId64] = nil
    end
  end
end )