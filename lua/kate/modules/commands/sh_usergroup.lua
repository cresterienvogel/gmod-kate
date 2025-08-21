local function setUser( pl, steamId64 )
  kate.SetUserGroup( steamId64, 'user' )

  local phrase = function( showSteamId )
    return { 'LOG_SETGROUP', kate.GetActor( pl, showSteamId ), kate.GetTarget( steamId64, showSteamId ), 'User' }
  end

  kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
  kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
end

local function setGroup( pl, steamId64, givenGroup, expireTime, expireGroup )
  local args = {}

  args[1] = steamId64
  args[2] = givenGroup
  args[3] = ( expireTime ~= nil ) and os.time() + expireTime or 'NULL'
  args[4] = ( expireGroup ~= nil ) and expireGroup or 'NULL'
  args[5] = IsValid( pl ) and pl:SteamID64() or 'NULL'

  kate.SetUserGroup( unpack( args ) )

  return args
end

local function canRun( pl, givenGroup, expireGroup )
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
end

local function createLog( pl, steamId64, args )
  local givenObj = kate.UserGroups.Stored[args[2]]
  local expireObj = kate.UserGroups.Stored[args[4]]

  local givenGroup = givenObj:GetName()
  local expireTime = ( ( args[3] ~= nil ) and ( args[3] ~= 'NULL' ) ) and os.date( '%d.%m.%y (%H:%M)', args[3] ) or nil
  local expireGroup = ( ( args[4] ~= nil ) and ( args[4] ~= 'NULL' ) ) and ( expireObj ~= nil and expireObj:GetName() ) or nil

  local phrase = function( showSteamId )
    local actor = kate.GetActor( pl, showSteamId )
    local target = kate.GetTarget( steamId64, showSteamId )

    return ( ( expireTime ~= nil ) and ( expireGroup ~= nil ) ) and {
      'LOG_SETGROUP_TIME_GROUP', actor, target, givenGroup, expireTime, expireGroup } or ( expireTime ~= nil ) and {
      'LOG_SETGROUP_TIME', actor, target, givenGroup, expireTime } or {
      'LOG_SETGROUP', actor, target, givenGroup }
  end

  kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
  kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
end

kate.AddCommand( 'Set Group',
  function( pl, target, givenGroup, expireTime, expireGroup )
    local steamId64 = kate.TargetToSteamID64( target )
    if steamId64 == nil then
      return
    end

    if givenGroup == 'user' then
      setUser( pl, steamId64 )

      return
    end

    local runRes = canRun( pl, givenGroup, expireGroup )
    if runRes == false then
      return
    end

    local args = setGroup( pl, steamId64, givenGroup, expireTime, expireGroup )
    createLog( pl, steamId64, args )
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