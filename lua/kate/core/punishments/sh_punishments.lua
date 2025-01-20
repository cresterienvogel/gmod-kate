kate.Punishments = kate.Punishments or {
  Stored = {},
  Vendor = include( 'sh_vendor.lua' )
}

local vendor = {
  CreateTable = kate.Punishments.Vendor.CreateTable,
  RegisterPunishment = kate.Punishments.Vendor.RegisterPunishment,
  RegisterVars = kate.Punishments.Vendor.RegisterVars
}

function kate.AddPunishment( name, columns, vars, hooks )
  vendor.RegisterVars( columns, vars )

  if SERVER then
    vendor.CreateTable( name, columns )

    for hookName, func in pairs( hooks ) do
      hook.Add( hookName, 'Kate::' .. name, func )
    end

    local punishment = vendor.RegisterPunishment( name, columns, vars )
    timer.Simple( 0, punishment.LoadPlayersCache )
    timer.Create( 'Kate::Load' .. name, 60, 0, punishment.LoadPlayersCache )
  end
end