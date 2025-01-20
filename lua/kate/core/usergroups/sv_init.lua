function kate.SetUserGroup( steamId64, givenGroup, expireTime, expireGroup, giverSteamId64 )
  if not kate.IsSteamID64( steamId64 ) then
    return
  end

  if ( givenGroup ~= 'user' ) and ( kate.UserGroups.Stored[givenGroup] == nil ) then
    return
  end

  if ( expireTime ~= nil ) and ( expireTime ~= 0 ) and ( os.time() > expireTime ) then
    return
  end

  if ( expireGroup ~= nil ) and ( kate.UserGroups.Stored[expireGroup] == nil ) then
    return
  end

  local adminSteamId64 = 'Console'
  if ( giverSteamId64 ~= nil ) and kate.IsSteamID64( giverSteamId64 ) then
    adminSteamId64 = giverSteamId64
  end

  kate.DB:Query( string.format( 'DELETE FROM kate_usergroups WHERE SteamID64 = %q;', steamId64 ) )
    :SetOnSuccess( function()
      if givenGroup == 'user' then
        kate.UserGroups.Cache[steamId64] = nil

        local target = kate.FindPlayer( steamId64 )
        if not IsValid( target ) then
          return
        end

        target:SetUserGroup( 'user' )

        target:SetNetVar( 'Kate_ExpireUserGroup', nil )
        target:SetNetVar( 'Kate_ExpireUserGroupTime', nil )
        target:SetNetVar( 'Kate_Mentor', nil )

        return
      end

      kate.DB:Query(
        string.format( 'INSERT INTO kate_usergroups ( SteamID64, UserGroup, ExpireGroup, ExpireTime, AdminSteamID64 ) VALUES ( %q, %q, %q, %i, %q );',
          kate.DB:Escape( steamId64 ), givenGroup, expireGroup or 'user', expireTime or 0, adminSteamId64
        )
      )
        :SetOnSuccess( function()
          kate.UserGroups.Cache[steamId64] = givenGroup

          local target = kate.FindPlayer( steamId64 )
          if not IsValid( target ) then
            return
          end

          target:SetUserGroup( givenGroup )

          target:SetNetVar( 'Kate_ExpireUserGroup', expireGroup )
          target:SetNetVar( 'Kate_ExpireUserGroupTime', expireTime )
          target:SetNetVar( 'Kate_Mentor', adminSteamId64 )
        end )
        :Start()
    end )
    :Start()
end

local function cacheUsers()
  kate.UserGroups.Cache = {}

  kate.DB:Query( 'SELECT SteamID64, UserGroup FROM kate_usergroups;' )
    :SetOnSuccess( function( _, info )
      for _, data in ipairs( info ) do
        kate.UserGroups.Cache[data.SteamID64] = data.UserGroup
      end
    end )
    :Start()
end

timer.Simple( 0, cacheUsers )
timer.Create( 'Kate::CacheUsers', 60, 0, cacheUsers )