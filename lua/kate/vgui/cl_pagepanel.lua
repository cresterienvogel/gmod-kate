local PANEL = {}

PANEL.Speed = 17

AccessorFunc(PANEL, "m_iMaxPerPage", "MaxPerPage", FORCE_NUMBER)

function PANEL:Init()
	self.Page = 1

	self.Pages = {}
	self.Columns = {}

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
			local dMenu = DermaMenu()
			dMenu:SetPos(input.GetCursorPos())

			for i, column in ipairs(s.Columns) do
				dMenu:AddOption("Copy " .. column.Header:GetText(), function()
					local pseudo = row.PseudoColumns[i]
					SetClipboardText(pseudo and pseudo:GetValue() or row:GetColumnText(i))
				end)
			end

			local options = self.Options

			if options then
				for _, data in pairs(options) do
					for i, column in ipairs(s.Columns) do
						if column.Header:GetText() == data.parsed then
							dMenu:AddOption(data.name, function()
								data.func(row:GetColumnText(i))
							end)
						end
					end
				end
			end

			dMenu:Open()
		end

		local vBar = view.VBar

		vBar:SetHideButtons(true)
		vBar.btnUp:SetVisible(false)
		vBar.btnDown:SetVisible(false)

		vBar.ScrollTarget = 0
		vBar.ScrollSpeed = self.Speed

		vBar.OnMouseWheeled = function(s, delta)
			s.ScrollSpeed = s.ScrollSpeed + (RealFrameTime() * 14)
			s:AddScroll(delta * -s.ScrollSpeed)
		end

		vBar.SetScroll = function(s, amount)
			if not s.Enabled then
				s.Scroll = 0
				return
			end

			s.ScrollTarget = amount
			s:InvalidateLayout()
		end

		vBar.OnCursorMoved = function(s, _, y)
			if not s.Dragging then
				return
			end

			y = y - s.HoldPos
			y = y / (s:GetTall() - s:GetWide() * 2 - s.btnGrip:GetTall())

			s.ScrollTarget = y * s.CanvasSize
		end

		vBar.Think = function(s)
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

		vBar.PerformLayout = function(s, w, h)
			local scroll = s:GetScroll() / s.CanvasSize
			local barSize = math.max(s:BarScale() * h, 10)

			local track = (h - barSize) + 1
			scroll = scroll * track

			s.btnGrip.y = scroll
			s.btnGrip:SetSize(w, barSize)
		end

		view.Think = function(s)
			local canvas = s.pnlCanvas

			canvas.y = vBar.Enabled and -vBar.Scroll or Lerp(
				RealFrameTime() * 14,
				canvas._y or canvas.y,
				-vBar.Scroll
			)
		end

		self.ListView = view
	end
end

function PANEL:SetPage(n, forced)
	if (not forced) and (self.Page == n) then
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
	tbl = tbl or {}

	if not self.InitData then
		local ratings = {}

		for column, data in ipairs(tbl) do
			ratings[data] = 0

			for _, value in pairs(data) do
				local validTimeRating, timeRating = kate.RatingFromTime(value)
				local validDateRating, dateRating = kate.RatingFromDate(value)

				if validTimeRating or validDateRating then
					ratings[data] = timeRating or dateRating
					self.RatingColumn = column
					break
				end
			end
		end

		table.sort(tbl, function(a, b)
			return ratings[a] > ratings[b]
		end)

		self.InitData = tbl
	end

	self.Data = tbl

	self.Pages = {}
	self.Columns = {}

	local page, handled = 1, 0
	for i, data in ipairs(tbl) do
		if handled == self:GetMaxPerPage() then
			page = page + 1
			handled = 0
		end

		self.Pages[page] = self.Pages[page] or {}
		self.Pages[page][#self.Pages[page] + 1] = data

		handled = handled + 1
	end

	local view = self.ListView
	if tbl[1] and (#view.Columns == 0) then
		for param in pairs(tbl[1]) do
			view:AddColumn(param)
			self.Columns[param] = table.Count(self.Columns) + 1
		end
	end
end

PANEL.DataFound = {}
PANEL.DataAdded = {}

function PANEL:Build(page)
	page = page or 1

	local pageData = self.Pages[page]
	if not pageData then
		goto buildPage
	end

	for i, data in ipairs(pageData) do
		local lineData = table.ClearKeys(data)

		local line = self.ListView:AddLine(unpack(lineData))
		line.PseudoColumns = {}

		for k, value in ipairs(lineData) do
			local validTimeRating, ratingTimeNumber = kate.RatingFromTime(value)
			local validDateRating, ratingDateNumber = kate.RatingFromDate(value)

			if not (validTimeRating or validDateRating) then
				continue
			end

			do
				local pseudo = vgui.Create("DListViewLabel", line)
				pseudo:SetMouseInputEnabled(false)
				pseudo:SetText(tostring(value))
				pseudo.Value = value

				line.PseudoColumns[k] = pseudo
			end

			line:SetValue(k, ratingTimeNumber or ratingDateNumber)
		end

		line.SetSelected = function(s, bool)
			s.m_bSelected = bool

			for k, column in pairs(s.Columns) do
				column:ApplySchemeSettings()

				local pseudo = s.PseudoColumns[k]
				if pseudo then
					pseudo:ApplySchemeSettings()
				end
			end
		end

		line.DataLayout = function(s, listView)
			s:ApplySchemeSettings()

			local x = 0
			local height = s:GetTall()

			for k, column in pairs(s.Columns) do
				local w = listView:ColumnWidth(k)

				column:SetPos(x, 0)
				column:SetSize(w, height)

				local pseudo = s.PseudoColumns[k]
				if pseudo then
					column:SetVisible(false)
					pseudo:SetPos(x, 0)
					pseudo:SetSize(w, height)
				end

				x = x + w
			end
		end
	end

	::buildPage::
	do
		local onChange = function(s, searched)
			searched = string.Trim(string.lower(searched))

			self.DataAdded = {}
			self.DataFound = {}

			if (not searched) or (searched == "") then
				if util.TableToJSON(self.Data) ~= util.TableToJSON(self.InitData) then
					self:SetData(self.InitData)
					self:SetPage(1, true)
				end

				return
			end

			for i, data in ipairs(self.InitData) do
				local json = util.TableToJSON(data)

				for field, value in pairs(data) do
					value = string.lower(tostring(value))

					local searchBy = self.SearchBy:GetSelected()
					if searchBy and searchBy ~= "all fields" then
						if (not self.DataAdded[json]) and (field == searchBy) and string.find(value, searched) then
							self.DataFound[#self.DataFound + 1] = data
							self.DataAdded[json] = true
						end
					else
						if (not self.DataAdded[json]) and string.find(value, searched) then
							self.DataFound[#self.DataFound + 1] = data
							self.DataAdded[json] = true
						end
					end
				end
			end

			self:SetData(self.DataFound)
			self:SetPage(1, true)
		end

		self.TextEntry.OnValueChange = onChange

		self.SearchBy.OnSelect = function(s, searchBy)
			local entryValue = self.TextEntry:GetValue()
			onChange(s, searchBy)

			if entryValue and (entryValue ~= "") then
				timer.Simple(0, function()
					if IsValid(self) then
						self.TextEntry:SetValue(entryValue)
					end
				end)
			end
		end
	end

	local ratingColumn = self.RatingColumn
	if ratingColumn then
		self.ListView:SortByColumn(ratingColumn, true)
	end
end

vgui.Register("KPagePanel", PANEL, "DPanel")