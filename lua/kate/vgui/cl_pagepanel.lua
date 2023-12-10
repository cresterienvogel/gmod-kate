local PANEL = {}

PANEL.Speed = 17

AccessorFunc(PANEL, "m_iMaxPerPage", "MaxPerPage", FORCE_NUMBER)

function PANEL:Init()
	self.Players = {}
	self.Page = 1

	local parent = self:GetParent()
	local wide = parent:GetWide() / 6

	local top, bottom

	-- page panel
	do
		-- main panels
		do
			top = vgui.Create("EditablePanel", self)
			top:Dock(TOP)
			top:DockMargin(2, 2, 2, 2)
			top:SetTall(28)

			bottom = vgui.Create("EditablePanel", self)
			bottom:Dock(BOTTOM)
			bottom:DockMargin(2, 2, 2, 2)
			bottom:SetTall(parent:GetTall() / 22)
		end

		-- first
		do
			local btn = vgui.Create("DButton", bottom)
			btn:SetText("<<")
			btn:SetWide(wide)
			btn:Dock(LEFT)
			btn:DockMargin(1, 1, 1, 1)

			btn.DoClick = function()
				self:SetPage(1)
			end
		end

		-- prev
		do
			local btn = vgui.Create("DButton", bottom)
			btn:SetText("<")
			btn:SetWide(wide)
			btn:Dock(LEFT)
			btn:DockMargin(1, 1, 1, 1)

			btn.DoClick = function()
				self:SetPage(math.Clamp(self.Page - 1, 1, #self.Pages))
			end
		end

		-- current
		do
			local entry = vgui.Create("DTextEntry", bottom)
			entry:SetValue(1)
			entry:SetContentAlignment(5)
			entry:SetWide(wide)

			entry:Dock(FILL)
			entry:DockMargin(1, 1, 1, 1)

			entry:SetNumeric(true)

			entry.Think = function(s)
				local val = s:GetValue()

				if string.find(val, "/") then
					val = tonumber(string.Explode("/", val)[1])
				end

				if val == 0 then
					val = 1
				end

				local pages = self.Pages
				self:SetPage(math.Clamp(val ~= "" and val or 1, 1, #pages))
				s:SetValue(s:IsEditing() and val or (val .. "/" .. (#pages == 0 and 1 or #pages)))
			end

			bottom.Entry = entry
		end

		-- last
		do
			local btn = vgui.Create("DButton", bottom)
			btn:SetText(">>")
			btn:SetWide(wide)
			btn:Dock(RIGHT)
			btn:DockMargin(1, 1, 1, 1)

			btn.DoClick = function()
				self:SetPage(#self.Pages)
			end
		end

		-- next
		do
			local btn = vgui.Create("DButton", bottom)
			btn:SetText(">")
			btn:SetWide(wide)
			btn:Dock(RIGHT)
			btn:DockMargin(1, 1, 1, 1)

			btn.DoClick = function()
				self:SetPage(math.Clamp(self.Page + 1, 1, #self.Pages))
			end
		end

		self.PagePanel = bottom
	end

	-- text entry
	do
		local entry = vgui.Create("DTextEntry", top)
		entry:SetPlaceholderText("Any data to find...")
		entry:SetUpdateOnType(true)
		entry:Dock(FILL)

		self.TextEntry = entry
	end

	-- reset button
	do
		local btn = vgui.Create("DButton", top)
		btn:SetText("")
		btn:SetIcon("icon16/arrow_rotate_clockwise.png")
		btn:Dock(RIGHT)
		btn:DockMargin(2, 0, 0, 0)
		btn:SetWide(24)

		btn.DoClick = function()
			self.SearchBy:SetValue("all fields")
			self.TextEntry:SetValue("")
		end
	end

	-- search by row
	do
		local combo = vgui.Create("DComboBox", top)
		combo:SetValue("all fields")
		combo:Dock(RIGHT)
		combo:SizeToContents()
		combo:SetWide(combo:GetWide() * 2)
		combo:DockMargin(2, 0, 0, 0)

		combo:AddChoice("all fields")

		-- let fields load
		timer.Simple(0.01, function()
			local data = self.Data
			if not data then
				return
			end

			local eg = data[1]
			if not eg then
				return
			end

			for field in pairs(eg) do
				combo:AddChoice(field)
			end
		end)

		self.SearchBy = combo
	end

	-- data list
	do
		local view = vgui.Create("DListView", self)
		view:Dock(FILL)
		view:DockMargin(2, 2, 2, 2)

		view:SetMultiSelect(false)

		view.OnRowRightClick = function(s, id, row)
			local dmenu = DermaMenu()
			dmenu:SetPos(input.GetCursorPos())

			for i, column in ipairs(s.Columns) do
				dmenu:AddOption("Copy " .. column.Header:GetText(), function()
					SetClipboardText(row:GetColumnText(i))
				end)
			end

			local options = self.Options

			if options then
				for _, data in pairs(options) do
					for i, column in ipairs(s.Columns) do
						if column.Header:GetText() == data.parsed then
							dmenu:AddOption(data.name, function()
								data.func(row:GetColumnText(i))
							end)
						end
					end
				end
			end

			dmenu:Open()
		end

		local vbar = view.VBar

		vbar:SetHideButtons(true)
		vbar.btnUp:SetVisible(false)
		vbar.btnDown:SetVisible(false)

		vbar.ScrollTarget = 0
		vbar.ScrollSpeed = self.Speed

		vbar.OnMouseWheeled = function(s, delta)
			s.ScrollSpeed = s.ScrollSpeed + (RealFrameTime() * 14)
			s:AddScroll(delta * -s.ScrollSpeed)
		end

		vbar.SetScroll = function(s, amount)
			if not s.Enabled then
				s.Scroll = 0
				return
			end

			s.ScrollTarget = amount
			s:InvalidateLayout()
		end

		vbar.OnCursorMoved = function(s, _, y)
			if not s.Dragging then
				return
			end

			y = y - s.HoldPos
			y = y / (s:GetTall() - s:GetWide() * 2 - s.btnGrip:GetTall())

			s.ScrollTarget = y * s.CanvasSize
		end

		vbar.Think = function(s)
			local frameTime = RealFrameTime() * 14
			local scrollTarget = s.ScrollTarget

			s.Scroll = Lerp(
				frameTime,
				s.Scroll,
				scrollTarget
			)

			if not s.Dragging then
				s.ScrollTarget = Lerp(
					frameTime,
					scrollTarget,
					math.Clamp(scrollTarget, 0, s.CanvasSize)
				)
			end

			s.ScrollSpeed = Lerp(
				frameTime / 14,
				s.ScrollSpeed,
				self.Speed
			)
		end

		vbar.PerformLayout = function(s, w, h)
			local scroll = s:GetScroll() / s.CanvasSize
			local barSize = math.max(s:BarScale() * h, 10)

			local track = (h - barSize) + 1
			scroll = scroll * track

			s.btnGrip.y = scroll
			s.btnGrip:SetSize(w, barSize)
		end

		view.Think = function(s)
			local canvas = s.pnlCanvas

			canvas.y = vbar.Enabled and -vbar.Scroll or Lerp(
				RealFrameTime() * 14,
				canvas._y or canvas.y,
				-vbar.Scroll
			)
		end

		self.ListView = view
	end
end

function PANEL:SetPage(n)
	if self.Page == n then
		return
	end

	self.Page = math.Clamp(n, 1, #self.Pages)
	self.PagePanel.Entry:SetValue(self.Page)

	self.ListView:Clear()
	self:Build(self.Page)
end

function PANEL:AddOption(name, func, parsed)
	self.Options = self.Options or {}

	self.Options[#self.Options + 1] = {
		name = name,
		func = func,
		parsed = parsed
	}
end

function PANEL:SetData(tbl)
	if not self.InitData then -- const
		self.InitData = tbl
	end

	self.Data = tbl

	self.Pages = {}
	self.Columns = {}

	local page = 0
	for i, data in ipairs(tbl) do
		if (i % self:GetMaxPerPage()) == 0 then
			page = page + 1
		end

		self.Pages[page] = self.Pages[page] or {}
		self.Pages[page][#self.Pages[page] + 1] = data
	end

	local eg = tbl[1]
	local view = self.ListView
	if eg and (#view.Columns == 0) then
		for param in pairs(eg) do
			view:AddColumn(param)
			self.Columns[param] = table.Count(self.Columns) + 1
		end
	end
end

function PANEL:Build(page)
	page = page or 1

	do
		local tbl = self.Pages[page]
		if tbl then
			for i, data in ipairs(tbl) do
				self.ListView:AddLine(unpack(table.ClearKeys(data)))
			end
		end
	end

	do
		local tbl, added = {}, {}

		local onChange = function(s, val)
			added = {}

			if (not val) or (val == "") then
				tbl = {}

				if util.TableToJSON(self.Data) ~= util.TableToJSON(self.InitData) then
					self:SetData(self.InitData)
					self:Build()
					self:SetPage(1)
				end

				return
			end

			val = string.lower(val)

			for i, data in ipairs(self.InitData) do
				local json = util.TableToJSON(data)

				for field, value in pairs(data) do
					value = string.lower(tostring(value))

					local searchBy = self.SearchBy:GetSelected()
					if searchBy and searchBy ~= "all fields" then
						if (not added[json]) and (field == searchBy) and string.find(value, val) then
							tbl[#tbl + 1] = data
							added[json] = true
						end
					else
						if (not added[json]) and string.find(value, val) then
							tbl[#tbl + 1] = data
							added[json] = true
						end
					end
				end
			end

			self:SetData(tbl)
			self:Build()
			self:SetPage(1)
		end

		self.TextEntry.OnValueChange = onChange

		self.SearchBy.OnSelect = function(s, val)
			local entry_val = self.TextEntry:GetValue()
			if entry_val and (entry_val ~= "") then
				self.TextEntry:SetValue(entry_val)
				onChange(s, val)
			end
		end
	end
end

vgui.Register("KPagePanel", PANEL, "DPanel")