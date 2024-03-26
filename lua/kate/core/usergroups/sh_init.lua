function kate.CanTarget( pl, target )
  if ( not IsValid( target ) ) or ( not IsValid( pl ) ) then
    return false
  end

  return pl:GetRelevance() >= target:GetRelevance()
end

function kate.GetAdmins()
  local ret = {}
  for _, pl in ipairs( player.GetAll() ) do
    if pl:GetRelevance() > 0 then
      ret[#ret + 1] = pl
    end
  end

  return ret
end