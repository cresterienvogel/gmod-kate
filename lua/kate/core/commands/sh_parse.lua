-- https://github.com/CapsAdmin/fast_addons/blob/8e2292711355e1fde14a71afe0f5a3bf598fe35a/lua/notagain/aowl/init.lua#L153

local stringPattern = "[\"|']"
local argSepPattern = "[ ]"
local escapePattern = "[\\]"

function kate.ParseArgs(str)
	local ret = {}

	local strChar = ""
	local chr = ""

	local inStr = false
	local escaped = false

	for i = 1, #str do
		local char = str[i]

		if escaped then
			chr = chr .. char
			escaped = false
			continue
		end

		if string.find(char, stringPattern) and (not inStr) and (not escaped) then
			inStr = true
			strChar = char
		elseif string.find(char, escapePattern) then
			escaped = true
			continue
		elseif inStr and (char == strChar) then
			ret[#ret + 1] = string.Trim(chr)
			chr = ""
			inStr = false
		elseif string.find(char, argSepPattern) and (not inStr) then
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