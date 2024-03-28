kate.AddParam( 'PLAYER_STEAMID' )
  :SetName( 'Player/SteamID' )
  :SetParse( function( caller, cmdObj, arg )
    if IsValid( caller ) and ( ( arg == 'me' ) or ( arg == '^' ) ) then
      return true, caller
    end

    local result = kate.FindPlayer( arg )
    if ( result == nil ) and ( not kate.IsSteamID( arg ) ) then
      return false, 'ERROR_INVALID_PLAYER', { arg }
    end

    if not IsValid( caller ) then
      return true, result or arg
    end

    local group = kate.UserGroups.Cache[kate.SteamIDTo64( arg )]
    if group == nil then
      return true, result or arg
    end

    local groupObj = kate.UserGroups.Stored[group]
    if ( groupObj == nil ) or ( groupObj:GetRelevance() < caller:GetRelevance() ) then
      return true, result or arg
    end

    if IsValid( result ) then
      kate.Notify( result, LOG_COMMON, kate.GetPhrase( true, 'LOG_HIGHER_TARGET',
        kate.GetActor( caller ),
        cmdObj:GetName()
      ) )
    end

    return false, 'ERROR_HIGHER_TARGET', { result and result:Name() or arg }
  end )

kate.AddParam( 'PLAYER_STEAMID64' )
  :SetName( 'Player/SteamID64' )
  :SetParse( function( caller, cmdObj, arg )
    if IsValid( caller ) and ( ( arg == 'me' ) or ( arg == '^' ) ) then
      return true, caller
    end

    local result = kate.FindPlayer( arg )
    if ( result == nil ) and ( not kate.IsSteamID64( arg ) ) then
      return false, 'ERROR_INVALID_PLAYER', { arg }
    end

    if not IsValid( caller ) then
      return true, result or arg
    end

    local group = kate.UserGroups.Cache[arg]
    if group == nil then
      return true, result or arg
    end

    local groupObj = kate.UserGroups.Stored[group]
    if ( groupObj == nil ) or ( groupObj:GetRelevance() < caller:GetRelevance() ) then
      return true, result or arg
    end

    if IsValid( result ) then
      kate.Notify( result, LOG_COMMON, kate.GetPhrase( true, 'LOG_HIGHER_TARGET',
        kate.GetActor( caller ),
        cmdObj:GetName()
      ) )
    end

    return false, 'ERROR_HIGHER_TARGET', { result and result:Name() or arg }
  end )

kate.AddParam( 'PLAYER_ENTITY' )
  :SetName( 'Player/SteamID' )
  :SetParse( function( caller, cmdObj, arg )
    if IsValid( caller ) and ( ( arg == 'me' ) or ( arg == '^' ) ) then
      return true, caller
    end

    local result = kate.FindPlayer( arg )
    if result == nil then
      return false, 'ERROR_INVALID_PLAYER', { arg }
    end

    if not IsValid( caller ) then
      return true, result
    end

    local group = kate.UserGroups.Cache[result:SteamID64()]
    if group == nil then
      return true, result
    end

    local groupObj = kate.UserGroups.Stored[group]
    if ( groupObj == nil ) or ( groupObj:GetRelevance() < caller:GetRelevance() ) then
      return true, result
    end

    kate.Notify( result, LOG_COMMON, kate.GetPhrase( true, 'LOG_HIGHER_TARGET',
      kate.GetActor( caller ),
      cmdObj:GetName()
    ) )

    return false, 'ERROR_HIGHER_TARGET', { result:Name() }
  end )

