return {
  LoadUserInfo = function( pl )
    local name = pl:Name()
    local steamId64 = pl:SteamID64()
    local ip = kate.StripPort( pl:IPAddress() )

    pl:SetLastJoin( os.time() )
    pl:SetSessionStarted( CurTime() )

    kate.DB:Query( string.format( 'SELECT * FROM kate_users WHERE SteamID64 = %q;', steamId64 ) )
      :SetOnSuccess( function( _, info )
        if info[1] then
          pl:SetFirstJoin( info[1].FirstJoin )
          pl:SetNetVar( 'Kate_Playtime', info[1].Playtime )

          kate.DB:Query(
            string.format( 'UPDATE kate_users SET Name = %q, LastJoin = %i, IP = %q WHERE SteamID64 = %q;',
              kate.DB:Escape( name ), os.time(), ip, steamId64
            )
          )
            :Start()
        else
          pl:SetFirstJoin( os.time() )
          pl:SetNetVar( 'Kate_Playtime', 0 )

          kate.DB:Query(
            string.format( 'INSERT INTO kate_users ( SteamID64, Name, FirstJoin, LastJoin, Playtime, IP ) VALUES ( %q, %q, %i, %i, %i, %q );',
              steamId64, kate.DB:Escape( name ), os.time(), os.time(), 0, ip
            )
          )
            :Start()
        end
      end )
      :Start()
  end,
  LoadUserGroup = function( pl )
    kate.DB:Query( string.format( 'SELECT * FROM kate_usergroups WHERE SteamID64 = %q;', pl:SteamID64() ) )
    :SetOnSuccess( function( _, info )
      if info[1] == nil then
        return
      end

      pl:SetUserGroup( info[1]['UserGroup'] )
      pl:SetExpireUserGroup( info[1]['ExpireGroup'] )
      pl:SetExpireTime( info[1]['ExpireTime'] )
      pl:SetMentor( info[1]['Mentor'] )
    end )
    :Start()
  end,
  LoadUserPunishments = function( pl )
    for punishment in pairs( kate.Punishments.Stored ) do
      local tbl = string.gsub( string.lower( punishment ), ' ', '_' )

      kate.DB:Query( string.format( 'SELECT * FROM kate_punishments_%s WHERE SteamID64 = %q;', tbl, pl:SteamID64() ) )
        :SetOnSuccess( function( _, info )
          if info[1] == nil then
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
  end,
  SaveUserPlaytime = function( pl )
    kate.DB:Query(
      string.format( 'UPDATE kate_users SET Playtime = %i, LastJoin = %i WHERE SteamID64 = %q;',
        pl:GetPlaytime(), os.time(), pl:SteamID64()
      )
    )
      :Start()
  end,
  SaveUsersPlaytime = function()
    for _, pl in ipairs( player.GetHumans() ) do
      kate.DB:Query(
        string.format( 'UPDATE kate_users SET Playtime = %i, LastJoin = %i WHERE SteamID64 = %q;',
          pl:GetPlaytime(), os.time(), pl:SteamID64()
        )
      )
        :Start()
    end
  end
}