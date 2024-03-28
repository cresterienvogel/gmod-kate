local vendor = {
  SetUser = function( pl, steamId64 )
    kate.SetUserGroup( steamId64, 'user' )

    local phrase = function( showSteamId )
      return { 'LOG_SETGROUP', kate.GetActor( pl, showSteamId ), kate.GetTarget( steamId64, showSteamId ), 'User' }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end,
  SetGroup = function( pl, steamId64, givenGroup, expireTime, expireGroup )
    local args = {}

    args[1] = steamId64
    args[2] = givenGroup

    if expireTime ~= nil then
      args[3] = os.time() + expireTime
    end

    if expireGroup ~= nil then
      args[4] = expireGroup
    end

    if IsValid( pl ) then
      args[5] = pl:SteamID64()
    end

    kate.SetUserGroup( unpack( args ) )

    return args
  end,
  CanRun = function( pl, givenGroup, expireGroup )
    local givenObj = kate.UserGroups.Stored[givenGroup]
    if givenObj == nil then
      return false
    end

    if IsValid( pl ) and ( givenObj:GetRelevance() > pl:GetRelevance() ) then
      local phrase = { 'ERROR_HIGHER_USERGROUP', givenObj:GetName() }
      kate.Notify( pl, LOG_ERROR, kate.GetPhrase( true, unpack( phrase ) ) )

      return false
    end

    local expireObj = kate.UserGroups.Stored[expireGroup]
    if ( expireGroup ~= nil ) and ( expireGroup ~= 'user' ) and ( expireObj:GetRelevance() > givenObj:GetRelevance() ) then
      local phrase = { 'ERROR_HIGHER_EXPIRED_USERGROUP', expireObj:GetName(), givenObj:GetName() }
      kate.Notify( pl, LOG_ERROR, kate.GetPhrase( IsValid( pl ), unpack( phrase ) ) )

      return false
    end

    return true
  end,
  Log = function( pl, steamId64, args )
    local givenObj = kate.UserGroups.Stored[args[2]]
    local expireObj = kate.UserGroups.Stored[args[4]]

    local givenGroup = givenObj:GetName()
    local expireTime = ( args[3] ~= nil ) and os.date( '%d.%m.%y (%H:%M)', args[3] )
    local expireGroup = ( args[4] ~= nil ) and expireObj:GetName()

    local phrase = function( showSteamId )
      local actor = kate.GetActor( pl, showSteamId )
      local target = kate.GetTarget( steamId64, showSteamId )

      return ( ( args[3] ~= nil ) and ( args[4] ~= nil ) ) and {
        'LOG_SETGROUP_TIME_GROUP', actor, target, givenGroup, expireTime, expireGroup } or ( args[3] ~= nil ) and {
        'LOG_SETGROUP_TIME', actor, target, givenGroup, expireTime } or {
        'LOG_SETGROUP', actor, target, givenGroup }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end
}

kate.AddCommand( 'Set Group', function( pl, target, givenGroup, expireTime, expireGroup )
  local steamId64 = kate.TargetToSteamID64( target )
  if steamId64 == nil then
    return
  end

  if givenGroup == 'user' then
    vendor.SetUser( pl, steamId64 )

    return
  end

  local canRun = vendor.CanRun( pl, givenGroup, expireGroup )
  if canRun == false then
    return
  end

  local args = vendor.SetGroup( pl, steamId64, givenGroup, expireTime, expireGroup )
  vendor.Log( pl, steamId64, args )
end )
  :SetFlag( 'usergroup' )
  :AddParam( 'PLAYER_STEAMID' )
  :AddParam( 'USERGROUP' )
  :AddParam( 'TIME', true )
  :AddParam( 'USERGROUP', true )
  :AddAlias( 'Set User Group' )
  :AddAlias( 'Set Rank' )
  :AddAlias( 'Set Access' )
  :AddAlias( 'Set User' )
  :AddAlias( 'Add User' )