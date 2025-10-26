local IsValid = IsValid
local CurTime = CurTime

local ENTITY = FindMetaTable( 'Entity' )
local PLAYER = FindMetaTable( 'Player' )

local IsPlayer = ENTITY.IsPlayer
local GetClass = ENTITY.GetClass
local GetEyeTrace = PLAYER.GetEyeTrace
local GetActiveWeapon = PLAYER.GetActiveWeapon
local KeyDown = PLAYER.KeyDown
local GetInfoNum = PLAYER.GetInfoNum

local function getEyeTraceCached( pl )
  local ct = CurTime()
  if pl.Kate_EyeTraceTime ~= ct then
    pl.Kate_EyeTrace = GetEyeTrace( pl )
    pl.Kate_EyeTraceTime = ct
  end
  return pl.Kate_EyeTrace
end

if SERVER then
  local function cloakWeapons( pl, shouldDraw )
    for _, wep in pairs( pl:GetWeapons() ) do
      wep:SetNoDraw( shouldDraw )
    end

    local beams = ents.FindByClassAndParent( 'physgun_beam', pl )
    if beams == nil then
      return
    end

    for i = 1, #beams do
      beams[i]:SetNoDraw( shouldDraw )
    end
  end

  function kate.Cloak( pl, shouldCloak )
    if not IsValid( pl ) then
      return false
    end

    local canCloak, failReason = hook.Run( 'Kate::PlayerCanCloak', pl, shouldCloak )
    if canCloak == false then
      return false, failReason
    end

    pl:SetNetVar( 'Kate_Cloak', shouldCloak )
    pl:SetMoveType( shouldCloak and MOVETYPE_NOCLIP or MOVETYPE_WALK )
    pl:SetNoDraw( shouldCloak )
    pl:DrawWorldModel( not shouldCloak )
    pl:SetRenderMode( shouldCloak and RENDERMODE_TRANSALPHA or RENDERMODE_NORMAL )
    pl:Fire( 'alpha', shouldCloak and 0 or 255, 0 )
    pl:SetCustomCollisionCheck( shouldCloak )
    pl:CollisionRulesChanged()

    cloakWeapons( pl, shouldCloak )

    return true
  end

  hook.Add( 'PlayerSpawn', 'Kate::Cloak', function( pl )
    local isCloaked = pl:GetNetVar( 'Kate_Cloak' )
    if not isCloaked then
      pl:SetCustomCollisionCheck( false )
      pl:CollisionRulesChanged()
      return
    end

    timer.Simple( 0, function()
      kate.Cloak( pl, isCloaked )
    end )
  end )

  hook.Add( 'PlayerSwitchWeapon', 'Kate::Cloak', function( pl )
    local isCloaked = pl:GetNetVar( 'Kate_Cloak' )
    if not isCloaked then
      return
    end

    timer.Simple( 0, function()
      cloakWeapons( pl, isCloaked )
    end )
  end )
end

hook.Add( 'ShouldCollide', 'Kate::DisableCloakCollision', function( ent1, ent2 )
  if ( not IsPlayer( ent1 ) ) or ( not IsPlayer( ent2 ) ) then
    return
  end

  local cloak1 = ent1:GetNetVar( 'Kate_Cloak' )
  local cloak2 = ent2:GetNetVar( 'Kate_Cloak' )

  if ( not cloak1 ) and ( not cloak2 ) then
    return
  end

  local function canPhysgunCollide( pl, target )
    if GetInfoNum( pl, 'kate_physgun', 1 ) ~= 1 then
      return false
    end

    local wep = GetActiveWeapon( pl )
    if wep == nil then
      return false
    end

    if not IsValid( wep ) then
      return false
    end

    if GetClass( wep ) ~= 'weapon_physgun' then
      return false
    end

    if not KeyDown( pl, IN_ATTACK ) then
      return false
    end

    local tr = getEyeTraceCached( pl )
    if tr == nil then
      return false
    end

    local ent = tr.Entity
    if ent == nil then
      return false
    end

    if not IsValid( ent ) then
      return false
    end

    if ent ~= target then
      return false
    end

    return true
  end

  if cloak1 and canPhysgunCollide( ent1, ent2 ) then
    return true
  end

  if cloak2 and canPhysgunCollide( ent2, ent1 ) then
    return true
  end

  return false
end )

hook.Add( 'Kate::PlayerCanNoclip', 'Kate::Cloak', function( pl, desired )
  if pl:GetNetVar( 'Kate_Cloak' ) and ( desired == false ) then
    return false
  end
end )
