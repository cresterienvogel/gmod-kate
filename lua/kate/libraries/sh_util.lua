function kate.StripPort( ip )
  local pos = string.find( ip, ':' )

  return ( pos == nil ) and ip or string.sub( ip, 1, pos - 1 )
end