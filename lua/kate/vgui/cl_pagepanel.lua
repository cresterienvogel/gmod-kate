local speed = 17

local PANEL = {}

AccessorFunc(PANEL, "max_per_page", "MaxPerPage", FORCE_NUMBER)

function PANEL:Init()
	self.Players = {}
	self.Page = 1

	local parent = self:GetParent()
	local wide = parent:GetWide() / 6

	-- page panel
	do
		local pnl = vgui.Create("EditablePanel", self)
		pnl:Dock(BOTTOM)
		pnl:DockMargin(2, 2, 2, 2)
		pnl:SetTall(parent:GetTall() / 22)

		-- first
		do
			local btn = vgui.Create("DButton", pnl)
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
			local btn = vgui.Create("DButton", pnl)
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
			local entry = vgui.Create("DTextEntry", pnl)
			entry:SetValue(1)
			entry:SetContentAlignment(5)
			entry:SetWide(wide)

			entry:Dock(FILL)
			entry:DockMargin(1, 1, 1, 1)

			entry:SetNumeric(true)

			entry.Think = function(s)
				local val = s:GetValue()
				if val:find("/") then
					val = tonumber(string.Explode("/", val)[1])
				end

				if val == 0 then
					val = 1
				end

				local pages = self.Pages
				self:SetPage(math.Clamp(val ~= "" and val or 1, 1, #pages))
				s:SetValue(s:IsEditing() and val or (val .. "/" .. (#pages == 0 and 1 or #pages)))
			end

			pnl.Entry = entry
		end

		-- last
		do
			local btn = vgui.Create("DButton", pnl)
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
			local btn = vgui.Create("DButton", pnl)
			btn:SetText(">")
			btn:SetWide(wide)
			btn:Dock(RIGHT)
			btn:DockMargin(1, 1, 1, 1)

			btn.DoClick = function()
				self:SetPage(math.Clamp(self.Page + 1, 1, #self.Pages))
			end
		end

		self.PagePanel = pnl
	end

	-- text entry
	do
		local entry = vgui.Create("DTextEntry", self)
		entry:SetPlaceholderText("Any data to find...")
		entry:Dock(TOP)
		entry:DockMargin(2, 2, 2, 2)
		entry:SetTall(28)

		self.TextEntry = entry
	end

	-- data list
	do
		local view = vgui.Create("DListView", self)
		view:Dock(FILL)
		view:DockMargin(2, 2, 2, 2)

		view:SetMultiSelect(false)

		view.OnRowSelected = function(s, id, row)
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
		vbar.ScrollSpeed = speed

		vbar.OnMouseWheeled = function(s, delta)
			s.ScrollSpeed = s.ScrollSpeed + (14 * RealFrameTime())
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
			if s.Dragging then
				y = y - s.HoldPos
				y = y / (s:GetTall() - s:GetWide() * 2 - s.btnGrip:GetTall())
				s.ScrollTarget = y * s.CanvasSize
			end
		end

		vbar.Think = function(s)
			local frame_time = RealFrameTime() * 14
			local scroll_target = s.ScrollTarget

			s.Scroll = Lerp(frame_time, s.Scroll, scroll_target)

			if not s.Dragging then
				s.ScrollTarget = Lerp(frame_time, scroll_target, math.Clamp(scroll_target, 0, s.CanvasSize))
			end

			s.ScrollSpeed = Lerp(frame_time / 14, s.ScrollSpeed, speed)
		end

		vbar.PerformLayout = function(s, w, h)
			local scroll = s:GetScroll() / s.CanvasSize
			local bar_size = math.max(s:BarScale() * h, 10)

			local track = (h - bar_size) + 1
			scroll = scroll * track

			s.btnGrip.y = scroll
			s.btnGrip:SetSize(w, bar_size)
		end

		view.Think = function(s)
			local canvas = s.pnlCanvas
			canvas.y = vbar.Enabled and -vbar.Scroll or Lerp(14 * RealFrameTime(), canvas._y or canvas.y, -vbar.Scroll)
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

	local page = 0
	for i, data in ipairs(tbl) do
		if i % self:GetMaxPerPage() == 0 then
			page = page + 1
		end

		self.Pages[page] = self.Pages[page] or {}
		self.Pages[page][#self.Pages[page] + 1] = data
	end

	local view = self.ListView
	if tbl[1] and #view.Columns == 0 then
		for param in pairs(tbl[1]) do
			view:AddColumn(param)
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
		local tbl = {}
		self.TextEntry.OnChange = function(s)
			local val = s:GetValue()
			if val == "" then
				tbl = {}
				if #self.Data ~= #self.InitData then
					self:SetData(self.InitData)
					self:Build()
				end
				return
			end

			for i, data in ipairs(self.InitData) do
				for _, v in pairs(data) do
					if v:find(val) then
						tbl[#tbl + 1] = data
					end
				end
			end

			self:SetData(tbl)
			self:Build()
			self:SetPage(1)
		end
	end
end

vgui.Register("KPagePanel", PANEL, "DPanel")