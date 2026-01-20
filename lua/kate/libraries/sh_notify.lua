LOG_TIMESTAMP = Color( 234, 163, 92 )
LOG_SUCCESS = Color( 133, 213, 196 )
LOG_ERROR = Color( 213, 85, 85 )
LOG_COMMON = Color( 216, 134, 234 )
LOG_HIGHLIGHT = Color( 134, 253, 136 )

if SERVER then
  util.AddNetworkString( 'Kate_Notify' )
else
  local function split( text )
    local tbl = {}
    for str in string.gmatch( text, '([^%s]+)' ) do
      tbl[#tbl + 1] = str
    end

    return tbl
  end

  local function match( words, names )
    local phrase = ''
    for i, word in ipairs( words ) do
      phrase = ( i > 1 ) and ( phrase .. ' ' .. word ) or word
      if names[phrase] ~= nil then
        return phrase, i
      end
    end

    return nil, 0
  end

  net.Receive( 'Kate_Notify', function()
    local status = net.ReadColor()
    local text = net.ReadString()
    local highlight = net.ReadTable()

    for _, p in pairs( kate.Commands.StoredParams ) do
      highlight[p:GetName()] = true
    end

    local i = 1
    local args = {}
    local words = split( text )

    while i <= #words do
      local phrase, length = match( { unpack( words, i ) }, highlight )
      if phrase ~= nil then
        args[#args + 1] = LOG_HIGHLIGHT
        args[#args + 1] = phrase .. ' '
        args[#args + 1] = color_white

        i = i + length
      else
        args[#args + 1] = words[i] .. ' '
        i = i + 1
      end
    end

    chat.AddText( status, '» ', color_white, unpack( args ) )
  end )
end

function kate.GetActor( pl, showSteamId )
  return IsValid( pl ) and
    ( showSteamId and ( pl:Name() .. ' (' .. pl:SteamID() .. ')' ) or pl:Name() ) or
    'Console'
end

function kate.GetTarget( target, showSteamId )
  if IsValid( target ) then
    if showSteamId then
      return target:Name() .. ' (' .. target:SteamID() .. ')'
    end

    return target:Name()
  end

  local found = kate.FindPlayer( target )
  if IsValid( found ) then
    if showSteamId then
      return found:Name() .. ' (' .. found:SteamID() .. ')'
    end

    return found:Name()
  end

  local id = kate.SteamIDFrom64( target )
  if id ~= nil then
    return id
  end

  return 'Unknown'
end

function kate.Print( status, ... )
  local text = table.concat( { ... }, ' ' )

  timer.Simple( 0, function()
    MsgC( LOG_TIMESTAMP, os.date( '[%d/%m/%y] [%H:%M:%S]', os.time() ), status, ' » ', color_white, text, '\n' )
  end )
end

function kate.Notify( recievers, status, ... )
  local text = table.concat( { ... }, ' ' )

  timer.Simple( 0, function()
    if ( not IsValid( recievers ) ) and ( type( recievers ) ~= 'table' ) then
      kate.Print( status, text )

      return
    end

    if CLIENT then
      chat.AddText( status, '» ', color_white, text )

      return
    end

    local names = {}
    for _, pl in player.Iterator() do
      names[pl:Name()] = true
    end

    net.Start( 'Kate_Notify' )
      net.WriteColor( status )
      net.WriteString( text )
      net.WriteTable( names )
    net.Send( recievers )
  end )
end