do
	kate.Commands:Register("teleport", function(self, pl, args)
		local target = args.target

		target:SetReturnPos(target:GetPos())
		target:SetPos(pl:GetEyeTrace().HitPos)

		do
			local msg = string.format("%s has teleported %s",
				kate.GetExecuter(pl),
				kate.GetTarget(target)
			)

			kate.Print(3, msg)
			kate.Message(kate.GetAdmins(), 3, msg)
		end
	end)
	:SetTitle("Teleport")
	:SetCategory("Teleport")
	:SetIcon("icon16/arrow_down.png")
	:SetImmunity(1000)
	:SetArgs("Target")
	:SetSelfRun(false)
	:SetOnlineTarget(true)
	:AddAlias("tp")
	:AddAlias("tele")
end

do
	kate.Commands:Register("bring", function(self, pl, args)
		local target = args.target

		target:SetReturnPos(target:GetPos())
		target:SetPos(kate.FindEmptyPos(pl:GetPos(), {}, 32, 32, Vector(16, 16, 64)))

		do
			local msg = string.format("%s has brought %s",
				kate.GetExecuter(pl),
				kate.GetTarget(target)
			)

			kate.Print(3, msg)
			kate.Message(kate.GetAdmins(), 3, msg)
		end
	end)
	:SetTitle("Bring")
	:SetCategory("Teleport")
	:SetIcon("icon16/arrow_in.png")
	:SetImmunity(1000)
	:SetSelfRun(false)
	:SetOnlineTarget(true)
	:SetArgs("Target")
end

do
	kate.Commands:Register("return", function(self, pl, args)
		local target = args.target or pl

		local pos = target:GetReturnPos()
		if not pos then
			kate.Message(pl, 2, "Target has no pos to return")
			return
		end

		target:SetReturnPos(nil)
		target:SetPos(pos)

		do
			local msg = string.format("%s has returned %s",
				kate.GetExecuter(pl),
				kate.GetTarget(target)
			)

			kate.Print(3, msg)
			kate.Message(kate.GetAdmins(), 3, msg)
		end
	end)
	:SetTitle("Return")
	:SetCategory("Teleport")
	:SetIcon("icon16/arrow_redo.png")
	:SetImmunity(1000)
	:SetOnlineTarget(true)
	:SetArgs("Target")
	:SetOptionalArgs("Target")
end