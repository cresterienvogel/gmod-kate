hook.Add( 'Kate::OnCommandError', 'Kate::CommandErrorNotify', function( pl, _, phrase, phraseArgs )
  kate.Notify( pl, LOG_ERROR, kate.GetPhrase( IsValid( pl ), phrase, unpack( phraseArgs or {} ) ) )
end )

hook.Add( 'PlayerSay', 'Kate::RunCommand', function( pl, text )
  text = string.Trim( text )
  if text[1] ~= '!' then
    return
  end

  local args = string.Explode( ' ', text )
  local command = string.sub( string.lower( args[1] ), 2 )
  table.remove( args, 1 )

  local succ = kate.RunCommand( pl, command, args )
  if not succ then
    return ''
  end

  return text
end )