function kate.RunCommand( pl, cmd, args )
  local cmdObj = kate.Commands.StoredCommands[cmd]
  if cmdObj == nil then
    hook.Run( 'Kate_OnCommandError', pl, nil, 'ERROR_INVALID_COMMAND', { cmd } )

    return
  end

  local flag = cmdObj:GetFlag()
  if IsValid( pl ) and ( flag ~= nil ) and ( not ( pl:HasFlag( '*' ) or pl:HasFlag( flag ) ) ) then
    hook.Run( 'Kate_OnCommandError', pl, cmdObj, 'ERROR_COMMAND_NOACCESS', { cmdObj:GetName() } )

    return
  end

  for i = 1, #args do
    if ( string.upper( tostring( args[i] ) ) == 'STEAM_0' ) and ( args[i + 4] ) then
      args[i] = table.concat( args, '', i, i + 4 )

      for _ = 1, 4 do
        table.remove( args, i + 1 )
      end

      break
    end
  end

  for k, v in ipairs( args ) do
    args[k] = string.sub( v, 1, 126 )
  end

  if hook.Run( 'Kate_CanRunCommand', nil, pl, cmdObj, args ) == false then
    return
  end

  if IsValid( pl ) and pl:IsPlayer() then
    if CurTime() < ( pl.KateDelay or 0 ) then
      hook.Run( 'Kate_OnCommandError', pl, cmdObj, 'ERROR_COMMAND_COOLDOWN' )

      return
    end

    pl.KateDelay = CurTime() + 1
  end

  local succ, parsedArgs = kate.Parse( pl, cmdObj, table.concat( args, ' ' ) )
  if succ ~= false then
    hook.Run( 'Kate_OnCommandRun', pl, cmdObj, parsedArgs, cmdObj:Run( pl, unpack( parsedArgs ) ) )
  end
end