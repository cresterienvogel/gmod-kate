timer.Create( 'Kate_CheckExpirations', 120, 0, function()
  for _, pl in ipairs( player.GetHumans() ) do
    local steamId64 = pl:SteamID64()

    local expireTime = pl:GetExpireTime()
    local expireGroup = pl:GetExpireUserGroup()

    if ( expireTime ~= nil ) and ( expireTime ~= 0 ) and ( os.time() > expireTime ) then
      kate.SetUserGroup( steamId64, expireGroup or 'user' )
      kate.UserGroups.Cache[steamId64] = nil
    end
  end
end )