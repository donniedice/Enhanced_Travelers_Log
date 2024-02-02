--v0.0.4

-- This script creates a progress bar for the Monthly Activities section of the Encounter Journal in World of Warcraft.
-- It sets the progress bar values based on the current and total requirements for each activity.
-- The override table allows for specific total values to be set for certain activities.
-- The CreateProgressBar function creates the progress bar UI elements.
-- The SetProgressBar function updates the progress bar values and displays it.
-- The handler registers for the ADDON_LOADED event and hooks into the Monthly Activities frames to call SetProgressBar.

-- Define the name of the addon
local addonName = Enhanced_Travelers_Log

-- Define a table that allows for specific total values to be set for certain activities
local override = {
	[40] = 2,
	[52] = 5000,
	[85] = 1,
	[90] = 1,
	[93] = 1,
	[97] = 2,
	[121] = 2,
}

-- Define a function that creates the progress bar UI elements
local function CreateProgressBar(self)
	-- Create the progress bar background frame
	self.ProgressBarBg = CreateFrame("FRAME",nil,self,"BackdropTemplate")
	self.ProgressBarBg:SetFrameStrata("MEDIUM")
	self.ProgressBarBg:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",56,16)
	self.ProgressBarBg:SetSize(344,24)
	self.ProgressBarBg:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = false,
		tileSize = 32,
		tileEdge = false,
		edgeSize = 16,
		insets = {left=4,right=4,top=4,bottom=4},
	})
	self.ProgressBarBg:SetBackdropColor(0,0,0,1)
	
	-- Create the progress bar text
	local font,size,flags = self.Name:GetFont()
	self.ProgressBarText = self.ProgressBarBg:CreateFontString(nil,"OVERLAY")
	self.ProgressBarText:SetPoint("CENTER")
	self.ProgressBarText:SetFont(font,size,flags)
	
	-- Create the progress bar itself
	self.ProgressBar = CreateFrame("StatusBar",nil,self)
	self.ProgressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	self.ProgressBar:SetStatusBarColor(0.584, 0, 0.255, 1) -- Set color to #950041
	self.ProgressBar:SetFrameStrata("MEDIUM")
	self.ProgressBar:SetPoint("CENTER",self.ProgressBarBg)
	self.ProgressBar:SetSize(336,16)
end

-- Define a function that updates the progress bar values and displays it
local function SetProgressBar(self,data)
	-- If the progress bar hasn't been created yet, create it
	if not self.hooked then
		self.Name:ClearAllPoints()
		self.Name:SetPoint("TOPLEFT",self,"TOPLEFT",20,0)
		self.Name:SetWidth(416)
		
		CreateProgressBar(self)
		
		self.hooked = true
	end
	
	-- Calculate the current and total values for the progress bar
	local current,total = 0,0
	for _,requirement in ipairs(self.requirementsList) do
		local currentR,totalR = string.match(requirement.requirementText,"(%d+) / (%d+)")
		if currentR and totalR then
			current = current+currentR
			total = total+totalR
		else
			currentR = string.match(requirement.requirementText,"(%d+)")
			current = current+(currentR or 0)
		end
	end
	current = (current == 0 and self.completed and 1) or current
	total = override[self.id or 0] or total
	
	-- Update the progress bar text and values
	self.ProgressBarText:SetFormattedText("%d / %d",math.min(current,total),total)
	self.ProgressBar:SetMinMaxValues(0,total)
	self.ProgressBar:SetValue(current)
	self.ProgressBar:Show()
end

-- Define a handler that registers for the ADDON_LOADED event and hooks into the Monthly Activities frames to call SetProgressBar
local handler = CreateFrame("FRAME")
handler:RegisterEvent("ADDON_LOADED")
handler:SetScript("OnEvent",function(self,event,name)
	if event == "ADDON_LOADED" and (addonName == name or "Blizzard_EncounterJournal" == name) then
		if not MonthlyActivitiesButtonMixin then return end
		self:UnregisterEvent(event)
		for _,frame in ipairs({EncounterJournalMonthlyActivitiesFrame.ScrollBox.ScrollTarget:GetChildren()}) do
			hooksecurefunc(frame,"Init",SetProgressBar)
		end
		hooksecurefunc(MonthlyActivitiesButtonMixin,"Init",SetProgressBar)
	end
end)