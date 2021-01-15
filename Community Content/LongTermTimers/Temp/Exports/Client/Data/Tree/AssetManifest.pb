
?���������	Sun LightR%
BlueprintAssetRefCORESKY_SunLight
�?ץҝ߮���_LongTermTimerManagerZ�>�>--[[
  Long Term Timer Manager
  V1.0 - 7/15/2020
  by Chris
]]


local LuaEvent = require(script:GetCustomProperty("LuaEvents"))
timerFiredEvent = LuaEvent.New()
local STORAGE_KEY = "lte_LTTimerTable"

local LTTimerTable = {}
local LTTimerTask = nil

-- Internal helper function - Recalculates how long until the next event
-- triggers, and spawns the task to wait for it.
function ResetLTTimerTask()
	if LTTimerTask ~= nil then
		LTTimerTask:Cancel()
		LTTimerTask = nil
	end

	local nextEventTime, nextEventList = FindNextEvents()

	if #nextEventList > 0 then
		LTTimerTask = Task.Spawn(function() LTTimerTaskFunction(nextEventTime - os.time(), nextEventList) end)
	end

end

-- Helper function - this is the task that runs while
-- it is waiting for the next event.  (If there is one)
-- It basically just waits for the given duration, and then
-- fires the provided events.  (This calcluation is done before
-- the task is spawned)
function LTTimerTaskFunction(duration, eventList)
	Task.Wait(duration)
	for k,v in pairs(eventList) do
		timerFiredEvent:Trigger({GetPlayerFromPid(v.pid), v.id, v.start, v.duration})
		RemoveEventInternal(v.pid, v.id)
	end
	ResetLTTimerTask()
end

-- Helper function for removing events.
function RemoveEventInternal(pid, timerId)
	if LTTimerTable ~= nil and LTTimerTable[pid] ~= nil then
		LTTimerTable[pid][timerId] = nil
	end
end

-- Removes an event from a player.  It does not fire;
-- it simply disappears.
function CancelPlayerTimer(player, timerId)
	RemoveEventInternal(player.id, timerId)
	ResetLTTimerTask()
end

-- Returns a table containing details about a given event for a player.
-- If the event ID does not match any current events, then nil is returned.
-- Otherwise, the table has the following data:
-- start:  os.time when the event was created.
-- duration:  duration in seconds for the event.
-- Remaining(): function, that returns the number of seconds remaining until the timer fires.
function GetTimerDetails(player, timerId)
	if not WaitForDataToLoad(player) then return nil end
	if LTTimerTable ~= nil and LTTimerTable[player.id] ~= nil and LTTimerTable[player.id][timerId] ~= nil then
		local details = {}
		for k,v in pairs(LTTimerTable[player.id][timerId]) do
			details[k] = v
		end
		details.Remaining = DetailsTimeRemaining
		return details
	else
		return nil
	end
end

function DetailsTimeRemaining(self)
	return (self.duration + self.start) - os.time()
end

-- Returns a list of ALL the details for timers associated with a player,
-- as a table, keyed by the timer ID.
function GetAllTimerDetails(player)
	if not WaitForDataToLoad(player) then return nil end
	local results = {}
	for timerId,_ in pairs(LTTimerTable[player.id]) do
		results[timerId] = GetTimerDetails(player, timerId)
	end
	return results
end


-- Internal utility function, for getting the player object from the player ID.
function GetPlayerFromPid(pid)
	for _, player in ipairs(Game.GetPlayers()) do
		if player.id == pid then return player end
	end
	return nil
end


-- Internal utility function, for figuring out which timer (or timers)
-- will fire next.  Gets recalculated every time a timer list changes.
function FindNextEvents()
	local MAX_TIME = 2^52
	local timeUntilNextEvents = MAX_TIME
	local nextEvents = {}
	for pid, playerTimerTable in pairs(LTTimerTable) do
		for id, targetTime in pairs(playerTimerTable) do
			if targetTime.duration ~= nil and targetTime.start ~= nil then
				local timerTime = targetTime.duration + targetTime.start
				if timerTime < timeUntilNextEvents then
					nextEvents = {}
				end
				if timerTime <= timeUntilNextEvents then
					table.insert(nextEvents, {
							pid = pid,
							id = id,
							start = targetTime.start,
							duration = targetTime.duration
						})
					timeUntilNextEvents = timerTime
				end
			else
				-- Bad entry.  Remove it?
			end
		end
	end	
	return timeUntilNextEvents, nextEvents
end



-- Creates a new timer for the given player.  The arguments are the
-- player to create the timer for, the duration of the timer, and the timerId.
-- Note that if there is already an timer with the given timerId, it will be
-- overwritten.
function StartPlayerTimer(player, timerId, duration)
	timerId = tostring(timerId)
	if LTTimerTable[player.id] == nil then LTTimerTable[player.id] = {} end
	LTTimerTable[player.id][timerId] = { start = os.time(), duration = duration }
	ResetLTTimerTask()
	return GetTimerDetails(player, timerId)
end

-- Internal utility function for verifying the elements of
-- a player timer data table.  Returns either the table
-- unchanged, or nil.  (If the table was invalid)
function VerifyLTTimerTable(playerTable)
	if playerTable == nil then
		--warn("Table was nil")
		return {}
	else
		for k,v in pairs(playerTable) do
			if type(k) ~= "string" or type(v) ~= "table" then
				warn("Table had invalid entries.")
				return {}
			end
			if v.start == nil or v.duration == nil then
				warn("Table entry missing a field.")
				return {}
			end
		end
	end
	-- Everything is fine!
	return playerTable
end

-- Loads the playerdata, and extracts the timer data for that
-- player from it.  Intended to be paired with SaveAsPlayerData()
-- Note that if any events loaded have expired while the player
-- was logged off, they will fire immedietely.  (So it is good
-- practice to connect any timer listeners before loading events.)
function LoadFromPlayerData(player)
	local playerEvents = Storage.GetPlayerData(player)[STORAGE_KEY]
	LTTimerTable[player.id] = VerifyLTTimerTable(playerEvents)
	ResetLTTimerTask()
	print("player = " .. player.name)
	for k,v in pairs(LTTimerTable[player.id]) do
		print(k, ":", tostring(v.duration - DetailsTimeRemaining(v)) .. "/" .. tostring(v.duration))
	end
end

-- Loads the timers for a player from a table.
-- (Presuambly one created by ExportAsTable() and
-- saved manually in playerdata)
-- Note that if any timers loaded have expired while the player
-- was logged off, they will fire immedietely.  (So it is good
-- practice to connect any event listeners before loading timers.)
function ImportFromTable(player, t)
	LTTimerTable[player.id] = VerifyLTTimerTable(t)
	ResetLTTimerTask()
end

-- Saves the timers for a player as part of the player data.
-- This function will preserve any existing player data, and just
-- add the timer data as a separate field.
function SaveAsPlayerData(player)
	local playerData = Storage.GetPlayerData(player)
	playerData[STORAGE_KEY] = LTTimerTable[player.id]
	local resultCode, errorMsg = Storage.SetPlayerData(player, playerData)
	print(errorMsg)
	print("resultCode = ", resultCode)
end


