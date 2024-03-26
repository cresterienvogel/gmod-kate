kate.UserGroups = kate.UserGroups or {
  Stored = {},
  Cache = {}
}

local USERGROUP = {}
USERGROUP.__index = USERGROUP

function kate.AddUserGroup( name )
  local id = string.gsub( string.lower( name ), ' ', '' )

  local NEW_USERGROUP = {
    Id = id,
    Name = name,
    Flags = {}
  }

  setmetatable( NEW_USERGROUP, USERGROUP )
  kate.UserGroups.Stored[id] = NEW_USERGROUP

  return NEW_USERGROUP
end

function USERGROUP:SetFlags( flags )
  if type( flags ) == 'string' then
    self.Flags[flags] = true

    return self
  end

  for _, flag in ipairs( flags ) do
    self.Flags[flag] = true
  end

  return self
end

function USERGROUP:SetRelevance( amount )
  self.Relevance = amount

  return self
end

function USERGROUP:SetAdmin( bool )
  self.Admin = bool

  return self
end

function USERGROUP:SetSuperAdmin( bool )
  self.SuperAdmin = bool

  return self
end

function USERGROUP:GetName()
  return self.Name
end

function USERGROUP:GetFlag( flag )
  return ( self.Flags['*'] and true ) or ( self.Flags[flag] or false )
end

function USERGROUP:GetFlags()
  return self.Flags
end

function USERGROUP:GetRelevance()
  return self.Relevance
end

function USERGROUP:IsAdmin()
  return ( self.SuperAdmin == true ) or ( self.Admin == true )
end

function USERGROUP:IsSuperAdmin()
  return self.SuperAdmin == true
end