kate.AddParam( 'PLAYER_ENTITY_MULTI' )
  :SetName( 'Players/SteamIDs' )
  :SetParse( function( caller, cmdObj, _, args, step )
    local results = {}

    for i = 1, ( ( #args + step ) - #cmdObj:GetParams() ) do
      local result = kate.FindPlayer( args[i] )
      if result == nil then
        return false, 'ERROR_INVALID_PLAYER', { args[i] }
      end

      if not IsValid( caller ) then
        results[#results + 1] = result

        continue
      end

      local group = kate.UserGroups.Cache[result:SteamID64()]
      if group == nil then
        results[#results + 1] = result

        continue
      end

      local groupObj = kate.UserGroups.Stored[group]
      if ( groupObj == nil ) or ( groupObj:GetRelevance() < caller:GetRelevance() ) then
        results[#results + 1] = result

        continue
      end

      kate.Notify( result, LOG_COMMON, kate.GetPhrase( true, 'LOG_HIGHER_TARGET',
        kate.GetActor( caller ),
        cmdObj:GetName()
      ) )

      return false, 'ERROR_HIGHER_TARGET', { result:Name() }
    end

    return true, results, #results
  end )

kate.AddParam( 'WORD' )
  :SetName( 'Single World' )
  :SetParse( function( _, _, arg )
    if ( arg == nil ) or ( arg == '' ) then
      return false, 'ERROR_INVALID_COMMAND', { arg }
    end

    return true, arg
  end )

kate.AddParam( 'STRING' )
  :SetName( 'String' )
  :SetParse( function( _, cmdObj, _, args, step )
    local results = ''

    local c = 0
    for i = 1, ( ( #args + step ) - #cmdObj:GetParams() ) do
      results = results .. ( ( i == 1 ) and '' or ' ' ) .. args[i]
      c = c + 1
    end

    return true, results, c
  end )

kate.AddParam( 'NUMBER' )
  :SetName( 'Number' )
  :SetParse( function( _, _, arg )
    local s = 0

    local match = false
    for k, t in string.gmatch( string.lower( arg ), '(%d+)(%a+)' ) do
      if kate.Commands.NumberUnits[t] ~= nil then
        s = s + k * kate.Commands.NumberUnits[t]
        match = true

        break
      end

      return false, 'ERROR_INVALID_NUMBER', { arg }
    end

    if not match then
      local n = tonumber( arg )
      if n == nil then
        return false, 'ERROR_INVALID_NUMBER', { arg }
      end

      return true, n
    end

    return true, s
  end )

kate.AddParam( 'BOOL' )
  :SetName( 'Boolean' )
  :SetParse( function( _, _, arg )
    if arg == 'true' then
      return true, true
    end

    if arg == 'false' then
      return true, false
    end

    return false, 'ERROR_INVALID_BOOL', { arg }
  end )

kate.AddParam( 'MODEL' )
  :SetName( 'Model' )
  :SetParse( function( _, _, arg )
    if not util.IsModelLoaded( arg ) then
      return false, 'ERROR_INVALID_MODEL', { arg }
    end

    return true, arg
  end )

kate.AddParam( 'SWEP' )
  :SetName( 'Weapon' )
  :SetParse( function( _, _, arg )
    local swep = weapons.Get( arg )
    if swep == nil then
      return false, 'ERROR_INVALID_SWEP', { arg }
    end

    return true, {
      Class = arg,
      Data = swep
    }
  end )

kate.AddParam( 'AMMOTYPE' )
  :SetName( 'AmmoType' )
  :SetParse( function( _, _, arg )
    if ( arg == nil ) or ( arg == '' ) then
      return false, 'ERROR_INVALID_AMMOTYPE', { arg or '' }
    end

    local types = game.GetAmmoTypes()

    local id = tonumber( arg )
    local name = types[id]

    if ( id ~= nil ) and ( name ~= nil ) then
      return true, {
        Id = id,
        Name = name
      }
    end

    for ammoId, ammoName in pairs( types ) do
      if ( ammoId == tonumber( arg ) ) or string.find( ammoName, arg ) then
        return true, {
          Id = ammoId,
          Name = ammoName
        }
      end
    end

    return false, 'ERROR_INVALID_AMMOTYPE', { arg }
  end )

kate.AddParam( 'TIME' )
  :SetName( 'Time' )
  :SetParse( function( _, _, arg )
    if arg == '0' then
      return true, 0
    end

    local s = 0
    for k, t in string.gmatch( string.lower( arg ), '(%d+)(%a+)' ) do
      if kate.Commands.TimeUnits[t] == nil then
        return false, 'ERROR_INVALID_TIME', { arg }
      end

      s = s + ( k * kate.Commands.TimeUnits[t] )
    end

    if s == 0 then
      return false, 'ERROR_INVALID_TIME', { arg }
    end

    return true, s
  end )

kate.AddParam( 'USERGROUP' )
  :SetName( 'UserGroup' )
  :SetParse( function( pl, _, arg )
    local usergroup = kate.UserGroups.Stored[arg]
    if usergroup == nil then
      return false, 'ERROR_INVALID_USERGROUP', { arg }
    end

    return true, arg
  end )

kate.AddParam( 'RAW' )
  :SetName( 'Raw' )
  :SetParse( function( _, _, _, args )
    return true, args, #args
  end )