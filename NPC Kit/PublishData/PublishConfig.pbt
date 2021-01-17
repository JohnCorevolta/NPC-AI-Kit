﻿GameId: "bce549479dec489890d8256dfa35be55"
ClientVersion: "1.0.121-prod-s"
Name: "NPC AI Kit"
Description: "This is the map I use for development of the NPC Kit."
MaxPlayers: 8
IsOpenForEdit: true
Tags: "Action"
Tags: "RPG"
Tags: "Strategy"
Tags: "Fantasy"
ScreenshotPaths: "C:\\Users\\gbsus\\Documents\\My Games\\CORE\\Saved\\Maps\\CREL-games\\NPC Kit\\Screenshots\\Screenshot0003.png"
ReleaseNotes: "v0.11.2\r\n\r\nHighlights\r\n- Added headshots.\r\n- Improved animation controller.\r\n- Breaking changes to Combat Wrapper.\r\n- NavMesh Zones, a new component that allows level designs to be hybrid, with Nav Mesh in some areas and terrain in others.\r\n- Reduced network objects by a third.\r\n\r\nGeneral Improvements\r\n- NPC templates have been restructured, reducing the amount of networked objects per NPC from 6 to 4.\r\n- Added support for headshot damage to dragons, skeletons and raptor.\r\n- The NPCAIServer script now has an optional \"EngageEffect\" custom property. Assign a template to be spawned when the NPC finds a target and engages it.\r\n- NPCs now abandon a chase after a certain distance.\r\n- NPCs now have an optional \"PatrolSpeed\" custom property, resulting in more complex behavior when they are not engaged in combat. If not defined, the default patrol speed is 1/3 the movement speed.\r\n- NPCs now have a SetTarget() function that can be used for a variety of custom interactions.\r\n- NPCs now switch target if they are damaged by an enemy that is much closer than their current target.\r\n- Added NavMesh Zones to help NPCs distinguish between outdoor and indoor pathing logic in games with hybrid environments.\r\n- NPCs can now look at and engage projectiles (used with Zombie Bait, in Survival Kit).\r\n- New NPCKitKillFeedAdapter and SetObjectName scripts allow NPC names to appear in the kill feed when they kill a player. To use this, add the Adapter to the hierarchy and a copy of SetObjectName to each NPC template\'s server context.\r\n- Added new enemy RPG Skeleton - Unarmed.\r\n- Added engage sound effect to dragons.\r\n- Added optional property Attack Min Angle that can be used to constrain NPCs from attacking while the target is behind them.\r\n- Added a new health bar with minimalistic design, as an alternate version to the larger one. Now used by the skeletons.\r\n- Added HomingTarget custom property so each NPC can specify where on their body homing shots will hit.\r\n\r\nCombat Wrapper\r\n- Breaking change: The ApplyDamage() function has been refactored. It now takes a single table parameter. This allows much more flexibility and power in implementing auxilary systems that react to combat events. E.g. damage types, defensive moves, quest progress, etc.\r\n- Added GetVelocity()\r\n- Added GetMaxHitPoints()\r\n- Optional parameters for FindInSphere() are now implemented to match those of Player API.\r\n\r\nAnimation Controller\r\n- Added new animation controller AnimControllerZombie, a versatile humanoid controller.\r\n- The NPCAIClient script no longer has custom properties for each of the states. If your NPCs have different visual pieces that should turn on/off according to state, set those up with an additional animation controller script.\r\n- Skeleton Marksman arrow now hides/shows its crossbow by using the new AnimControllerHideAttackProp script.\r\n- Skeletons now use the AnimControllerZombie.\r\n- Added new animation controller StateBasedAnimController for use with NPCs that don\'t have an animated mesh. E.g. Minions in the MOBA example.\r\n\r\nBugs\r\n- Fixed a bug where NPC colliders could pitch up or down when searching or returning to their spawn points.\r\n- Dragon NPCs have been adjusted so the vertical position of their animated mesh during edit mode coincides with how it will behave at runtime.\r\n- Decreased the size of Easy RPG Dragon\'s collider.\r\n- Changed the shape of RPG Raptor\'s collider.\r\n- Fixed an error when NPCs collide with an object that is in the process of being destroyed.\r\n- Health bars no longer cast shadows.\r\n- Fixed a bug where NPCs could be dealt damage and drop multiple loot after they were already dead, if damaged with AOE.\r\n- Fixed usability isses when swapping the artwork on an NPC, such as jitter from not assigning some custom properties correctly.\r\n\r\nCombat Dependencies - v1.1.1\r\n- Includes the new NPCKitKillFeedAdapter - v1.0\r\n- Combat Wrap API - v0.11.2\r\n\r\nLeaping Staff\r\n- Now deals 50 headshot damage.\r\n- Replaced a deprecated call t"
OwnerId: "b4c6e32137e54571814b5e8f27aa2fcd"
SerializationVersion: 1
PublishedState: Public
