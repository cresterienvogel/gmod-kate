do
	kate.Commands.Register("teleport", function(self, pl, args)
		local target = kate.FindPlayer(args[1])
		if not IsValid(target) or pl == target then
			kate.Message(pl, 2, "Target not found")
			return
		end

		target:SetKateVar("Return", target:GetPos())
		target:SetPos(pl:GetEyeTrace().HitPos)

		do
			local msg = kate.GetExecuter(pl) .. " has teleported " .. kate.GetTarget(target)

			kate.Print(msg)
			kate.Message(kate.GetAdmins(), 3, msg)
		end
	end)
	:SetTitle("Teleport")
	:SetCategory("Teleport")
	:SetIcon("icon16/arrow_down.png")
	:SetImmunity(1000)
	:AddAlias("tp")
	:AddAlias("tele")
	:SetArgs("Target")
end

do
	kate.Commands.Register("bring", function(self, pl, args)
		local target = kate.FindPlayer(args[1])
		if not IsValid(target) or pl == target then
			kate.Message(pl, 2, "Target not found")
			return
		end

		target:SetKateVar("Return", target:GetPos())
		target:SetPos(kate.FindEmptyPos(pl:GetPos(), {}, 32, 32, Vector(16, 16, 64)))

		do
			local msg = kate.GetExecuter(pl) .. " has brought " .. kate.GetTarget(target)

			kate.Print(msg)
			kate.Message(kate.GetAdmins(), 3, msg)
		end
	end)
	:SetTitle("Bring")
	:SetCategory("Teleport")
	:SetIcon("icon16/arrow_in.png")
	:SetImmunity(1000)
	:SetArgs("Target")
end

do
	kate.Commands.Register("return", function(self, pl, args)
		local target = kate.FindPlayer(args[1])
		if not IsValid(target) or pl == target then
			kate.Message(pl, 2, "Target not found")
			return
		end

		local pos = target:GetKateVar("ReturnPos")
		if not pos then
			kate.Message(pl, 2, "Target has no pos to return")
			return
		end

		target:SetKateVar("ReturnPos", nil)
		target:SetPos(pos)

		do
			local msg = kate.GetExecuter(pl) .. " has returned " .. kate.GetTarget(target)

			kate.Print(msg)
			kate.Message(kate.GetAdmins(), 3, msg)
		end
	end)
	:SetTitle("Return")
	:SetCategory("Teleport")
	:SetIcon("icon16/arrow_redo.png")
	:SetImmunity(1000)
	:SetArgs("Target")
end