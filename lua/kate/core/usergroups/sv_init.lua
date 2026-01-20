function kate.SetUserGroup( steamId64, givenGroup, expireTime, expireGroup, giverSteamId64 )
  if not kate.IsSteamID64( steamId64 ) then
    return
  end

  if expireTime == 'NULL' then
    expireTime = nil
  end

  if expireGroup == 'NULL' then
    expireGroup = nil
  end

  if giverSteamId64 == 'NULL' then
    giverSteamId64 = nil
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

  local adminSteamId64 = '<Console>'
  if ( giverSteamId64 ~= nil ) and kate.IsSteamID64( giverSteamId64 ) then
    adminSteamId64 = giverSteamId64
  end

  kate.Database
    :Query( string.format( 'DELETE FROM kate_usergroups WHERE SteamID64 = %q;', steamId64 ) )
    :SetOnSuccess( function()
      if givenGroup == 'user' then
        local target = kate.FindPlayer( steamId64 )
        if IsValid( target ) then
          target:SetUserGroup( 'user' )
          target:SetNetVar( 'Kate_ExpireUserGroup', nil )
          target:SetNetVar( 'Kate_ExpireUserGroupTime', nil )
          target:SetNetVar( 'Kate_Mentor', nil )
        end

        hook.Run( 'Kate::UserGroupRemoved', steamId64, adminSteamId64 )

        return
      end

      kate.Database
        :Query( string.format( 'INSERT INTO kate_usergroups ( SteamID64, UserGroup, ExpireGroup, ExpireTime, AdminSteamID64 ) VALUES ( %q, %q, %q, %i, %q );',
          kate.Database:Escape( steamId64 ), givenGroup, expireGroup or 'user', expireTime or 0, adminSteamId64
        ) )
        :SetOnSuccess( function()
          local target = kate.FindPlayer( steamId64 )
          if IsValid( target ) then
            target:SetUserGroup( givenGroup )
            target:SetNetVar( 'Kate_ExpireUserGroup', expireGroup )
            target:SetNetVar( 'Kate_ExpireUserGroupTime', expireTime )
            target:SetNetVar( 'Kate_Mentor', adminSteamId64 )
          end

          hook.Run( 'Kate::UserGroupChanged', steamId64, givenGroup, expireTime or 0, expireGroup or 'user', adminSteamId64 )
        end )
        :Start()
    end )
    :Start()
end