
?���������	Sun LightR%
BlueprintAssetRefCORESKY_SunLight
�:ץҝ߮���_LongTermTimerManagerZ�:�9local LuaEvent = require(script:GetCustomProperty("LuaEvents"))
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

function GetAllTimerDetails(player)
	local results = {}
	for timerId,_ in pairs(LTTimerTable[player.id]) do
		results[timerId] = GetTimerDetails(player, timerId)
	end
	return results
end

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
 LuaEventsZ��

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

���ʀ����Sample_ServerZ��local prop_LongTermTimerManager = script:GetCustomProperty("_LongTermTimerManager")
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

���������
LTT_SampleZ��local prop_LongTermTimerManager = script:GetCustomProperty("_LongTermTimerManager")
local LTT = require(prop_LongTermTimerManager)

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
	end
end

Events.ConnectForPlayer("RequestTimerInfo", OnRequestTimer)

Game.playerJoinedEvent:Connect(OnPlayerJoined)
Game.playerLeftEvent:Connect(OnPlayerLeft)
*
(
cs:_LongTermTimerManager�ץҝ߮���
6��������CubeR!
StaticMeshAssetRefsm_cube_002
>�����SkylightR%
BlueprintAssetRefCORESKY_Skylight
8�����ƺmSky DomeR 
BlueprintAssetRefCORESKY_Sky
�����⒋�BReadmeb�
� �Ԝ�����8*��Ԝ�����8Readme"  �?  �?  �?(�����Bz(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

���ר��
NoneNone�
�'���ר��ReadmeZ�'�'--[[

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

�Rޖ������1Long Term Timer Sampleb�R
�R ��������q*���������qLong Term Timer Sample"  �?  �?  �?(�����B2'��ʥ����I���ڒŚ��Ц�������䠙���إ�z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*���ʥ����I
LTT Sample"

  �� ��   �?  �?  �?(��������qz(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��������*����ڒŚ��10-sec Monitor"$
   C  ��  \C   �?  �?  �?(��������q2/��������6���ہ�������Ћ���+�����Ƽ9��������Z-

cs:TimerNamej10Sec

cs:TimerDurationX
z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*���������6Sample_Server"
    �?  �?  �?(���ڒŚ��Z�
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
  >�  �   � �̌?�̌?�̌?(���ڒŚ��z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�7Start 10 Second Timer"08*
mc:etriggershape:box*����Ћ���+CancelTrigger"$
  >�  C   � �̌?�̌?�̌?(���ڒŚ��z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�.Cancel Timer"08*
mc:etriggershape:box*������Ƽ9ClientContext"
    �?  �?  �?(���ڒŚ��2��ÿѦ����㲹��(z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent� *���ÿѦ��
World Text")
�N�@  �AS�B��3�  @@  @@  @@(�����Ƽ9z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�j
---�E?�Ç=%  �?%  �?-  �?2$
"mc:ecoretexthorizontalalign:center:"
 mc:ecoretextverticalalign:center*���㲹��(Sample_Client"
    �?  �?  �?(�����Ƽ9Z7

cs:WorldText���ÿѦ��

cs:Root����ڒŚ��z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

������+*���������Geometry"$
  ��   A  \�   �?  �?  �?(���ڒŚ��28��뽇ݧ�H�ݙ����㔹�Ā���ūܜu���ٿ�ـ�����_z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*���뽇ݧ�HComputer Monitor 01")
  C   A  \C �Bgf�@�̌?gf�@(��������ZB
 
ma:Prop_Screen:id�
͈�����

ma:Prop_Screen:color�%  �?z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����Ǫ��+088�
 *��ݙ���Computer Stand"$

��B (@���B��@�5|@ѭ�@(��������z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��������088�
 *��㔹�ĀCylinder - Chamfered"$
  ��  ��B   �?  �?  �?(��������Z*
(
ma:Shared_BaseMaterial:id�
͈�����z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����½��h088�
 *����ūܜuCylinder - Chamfered"$
  ��  C�B   �?  �?  �?(��������Z*
(
ma:Shared_BaseMaterial:id�
͈�����z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����½��h088�
 *����ٿ�ـ�Sphere"$
  ��  �  �B ���>���>��L>(��������ZX
)
ma:Shared_BaseMaterial:id���Ĉ�����
+
ma:Shared_BaseMaterial:color�
  �A%  �?z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�Ŭ��ܾ�088�
 *�����_Sphere"$
  ��  C  �B ���>���>��L>(��������ZW
+
ma:Shared_BaseMaterial:color�
   A%  �?
(
ma:Shared_BaseMaterial:id�
��������Xz(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�Ŭ��ܾ�088�
 *�Ц�������5-min Monitor"$
   C  >C  \C   �?  �?  �?(��������q20���Ĥ���Ü��ƴ����Ӝ�ǌ���������/��ƣꁰSZ-

cs:TimerNamej5min

cs:TimerDurationX�z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*����Ĥ�Sample_Server"
    �?  �?  �?(Ц�������Z�
(
cs:_LongTermTimerManager�ץҝ߮���

cs:Root�Ц�������

cs:StartTrigger���Ü��ƴ�
 
cs:CancelTrigger����Ӝ�ǌ�z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��ʀ����*���Ü��ƴ�StartTrigger"$
  >�  �   � �̌?�̌?�̌?(Ц�������z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�6Start 5 Minute Timer"08*
mc:etriggershape:box*����Ӝ�ǌ�CancelTrigger"$
  >�  C   � �̌?�̌?�̌?(Ц�������z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�.Cancel Timer"08*
mc:etriggershape:box*���������/ClientContext"
    �?  �?  �?(Ц�������2��Հ���4���������z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent� *���Հ���4
World Text")
�N�@  �AS�B��3�  @@  @@  @@(��������/z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�j
---�E?�Ç=%  �?%  �?-  �?2$
"mc:ecoretexthorizontalalign:center:"
 mc:ecoretextverticalalign:center*����������Sample_Client"
    �?  �?  �?(��������/Z6

cs:WorldText�
��Հ���4

cs:Root�Ц�������z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

������+*���ƣꁰSGeometry"$
  ��   A  \�   �?  �?  �?(Ц�������27������лt��������V�����������������I�㏲����j܆��ڴ��!z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*�������лtComputer Monitor 01")
  C   A  \C �Bgf�@�̌?gf�@(��ƣꁰSZB
 
ma:Prop_Screen:id�
͈�����

ma:Prop_Screen:color�%  �?z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����Ǫ��+088�
 *���������VComputer Stand"$

��B (@���B��@�5|@ѭ�@(��ƣꁰSz(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��������088�
 *����������Cylinder - Chamfered"$
  ��  ��B   �?  �?  �?(��ƣꁰSZ*
(
ma:Shared_BaseMaterial:id�
͈�����z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����½��h088�
 *���������ICylinder - Chamfered"$
  ��  C�B   �?  �?  �?(��ƣꁰSZ*
(
ma:Shared_BaseMaterial:id�
͈�����z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����½��h088�
 *��㏲����jSphere"$
  ��  �  �B ���>���>��L>(��ƣꁰSZX
)
ma:Shared_BaseMaterial:id���Ĉ�����
+
ma:Shared_BaseMaterial:color�
  �A%  �?z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�Ŭ��ܾ�088�
 *�܆��ڴ��!Sphere"$
  ��  C  �B ���>���>��L>(��ƣꁰSZW
+
ma:Shared_BaseMaterial:color�
   A%  �?
(
ma:Shared_BaseMaterial:id�
��������Xz(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�Ŭ��ܾ�088�
 *�䠙���إ�2-hour Monitor"$
   C  MD  \C   �?  �?  �?(��������q2/�������{��Ϲ�÷�5����ح��X��ޚ�������Ͼ�����Z.

cs:TimerNamej2hour

cs:TimerDurationX�8z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*��������{Sample_Server"
    �?  �?  �?(䠙���إ�Z�
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
  >�  �   � �̌?�̌?�̌?(䠙���إ�z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�4Start 1 Hour Timer"08*
mc:etriggershape:box*�����ح��XCancelTrigger"$
  >�  C   � �̌?�̌?�̌?(䠙���إ�z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�.Cancel Timer"08*
mc:etriggershape:box*���ޚ�����ClientContext"
    �?  �?  �?(䠙���إ�2�����ǆ��͠Ƒ�ӳ�gz(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent� *������ǆ��
World Text")
�N�@  �AS�B��3�  @@  @@  @@(��ޚ�����z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�j
---�E?�Ç=%  �?%  �?-  �?2$
"mc:ecoretexthorizontalalign:center:"
 mc:ecoretextverticalalign:center*�͠Ƒ�ӳ�gSample_Client"
    �?  �?  �?(��ޚ�����Z7

cs:WorldText������ǆ��

cs:Root�䠙���إ�z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

������+*���Ͼ�����Geometry"$
  ��   A  \�   �?  �?  �?(䠙���إ�2:�΋ӭ��������ʱ��������������漿��r֣������ܧ�����z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�*��΋ӭ����Computer Monitor 01")
  C   A  \C �Bgf�@�̌?gf�@(��Ͼ�����ZB
 
ma:Prop_Screen:id�
͈�����

ma:Prop_Screen:color�%  �?z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����Ǫ��+088�
 *�����ʱ���Computer Stand"$

��B (@���B��@�5|@ѭ�@(��Ͼ�����z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
��������088�
 *���������Cylinder - Chamfered"$
  ��  ��B   �?  �?  �?(��Ͼ�����Z*
(
ma:Shared_BaseMaterial:id�
͈�����z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����½��h088�
 *����漿��rCylinder - Chamfered"$
  ��  C�B   �?  �?  �?(��Ͼ�����Z*
(
ma:Shared_BaseMaterial:id�
͈�����z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�

����½��h088�
 *�֣������Sphere"$
  ��  �  �B ���>���>��L>(��Ͼ�����ZX
)
ma:Shared_BaseMaterial:id���Ĉ�����
+
ma:Shared_BaseMaterial:color�
  �A%  �?z(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�Ŭ��ܾ�088�
 *�ܧ�����Sphere"$
  ��  C  �B ���>���>��L>(��Ͼ�����ZW
+
ma:Shared_BaseMaterial:color�
   A%  �?
(
ma:Shared_BaseMaterial:id�
��������Xz(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
�Ŭ��ܾ�088�
 
NoneNone�
R��������XEmissive Glow TransparentR)
MaterialAssetRefmi_basic_emissive_001
M��Ĉ�����Emissive Glow OpaqueR(
MaterialAssetReffxma_opaque_emissive
:�Ŭ��ܾ�SphereR#
StaticMeshAssetRefsm_sphere_002
M����½��hCylinder - ChamferedR)
StaticMeshAssetRefsm_cylinder_chamfer
N��������Computer StandR/
StaticMeshAssetRefsm_urb_computer-stand_001
B͈�����Plastic MatteR%
MaterialAssetRefplastic_matte_001
T����Ǫ��+Computer Monitor 01R1
StaticMeshAssetRefsm_urb_computer-monitor_001
�������+Sample_ClientZ��local propWorldText = script:GetCustomProperty("WorldText"):WaitForObject()
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
�������܆Long Term Timersb�
� ���猟ᒄ*����猟ᒄTemplateBundleDummy"
    �?  �?  �?z
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
� ���ܩ�*����ܩ�_LongTermTimerManager"  �?  �?  �?(�����Bz(
&mc:ecollisionsetting:inheritfromparent�)
'mc:evisibilitysetting:inheritfromparent�
ץҝ߮���
NoneNone