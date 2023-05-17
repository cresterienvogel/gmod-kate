local speed = 6

local PANEL = {}

AccessorFunc(PANEL, "m_bFromBottom", "FromBottom", FORCE_BOOL)
AccessorFunc(PANEL, "m_bVBarPadding", "VBarPadding", FORCE_NUMBER)

PANEL:SetVBarPadding(0)

PANEL.NoOverrideClear = true

function PANEL:Init()
	local canvas = self:GetCanvas()

	local children = {}

	do
		function canvas:OnChildAdded(child)
			table.insert(children, child)
		end

		function canvas:OnChildRemoved(child)
			for i = 1, #children do
				local v = children[i]
				if v == child then
					table.remove(children, i)
					return
				end
			end
		end

		canvas.GetChildren = function()
			return children
		end

		canvas.children = children
	end

	local vbar = self.VBar
	vbar:SetHideButtons(true)
	vbar.btnUp:SetVisible(false)
	vbar.btnDown:SetVisible(false)

	vbar.ScrollTarget = 0
	vbar.ScrollSpeed = speed

	do
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
	end
end

function PANEL:OnChildAdded(child)
	self:AddItem(child)
	self:ChildAdded(child)
end

function PANEL:ChildAdded()

end

function PANEL:ScrollToBottom()
	local vbar = self.VBar
	for k, anim in pairs(vbar.m_AnimList or {}) do
		anim:Think(vbar, 1)
		vbar.m_AnimList[k] = nil
	end

	self:InvalidateParent(true)
	self:InvalidateChildren(true)

	vbar:SetScroll(vbar.CanvasSize)
end

function PANEL:PerformLayoutInternal(w, h)
	w = w or self:GetWide()
	h = h or self:GetTall()

	local canvas = self.pnlCanvas

	self:Rebuild()

	local vbar = self.VBar
	vbar:SetUp(h, canvas:GetTall())

	if vbar.Enabled then
		w = w - vbar:GetWide() - self.m_bVBarPadding
	end

	canvas:SetWide(w)

	self:Rebuild()
end

function PANEL:Think()
	local canvas = self.pnlCanvas

	local vbar = self.VBar
	if vbar.Enabled then
		canvas.y = -vbar.Scroll
	else
		if self:GetFromBottom() then
			canvas._y = Lerp(14 * RealFrameTime(), canvas._y or canvas.y, self:GetTall() - canvas:GetTall())
		else
			canvas._y = Lerp(14 * RealFrameTime(), canvas._y or canvas.y, -vbar.Scroll)
		end

		canvas.y = canvas._y
	end
end

vgui.Register("KScrollPanel", PANEL, "DScrollPanel")