kate.AddPunishment( 'Gag',
  {
    GagReason = 'string',
    GagGiver = 'string',
    GagTime = 'number',
    UnGagTime = 'number'
  },
  {
    GagReason = true,
    GagGiver = true,
    GagTime = true,
    UnGagTime = true
  },
  {
    PlayerCanHearPlayersVoice = function( _, pl )
      local gag = pl:GetUnGagTime()
      if gag == nil then
        return
      end

      if ( gag ~= 0 ) and ( os.time() > gag ) then
        kate.UnGag( pl:SteamID64() )
        kate.Print( LOG_COMMON, kate.GetPhrase( false, 'LOG_UNGAG_AUTO', kate.GetTarget( pl, true ) ) )

        return
      end

      if pl:IsSpeaking() and ( CurTime() > ( pl.KateGagMessageDelay or 0 ) ) then
        if gag == 0 then
          kate.Notify( pl, LOG_ERROR, kate.GetPhrase( true, 'ERROR_GAG_PERMA' ) )
        else
          kate.Notify( pl, LOG_ERROR, kate.GetPhrase( true, 'ERROR_GAG', os.date( '%d.%m.%y (%H:%M)', gag ) ) )
        end

        pl.KateGagMessageDelay = CurTime() + 1
      end

      return false
    end
  }
)

kate.AddPunishment( 'Mute',
  {
    MuteReason = 'string',
    MuteGiver = 'string',
    MuteTime = 'number',
    UnMuteTime = 'number'
  },
  {
    MuteReason = true,
    MuteGiver = true,
    MuteTime = true,
    UnMuteTime = true
  },
  {
    PlayerSay = function( pl )
      local mute = pl:GetUnMuteTime()
      if mute == nil then
        return
      end

      if ( mute ~= 0 ) and ( os.time() > mute ) then
        kate.UnMute( pl:SteamID64() )
        kate.Print( LOG_COMMON, kate.GetPhrase( false, 'LOG_UNMUTE_AUTO', kate.GetTarget( pl, true ) ) )

        return
      end

      if CurTime() > ( pl.KateMuteMessageDelay or 0 ) then
        if gag == 0 then
          kate.Notify( pl, LOG_ERROR, kate.GetPhrase( true, 'ERROR_MUTE_PERMA' ) )
        else
          kate.Notify( pl, LOG_ERROR, kate.GetPhrase( true, 'ERROR_MUTE', os.date( '%d.%m.%y (%H:%M)', gag ) ) )
        end

        pl.KateMuteMessageDelay = CurTime() + 1
      end

      return ''
    end
  }
)