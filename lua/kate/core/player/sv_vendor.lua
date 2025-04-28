local VENDOR = {}

function VENDOR.LoadUserInfo( pl )
  local name = pl:Name()
  local steamId64 = pl:SteamID64()
  local address = kate.StripPort( pl:IPAddress() )

  pl:SetNetVar( 'Kate_LastJoin', os.time() )
  pl:SetNetVar( 'Kate_SessionStarted', CurTime() )

  kate.DB:Query( string.format( 'SELECT * FROM kate_users WHERE SteamID64 = %q;', steamId64 ) )
    :SetOnSuccess( function( _, info )
      if not IsValid( pl ) then
        return
      end

      if info[1] then
        pl:SetNetVar( 'Kate_FirstJoin', info[1].FirstJoin )
        pl:SetNetVar( 'Kate_Playtime', info[1].Playtime )

        kate.DB:Query( string.format( 'UPDATE kate_users SET Name = %q, LastJoin = %i, IP = %q WHERE SteamID64 = %q;',
          kate.DB:Escape( name ), os.time(), address, steamId64
        ) ):Start()
      else
        pl:SetNetVar( 'Kate_FirstJoin', os.time() )
        pl:SetNetVar( 'Kate_Playtime', 0 )

        kate.DB:Query( string.format( 'INSERT INTO kate_users ( SteamID64, Name, FirstJoin, LastJoin, Playtime, IP ) VALUES ( %q, %q, %i, %i, %i, %q );',
          steamId64, kate.DB:Escape( name ), os.time(), os.time(), 0, address
        ) ):Start()
      end
    end )
    :Start()
end

function VENDOR.LoadUserGroup( pl )
  kate.DB:Query( string.format( 'SELECT * FROM kate_usergroups WHERE SteamID64 = %q;', pl:SteamID64() ) )
    :SetOnSuccess( function( _, info )
      if ( not IsValid( pl ) ) or ( info[1] == nil ) then
        return
      end

      pl:SetUserGroup( info[1]['UserGroup'] )

      pl:SetNetVar( 'Kate_ExpireUserGroup', info[1]['ExpireGroup'] )
      pl:SetNetVar( 'Kate_ExpireUserGroupTime', info[1]['ExpireTime'] )
      pl:SetNetVar( 'Kate_Mentor', info[1]['Mentor'] )
    end )
    :Start()
end

function VENDOR.LoadUserPunishments( pl )
  for punishment in pairs( kate.Punishments.Stored ) do
    local tbl = string.gsub( string.lower( punishment ), ' ', '_' )

    kate.DB:Query( string.format( 'SELECT * FROM kate_punishments_%s WHERE SteamID64 = %q;', tbl, pl:SteamID64() ) )
      :SetOnSuccess( function( _, info )
        if ( not IsValid( pl ) ) or ( info[1] == nil ) then
          return
        end

        for column, value in pairs( info[1] ) do
          if nw.Vars['Kate_' .. column] ~= nil then
            pl:SetNetVar( 'Kate_' .. column, value )
          end
        end
      end )
      :Start()
  end
end

function VENDOR.SaveUserPlaytime( pl )
  kate.DB:Query( string.format( 'UPDATE kate_users SET Playtime = %i, LastJoin = %i WHERE SteamID64 = %q;',
    pl:GetPlaytime(),
    os.time(),
    pl:SteamID64()
  ) ):Start()
end

function VENDOR.SaveUsersPlaytime()
  for _, pl in player.Iterator() do
    if pl:IsBot() then
      continue
    end

    kate.DB:Query(string.format( 'UPDATE kate_users SET Playtime = %i, LastJoin = %i WHERE SteamID64 = %q;',
      pl:GetPlaytime(),
      os.time(),
      pl:SteamID64()
    ) ):Start()
  end
end

return VENDOR