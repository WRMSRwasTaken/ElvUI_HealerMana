local E, L, V, P, G, _ = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local HM = E:NewModule('HM', 'AceEvent-3.0', 'AceHook-3.0')
local UF = E:GetModule('UnitFrames')
local EP = LibStub("LibElvUIPlugin-1.0")

local addonName, Engine = ...
local GetAddOnMetadata  = GetAddOnMetadata
local random = random
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitIsConnected = UnitIsConnected
local UnitClass = UnitClass

function HM:Initialize()
	self:SecureHook(UF, "Update_PartyFrames", HM.Update_Frames)
	self:SecureHook(UF, "Update_RaidFrames", HM.Update_Frames)

	print(format("%sElvUI_HealerMana|r Version %s%s|r loaded.", E.media.hexvaluecolor, E.media.hexvaluecolor, GetAddOnMetadata("ElvUI_HealerMana", "Version")))
end

function HM:ShouldShow(frame)
	local role = UnitGroupRolesAssigned(frame.unit)

	if (role == 'HEALER') then return true end -- generally show mana bars for all healers
	if (role == 'TANK') then  -- BDK's runic power and BMM's stagger would be intersting to see whether they need immediate babysitting or not (this would be a good idea to make it customizable imho)
		local _, class = UnitClass(frame.unit)
		if (class == 'DEATHKNIGHT') then
			return true
		elseif (class == 'MONK') then
			return true
		end
	end

	return false
end

function HM:Update_Frames(frame, db)
	if not frame then return end

	-- don't do stuff if ElvUI's option is enabled to generally show all power bars
	if db.power.enabled then return end

	if frame.isForced then -- test mode to show only the power bars only on a few random units
		if random(1, 3) ~= 1 then
			return
		end
	elseif not HM:ShouldShow(frame) then return end

	-- let ElvUI re-evaluate everything depending on the USE_POWERBAR variable
	frame.USE_POWERBAR = true
	frame.POWERBAR_DETACHED = false
	frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == 'inset' and frame.USE_POWERBAR
	frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == 'spaced' and frame.USE_POWERBAR)
	frame.USE_POWERBAR_OFFSET = (db.power.width == 'offset' and db.power.offset ~= 0) and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED
	frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0
	frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height
	frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (UF.BORDER*2))*0.5 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((UF.BORDER+UF.SPACING)*2)))
	frame.CLASSBAR_WIDTH = frame.UNIT_WIDTH - frame.PORTRAIT_WIDTH - (frame.ORIENTATION == 'MIDDLE' and (frame.POWERBAR_OFFSET*2) or frame.POWERBAR_OFFSET)
	frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and (UF.SPACING+(frame.CLASSBAR_HEIGHT*0.5)) or (frame.CLASSBAR_HEIGHT - (UF.BORDER-UF.SPACING)))
	frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and db.infoPanel.enable
	frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)

	UF:Configure_HealthBar(frame)
	UF:Configure_Power(frame)

	frame:UpdateAllElements('ElvUI_UpdateAllElements')
end

E.Libs.EP:HookInitialize(HM, HM.Initialize)