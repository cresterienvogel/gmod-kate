util.AddNetworkString( 'Kate::CacheUserGroups' )

function kate.UserGroups.Store( steamId64, userGroup )
  kate.UserGroups.Cache[steamId64] = userGroup
  kate.UserGroups.Send()
end

function kate.UserGroups.Send( pl )
  local safe = {}
  for steamId64, userGroup in pairs( kate.UserGroups.Cache ) do
    local steamId = util.SteamIDFrom64( steamId64 )
    safe[steamId] = userGroup
  end

  local json = util.TableToJSON( safe )
  local comp = util.Compress( json )
  local bytes = #comp

  net.Start( 'Kate::CacheUserGroups' )
    net.WriteUInt( bytes, 16 )
    net.WriteData( comp, bytes )
  if IsValid( pl ) then
    net.Send( pl )
  else
    net.Broadcast()
  end
end

hook.Add( 'InitPostEntity', 'Kate::CacheUserGroups', function()
  kate.DB:Query( 'SELECT SteamID64, UserGroup FROM kate_usergroups;' )
    :SetOnSuccess( function( _, info )
      for _, data in ipairs( info ) do
        kate.UserGroups.Cache[data.SteamID64] = data.UserGroup
      end
    end )
    :Start()
end )

hook.Add( 'PlayerInitialSpawn', 'Kate::CacheUserGroups', function( pl )
  kate.UserGroups.Send( pl )
end )