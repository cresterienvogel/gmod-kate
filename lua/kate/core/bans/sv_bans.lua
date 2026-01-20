kate.Bans = kate.Bans or {
  Cache = {},
  Vendor = include( 'sv_vendor.lua' )
}

local vendor = {
  Insert = kate.Bans.Vendor.Insert,
  Update = kate.Bans.Vendor.Update
}

function kate.Ban( steamId64, details )
  if not kate.IsSteamID64( steamId64 ) then
    return
  end

  local banTime = os.time()
  local unbanTime = details.UnbanTime or 0
  local banReason = details.Reason or '<Unknown>'
  local targetName = details.Name or '<Offline ban>'
  local targetIp = details.IP or '<Offline ban>'
  local adminSteamId64 = details.AdminSteamID64 or '<Console>'
  local adminName = details.AdminName or '<Console>'
  local adminIp = details.AdminIP or '<Console>'

  kate.Database
    :Query( string.format( 'SELECT * FROM kate_bans WHERE SteamID64 = %q AND ( UnbanTime > %i OR UnbanTime = 0 );', steamId64, os.time() ) )
    :SetOnSuccess( function( _, info )
      if info[1] ~= nil then
        vendor.Update(
          {
            Reason = kate.Database:Escape( banReason ),
            BanTime = banTime,
            UnbanTime = unbanTime,
            AdminSteamID64 = adminSteamId64,
            AdminName = kate.Database:Escape( adminName ),
            AdminIP = adminIp
          },
          info[1]
        )

        hook.Run( 'Kate::BanUpdated', steamId64, targetName, targetIp, adminSteamId64, adminName, adminIp, banReason, banTime, unbanTime )
      else
        vendor.Insert( {
          SteamID64 = steamId64,
          Name = kate.Database:Escape( targetName ),
          IP = targetIp,
          Reason = kate.Database:Escape( banReason ),
          BanTime = banTime,
          UnbanTime = unbanTime,
          AdminSteamID64 = adminSteamId64,
          AdminName = kate.Database:Escape( adminName ),
          AdminIP = adminIp
        } )

        hook.Run( 'Kate::BanCreated', steamId64, targetName, targetIp, adminSteamId64, adminName, adminIp, banReason, banTime, unbanTime )
      end
    end )
    :Start()
end

function kate.Unban( steamId64, details )
  if not kate.IsSteamID64( steamId64 ) then
    return
  end

  local adminSteamId64 = details.AdminSteamID64 or '<Console>'
  local adminName = details.AdminName or '<Console>'
  local adminIp = details.AdminIP or '<Console>'
  local unbanReason = details.Reason or '<Unknown>'
  local unbanTime = os.time()

  kate.Database
    :Query( string.format( 'SELECT * FROM kate_bans WHERE SteamID64 = %q AND ( UnbanTime > %i OR UnbanTime = 0 );', steamId64, os.time() ) )
    :SetOnSuccess( function( _, info )
      if info[1] == nil then
        return
      end

      vendor.Update(
        {
          Reason = kate.Database:Escape( unbanReason ),
          UnbanTime = unbanTime,
          AdminSteamID64 = adminSteamId64,
          AdminName = kate.Database:Escape( adminName ),
          AdminIP = adminIp
        },
        info[1],
        function()
          kate.Bans.Cache[steamId64] = nil
          hook.Run( 'Kate::BanRemoved', steamId64, adminSteamId64, adminName, adminIp, unbanReason, unbanTime )
        end
      )
    end )
    :Start()
end

local function cacheBans()
  kate.Bans.Cache = {}

  kate.Database
    :Query( string.format( 'SELECT * FROM kate_bans WHERE ( UnbanTime > %i OR UnbanTime = 0 );', os.time() ) )
    :SetOnSuccess( function( _, info )
      for _, details in ipairs( info ) do
        kate.Bans.Cache[details.SteamID64] = details
      end
    end )
    :Start()
end

timer.Simple( 0, cacheBans )
timer.Create( 'Kate::SyncBans', 60, 0, cacheBans )