local PANEL = {}

function PANEL:Init()
	self:SetSizable(true)

	do
		self.btnMaxim:SetEnabled(true)

		self.btnMaxim.DoClick = function(s)
			self.Width, self.Height = self:GetSize()
			self.PosX, self.PosY = self:GetPos()

			self:SetSize(ScrW(), ScrH())
			self:SetPos(0, 0)

			s:SetEnabled(false)
			self.btnMinim:SetEnabled(true)
		end
	end

	do
		self.btnMinim.DoClick = function(s)
			self:SetSize(self.Width, self.Height)
			self:SetPos(self.PosX, self.PosY)

			s:SetEnabled(false)
			self.btnMaxim:SetEnabled(true)
		end
	end
end

vgui.Register("KFrame", PANEL, "DFrame")