-- Export all the timers associated with a player to a table.
-- Use this if you want to manage your own save data.  (Just save
-- this table as part of playerdata, and load it up on startup.)
function ExportAsTable(player)
	local result = {}
	for k,v in pairs(LTTimerTable[player.id]) do
		result[k] = v
	end
	return result
end

-- Remove all timers from a player.
-- This will not fire the timers or anything - just zero them out.
function CancelAllPlayerTimers(player)
	LTTimerTable[player.id] = nil
	ResetLTTimerTask()
end


function WaitForDataToLoad(player)
	local startTime = time()
	while LTTimerTable[player.id] == nil do
		if startTime + 5 < time() then
			print("feh")
			return false
		end
		Task.Wait()
	end
	return true
end


return {
	timerFiredEvent = timerFiredEvent,

	LoadFromPlayerData = LoadFromPlayerData,
	SaveAsPlayerData = SaveAsPlayerData,

	ImportFromTable = ImportFromTable,
	ExportAsTable = ExportAsTable,
	
	StartPlayerTimer = StartPlayerTimer,
	GetTimerDetails = GetTimerDetails,
	GetAllTimerDetails = GetAllTimerDetails,

	CancelPlayerTimer = CancelPlayerTimer,
	CancelAllPlayerTimers = CancelAllPlayerTimers,
}

cs:LuaEvents�
�������L
��������L
 LuaEventsZ��--[[
  Lua Event Library
  V1.0 - 7/15/2020
  by Chris
]]


local LuaEvent = {}
local Listener = {}

function LuaEvent.New()
	newEvent = {
		listeners = {},
		nextListenerId = 0,
	}
	setmetatable(newEvent, {__index = LuaEvent})
	return newEvent
end

function LuaEvent.Connect(self, func)
	self.listeners[func] = true
	return Listener.New(self, func)
end

function LuaEvent.Trigger(self, args)
	if args == nil then args = {} end
	for k,v in pairs(self.listeners) do
		k(table.unpack(args))
	end
end

function LuaEvent.DisconnectListener(self, func)
	self.listeners[func] = nil
end

function LuaEvent.IsListenerActive(self, func)
	return self.listeners[func] ~= nil
end


function Listener.New(event, func)
	newListener = {
		func = func,
		event = event,
	}
	setmetatable(newListener, {__index = Listener})
	return newListener
end

function Listener.Disconnect(self)
	self.event:DisconnectListener(self.func)
end

function Listener.IsActive(self)
	return self.event:IsListenerActive(func)
end


return {
	New = LuaEvent.New
}

���ʀ����
  Long Term Timer Manager Sample - Client Code
  V1.0 - 7/15/2020
  by Chris
]]


local prop_LongTermTimerManager = script:GetCustomProperty("_LongTermTimerManager")
local propRoot = script:GetCustomProperty("Root"):WaitForObject()
local propStartTrigger = script:GetCustomProperty("StartTrigger"):WaitForObject()
local propCancelTrigger = script:GetCustomProperty("CancelTrigger"):WaitForObject()

local propTimerName = propRoot:GetCustomProperty("TimerName")
local propTimerDuration = propRoot:GetCustomProperty("TimerDuration")

local LTT = require(prop_LongTermTimerManager)



function OnTimerFired(player, id, start, duration)
	if id == propTimerName then
		Events.BroadcastToPlayer(player, "TimerCompleted", id)
	end
end

function OnStartPressed(trigger, player)
	print(player.name .. ": starting timer " .. propTimerName .. " for " .. tostring(propTimerDuration) .. " seconds.")
	local timerDetails = LTT.StartPlayerTimer(player, propTimerName, propTimerDuration)
	Events.BroadcastToPlayer(player, "TimerStarted", propTimerName, timerDetails.start + timerDetails.duration)
end

function OnCancelPressed(trigger, player)
	print(player.name .. ": canceling timer " .. propTimerName .. ".")
	LTT.CancelPlayerTimer(player, propTimerDuration, propTimerName)
	Events.BroadcastToPlayer(player, "TimerCanceled", propTimerName)
end


LTT.timerFiredEvent:Connect(OnTimerFired)
propStartTrigger.interactedEvent:Connect(OnStartPressed)
propCancelTrigger.interactedEvent:Connect(OnCancelPressed)

���������
LTT_SampleZ��--[[
  Long Term Timer Sample
  V1.0 - 7/15/2020
  by Chris
]]

local LTT = require(script:GetCustomProperty("_LongTermTimerManager"))

function OnPlayerJoined(player)
	LTT.LoadFromPlayerData(player)
end

function OnPlayerLeft(player)
	LTT.SaveAsPlayerData(player)
end

function OnRequestTimer(player, timerId)
	local timerDetails = LTT.GetTimerDetails(player, timerId)
	if timerDetails ~= nil then
		Events.BroadcastToPlayer(player, "TimerStarted", timerId, timerDetails.start + timerDetails.duration)
	else
		print("Timer details were nil, for", player.id, timerId)
	end
end

Events.ConnectForPlayer("RequestTimerInfo", OnRequestTimer)

