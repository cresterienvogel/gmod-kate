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

  local unbanTime = details.UnbanTime or 0
  local banReason = details.Reason or 'Unknown'
  local targetName = details.Name or 'Offline ban'
  local targetIp = details.IP or 'Offline ban'
  local adminSteamId64 = details.AdminSteamID64 or 'Console'
  local adminName = details.AdminName or 'Console'
  local adminIp = details.AdminIP or 'Console'

  kate.DB:Query( string.format( 'SELECT * FROM kate_bans WHERE SteamID64 = %q AND ( UnbanTime > %i OR UnbanTime = 0 );', steamId64, os.time() ) )
    :SetOnSuccess( function( _, info )
      if info[1] ~= nil then
        vendor.Update(
          {
            Reason = kate.DB:Escape( banReason ),
            BanTime = os.time(),
            UnbanTime = unbanTime,
            AdminSteamID64 = adminSteamId64,
            AdminName = kate.DB:Escape( adminName ),
            AdminIP = adminIp
          },
          info[1]
        )
      else
        vendor.Insert( {
          SteamID64 = steamId64,
          Name = kate.DB:Escape( targetName ),
          IP = targetIp,
          Reason = kate.DB:Escape( banReason ),
          BanTime = os.time(),
          UnbanTime = unbanTime,
          AdminSteamID64 = adminSteamId64,
          AdminName = kate.DB:Escape( adminName ),
          AdminIP = adminIp
        } )
      end
    end )
    :Start()
end

function kate.Unban( steamId64, details )
  if not kate.IsSteamID64( steamId64 ) then
    return
  end

  local unbanReason = details.Reason or 'Unknown'
  local adminSteamId64 = details.AdminSteamID64 or 'Console'
  local adminName = details.AdminName or 'Console'
  local adminIp = details.AdminIP or 'Console'

  kate.DB:Query( string.format( 'SELECT * FROM kate_bans WHERE SteamID64 = %q AND ( UnbanTime > %i OR UnbanTime = 0 );', steamId64, os.time() ) )
    :SetOnSuccess( function( _, info )
      if info[1] == nil then
        return
      end

      vendor.Update(
        {
          Reason = kate.DB:Escape( unbanReason ),
          UnbanTime = os.time(),
          AdminSteamID64 = adminSteamId64,
          AdminName = kate.DB:Escape( adminName ),
          AdminIP = adminIp
        },
        info[1],
        function()
          kate.Bans.Cache[steamId64] = nil
        end
      )
    end )
    :Start()
end

local function cacheBans()
  kate.Bans.Cache = {}

  kate.DB:Query( string.format( 'SELECT * FROM kate_bans WHERE ( UnbanTime > %i OR UnbanTime = 0 );', os.time() ) )
    :SetOnSuccess( function( _, info )
      for _, details in ipairs( info ) do
        kate.Bans.Cache[details.SteamID64] = details
      end
    end )
    :Start()
end

timer.Simple( 0, cacheBans )
timer.Create( 'Kate::SyncBans', 60, 0, cacheBans )