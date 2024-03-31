kate = kate or {}

CreateClientConVar( 'kate_physgun', '1', true, true,
  'Enable/disable whether you can pick up players with physgun',
  0, 1
)

local vendor = {
  ['sv_'] = function( fileName, fileDir )
    if SERVER then
      include( fileDir .. fileName )
    end
  end,
  ['cl_'] = function( fileName, fileDir )
    if SERVER then
      AddCSLuaFile( fileDir .. fileName )
    else
      include( fileDir .. fileName )
    end
  end,
  ['sh_'] = function( fileName, fileDir )
    if SERVER then
      AddCSLuaFile( fileDir .. fileName )
    end

    include( fileDir .. fileName )
  end
}

local function includeFile( fileName, fileDir )
  local filePrefix = string.lower( string.Left( fileName, 3 ) )

  local includeFunc = vendor[filePrefix]
  if includeFunc == nil then
    return
  end

  includeFunc( fileName, fileDir )
end

local function includeDir( curDir, isRecursive )
  curDir = curDir .. '/'

  local filesOfDir, dirsOfDir = file.Find( curDir .. '*', 'LUA' )

  for _, includable in ipairs( filesOfDir ) do
    includeFile( includable, curDir )
  end

  if isRecursive then
    for _, includable in ipairs( dirsOfDir ) do
      includeDir( curDir .. includable, true )
    end
  end
end

includeDir( 'kate/libraries', true )
includeDir( 'kate/core', true )
includeDir( 'kate/modules', true )