Game.playerJoinedEvent:Connect(OnPlayerJoined)
Game.playerLeftEvent:Connect(OnPlayerLeft)
*
(
cs:_LongTermTimerManager�ץҝ߮���
�˹��ù��GoldDisplay_ClientZ��local propWorldText = script:GetCustomProperty("WorldText"):WaitForObject()
local propVFX = script:GetCustomProperty("VFX"):WaitForObject()

local player = Game.GetLocalPlayer()


function AddCommas(amount)
	local result = tostring(amount)
	local k = -1
	while k ~= 0 do  
		result, k = string.gsub(result, "^(-?%d+)(%d%d%d)", '%1,%2')
	end
	return result
end

function UpdateGoldReadout(player, resource, amt)
	if resource ~= "Gold" then return end
	
	if amt == nil then
		amt = player:GetResource("Gold")
	end
	propWorldText.text = "$" .. AddCommas(amt)
	propVFX:Play()
end



player.resourceChangedEvent:Connect(UpdateGoldReadout)
UpdateGoldReadout(player, "Gold")
6��������CubeR!
StaticMeshAssetRefsm_cube_002
>�����SkylightR%
BlueprintAssetRefCORESKY_Skylight
������Љ��Mine_ServerZ��local LTT = require(script:GetCustomProperty("_LongTermTimerManager"))
local npcStates = {}


local STATE_READY = 0
local STATE_IN_MINE = 1
local STATE_HAS_MONEY = 2


function OnPlayerJoined(player)
	local playerData = Storage.GetPlayerData(player)
	local playerRsc = playerData.rsc
	if playerRsc == nil then playerRsc = {} end
	for k,v in pairs(playerRsc) do
		player:SetResource(k, v)
	end
	npcStates[player.id] = playerData.npc
	if npcStates[player.id] == nil then npcStates[player.id] = {} end
	LTT.LoadFromPlayerData(player)

end

function OnPlayerLeft(player)
	local rsc = {}
	for k,v in pairs(player:GetResources()) do
		rsc[k] = v
	end
	Storage.SetPlayerData(player, {rsc = rsc, npc = npcStates[player.id]})
	LTT.SaveAsPlayerData(player)
end

function OnRequestTimerInfo(player, timerId)
	local timerDetails = LTT.GetTimerDetails(player, timerId)
	if timerDetails ~= nil then
		npcStates[player.id][timerId] = STATE_IN_MINE
		Events.BroadcastToPlayer(player, "TimerActive", timerId, timerDetails.start + timerDetails.duration)
	else
		if npcStates[player.id][timerId] == nil then
			npcStates[player.id][timerId] = STATE_READY
		end
		Events.BroadcastToPlayer(player, "NPCState", timerId, npcStates[player.id][timerId])
	end
end

function OnTimerFired(player, id, start, duration)
	Events.BroadcastToPlayer(player, "TimerCompleted", id)
	npcStates[player.id][id] = STATE_HAS_MONEY
end


function OnStartTimer(player, timerId, duration)
	local timerDetails = LTT.StartPlayerTimer(player, timerId, duration)
	Events.BroadcastToPlayer(player, "TimerStarted", timerId, timerDetails.start + timerDetails.duration)
	npcStates[player.id][timerId] = STATE_IN_MINE
end

function OnApplyReward(player, amount, npcId)
	if npcStates[player.id][npcId] ~= STATE_HAS_MONEY then
		warn("Somehow we requested a reward from an NPC who wasn't done?")
		print(npcId, npcStates[player.id][npcId])
	else
		player:AddResource("Gold", amount)
		npcStates[player.id][npcId] = STATE_READY
	end
end

Events.ConnectForPlayer("RequestTimerInfo", OnRequestTimerInfo)
Events.ConnectForPlayer("StartTimer", OnStartTimer)
Events.ConnectForPlayer("ApplyReward", OnApplyReward)

LTT.timerFiredEvent:Connect(OnTimerFired)

Game.playerJoinedEvent:Connect(OnPlayerJoined)
Game.playerLeftEvent:Connect(OnPlayerLeft)


�¬����ʾ�
local propButton_Yes = script:GetCustomProperty("Button_Yes"):WaitForObject()
local propButton_No = script:GetCustomProperty("Button_No"):WaitForObject()
local propDialogText = script:GetCustomProperty("DialogText"):WaitForObject()
local propButton_Yes_Root = script:GetCustomProperty("Button_Yes_Root"):WaitForObject()
local propButton_No_Root = script:GetCustomProperty("Button_No_Root"):WaitForObject()

propUI_Root.isEnabled = false

local player = Game.GetLocalPlayer()
local currentMinerScript = nil
local playerPos = nil

local STATE_READY = 0
local STATE_HAS_MONEY = 1

local uiState = STATE_READY

function ShowReadyUI(minerScript)
	if currentMiner then
		HideUI()
	end
	uiState = STATE_READY
	currentMinerScript = minerScript
	local trigger = currentMinerScript:GetCustomProperty("Trigger"):WaitForObject()
	if trigger then trigger.isEnabled = false end
	UI.SetCursorVisible(true)
	player.lookSensitivity = 0
	propUI_Root.isEnabled = true
	playerPos = player:GetWorldPosition()
	propDialogText.text = currentMinerScript.parent:GetCustomProperty("Dialog")
end


function ShowDoneUI(minerScript)
	if currentMiner then
		HideUI()
	end
	uiState = HAS_MONEY
	propButton_No_Root.isEnabled = false
	currentMinerScript = minerScript
	local trigger = currentMinerScript:GetCustomProperty("Trigger"):WaitForObject()
	if trigger then trigger.isEnabled = false end
	UI.SetCursorVisible(true)
	player.lookSensitivity = 0
	propUI_Root.isEnabled = true
	playerPos = player:GetWorldPosition()
	propDialogText.text = currentMinerScript.parent:GetCustomProperty("ReturnDialog")
end


function HideUI(reEnableTrigger)
	propButton_No_Root.isEnabled = true
	local trigger = currentMinerScript:GetCustomProperty("Trigger"):WaitForObject()
	if trigger then trigger.isEnabled = reEnableTrigger end
	UI.SetCursorVisible(false)
	player.lookSensitivity = 1
	propUI_Root.isEnabled = false
	playerPos = nil
	currentMinerScript = nil
end


function Tick()
	if propUI_Root.isEnabled then
		if (player:GetWorldPosition() - playerPos).size > 50 then
			HideUI(true)
		end
	end
end


function OnYesPressed()
	if uiState == STATE_READY then
		local duration = currentMinerScript.parent:GetCustomProperty("DigTime")
		local reward = currentMinerScript.parent:GetCustomProperty("DigReward")
		Events.BroadcastToServer("StartTimer", currentMinerScript:GetReference().id, duration, reward)
		HideUI(false)
	else
		HideUI(true)
	end
end


function OnNoPressed()
	HideUI(true)
end


Events.Connect("ShowMineDialog", ShowReadyUI)
Events.Connect("ShowMoneyDialog", ShowDoneUI)
propButton_Yes.clickedEvent:Connect(OnYesPressed)
propButton_No.clickedEvent:Connect(OnNoPressed)


Q��������Shadow Haze

emissive_booste    

color�%��>
R��������XEmissive Glow TransparentR)
MaterialAssetRefmi_basic_emissive_001
8�����ƺmSky DomeR 
BlueprintAssetRefCORESKY_Sky
�������͈�dLTT - Mining Sampleb��
�� ��ޫъ��.*���ޫъ��.Miner Timer Sample"
�ܘ������ۜ������ۇ����fʈ�������z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*����Ć�XMine")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*�۫ȹ�����Rock 01")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�������§088�
 *������踴nRock 02"3

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

�̚����N088�
 *���Éĸԁ�Wooden Arch"


&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*���������?Large Wood Board 8m".


��B����  4C
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *��Ǫ��걨�Large Wood Board 8m".


&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *���ͣ����Large Wood Board 8m".

���B3B�7
?�p-@]��@(��Éĸԁ�z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *����������Rock Flat 01"3

 �?�-@(���Ć�Xz(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

��ۚ����/088�
 *��ճ�����Wooden Arch"


&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*����٭���fLarge Wood Board 8m".


��B����  4C
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *�������hLarge Wood Board 8m".


&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *�ż������Large Wood Board 8m".

���B3B�7
?�p-@]��@(�ճ�����z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *�󸉧����zWooden Arch"


&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*��ң�Ȏ��6Large Wood Board 8m".


��B����  4C
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *��������ILarge Wood Board 8m".


&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *��ۿ������Large Wood Board 8m".

���B3B�7
?�p-@]��@(󸉧����zz(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *�����Ύ�/Rock Flat 01")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

��ۚ����/088�
 *���������Rock 02"3

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

�̚����N088�
 *�߳�䘩�ƎRock 03".

����U��
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

�����G088�
 *��������Rock 03")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

�����G088�
 *�����ׄ�ȪRock Flat 02")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

������~088�
 *������鑆�Rock 03"$

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

�����G088�
 *���ىֽ���Rock 03"3

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

�����G088�
 *���脃�ߎ�Darkness"$

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*���������Darkness"
  
)
ma:Shared_BaseMaterial:id���������z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��������08�
 *�����ͷ��Darkness"

)
ma:Shared_BaseMaterial:id���������z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��������08�
 *��������&Darkness"

)
ma:Shared_BaseMaterial:id���������z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��������08�
 *��������Darkness"

)
ma:Shared_BaseMaterial:id���������z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��������08�
 *���Ś�����Darkness"

)
ma:Shared_BaseMaterial:id���������z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��������08�
 *���������\Rock 01"3

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�������§088�
 *���������Mine_Server"$

