local Vector = Vector
local FindInSphere = ents.FindInSphere
local PointContents = util.PointContents

local BLACKLIST = {
  [CONTENTS_SOLID] = true,
  [CONTENTS_MOVEABLE] = true,
  [CONTENTS_LADDER] = true,
  [CONTENTS_PLAYERCLIP] = true,
  [CONTENTS_MONSTERCLIP] = true
}

function kate.IsPosEmpty( pos, area )
  if BLACKLIST[PointContents( pos )] ~= nil then
    return false
  end

  if not util.IsInWorld( pos ) then
    return false
  end

  local entities = FindInSphere( pos, area or 35 )
  for i = 1, #entities do
    local ent = entities[i]

    if ent:GetClass() == 'prop_physics' then
      return false
    end

    if ( type( ent ) == 'Player' ) and ( ent:Health() > 0 ) then
      return false
    end

    if ( type( ent ) == 'NPC' ) and ( ent:Health() > 0  ) then
      return false
    end
  end

  return true
end

function kate.FindEmptyPos( pos, area, steps )
  pos = Vector( pos.x, pos.y, pos.z )
  area = area or 35
  steps = steps or 6

  if kate.IsPosEmpty( pos, area ) then
    return pos
  end

  for i = 1, steps do
    local step = ( i * 50 )

    if kate.IsPosEmpty( Vector( pos.x + step, pos.y, pos.z ), area ) then
      pos.x = pos.x + step

      return pos
    end

    if kate.IsPosEmpty( Vector( pos.x, pos.y + step, pos.z ), area ) then
      pos.y = pos.y + step

      return pos
    end

    if kate.IsPosEmpty( Vector( pos.x, pos.y, pos.z + step ), area ) then
      pos.z = pos.z + step

      return pos
    end
  end

  return pos
end