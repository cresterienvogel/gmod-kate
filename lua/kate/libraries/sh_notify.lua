local LOG_TIMESTAMP = Color( 234, 163, 92 )

local LOG_STATUS = {
  Color( 133, 213, 196 ), -- success
  Color( 213, 85, 85 ), -- error
  Color( 216, 134, 234 ) -- common
}

if SERVER then
  util.AddNetworkString( 'Kate_Notify' )
else
  net.Receive( 'Kate_Notify', function()
    local status = net.ReadUInt( 2 )
    local text = net.ReadString()

    chat.AddText( LOG_STATUS[status] or 3, '» ', color_white, text )
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
    else
      return target:Name()
    end
  end

  local found = kate.FindPlayer( target )
  if IsValid( found ) then
    if showSteamId then
      return found:Name() .. ' (' .. found:SteamID() .. ')'
    else
      return found:Name()
    end
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
    MsgC(
      LOG_TIMESTAMP,
      os.date( '[%d/%m/%y] [%H:%M:%S]', os.time() ),
      LOG_STATUS[status] or 3,
      ' » ',
      color_white,
      text,
      '\n'
    )
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
      chat.AddText( LOG_STATUS[status] or 3, '» ', color_white, text )

      return
    end

    net.Start( 'Kate_Notify' )
      net.WriteUInt( status, 2 )
      net.WriteString( text )
    net.Send( recievers )
  end )
end