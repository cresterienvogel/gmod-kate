local PLAYER = FindMetaTable( 'Player' )

function PLAYER:GetUserGroupInfo()
  return kate.UserGroups.Stored[self:GetUserGroup()]
end

function PLAYER:IsAdmin()
  local info = self:GetUserGroupInfo()
  if info == nil then
    return false
  end

  return info:IsAdmin()
end

function PLAYER:IsSuperAdmin()
  local info = self:GetUserGroupInfo()
  if info == nil then
    return false
  end

  return info:IsSuperAdmin()
end

function PLAYER:HasFlag( flag )
  local info = self:GetUserGroupInfo()
  if info == nil then
    return false
  end

  return info:HasFlag( flag )
end

function PLAYER:GetFlags()
  local info = self:GetUserGroupInfo()
  if info == nil then
    return {}
  end

  return info:GetFlags()
end

function PLAYER:GetRelevance()
  local info = self:GetUserGroupInfo()
  if info == nil then
    return 0
  end

  return info:GetRelevance()
end

function PLAYER:GetRank()
  local info = self:GetUserGroupInfo()
  if info == nil then
    return 'User'
  end

  return info:GetName()
end

function PLAYER:CanTarget( target )
  return kate.CanTarget( self, target )
end