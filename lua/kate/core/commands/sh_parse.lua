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

		if char:find(s_pattern) and not instr and not escaped then
			instr = true
			strchar = char
		elseif char:find(e_pattern) then
			escaped = true
			continue
		elseif instr and char == strchar then
			table.insert(ret, chr:Trim())
			chr = ""
			instr = false
		elseif char:find(a_pattern) and not instr then
			if chr ~= "" then
				table.insert(ret, chr)
				chr = ""
			end
		else
			chr = chr .. char
		end
	end

	if chr:Trim():len() ~= 0 then
		table.insert(ret, chr)
	end

	return ret
end