(
cs:_LongTermTimerManager�ץҝ߮���z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�����Љ��*���˸�ћ�k	UI Client"


mc:ecollisionsetting:forceoff�)
'mc:evisibilitysetting:inheritfromparent� *���������UI Container"$

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�Y:

mc:euianchor:middlecenter� �4


mc:euianchor:topleft

mc:euianchor:topleft*�ۿ�ރ���TUI Panel"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�n��-����:

mc:euianchor:middlecenter� �>


mc:euianchor:bottomcenter

mc:euianchor:bottomcenter*��ޜ���ک�UI Image"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent����:

mc:euianchor:middlecenterPX� 
��������


mc:euianchor:topleft

mc:euianchor:topleft*�꠱������UI Image"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent����:

mc:euianchor:middlecenterPX�$

����ʳ��c


mc:euianchor:topleft

mc:euianchor:topleft*��ї�����UI Text Box"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent����%@�-B-$B:

mc:euianchor:middlecenter��
YI'm a fast digger!  Send me into the mines, and I'll be back in 30 seconds, with 10 gold!
mc:etextjustify:left(�4


mc:euianchor:topleft

mc:euianchor:topleft*������ٜ��
Yes Button"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�r�p%�?4D-��/�:

mc:euianchor:middlecenter� �>


mc:euianchor:bottomcenter

mc:euianchor:bottomcenter*�������UI Image"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent����:

mc:euianchor:middlecenterPX� 
��������


mc:euianchor:topleft

mc:euianchor:topleft*��������UI Image"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent����:

mc:euianchor:middlecenterPX�$

����ʳ��c


mc:euianchor:topleft

mc:euianchor:topleft*�ʦө����UI Text Box"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent���S:

mc:euianchor:middlecenter�;
Okay!
mc:etextjustify:center(�>


mc:euianchor:middlecenter

mc:euianchor:middlecenter*���֛�����	UI Button"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent��d:

mc:euianchor:middlecenterPX�z%  �?"
��������HZ
mc:ebuttonclickmode:default�4


mc:euianchor:topleft

mc:euianchor:topleft*�ꉤԘ���	No Button"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�r�p%�?4D-�Dj�:

mc:euianchor:middlecenter� �>


mc:euianchor:bottomcenter

mc:euianchor:bottomcenter*�����̶�vUI Image"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent����:

mc:euianchor:middlecenterPX� 
��������


mc:euianchor:topleft

mc:euianchor:topleft*������ҁ��UI Image"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent����:

mc:euianchor:middlecenterPX�$

����ʳ��c


mc:euianchor:topleft

mc:euianchor:topleft*���Ɂ�����UI Text Box"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent���S:

mc:euianchor:middlecenter�>
Not yet.
mc:etextjustify:center(�>


mc:euianchor:middlecenter

mc:euianchor:middlecenter*����������	UI Button"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent��d:

mc:euianchor:middlecenterPX�z%  �?"
��������HZ
mc:ebuttonclickmode:default�4


mc:euianchor:topleft

mc:euianchor:topleft*��������W
  


cs:UI_Root���������



cs:Button_No����������


�ї�����
"
cs:Button_Yes_Root������ٜ��
 
cs:Button_No_Root�
ꉤԘ���z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
¬����ʾ�*�����՘��?Chest")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*����Ŧ�̬�Fantasy Chest Lid 03"

p���j@�B 
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

������Ѿm088�
 *������Ը�Fantasy Chest Base 03"
p��A 
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

ۆ���088�
 *���ڕ�悾�

mc:ecollisionsetting:forceoff�)
'mc:evisibilitysetting:inheritfromparent� *��ϼ�����6
World Text"
 ���B
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�x
$999,999,999
"mc:ecoretexthorizontalalign:center:"
 mc:ecoretextverticalalign:center*�Ƹ����Ě�GoldDisplay_Client"
  

cs:WorldText�
�ϼ�����6

cs:VFX�������ߏ�z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
˹��ù��*�������ߏ�Level Up VFX"

pV��Μ�� 
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

��Ծ����? � *�������Ƌ�

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

ң���ܚ�b088�
 *�����И�
PathIntoMine"$

mc:ecollisionsetting:forceoff� 
mc:evisibilitysetting:forceoff�*����Ѽ���&Sphere"


z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�Ŭ��ܾ�088�
 *�׽բ�����Sphere"$

z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�Ŭ��ܾ�088�
 *�Ԕ���ԩ��Sphere"$

z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�Ŭ��ܾ�088�
 *��ܘ���NPC Helper - Guy"$

f
	cs:DialogjYI'm a fast digger!  Send me into the mines, and I'll be back in 10 seconds, with 10 gold!
=
cs:ReturnDialogj*Here it is, 10 gold, just like I promised!


cs:DigTimeX


cs:DigRewardX
z
mc:ecollisionsetting:forceoff�)
'mc:evisibilitysetting:inheritfromparent� *���𯆏�NPC"
 �-�B
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�A
��������088�)"unarmed_idle_relaxed-  �?0=  �?J  �?*���Ư��Trigger"
  
mc:ecollisionsetting:forceon�)
'mc:evisibilitysetting:inheritfromparent�&Talk"08*
mc:etriggershape:box*�����䣏�NPC Helper Script"
  


cs:Trigger���Ư��

cs:AnimatedMesh�
��𯆏�

cs:WalkPath�
����И�

!
cs:ReadyIndicator����ί���

cs:DoneIndicator�
ź���V

cs:Sign�������

