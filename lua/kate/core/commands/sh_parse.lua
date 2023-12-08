-- https://github.com/CapsAdmin/fast_addons/blob/8e2292711355e1fde14a71afe0f5a3bf598fe35a/lua/notagain/aowl/init.lua#L153

local s_pattern = "[\"|']"
local a_pattern	= "[ ]"
local e_pattern	= "[\\]"

function kate.ParseArgs(str)
	local ret = {}
	local instr = false
	local strchar = ""
	local chr = ""
	local escaped = false

	for i = 1, #str do
		local char = str[i]

		if escaped then
			chr = chr .. char
			escaped = false
			continue
		end

		if string.find(char, s_pattern) and (not instr) and (not escaped) then
			instr = true
			strchar = char
		elseif string.find(char, e_pattern) then
			escaped = true
			continue
		elseif instr and (char == strchar) then
			ret[#ret + 1] = string.Trim(chr)
			chr = ""
			instr = false
		elseif string.find(char, a_pattern) and (not instr) then
			if chr ~= "" then
				ret[#ret + 1] = chr
				chr = ""
			end
		else
			chr = chr .. char
		end
	end

	if utf8.len(string.Trim(chr)) ~= 0 then
		ret[#ret + 1] = chr
	end

	return ret
end