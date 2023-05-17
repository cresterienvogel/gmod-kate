local PANEL = {}

function PANEL:Init()
	self.Data = {}

	self:MakePopup()

	self.Fill = vgui.Create("DPanel", self)
	self.Fill:Dock(FILL)
	self.Fill:DockMargin(2, 2, 2, 2)
end

function PANEL:SetQueries(q)
	self.Queries = q
end

function PANEL:GetQueries()
	return self.Data
end

function PANEL:SetPlayer(id)
	self.Player = id
end

function PANEL:SetFunction(func)
	self.Function = func
end

function PANEL:Build()
	local queries = self.Queries

	self:SetTall(38 + (table.Count(queries) + 1) * 28)

	for i, query in ipairs(queries) do
		local entry = vgui.Create("DTextEntry", self.Fill)
		entry:Dock(TOP)
		entry:DockMargin(2, 2, 2, 2)
		entry:SetTall(24)
		entry:SetPlaceholderText(query)

		entry.Think = function(s)
			local val = s:GetValue()
			self.Data[i] = val ~= "" and val or nil
		end
	end

	local btn = vgui.Create("DButton", self.Fill)
	btn:SetText("Done")
	btn:Dock(TOP)
	btn:DockMargin(2, 2, 2, 2)
	btn:SetTall(24)

	btn.DoClick = function()
		self:Close()
		self.Function()
	end
end

vgui.Register("KQuery", PANEL, "DFrame")