cs:SignText�
玧�����gz(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

���˰��/*���甲���
Indicators"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*�ź���V
Text 04: ?"


 
ma:Font.Sides:id����ਖ਼���
 
ma:Font.Faces:id����ਖ਼���
 
ma:Font.Bevel:id����ਖ਼���z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�����̭�088�
 *����ί���
Text 04: !"


 
ma:Font.Sides:id����ਖ਼���
 
ma:Font.Faces:id����ਖ਼���
 
ma:Font.Bevel:id����ਖ਼���
'
ma:Font.Bevel:color�
'
ma:Font.Faces:color�
'
ma:Font.Sides:color�
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

��⚺���@088�
 *�������Sign"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*����ס���
Grass Tall"$

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

�����ٸ�f088�
 *����������Large Wood Board 8m"3

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *���ƌ��Large Wood Board 8m")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *��ζǁ�˪JLarge Wood Board 8m"3

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *����������Large Wood Board 8m")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *�玧�����g
World Text")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�g

Back Soon!%  �?%  �?-  �?2$
"mc:ecoretexthorizontalalign:center:"
 mc:ecoretextverticalalign:center*����ۜ����NPC Helper - Girl"$

l
	cs:Dialogj_I'm really thorough!  Let me go looking for gold, and I'll be back in 20 seconds, with 30 gold!
?
cs:ReturnDialogj,I counted twice and this is exactly 30 gold.


cs:DigTimeX

cs:DigRewardXz
mc:ecollisionsetting:forceoff�)
'mc:evisibilitysetting:inheritfromparent� *����ϔ���UNPC"
 �-�B
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�@

�����Ԍ�@088�)"unarmed_idle_relaxed-  �?0=  �?J  �?*��ۭ��׻��Trigger"
  
mc:ecollisionsetting:forceon�)
'mc:evisibilitysetting:inheritfromparent�&Talk"08*
mc:etriggershape:box*���ʍ�����NPC Helper Script"
  


cs:Trigger��ۭ��׻��

cs:AnimatedMesh�
���ϔ���U

cs:WalkPath�
����И�

!
cs:ReadyIndicator��ޙ۪����
 
cs:DoneIndicator�ȣ�˅�ޗ�

cs:Sign���ߖ�����

cs:SignText�
ϖ������Az(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

���˰��/*������Շ�]
Indicators"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*�ȣ�˅�ޗ�
Text 04: ?"


 
ma:Font.Sides:id����ਖ਼���
 
ma:Font.Faces:id����ਖ਼���
 
ma:Font.Bevel:id����ਖ਼���z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�����̭�088�
 *��ޙ۪����
Text 04: !"


 
ma:Font.Sides:id����ਖ਼���
 
ma:Font.Faces:id����ਖ਼���
 
ma:Font.Bevel:id����ਖ਼���
'
ma:Font.Bevel:color�
'
ma:Font.Faces:color�
'
ma:Font.Sides:color�
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

��⚺���@088�
 *���ߖ�����Sign"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*������G
Grass Tall"$

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

�����ٸ�f088�
 *���㼈��Large Wood Board 8m"3

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *����������Large Wood Board 8m")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *��缰�����Large Wood Board 8m"3

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *�������&Large Wood Board 8m")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *�ϖ������A
World Text")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�g

Back Soon!%  �?%  �?-  �?2$
"mc:ecoretexthorizontalalign:center:"
 mc:ecoretextverticalalign:center*���ۇ����fNPC Helper - Skeleton"$

U
	cs:DialogjHDid you know I have 206 bones?  Also, I can mine 300 gold in one minute!
i
cs:ReturnDialogjVDid you know, more than half my bones are hand and foot bones?  Also, here's 300 gold.


cs:DigTimeX<

cs:DigRewardX�z
mc:ecollisionsetting:forceoff�)
'mc:evisibilitysetting:inheritfromparent� *���щ����NPC"
 �-�B
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�A
�܆��Ǵ��088�)"unarmed_idle_relaxed-  �?0=  �?J  �?*�ʹ���̟��Trigger"
  
mc:ecollisionsetting:forceon�)
'mc:evisibilitysetting:inheritfromparent�&Talk"08*
mc:etriggershape:box*����������NPC Helper Script"
  


cs:Trigger�ʹ���̟��

cs:AnimatedMesh�
��щ����

cs:WalkPath�
����И�

 
cs:ReadyIndicator�
���Ɩ���
 
cs:DoneIndicator����������

cs:Sign�
��݀���q

cs:SignText�����Ű���z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

���˰��/*�������螒
Indicators"
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*����������
Text 04: ?"


 
ma:Font.Sides:id����ਖ਼���
 
ma:Font.Faces:id����ਖ਼���
 
ma:Font.Bevel:id����ਖ਼���z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�����̭�088�
 *����Ɩ���
Text 04: !"


 
ma:Font.Sides:id����ਖ਼���
 
ma:Font.Faces:id����ਖ਼���
 
ma:Font.Bevel:id����ਖ਼���
'
ma:Font.Bevel:color�
'
ma:Font.Faces:color�
'
ma:Font.Sides:color�
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

��⚺���@088�
 *���݀���qSign"
   � 
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*����͆���R
Grass Tall"$

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

�����ٸ�f088�
 *�����ٗ�ZLarge Wood Board 8m"3

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *����ó���Large Wood Board 8m")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *������Ӣ�dLarge Wood Board 8m"3

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *�シ������Large Wood Board 8m")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *�����Ű���
World Text")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�g

Back Soon!%  �?%  �?-  �?2$
"mc:ecoretexthorizontalalign:center:"
 mc:ecoretextverticalalign:center*�ʈ�������NPC Helper - Dragon"$

g
	cs:DialogjZRawr rawr rawr.  Rawr rawr rawr rawr rawr.  (5 minutes.  2000 gold.  Take it or leave it.)
G
cs:ReturnDialogj4Rawr rawr rawr rawr rawr.  (Here is your 2000 gold.)


cs:DigTimeX�

cs:DigRewardX�z
mc:ecollisionsetting:forceoff�)
'mc:evisibilitysetting:inheritfromparent� *��������sNPC"
 �-�B
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�A
ͯ���ۘ��088�)"unarmed_idle_relaxed-  �?0=  �?J  �?*���������Trigger"
  
mc:ecollisionsetting:forceon�)
'mc:evisibilitysetting:inheritfromparent�&Talk"08*
mc:etriggershape:box*��۠���¤NPC Helper Script"
  


cs:Trigger���������

cs:AnimatedMesh�
�������s

cs:WalkPath�
����И�

!
cs:ReadyIndicator�ж�������

cs:DoneIndicator�
�������O

cs:Sign�������μ�

cs:SignText�
�򣓟���;z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

���˰��/*������╦
Indicators"
   � 
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*��������O
Text 04: ?"


 
ma:Font.Sides:id����ਖ਼���
 
ma:Font.Faces:id����ਖ਼���
 
ma:Font.Bevel:id����ਖ਼���z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�����̭�088�
 *�ж�������
Text 04: !"


 
ma:Font.Sides:id����ਖ਼���
 
ma:Font.Faces:id����ਖ਼���
 
ma:Font.Bevel:id����ਖ਼���
'
ma:Font.Bevel:color�
'
ma:Font.Faces:color�
'
ma:Font.Sides:color�
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

��⚺���@088�
 *�������μ�Sign"
   � 
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*����ѣ��
Grass Tall"$

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

�����ٸ�f088�
 *���Ӭ�����Large Wood Board 8m"3

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *�����֡���Large Wood Board 8m")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *�������ȪLarge Wood Board 8m"3

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *�����ͨʀ�Large Wood Board 8m")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��Ȓ��088�
 *��򣓟���;
World Text")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�g

Back Soon!%  �?%  �?-  �?2$
"mc:ecoretexthorizontalalign:center:"
 mc:ecoretextverticalalign:center
NoneNone
Vͯ���ۘ��
Dragon MobR;
AnimatedMeshAssetRef#npc_dragonling_chubby_basic_001_ref
U�܆��Ǵ��Skeleton MobR8
AnimatedMeshAssetRef npc_human_guy_skelington_001_ref
X�����Ԍ�@Fantasy Human Gal 1R5
AnimatedMeshAssetRefnpc_human_gal_fantasy_003_ref
D�����ٸ�f
Grass TallR*
StaticMeshAssetRefsm_grass_generic_001
;��⚺���@
Text 04: !R!
StaticMeshAssetRefF7_Text_037
M���ਖ਼���Additive Soft EdgeR*
MaterialAssetReffxma_additive_edgefade
<�����̭�
Text 04: ?R!
StaticMeshAssetRefF7_Text_065
�-���˰��/NPC Helper ScriptZ�-�-local propTrigger = script:GetCustomProperty("Trigger"):WaitForObject()
local propAnimatedMesh = script:GetCustomProperty("AnimatedMesh"):WaitForObject()
local propWalkPath = script:GetCustomProperty("WalkPath"):WaitForObject()
local propReadyIndicator = script:GetCustomProperty("ReadyIndicator"):WaitForObject()
local propDoneIndicator = script:GetCustomProperty("DoneIndicator"):WaitForObject()
local propSign = script:GetCustomProperty("Sign"):WaitForObject()
local propSignText = script:GetCustomProperty("SignText"):WaitForObject()

local player = Game.GetLocalPlayer()

local startPos = propAnimatedMesh:GetWorldPosition()
local startRot = propAnimatedMesh:GetWorldRotation()

local animTask = nil


local STATE_READY = 0
local STATE_IN_MINE = 1
local STATE_HAS_MONEY = 2

local completion = -1
local npcState = STATE_READY

local isTimerRunning = false
local completion = -1
local localPlayer = Game.GetLocalPlayer()
local myId = script:GetReference().id

local updateSignTask = nil

function UpdateIndicator()
	propReadyIndicator.isEnabled = npcState == STATE_READY
	propDoneIndicator.isEnabled = npcState == STATE_HAS_MONEY
	propSign.isEnabled = npcState == STATE_IN_MINE
	if propSign.isEnabled then
		StartUpdatingSign()
	else
		StopUpdatingSign()
	end
end


function OnInteracted()
	if npcState == STATE_READY then
		Events.Broadcast("ShowMineDialog", script)
	elseif npcState == STATE_HAS_MONEY then
		Events.Broadcast("ShowMoneyDialog", script)
		npcState = STATE_READY
		UpdateIndicator()
		Events.BroadcastToServer("ApplyReward",
			script.parent:GetCustomProperty("DigReward"),
			myId)
	end
end


function StartUpdatingSign()
	StopUpdatingSign()
	updateSignTask = Task.Spawn(UpdateSign)
end


function StopUpdatingSign()
	if updateSignTask then updateSignTask:Cancel() end
	updateSignTask = nil
end


function UpdateSign()
	while true do
		local rawSec = CoreMath.Clamp(completion - os.time(), 0, 2^52)

		local sec = rawSec % 60
		local min = math.floor(rawSec/60) % 60
		local hours = math.floor(rawSec/(60 * 60))

		if hours > 0 then
			timetext = "Back in\n" .. hours .. " hours."
		elseif min > 0 then
			timetext = "Back in\n" .. min .. " min."
		elseif sec > 0 then
			timetext = "Back in\n" .. sec .. " sec."
		else
			timetext = "Back\nsoon!"
		end
		
		propSignText.text = timetext
		Task.Wait()
	end
end



function WalkIntoMine()
	--print("entering mine!", npcScript)
	-- Make sure they're talking about us.
	--if npcScript ~= script then return end
	if npcState ~= STATE_READY then return end
	npcState = STATE_IN_MINE
	UpdateIndicator()
	if animTask ~= nil then animTask:Cancel() end
	animTask = Task.Spawn(function()
		propAnimatedMesh:SetWorldPosition(startPos)
		for _, waypoint in pairs(propWalkPath:GetChildren()) do
			propAnimatedMesh.animationStance = "unarmed_walk_forward"
			local waypointPos = waypoint:GetWorldPosition() + Vector3.UP * 100
			local dist = (propAnimatedMesh:GetWorldPosition() - waypointPos).size
			local duration = dist / 300
			propAnimatedMesh:LookAtContinuous(waypoint, true, 5)
			propAnimatedMesh:MoveTo(waypointPos, duration, false)
			Task.Wait(duration)
		end
		propAnimatedMesh.animationStance = "unarmed_idle_relaxed"
		animTask = nil
	end)
end


function WalkOutOfMine()
	if npcState ~= STATE_IN_MINE then return end
	npcState = STATE_HAS_MONEY
	if animTask ~= nil then animTask:Cancel() end
	animTask = Task.Spawn(function()
		local reversedPath = {}
		for k,v in pairs(propWalkPath:GetChildren()) do
			table.insert(reversedPath, 1, v)
		end
		table.insert(reversedPath, script)
		
		for _, waypoint in pairs(reversedPath) do
			propAnimatedMesh.animationStance = "unarmed_walk_forward"
			local waypointPos = waypoint:GetWorldPosition()
			if waypoint:IsA("StaticMesh") then
				-- Little bit of a hack here.
				waypointPos = waypointPos + Vector3.UP * 100
			end
			local dist = (propAnimatedMesh:GetWorldPosition() - waypointPos).size
			local duration = dist / 300
			propAnimatedMesh:LookAtContinuous(waypoint, true, 5)
			propAnimatedMesh:MoveTo(waypointPos, duration, false)
			Task.Wait(duration)
		end
		propAnimatedMesh.animationStance = "unarmed_idle_relaxed"
		propAnimatedMesh:RotateTo(startRot, 0.5)
		animTask = nil
		propTrigger.isEnabled = true
		UpdateIndicator()
	end)
end


function WarpIntoMine(npcScript)
	if animTask ~= nil then animTask:Cancel() end
	npcState = STATE_IN_MINE
	UpdateIndicator()
	local waypoints = propWalkPath:GetChildren()
	propAnimatedMesh:SetWorldPosition(waypoints[#waypoints]:GetWorldPosition())
	propTrigger.isEnabled = false
end


function OnTimerStarted(timerId, completionTimestamp)
	if timerId == myId then
		completion = completionTimestamp
		isTimerRunning = true
		WalkIntoMine()
	end
end


function OnTimerActive(timerId, completionTimestamp)
	if timerId == myId then
		completion = completionTimestamp
		isTimerRunning = true
		WarpIntoMine()
	end
end


function OnTimerCanceled(timerId)
	if timerId == myId then
		isTimerRunning = false
		WalkOutOfMine()
	end
end


function OnTimerCompleted(timerId)
	if timerId == myId then
		isTimerRunning = false
		WalkOutOfMine()
	end
end


function OnReceiveNPCState(timerId, newState)
	if timerId == myId then
		npcState = newState
		UpdateIndicator()
	end
end

UpdateIndicator()

propTrigger.interactedEvent:Connect(OnInteracted)

Events.Connect("TimerStarted", OnTimerStarted)
Events.Connect("TimerActive", OnTimerActive)
Events.Connect("TimerCanceled", OnTimerCanceled)
Events.Connect("TimerCompleted", OnTimerCompleted)
Events.Connect("NPCState", OnReceiveNPCState)
Events.BroadcastToServer("RequestTimerInfo", myId)



Y��������Fantasy Human Guy 1R5
AnimatedMeshAssetRefnpc_human_guy_fantasy_001_ref
:�Ŭ��ܾ�SphereR#
StaticMeshAssetRef
Fң���ܚ�b
StaticMeshAssetRefsm_rock_generic_006
A��Ծ����?Level Up VFXR%
VfxBlueprintAssetRef
Sۆ���Fantasy Chest Base 03R.
StaticMeshAssetRefsm_fantasy_chest_003_ref
V������ѾmFantasy Chest Lid 03R2
StaticMeshAssetRefsm_fantasy_chest_lid_003_ref
N����ʳ��cFantasy Frame 001	R-
PlatformBrushAssetRefUI_Fantasy_Frame_001
K��������BG Flat 003	R/
PlatformBrushAssetRefBackgroundNoOutline_21
E������~Rock Flat 02R)
StaticMeshAssetRefsm_rock_generic_005
@�����GRock 03R)
StaticMeshAssetRefsm_rock_generic_003
E��ۚ����/Rock Flat 01R)
StaticMeshAssetRefsm_rock_generic_004
K��Ȓ��Large Wood Board 8mR'
StaticMeshAssetRefsm_large_board_6m
Y�̚����NRock 02RB
StaticMeshAssetRef,sm_rock_generic_002_sm_rock_generic_002_LOD0
A�������§Rock 01R)
StaticMeshAssetRefsm_rock_generic_001
�����⒋�BLongTermTimers_READMEb�
� �Ԝ�����8*��Ԝ�����8Readme"
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

���ר��
NoneNone�
�.���ר��ReadmeZ�-�---[[

	Long Term Timers
	v1.0 - Dec 11, 2020
	by: Chris

	====================
	Overview
	====================
	
	Long Term Timer Manager is a library for setting timers that
	last longer than a single play session.  They can be used for
	things like crops, that take hours to grow, or bonuses that
	show up once per day, or similar!
	
	Timers are created and managed using functions like StartPlayerTimer,
	CancelPlayerTimer, GetTimerDetails, etc.  They are alwyas associated
	with a specific player, and live in that player's storage.  (So you
	will need to have "Enable Player Storage" checked in your game's
	Game Settings object, for them to work!)
	

	====================
	Samples
	====================
	The Long Term Timers package contains two complete examples:
	  * Basic Sample
	    This is just a set of buttons that can start or reset timers, and
	    some displays, showing the timer's status.  Nothing fancy; just
	    a bare-bones demo of how to use the timers.
	  * Mining Sample
	    This is a more complicated example, with a gold mine, and several
	    minions who can be dispatched to bring gold, over a set amount of
	    time.  Has a few more moving pieces than the basic sample.
	    
	Either sample can be run by simply dragging it into the hierarchy.


	====================
	How to use
	====================
	
	Long Term Timers is a library that is intended to be used via
	Lua's `require` function.  For scripts that need it, they should
	include a custom property asset reference, pointing to
	`_LongTermTimerManager`, and some code like this:
	
	local prop_LongTermTimerManager = script:GetCustomProperty("_LongTermTimerManager")
	local LTT = require(prop_LongTermTimerManager)
	
	Once this is done, all of the functions can be accessed through the LTT object.
	
	In general, you will want to include event handlers for when players join or leave
	the game, to load/save any timers associated with them:
	
	function OnPlayerJoined(player)
		LTT.LoadFromPlayerData(player)
	end
	
	function OnPlayerLeft(player)
		LTT.SaveAsPlayerData(player)
	end
	
	
	Once that is done, you can set and respond to timers fairly easily -
	Creating a new timer is as easy as calling:
	
	LTT.StartPlayerTimer(player, timerName, timerDuration)
	
	You can respond to timers by connecting to the LTT.timerFiredEvent
	event:
	
	function OnTimerFired(player, id, start, duration)
		if id == myTimerName then
			-- do stuff
		end
	end
	LTT.timerFiredEvent:Connect(OnTimerFired)


	====================
	Library Contents:
	====================
	
	timerFiredEvent
	----------------------------
	
	This is the main way you will receive events when timers complete.  It
	behaves identically to the Event class in the rest of the API.  (So you can
	Connect functions to it, etc.)
	
	Functions connected to it will be called with the following arguments:
	player:     The player associated with the timer that completed.
	id:         The id of the timer that completed.
	start:      The time (via os.time) when the timer started.
	duration:   The duration of the timer, in seconds.
	
	
	LoadFromPlayerData(player)
	----------------------------
	
	Loads timer data from the player storage directly.  It will be stored
	in a field named "lte_LTTimerTable" on the player storage table.
	This is usually paired with SaveAsPlayerData()
	
	Any timers that have expired while the player was not logged in will
	fire when data is loaded.
	
	
	SaveAsPlayerData(player)
	----------------------------
	
	Saves the timer data associated with a given player into their player
	storage table, in a field named "lte_LTTimerTable".
	
	Note that this function will preserve existing data in the table, so if
	your game needs to save its own data into player storage, you can call
	this function after you've saved your own data, and it should "just work."
	
	
	ImportFromTable(player, dataTable)
	----------------------------
	
	Loads the data for a player's long term timers from a table.
	(This is usually used if you are managing your own storage
	and have saved the data as a table via ExportAsTable)
	
	Any timers that have expired while the player was not logged in will
	fire when data is loaded.
	
	
	ExportAsTable(player)
	----------------------------
	
	Exports the timer data for a player as a table.  This is
	intended for use if you want to manage your own data
	storage, and just want a raw table to save somewhere.
	
	
	
	StartPlayerTimer(player, timerId, duration)
	----------------------------
	
	Creates a new timer for the given player.  The arguments are the
	player to create the timer for, the duration of the timer, and the
	timerId.
	
	timerId is a string that is used to identify the timer.
	Note that if there is already an timer with the given timerId, it will be
	overwritten.
	
	GetTimerDetails(player, timerId)
	----------------------------
	Returns a table containing details about a given event for a player.
	If the event ID does not match any current events, then nil is returned.
	Otherwise, the table has the following data:
	start:        os.time when the event was created.
	duration:     duration in seconds for the event.
	Remaining():  a function that returns the number of seconds remaining until the timer  fires.
	
	GetAllTimerDetails(player)
	----------------------------
	
	Returns a table, where the keys are the timerIds of every timer for the player,
	and the values are tables such as are returned from GetTimerDetails()
	
	
	CancelPlayerTimer(player, timerId)
	----------------------------
	
	Canceles a timer.  It will not fire.  It's just gone.
	
	
	CancelAllPlayerTimers(player)
	----------------------------
	
	Cancels all timers on a given player.
		
]]

�Rޖ������1LTT - Basic Sampleb�R
�R ��������q*���������qLong Term Timer Sample"
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*���ʥ����I
LTT Sample"


&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��������*����ڒŚ��10-sec Monitor"$


cs:TimerNamej10Sec

cs:TimerDurationX
z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*���������6
  
(
cs:_LongTermTimerManager�ץҝ߮���

cs:Root����ڒŚ��

cs:StartTrigger����ہ����

cs:CancelTrigger�
���Ћ���+z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��ʀ����*����ہ����StartTrigger"$

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�7Start 10 Second Timer"08*
mc:etriggershape:box*����Ћ���+

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�.Cancel Timer"08*
mc:etriggershape:box*������Ƽ9
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent� *���ÿѦ��
World Text")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�j
---�E?�Ç=%  �?%  �?-  �?2$
"mc:ecoretexthorizontalalign:center:"
 mc:ecoretextverticalalign:center*���㲹��(
  

cs:WorldText���ÿѦ��

cs:Root����ڒŚ��z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

������+*���������Geometry"$

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*���뽇ݧ�HComputer Monitor 01")

 
ma:Prop_Screen:id�
͈�����

ma:Prop_Screen:color�%  �?z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����Ǫ��+088�
 *��ݙ���Computer Stand"$


&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��������088�
 *��㔹�ĀCylinder - Chamfered"$

(
ma:Shared_BaseMaterial:id�
͈�����z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����½��h088�
 *����ūܜuCylinder - Chamfered"$

(
ma:Shared_BaseMaterial:id�
͈�����z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����½��h088�
 *����ٿ�ـ�Sphere"$

)
ma:Shared_BaseMaterial:id���Ĉ�����
+
ma:Shared_BaseMaterial:color�
  �A%  �?z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�Ŭ��ܾ�088�
 *�����_Sphere"$

+
ma:Shared_BaseMaterial:color�

(
ma:Shared_BaseMaterial:id�
��������Xz(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�Ŭ��ܾ�088�
 *�Ц�������


cs:TimerNamej5min

cs:TimerDurationX�z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*����Ĥ�
  
(
cs:_LongTermTimerManager�ץҝ߮���

cs:Root�Ц�������

cs:StartTrigger���Ü��ƴ�
 
cs:CancelTrigger����Ӝ�ǌ�z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��ʀ����*���Ü��ƴ�StartTrigger"$

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�6Start 5 Minute Timer"08*
mc:etriggershape:box*����Ӝ�ǌ�

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�.Cancel Timer"08*
mc:etriggershape:box*���������/
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent� *���Հ���4
World Text")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�j
---�E?�Ç=%  �?%  �?-  �?2$
"mc:ecoretexthorizontalalign:center:"
 mc:ecoretextverticalalign:center*����������
  

cs:WorldText�
��Հ���4

cs:Root�Ц�������z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

������+*���ƣꁰSGeometry"$

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*�������лtComputer Monitor 01")

 
ma:Prop_Screen:id�
͈�����

ma:Prop_Screen:color�%  �?z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����Ǫ��+088�
 *���������VComputer Stand"$


&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��������088�
 *����������Cylinder - Chamfered"$

(
ma:Shared_BaseMaterial:id�
͈�����z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����½��h088�
 *���������ICylinder - Chamfered"$

(
ma:Shared_BaseMaterial:id�
͈�����z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����½��h088�
 *��㏲����jSphere"$

)
ma:Shared_BaseMaterial:id���Ĉ�����
+
ma:Shared_BaseMaterial:color�
  �A%  �?z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�Ŭ��ܾ�088�
 *�܆��ڴ��!Sphere"$

+
ma:Shared_BaseMaterial:color�

(
ma:Shared_BaseMaterial:id�
��������Xz(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�Ŭ��ܾ�088�
 *�䠙���إ�2-hour Monitor"$


cs:TimerNamej2hour

cs:TimerDurationX�8z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*��������{
  
(
cs:_LongTermTimerManager�ץҝ߮���

cs:Root�䠙���إ�

cs:StartTrigger�
��Ϲ�÷�5

cs:CancelTrigger�
����ح��Xz(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��ʀ����*���Ϲ�÷�5StartTrigger"$

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�4Start 2 Hour Timer"08*
mc:etriggershape:box*�����ح��X

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�.Cancel Timer"08*
mc:etriggershape:box*���ޚ�����
  
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent� *������ǆ��
World Text")

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�j
---�E?�Ç=%  �?%  �?-  �?2$
"mc:ecoretexthorizontalalign:center:"
 mc:ecoretextverticalalign:center*�͠Ƒ�ӳ�g
  

cs:WorldText������ǆ��

cs:Root�䠙���إ�z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

������+*���Ͼ�����Geometry"$

&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*��΋ӭ����Computer Monitor 01")

 
ma:Prop_Screen:id�
͈�����

ma:Prop_Screen:color�%  �?z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����Ǫ��+088�
 *�����ʱ���Computer Stand"$


&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��������088�
 *���������Cylinder - Chamfered"$

(
ma:Shared_BaseMaterial:id�
͈�����z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����½��h088�
 *����漿��rCylinder - Chamfered"$

(
ma:Shared_BaseMaterial:id�
͈�����z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����½��h088�
 *�֣������Sphere"$

)
ma:Shared_BaseMaterial:id���Ĉ�����
+
ma:Shared_BaseMaterial:color�
  �A%  �?z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�Ŭ��ܾ�088�
 *�ܧ�����Sphere"$

+
ma:Shared_BaseMaterial:color�

(
ma:Shared_BaseMaterial:id�
��������Xz(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�Ŭ��ܾ�088�
 
NoneNone�
M��Ĉ�����Emissive Glow OpaqueR(
MaterialAssetReffxma_opaque_emissive
M����½��hCylinder - ChamferedR)
StaticMeshAssetRefsm_cylinder_chamfer
N��������Computer StandR/
StaticMeshAssetRefsm_urb_computer-stand_001
B͈�����
MaterialAssetRefplastic_matte_001
T����Ǫ��+Computer Monitor 01R1
StaticMeshAssetRefsm_urb_computer-monitor_001
�
  Long Term Timer Manager Sample - Client Code
  V1.0 - 7/15/2020
  by Chris
]]


local propWorldText = script:GetCustomProperty("WorldText"):WaitForObject()
local propRoot = script:GetCustomProperty("Root"):WaitForObject()


local propTimerName = propRoot:GetCustomProperty("TimerName")
local propTimerDuration = propRoot:GetCustomProperty("TimerDuration")


local isTimerRunning = false
local completion = -1
local localPlayer = Game.GetLocalPlayer()

function OnTimerStarted(timerId, completionTimestamp)
	if timerId == propTimerName then
		completion = completionTimestamp
		isTimerRunning = true
	end
end

function OnTimerCanceled(timerId)
	if timerId == propTimerName then
		isTimerRunning = false
		propWorldText.text = "Timer\nCanceled"
	end
end

function OnTimerCompleted(timerId)
	if timerId == propTimerName then
		isTimerRunning = false
		propWorldText.text = "Timer\nCompleted!"
	end
end

function Tick(deltaTime)
	if isTimerRunning then
		local rawSec = CoreMath.Clamp(completion - os.time(), 0, 2^52)

		local sec = rawSec % 60
		local min = math.floor(rawSec/60) % 60
		local hours = math.floor(rawSec/(60 * 60))

		local timetext = ""
		if hours > 0 then timetext = timetext .. hours .. " hours\n" end
		if min > 0 then timetext = timetext .. min .. " min\n" end
		timetext = timetext .. sec .. " sec"
		propWorldText.text = timetext
	end
end

Events.Connect("TimerStarted", OnTimerStarted)
Events.Connect("TimerCanceled", OnTimerCanceled)
Events.Connect("TimerCompleted", OnTimerCompleted)

Events.BroadcastToServer("RequestTimerInfo", propTimerName)
�������܆Long Term Timersb�
� ���猟ᒄ*����猟ᒄTemplateBundleDummy"
  
mc:ecollisionsetting:forceon�
mc:evisibilitysetting:forceon�&Z$

ӽ�Ĥ�

ޖ������1

����⒋�B
NoneNone��
 57666d8289a64c3fac82571748d3496b d97586e1f850481da13ee26d5cbddc02Chris*�Have you ever wanted to make a game where players could start a task, and then log out, and have it still go while they are offline?  Maybe you want them to grow crops.  Or have a daily login bonus.  Or give the player a real-world-time deadline to finish a quest?

This is the library for you!

Set timers for as long as you like, and have them saved with player storage, and restored when they log back in! 

Includes a sample and full documentation.

�ӽ�Ĥ�_LongTermTimerManagerb�
� ���ܩ�*����ܩ�_LongTermTimerManager"
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
ץҝ߮���
NoneNone