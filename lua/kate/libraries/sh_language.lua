kate.Language = kate.Language or {}

if SERVER then
  cvars.AddChangeCallback( 'sv_location', function( _, old, new )
    if ( kate.Language[new] == nil ) or ( old == new ) then
      return
    end

    nw.SetGlobal( 'Kate_Location', new )
  end )

  timer.Simple( 0, function()
    if nw.GetGlobal( 'Kate_Location' ) ~= nil then
      return
    end

    local location = GetConVar( 'sv_location' ):GetString()
    if ( kate.Language[location] == nil ) or ( location == '' ) then
      return
    end

    nw.SetGlobal( 'Kate_Location', location )
  end )
end

function kate.AddPhrase( location, phrase, translation )
  kate.Language[location] = kate.Language[location] or {}
  kate.Language[location][phrase] = translation
end

function kate.GetPhrase( translate, phrase, ... )
  local location = translate and nw.GetGlobal( 'Kate_Location' ) or 'eu'
  local phrases = kate.Language[location] or kate.Language['eu']

  local args = { ... }
  if #args == 0 then
    return phrases[phrase]
  end

  return string.format( phrases[phrase], unpack( { ... } ) )
end