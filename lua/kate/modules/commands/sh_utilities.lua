kate.AddCommand( 'Health',
  function( pl, target, health )
    health = ( health ~= nil ) and
      math.max( health, 1 ) or 100

    target:SetHealth( health )

    local phrase = function( showSteamId )
      return { 'LOG_HEALTH', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ), health }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end )
  :SetFlag( 'health' )
  :AddParam( 'PLAYER_ENTITY' )
  :AddParam( 'NUMBER', true )
  :AddAlias( 'HP' )
  :AddAlias( 'Set Health' )

kate.AddCommand( 'Armor',
  function( pl, target, armor )
    armor = armor or 100
    target:SetArmor( armor )

    local phrase = function( showSteamId )
      return { 'LOG_ARMOR', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ), armor }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end )
  :SetFlag( 'armor' )
  :AddParam( 'PLAYER_ENTITY' )
  :AddParam( 'NUMBER', true )
  :AddAlias( 'AR' )
  :AddAlias( 'Set Armor' )

kate.AddCommand( 'God',
  function( pl, target )
    if ( not IsValid( pl ) ) and ( target == nil ) then
      return
    end

    target = target or pl

    local isGod = target:HasGodMode()

    if isGod then
      target:GodDisable()
    else
      target:GodEnable()
    end

    local phrase = function( showSteamId )
      return isGod and {
        'LOG_UNGOD', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ) } or {
        'LOG_GOD', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ) }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end )
  :SetFlag( 'god' )
  :AddParam( 'PLAYER_ENTITY', true )
  :AddAlias( 'God Mode' )
  :AddAlias( 'Set God Mode' )

kate.AddCommand( 'Cloak',
  function( pl, target )
    if ( not IsValid( pl ) ) and ( target == nil ) then
      return
    end

    target = target or pl

    local isCloaked = target:GetNetVar( 'Kate_Cloak' )
    kate.Cloak( target, not isCloaked )

    local phraseMsg = isCloaked and {
      'LOG_UNCLOAK_MESSAGE', kate.GetActor( pl ) } or {
      'LOG_CLOAK_MESSAGE', kate.GetActor( pl ) }

    local phraseNotify = isCloaked and {
      'LOG_UNCLOAK', kate.GetActor( pl, true ), kate.GetTarget( target, true ) } or {
      'LOG_CLOAK', kate.GetActor( pl, true ), kate.GetTarget( target, true ) }

    kate.Notify( target, LOG_COMMON, kate.GetPhrase( true, unpack( phraseMsg ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phraseNotify ) ) )
  end )
  :SetFlag( 'cloak' )
  :AddParam( 'PLAYER_ENTITY', true )

kate.AddCommand( 'Ammo',
  function( pl, target, count, ammo )
    if ( not IsValid( pl ) ) and ( target == nil ) then
      return
    end

    target = target or pl
    count = count or 100

    if ammo ~= nil then
      target:GiveAmmo( count, ammo.Id )
    else
      for ammoType in pairs( game.GetAmmoTypes() ) do
        target:GiveAmmo( count, ammoType )
      end
    end

    local phrase = function( showSteamId )
      return ( ammo ~= nil ) and {
        'LOG_AMMO', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ), count, ammo.Name } or {
        'LOG_AMMO_ALL', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ), count }
    end

    kate.Notify( kate.GetAdmins(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end )
  :SetFlag( 'ammo' )
  :AddParam( 'PLAYER_ENTITY', true )
  :AddParam( 'NUMBER', true )
  :AddParam( 'AMMOTYPE', true )
  :AddAlias( 'Give Ammo' )

kate.AddCommand( 'Message',
  function( pl, target, text )
    if IsValid( pl ) then
      local from = string.format( '[ %s %s ]', kate.GetPhrase( true, 'ADMIN' ), kate.GetActor( pl ) )
      kate.Notify( target, LOG_COMMON, from, ':', text )

      local to = string.format( '[ %s %s ]', kate.GetPhrase( true, 'SENT_TO' ), kate.GetTarget( target ) )
      kate.Notify( pl, LOG_COMMON, to, ':', text )
    else
      local str = string.format( '%s: %s', 'Console', text )
      kate.Notify( target, LOG_COMMON, str )
    end

    local phrase = { 'LOG_MESSAGE', kate.GetActor( pl, true ), kate.GetTarget( target, true ), text }
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase ) ) )
  end )
  :SetFlag( 'message' )
  :AddParam( 'PLAYER_ENTITY' )
  :AddParam( 'STRING' )
  :AddAlias( 'Msg' )
  :AddAlias( 'Send' )