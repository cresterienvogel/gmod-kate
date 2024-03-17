local PANEL = {}

AccessorFunc(PANEL, "m_bFromBottom", "FromBottom", FORCE_BOOL)
AccessorFunc(PANEL, "m_iVBarPadding", "VBarPadding", FORCE_NUMBER)

PANEL.Speed = 6
PANEL.NoOverrideClear = true

function PANEL:Init()
	self:SetVBarPadding(0)

	local canvas = self:GetCanvas()

	local children = {}

	do
		function canvas:OnChildAdded(child)
			children[#children + 1] = child
		end

		function canvas:OnChildRemoved(child)
			for i = 1, #children do
				local v = children[i]
				if v == child then
					children[i] = nil
					return
				end
			end
		end

		canvas.GetChildren = function()
			return children
		end

		canvas.children = children
	end

	local vBar = self.VBar

	vBar:SetHideButtons(true)
	vBar.btnUp:SetVisible(false)
	vBar.btnDown:SetVisible(false)

	vBar.ScrollTarget = 0
	vBar.ScrollSpeed = self.Speed

	do
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
	end
end

function PANEL:OnChildAdded(child)
	self:AddItem(child)
	self:ChildAdded(child)
end

function PANEL:ChildAdded()

end

function PANEL:ScrollToBottom()
	local vBar = self.VBar

	for k, anim in pairs(vBar.m_AnimList or {}) do
		anim:Think(vBar, 1)
		vBar.m_AnimList[k] = nil
	end

	self:InvalidateParent(true)
	self:InvalidateChildren(true)

	vBar:SetScroll(vBar.CanvasSize)
end

function PANEL:PerformLayoutInternal(w, h)
	w = w or self:GetWide()
	h = h or self:GetTall()

	local canvas = self.pnlCanvas

	self:Rebuild()

	local vBar = self.VBar
	vBar:SetUp(h, canvas:GetTall())

	if vBar.Enabled then
		w = w - vBar:GetWide() - self.m_iVBarPadding
	end

	canvas:SetWide(w)

	self:Rebuild()
end

function PANEL:Think()
	local canvas = self.pnlCanvas
	local vBar = self.VBar

	if vBar.Enabled then
		canvas.y = -vBar.Scroll
		return
	end

	canvas._y = Lerp(
		RealFrameTime() * 14,
		canvas._y or canvas.y,
		self:GetFromBottom() and (self:GetTall() - canvas:GetTall()) or -vBar.Scroll
	)

	canvas.y = canvas._y
end

vgui.Register("KScrollPanel", PANEL, "DScrollPanel")