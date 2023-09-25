//
///////////////////////////////////////////////////////////////////////////////
main()
{
	codam\utils::_debug( "I'M IN C_WAWA" );

	// First time in, call the CoDaM initialization function with
	// ... the gametype registration function (which initializes
	// ... gametype-specific callbacks) and the actual game type string
	register = codam\init::main( ::gtRegister, "wawa" );

	spawnpointname = "mp_deathmatch_spawn";
	spawnpoints = [];
	for (i = 0; i < 10; i++)
	{
		part = getEntArray(spawnpointname + "_" + i, "classname");
		for (j = 0; j < part.size; j++)
		{
			spawnpoints[spawnpoints.size] = part[j];
		}
	}
	if (!spawnpoints.size)
	{
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}
	for (i = 0; i < spawnpoints.size; i++)
	{
		spawnpoints[i] placeSpawnpoint();
	}

	if (getCvar("scr_wawa_scorelimit") == "") // NUMBER OF KILLS TO WIN DUEL
	{
		setCvar("scr_wawa_scorelimit", "10");
	}	
	level.scorelimit = getCvarInt("scr_wawa_scorelimit");
	if (getCvar("scr_wawa_killcamtime") == "")
	{
		setCvar("scr_wawa_killcamtime", "4");
	}
	level.killcamtime = getCvarFloat("scr_wawa_killcamtime");

	level.spawnprotection = codam\utils::getVar("scr_wawa", "spawnprotection", "int", 1|2, 0);
	level.bulletreward = codam\utils::getVar("scr_wawa", "bulletreward", "bool", 1|2, false);

	level.healthqueue = [];
	level.healthqueuecurrent = 0;

	level.arenaFree = [];
	level.arenaFree[-1] = 0;
	level.bodies = [];
	level.arenaPlayer = [];
	for (i = 0; i < 10; i++)
	{
		level.arenaPlayer[i] = undefined;
		level.arenaFree[i] = 2;
		level.bodies[i] = [];
	}

	level.objectiveText = "Enter an arena to fight a duel, score " + level.scorelimit + " points to win!";

	level.hudoffset = 30;

	level.arenastatus[0] = &"Occupied";
	level.arenastatus[1] = &"Half-Free";
	level.arenastatus[2] = &"Free";

	level.arenahud[0] = &"#1";
	level.arenahud[1] = &"#2";
	level.arenahud[2] = &"#3";
	level.arenahud[3] = &"#4";
	level.arenahud[4] = &"#5";
	level.arenahud[5] = &"#6";
	level.arenahud[6] = &"#7";
	level.arenahud[7] = &"#8";
	level.arenahud[8] = &"#9   (Bash)";
	level.arenahud[9] = &"#10 (AW)";
	level.WawaScoreText = &"You   Opponent";
	level.WawaScoreSepe = &"|";
	level.arenainfo = &"^1FIRE^7/^1MELEE^7 to scroll, ^1[{+activate}]^7 to start!";
	level.arenahudstatus = &"Arena                                        Status";

	[[register]]("PlayerDisconnect", ::PlayerDisconnect, "thread");

	return;
}
//
///////////////////////////////////////////////////////////////////////////////
gtRegister(register, post)
{
	// Since CoDaM treats the first registration of a callback as the
	// ... "default" call, must ensure that gametype-specific functions
	// ... are registered first during Init.

	if (isdefined(post))
		return;

	// Script-level	callbacks
	[[register]]("StartGameType", ::StartGameType);
	[[register]]("PlayerConnect", codam\callbacks::PlayerConnect);
	[[register]]("PlayerDisconnect", codam\callbacks::PlayerDisconnect);
	[[register]]("PlayerDamage", ::PlayerDamage);
	[[register]]("PlayerKilled", ::PlayerKilled);

	// Game-type callbacks
	[[register]]("finishPlayerDamage", codam\miscmod::_finishPlayerDamage);
	[[register]]("finishPlayerKilled", codam\callbacks::finishPlayerKilled);
	[[register]]("gt_startGame", ::startGame);
	[[register]]("gt_spawnPlayer", ::spawnPlayer);
	[[register]]("gt_spawnSpectator", ::spawnSpectator);
	[[register]]("gt_spawnIntermission", ::spawnIntermission);
	[[register]]("gt_respawn", ::respawn );
	[[register]]("gt_menuHandler", ::menuHandler);

	return;
}
//
///////////////////////////////////////////////////////////////////////////////
StartGameType(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1,b2, b2,b4, b5,	b6, b7,	b8, b9)
{
	// Call	the CoDaM initialization function without any args to
	// continue with framework/custom mods initialization.
	codam\init::main();
	
	// If this is a	fresh map start	...
	if( !isdefined( game[ "gamestarted" ] ) )
	{
		precacheShader("gfx/hud/hud@ammocounterback.tga");
		precacheShader("gfx/hud/hud@health_cross.tga");
		[[ level.gtd_call ]]( "scoreboard" );
	}

	// Last call to CoDaM init to cause any last-minutes framework to
	// start.
	codam\init::main();

	game[ "gamestarted" ] =	true;
	[[ level.gtd_call ]]( "setClientNameMode", "auto_change" );
	thread [[ level.gtd_call ]]( "gt_startGame" );
	return;
}
//
///////////////////////////////////////////////////////////////////////////////
startGame(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
	level endon( "end_map" );
	level.starttime = getTime();
	level notify( "start_map" );
	return;
}
//
///////////////////////////////////////////////////////////////////////////////
menuHandler(menu, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
	self endon( "end_player" );

	for(;;)
	{
		resp = self [[ level.gtd_call ]]( "menuHandler", menu );
		if ( !isdefined( resp ) || ( resp.size < 2 ) || !isdefined( resp[ 0 ] ) || !isdefined( resp[ 1 ] ) )
		{
			// Shouldn't happen ... but just in case
			wait( 1 );
			continue;
		}

		val = resp[ 1 ];
		switch ( resp[ 0 ] )
		{
			case "team":
				switch ( val )
				{
					case "spectator":
						if (self.pers["team"] != "spectator")
						{
							hud_select_destroy();

							if (isDefined(self.arena))
							{
								level.arenaFree[self.arena]++;
								if (level.arenaFree[self.arena] > 2)
								{
									codam\utils::_debug("####### menuHandler: arenaFree is bigger than 2");
									level.arenaFree[self.arena] = 2;
								}
								level updateArenaStatus(self.arena);

								if (isDefined(self.opponent))
								{
									if (!isDefined(self.lose))
									{
										self.opponent iPrintLnBold("Your opponent has just left!");
									}
									level.arenaPlayer[self.arena] = self.opponent;
									self.opponent.opponent = undefined;
									level.arenaPlayer[self.arena] hud_score_create_update();
								}
								else
								{
									level.arenaPlayer[self.arena] = undefined;
								}
							}

							self.choosingArena = false;
							self.pers["team"] = "spectator";
							self.sessionteam = "spectator";
							self setClientCvar("g_scriptMainMenu", game["menu_team"]);
							self setClientCvar("scr_showweapontab", "0");

							spawnSpectator();
						}
						menu = undefined;
					break;

					default:
						//if self.archivetime is not 0, self is watching killcam, so their sessionstate is "spectator"
						if (self.sessionstate == "playing" || self.sessionstate == "dead" || self.choosingArena || self.archivetime)
						{
							self iPrintLnBold("Please first go Spectate");
							break;
						}
						self.pers["team"] = val;
						self.pers[ "weapon" ] = undefined;
						self.pers[ "weapon1" ] = undefined;
						self.pers[ "weapon2" ] = undefined;
						self.pers[ "savedmodel" ] = undefined;
						self.pers[ "spawnweapon" ] = undefined;
						menu = game[ "menu_weapon_" + val ];
						self setClientCvar( "g_scriptMainMenu", menu );
						self setClientCvar( level.ui_weapontab, "1" );
					break;
				}
			break;
			
			case "weapon":
				if ( ![[ level.gtd_call ]]( "isTeam", self.pers[ "team" ] ) )
				{
					// No team selected yet?
					menu = game[ "menu_team" ];
					break;
				}
				if ( !self [[ level.gtd_call ]]( "isWeaponAllowed", val ) )
				{
					self iprintln( "^3*** Weapon has been disabled." );
					break;
				}
				weapon = val;
				if ( isdefined( self.pers[ "weapon" ] ) && ( self.pers[ "weapon" ] == weapon ) )
				{
					menu = undefined;
					break;	// Same weapon selected!
				}
				// Is the weapon available?
				weapon = self [[ level.gtd_call ]]( "assignWeapon", weapon );
				if ( !isdefined( weapon ) )
				{
					self iprintln( "^3*** Weapon is unavailable." );
					break;
				}
				menu = undefined;

				if ( !isdefined( self.pers[ "weapon" ] ) )
				{
					// First selected weapon ...
					self.pers[ "weapon" ] = weapon;
					thread arenaSelection();
				}
				else
				{
					// Already have a weapon, wait 'til next spawn
					self.pers[ "weapon" ] = weapon;
					if ( maps\mp\gametypes\_teams::useAn( weapon ) )
						text = &"MPSCRIPT_YOU_WILL_RESPAWN_WITH_AN";
					else
						text = &"MPSCRIPT_YOU_WILL_RESPAWN_WITH_A";
					weaponname = maps\mp\gametypes\_teams::getWeaponName( weapon );
					self iprintln( text, weaponname );
				}
			break;
				
			case "menu":
				codam\utils::_debug("####### menuHandler: menu ");
				if ( ( val == "weapon" ) && isdefined( self.pers[ "team" ] ) )
				{
					menu = game[ "menu_weapon_" + self.pers[ "team" ] ];
				}
			break;

			default:
				codam\utils::_debug("####### menuHandler: default ");
				menu = undefined;
			break;
		}
	}
}

///////////////////////
PlayerDisconnect(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
	if (isDefined(self.arena))
	{
		level.arenaFree[self.arena]++;
		if (level.arenaFree[self.arena] > 2)
		{
			codam\utils::_debug("####### PlayerDisconnect: arenaFree is bigger than 2");
			level.arenaFree[self.arena] = 2;
		}
		level updateArenaStatus(self.arena);

		if (isDefined(self.opponent))
		{
			if (!isDefined(self.lose))
			{
				self.opponent iPrintLnBold("Your opponent has just left!");
			}
			level.arenaPlayer[self.arena] = self.opponent;
			self.opponent.opponent = undefined;
			level.arenaPlayer[self.arena] hud_score_create_update();
		}
		else
		{
			level.arenaPlayer[self.arena] = undefined;
		}
	}
}
PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
	if (isDefined(self.protected))
	{
		eAttacker thread spawnProtectionEmblem();
		eAttacker iPrintLn("Player is spawn-protected.");
		return;
	}
	if (isDefined(eAttacker.protected))
	{
		eAttacker iPrintLn("Can't kill while being spawn-protected.");
		eAttacker thread spawnProtectionEmblem();
		return;
	}
	self [[	level.gtd_call ]]( "finishPlayerDamage", eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc );
}
PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
	self endon("spawned");

	if(self.sessionteam == "spectator")
		return;
	// If the player was killed by a head shot, let players know it was a head shot kill
	if(sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE")
		sMeansOfDeath = "MOD_HEAD_SHOT";
	// send out an obituary message to all clients about the kill
	obituary(self, attacker, sWeapon, sMeansOfDeath);
	self.sessionstate = "dead";
	self.statusicon = "gfx/hud/hud@status_dead.tga";
	self.deaths++;

	attackerNum = -1;
	if (isPlayer(attacker))
	{
		if (attacker == self) // killed himself
		{
			doKillcam = false;
			attacker.score--;
		}
		else
		{
			attackerNum = attacker getEntityNumber();
			doKillcam = true;
			attacker.score++;

			pistolkill = codam\utils::getVar("scr_mm", "pistolkill", "bool", 1|2, false);
			//GIVE A NEW BULLET TO KILLER IF USED PISTOL 1SK
			if (level.bulletreward && pistolkill && codam\_mm_mmm::isSecondaryWeapon(sWeapon))
			{
				attacker setWeaponSlotAmmo("pistol", 1);
			}

			if (!isDefined(attacker.lose))
			{
				attacker checkScoreLimit();
			}
			if (isDefined(attacker.win)) //attacker wins
			{
				attacker iPrintlnBold("You ^2won^7 against " + codam\_mm_mmm::namefix(self.name));
				self iPrintlnBold("You ^1lost^7 to " + codam\_mm_mmm::namefix(attacker.name));
				iPrintLn(codam\_mm_mmm::namefix(attacker.name) + " ^7won^1!");
				attacker.win = undefined;
				self.lose = 1;
			}
		}
	}
	else // If you weren't killed by a player, you were in the wrong place at the wrong time
	{
		doKillcam = false;
		self.score--;
	}

	//Drop weapon and health
	if (self.arena == 9)
	{
		self dropItem(self getCurrentWeapon());
		self dropItem("item_health");
		self dropItem("item_health");
	}
	self.lastweapon = self getCurrentWeapon();
	body = self cloneplayer();
	for (i = 0; i < level.bodies[self.arena].size+1; i++)
	{
		if(!isDefined(level.bodies[self.arena][i]))
		{
			level.bodies[self.arena][i] = body;
			break;
		}
	}
	delay = 2;
	wait delay;

	if (isDefined(self.lose))
	{
		level.arenaFree[self.arena]++;
		if (level.arenaFree[self.arena] > 2)
		{
			codam\utils::_debug("####### PlayerKilled: arenaFree is bigger than 2");
			level.arenaFree[self.arena] = 2;
		}
		level updateArenaStatus(self.arena);

		if (isDefined(self.opponent)) //winner still plays after 2 seconds
		{
			level.arenaPlayer[self.arena] = self.opponent;
			self.opponent.opponent = undefined;
			if (!doKillcam)
			{
				self.opponent hud_score_create_update();
			}
		}
		else
		{
			level.arenaPlayer[self.arena] = undefined;
		} 
		self.arena = undefined;
	}

	if (doKillcam)
	{
		thread killcam(attackerNum, delay);
	}
	else if (!isDefined(self.lose))
	{
		thread respawn(self.arena);
	}
	else
	{
		self.pers["team"] = "spectator";
		self.pers["weapon"] = undefined;
		self.pers["savedmodel"] = undefined;
		self.sessionteam = "spectator";
		self setClientCvar("g_scriptMainMenu", game["menu_team"]);
		self setClientCvar("scr_showweapontab", "0");
		spawnSpectator(true);
	}
}
///////////////////////

//SPAWN FUNCTIONS
spawnSpectator(openmenu, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
	self.pers["team"] = "spectator";
	self.sessionteam = "spectator";
	self notify("spawned");
	self notify("end_respawn");
	resettimeout();

	self [[ level.gtd_call ]]("allowSpectateTeam", "allies", true);
	self [[ level.gtd_call ]]("allowSpectateTeam", "axis", true);
	self [[ level.gtd_call ]]("allowSpectateTeam", "freelook", true);
	self [[ level.gtd_call ]]("allowSpectateTeam", "none", true);

	_hud_score_destroy();
	self.lose = undefined;
	self.opponent = undefined;
	self.arena = undefined;
	self.choosingArena = false;
	self.score = 0;
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.archivetime = 0;

	if (self.pers["team"] == "spectator")
	{
		self.statusicon = "";
	}
	self showMap();

	self setClientCvar("cg_objectiveText", level.objectiveText);
	self setClientCvar("g_scriptMainMenu", game["menu_team"]);
	self setClientCvar("scr_showweapontab", "0");
	if (isDefined(openmenu))
	{
		self openMenu(game["menu_team"]);
	}
}
spawnIntermission(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
	codam\utils::_debug("####### spawnIntermission");

	self notify("spawned");
	self notify("end_respawn");
	resettimeout();
	_hud_score_destroy();
	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.archivetime = 0;
	if (isDefined(self.arena))
	{
		codam\utils::_debug("####### spawnintermission: ERROR: ARENA IS DEFINED");
		self.arena = undefined;
	}
	self showMap();
}
spawnPlayer(arena, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
	if (!isDefined(arena) || !isDefined(self.arena))
	{
		codam\utils::_debug("####### spawnPlayer: no arena");
		return;
	}

	self notify("spawned");
	self notify("end_respawn");
	resettimeout();
	self.sessionteam = "none";
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.archivetime = 0;

	spawnpointname = "mp_deathmatch_spawn_" + arena;
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = getSpawnPointWawa(spawnpoints);

	if (isDefined(spawnpoint))
	{
		self spawn(spawnpoint.origin, spawnpoint.angles);
	}
	else
	{
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
	}

	self.statusicon = "";
	self.maxhealth = 100;
	self.health = self.maxhealth;

	if (!isDefined(self.pers["savedmodel"]))
	{
		maps\mp\gametypes\_teams::model();
	}
	else
	{
		maps\mp\_utility::loadModel(self.pers["savedmodel"]);
	}
		
	//GIVE WEAPONS
	if (self.arena == 9) //AW ARENA
	{
		//SELECTED FROM MENU
		//Should disable instant kill if is this bolt weapon.
		_weap = self.pers[ "weapon" ];
		__weap = self [[ level.gtd_call ]]( "assignWeaponSlot", "primary", _weap );
		self setSpawnWeapon( __weap );
		self switchToWeapon( __weap );

		//GIVE A randomNonBoltRifle
		nonBoltRifles = [];
		nonBoltRifles[nonBoltRifles.size] = "mp44_mp";
		nonBoltRifles[nonBoltRifles.size] = "bar_mp";
		nonBoltRifles[nonBoltRifles.size] = "m1carbine_mp";
		nonBoltRifles[nonBoltRifles.size] = "ppsh_mp";
		randomNonBoltRifle = nonBoltRifles[randomInt(nonBoltRifles.size)];
		self giveWeapon(randomNonBoltRifle);
 		self giveMaxAmmo(randomNonBoltRifle);
		
		//GIVE GRENADE RANDOMLY
		if (randomInt(3) == 1)
		{
			self setWeaponSlotWeapon("grenade", "stielhandgranate_mp");
			self setWeaponSlotClipAmmo("grenade", 1);
		}
		//Should also give a pistol without instant kill.
	}
	else
	{
		//SELECTED FROM MENU
		_weap = self.pers[ "weapon" ];
		if (self.arena == 8) //BASH ARENA
		{
			__weap = self [[ level.gtd_call ]]( "assignWeaponSlot", "primary", _weap, 0 );
			self setWeaponSlotClipAmmo("primary", 0);
		}
		else
		{
			__weap = self [[ level.gtd_call ]]( "assignWeaponSlot", "primary", _weap );
		}
		self setSpawnWeapon( __weap );
		self switchToWeapon( __weap );

		//PISTOL
		if (self.arena == 8) //BASH ARENA
		{
			pistol = self [[ level.gtd_call ]]("assignWeapon", "colt_mp");
			self [[ level.gtd_call ]]("assignWeaponSlot", "pistol", pistol, 0);
			self setWeaponSlotClipAmmo("pistol", 0);
		}
		else
		{
			if (getCvar("scr_mm_allow_pistols") == "") //NOT USING MM CVAR
			{
				self [[ level.gtd_call ]]( "givePistol" );
			}
			else
			{
				if (getCvarInt("scr_mm_allow_pistols") > 0)
				{
					self [[ level.gtd_call ]]( "givePistol" );
				}
			}
		}
		//GRENADES
		if (self.arena != 8) //BASH ARENA
		{
			if (getCvar("scr_mm_allow_grenades") == "") //NOT USING MM CVAR
			{
				self [[ level.gtd_call ]]( "giveGrenade", _weap );
			}
			else
			{
				if (getCvarInt("scr_mm_allow_grenades") > 0)
				{
					self [[ level.gtd_call ]]( "giveGrenade", _weap );
				}
			}
		}
	}

	if (level.spawnprotection > 0)
	{
		thread spawnProtection(level.spawnprotection);
	}
}
spawnProtection(time)
{
	self endon("spawned");
	self endon("end_respawn");

	self.protected = 1;
	thread spawnProtectionNotify();

	wait time;
	self.protected = undefined;
}
spawnProtectionEmblem()
{
	self endon("spawned");

	if (isDefined(self.wawa_protemb))
		self.wawa_protemb destroy();

	self.wawa_protemb = newClientHudElem(self);
	self.wawa_protemb.alignX = "center";
	self.wawa_protemb.alignY = "middle";
	self.wawa_protemb.x = 320;
	self.wawa_protemb.y = 240;
	self.wawa_protemb.alpha = .5;
	self.wawa_protemb setShader("gfx/hud/hud@health_cross.tga", 32, 32);
	self.wawa_protemb scaleOverTime(.15, 64, 64);

	wait .15;

	if (isDefined(self.wawa_protemb))
		self.wawa_protemb destroy();
}
spawnProtectionNotify()
{
	if (isDefined(self.protnot))
		self.protnot destroy();

	self.protnot = newClientHudElem(self);
	self.protnot.x = 520;
	self.protnot.y = 410;
	self.protnot.alpha = 0.65;
	self.protnot.alignX = "center";
	self.protnot.alignY = "middle";
	self.protnot setShader("gfx/hud/hud@health_cross.tga",40,40);

	wait level.spawnprotection;

	if (isDefined(self.protnot))
		self.protnot destroy();
}
respawn(arena, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
	if (!isDefined(arena) || !isDefined(self.arena))
	{
		codam\utils::_debug("####### respawn: self.arena is NOT defined");
	}
	self endon("end_respawn");

	thread waitRespawnButton();
	self waittill("respawn");
	thread spawnPlayer(arena);
}
waitRespawnButton()
{
	self endon("end_respawn");
	self endon("respawn");

	wait 0; // Required or the "respawn" notify could happen before it's waittill has begun

	self.respawntext = newClientHudElem(self);
	self.respawntext.alignX = "center";
	self.respawntext.alignY = "middle";
	self.respawntext.x = 320;
	self.respawntext.y = 70;
	self.respawntext.archived = false;
	self.respawntext setText(&"MPSCRIPT_PRESS_ACTIVATE_TO_RESPAWN");

	thread removeRespawnText();
	thread waitRemoveRespawnText("end_respawn");
	thread waitRemoveRespawnText("respawn");

	while(self useButtonPressed() != true)
		wait .05;

	self notify("remove_respawntext");
	self notify("respawn");
}
waitRemoveRespawnText(message)
{
	self endon("remove_respawntext");

	self waittill(message);
	self notify("remove_respawntext");
}
removeRespawnText()
{
	self waittill("remove_respawntext");

	if(isDefined(self.respawntext))
		self.respawntext destroy();
}
showMap()
{
	origin = (163, -1892, 1225);
	angles = (10, 53, 0);
	self spawn(origin, angles);
}

//KILLCAM FUNCTIONS
killcam(attackerNum, delay)
{
	self endon("spawned");

	if (attackerNum < 0)
		return;
	self.sessionstate = "spectator";
	self.spectatorclient = attackerNum;
	self.archivetime = delay + level.killcamtime;
	wait 0.05; //wait till next server frame to update archivetime if needs trimming

	//TODO: CHECK THIS CODE PURPOSE
	/*
	if (self.archivetime <= delay)
	{
		self.spectatorclient = -1;
		self.archivetime = 0;
		self.sessionstate = "dead";
		
		if (!isDefined(self.lose))
		{
			hud_score_create_update();
			thread respawn(self.arena);
		}
		else
		{
			if (isDefined(self.opponent))
			{
				self.opponent hud_score_create_update();
			}
			self.pers["team"] = "spectator";
			self.sessionteam = "spectator";
			self setClientCvar("g_scriptMainMenu", game["menu_team"]);
			self setClientCvar("scr_showweapontab", "0");
			thread spawnSpectator();
		}
		return;
	}
	*/

	if (!isDefined(self.kc_topbar))
	{
		self.kc_topbar = newClientHudElem(self);
		self.kc_topbar.archived = false;
		self.kc_topbar.x = 0;
		self.kc_topbar.y = 0;
		self.kc_topbar.alpha = 0.5;
		self.kc_topbar setShader("black", 640, 112);
	}
	if (!isDefined(self.kc_bottombar))
	{
		self.kc_bottombar = newClientHudElem(self);
		self.kc_bottombar.archived = false;
		self.kc_bottombar.x = 0;
		self.kc_bottombar.y = 368;
		self.kc_bottombar.alpha = 0.5;
		self.kc_bottombar setShader("black", 640, 112);
	}
	if (!isDefined(self.kc_title))
	{
		self.kc_title = newClientHudElem(self);
		self.kc_title.archived = false;
		self.kc_title.x = 320;
		self.kc_title.y = 40;
		self.kc_title.alignX = "center";
		self.kc_title.alignY = "middle";
		self.kc_title.sort = 1; // force to draw after the bars
		self.kc_title.fontScale = 3.5;
	}
	self.kc_title setText(&"MPSCRIPT_KILLCAM");
	if (!isDefined(self.kc_skiptext))
	{
		self.kc_skiptext = newClientHudElem(self);
		self.kc_skiptext.archived = false;
		self.kc_skiptext.x = 320;
		self.kc_skiptext.y = 70;
		self.kc_skiptext.alignX = "center";
		self.kc_skiptext.alignY = "middle";
		self.kc_skiptext.sort = 1; // force to draw after the bars
	}
	self.kc_skiptext setText(&"MPSCRIPT_PRESS_ACTIVATE_TO_RESPAWN");
	thread spawnedKillcamCleanup();
	thread waitSkipKillcamButton();
	thread waitKillcamTime();
	self waittill("end_killcam");

	removeKillcamElements();

	self.spectatorclient = -1;
	self.archivetime = 0;
	self.sessionstate = "dead";

	if (!isDefined(self.lose))
	{
		hud_score_create_update();
		thread respawn(self.arena);
	}
	else
	{
		if (isDefined(self.opponent))
		{
			self.opponent hud_score_create_update();
		}
		self.pers["team"] = "spectator";
		self.sessionteam = "spectator";
		self setClientCvar("g_scriptMainMenu", game["menu_team"]);
		self setClientCvar("scr_showweapontab", "0");
		thread spawnSpectator(true);
	}
}
waitKillcamTime()
{
	self endon("end_killcam");

	wait(self.archivetime - 0.05);
	self notify("end_killcam");
}
waitSkipKillcamButton()
{
	self endon("end_killcam");

	while(self useButtonPressed())
		wait .05;
	while(!(self useButtonPressed()))
		wait .05;
	self notify("end_killcam");
}
removeKillcamElements()
{
	if(isDefined(self.kc_topbar))
		self.kc_topbar destroy();
	if(isDefined(self.kc_bottombar))
		self.kc_bottombar destroy();
	if(isDefined(self.kc_title))
		self.kc_title destroy();
	if(isDefined(self.kc_skiptext))
		self.kc_skiptext destroy();
}
spawnedKillcamCleanup()
{
	self endon("end_killcam");

	self waittill("spawned");
	self removeKillcamElements();
}

//HUD FUNCTIONS
_hud_select_create()
{
	if (isDefined(self.vote_hud_bgnd))
		return;

	self.vote_hud_bgnd = newClientHudElem(self);
	self.vote_hud_bgnd.archived = false;
	self.vote_hud_bgnd.alpha = .7;
	self.vote_hud_bgnd.x = 205;
	self.vote_hud_bgnd.y = level.hudoffset + 17;
	self.vote_hud_bgnd.sort = 9000;
	self.vote_hud_bgnd.color = (0,0,0);
	self.vote_hud_bgnd setShader("white", 260, 220);

	self.vote_header = newClientHudElem(self);
	self.vote_header.archived = false;
	self.vote_header.alpha = .3;
	self.vote_header.x = 208;
	self.vote_header.y = level.hudoffset + 19;
	self.vote_header.sort = 9001;
	self.vote_header setShader("white", 254, 21);

	self.vote_headerText = newClientHudElem(self);
	self.vote_headerText.archived = false;
	self.vote_headerText.x = 210;
	self.vote_headerText.y = level.hudoffset + 21;
	self.vote_headerText.sort = 9998;
	self.vote_headerText.label = level.arenainfo;
	self.vote_headerText.fontscale = 1.3;

	self.vote_leftline = newClientHudElem(self);
	self.vote_leftline.archived = false;
	self.vote_leftline.alpha = .3;
	self.vote_leftline.x = 207;
	self.vote_leftline.y = level.hudoffset + 19;
	self.vote_leftline.sort = 9001;
	self.vote_leftline setShader("white", 1, 215);

	self.vote_rightline = newClientHudElem(self);
	self.vote_rightline.archived = false;
	self.vote_rightline.alpha = .3;
	self.vote_rightline.x = 462;
	self.vote_rightline.y = level.hudoffset + 19;
	self.vote_rightline.sort = 9001;
	self.vote_rightline setShader("white", 1, 215);

	self.vote_bottomline = newClientHudElem(self);
	self.vote_bottomline.archived = false;
	self.vote_bottomline.alpha = .3;
	self.vote_bottomline.x = 207;
	self.vote_bottomline.y = level.hudoffset + 234;
	self.vote_bottomline.sort = 9001;
	self.vote_bottomline setShader("white", 256, 1);

	self.vote_hud_instructions = newClientHudElem(self);
	self.vote_hud_instructions.archived = false;
	self.vote_hud_instructions.x = 310;
	self.vote_hud_instructions.y = level.hudoffset + 56;
	self.vote_hud_instructions.sort = 9998;
	self.vote_hud_instructions.fontscale = 1;
	self.vote_hud_instructions.label = level.arenahudstatus;
	self.vote_hud_instructions.alignX = "center";
	self.vote_hud_instructions.alignY = "middle";

	for(i = 0; i < 10; i++)
	{
		self.arenahud[i] = newClientHudElem(self);
		self.arenahud[i].archived = false;
		self.arenahud[i].x = 230;
		self.arenahud[i].y = level.hudoffset + 69 + (i*16);
		self.arenahud[i].sort = 9998;
		self.arenahud[i].fontScale = 1.1;
		self.arenahud[i] setText(level.arenahud[i]);

		self.arenahudstatus[i] = newClientHudElem(self);
		self.arenahudstatus[i].archived = false;
		self.arenahudstatus[i].x = 380;
		self.arenahudstatus[i].y = level.hudoffset + 69 + (i*16);
		self.arenahudstatus[i].sort = 9998;
		self.arenahudstatus[i].fontScale = 1.1;
		self.arenahudstatus[i] setText(level.arenastatus[level.arenaFree[i]]);
	}

	self.vote_indicator = newClientHudElem( self );
	self.vote_indicator.alignY = "middle";
	self.vote_indicator.x = 208;
	self.vote_indicator.y = level.hudoffset + 60;
	self.vote_indicator.archived = false;
	self.vote_indicator.sort = 9998;
	self.vote_indicator.alpha = .3;
	self.vote_indicator.color = (0, 0, 1);
}
hud_select_destroy()
{
	if (!isDefined(self.vote_hud_bgnd))
		return;
	self.vote_hud_bgnd destroy();
	self.vote_header destroy();
	self.vote_headerText destroy();
	self.vote_leftline destroy();
	self.vote_rightline destroy();
	self.vote_bottomline destroy();
	self.vote_hud_instructions destroy();
	for (i = 0; i < 10; i++)
	{
		self.arenahudstatus[i] destroy();
		self.arenahud[i] destroy();
	}
	self.vote_indicator destroy();
}
hud_score_create_update(flag)
{
	//creates and updates hud for self and its opponent - no need to call twice, just call it on self.

	if (!isDefined(self.WawaScoreText))
	{
		self.WawaScoreShader = newClientHudElem(self);
		self.WawaScoreShader.alpha = 1;
		self.WawaScoreShader.x = 557;
		self.WawaScoreShader.y = 395;
		self.WawaScoreShader.sort = 9998;
		self.WawaScoreShader setShader("gfx/hud/hud@ammocounterback.tga", 80, 40);

		self.WawaScoreText = NewClientHudElem(self);
		self.WawaScoreText.x = 565;
		self.WawaScoreText.y = 392;
		self.WawaScoreText.fontScale = 0.8;
		self.WawaScoreText.sort = 9999;
		self.WawaScoreText setText(level.WawaScoreText);

		self.WawaScoreSepe = NewClientHudElem(self);
		self.WawaScoreSepe.x = 595;
		self.WawaScoreSepe.y = 408;
		self.WawaScoreSepe.fontScale = 0.9;
		self.WawaScoreSepe.sort = 9999;
		self.WawaScoreSepe setText(level.WawaScoreSepe);

		self.WawaSelfNumb = NewClientHudElem(self);
		self.WawaSelfNumb.x = 570;
		self.WawaSelfNumb.y = 406;
		self.WawaSelfNumb.sort = 9999;
		self.WawaSelfNumb.fontScale	= 1.2;

		self.WawaOppoNumb = NewClientHudElem(self);
		self.WawaOppoNumb.color = (1, 0, 0);
		self.WawaOppoNumb.x = 610;
		self.WawaOppoNumb.y = 406;
		self.WawaOppoNumb.sort = 9999;
		self.WawaOppoNumb.fontScale	= 1.2;
	}

	newScoreSelf = self.score;
	self.WawaSelfNumb setValue(newScoreSelf);

	if (isDefined(self.opponent))
	{
		newScoreOppo = self.opponent.score;
		self.WawaOppoNumb setValue(newScoreOppo);
		
		if (!isDefined(flag))
		{
			self.opponent hud_score_create_update(1); //update hud for the opponent too. 1 is not to crash the game due to infinite hud updating.
		}
	}
	else
		self.WawaOppoNumb setText(&"-");
}
_hud_score_destroy()
{
	if(!isDefined(self.WawaScoreText))
		return;
	self.WawaScoreSepe destroy();
	self.WawaScoreShader destroy();
	self.WawaScoreText destroy();
	self.WawaSelfNumb destroy();
	self.WawaOppoNumb destroy();
}

///////////////////////
checkScoreLimit()
{
	if(level.scorelimit <= 0)
		return;
	if (self.score < level.scorelimit)
		return;
	self.win = true;
	return;
}
arenaSelection()
{
	self notify("end_respawn");
	self endon("end_respawn");
	self endon("spawned");

	_hud_select_create();
	self.spectatorclient = -1;

	self [[ level.gtd_call ]]("allowSpectateTeam", "allies", false);
	self [[ level.gtd_call ]]("allowSpectateTeam", "axis", false);
	self [[ level.gtd_call ]]("allowSpectateTeam", "freelook", true);
	self [[ level.gtd_call ]]("allowSpectateTeam", "none", false);

	arena = 0;
	scrollStartFire = false;
	scrollStartMelee = false;
	for (;;)
	{
		wait .05;
		if (self attackButtonPressed())
		{
			scrollStartFire = true;
		}
		else if (self meleeButtonPressed())
		{
			scrollStartMelee = true;
			arena = 11;
		}
		if (scrollStartFire == true || scrollStartMelee == true)
		{
			break;
		}
	}

	self.vote_indicator setShader("white", 254, 17);

	while (true)
	{
		if (self useButtonPressed() && level.arenaFree[arena-1])
		{
			level.arenaFree[arena-1]--;

			if (level.arenaFree[arena-1] < 0)
			{
				println("####### arenaSelection: arenaFree is fewer than 0");
				level.arenaFree[arena-1] = 0;
			}
			self.arena = arena-1;
			self.choosingArena = false;
			self.score = 0;
			self.deaths = 0;

			self [[ level.gtd_call ]]("allowSpectateTeam", "allies", true);
			self [[ level.gtd_call ]]("allowSpectateTeam", "axis", true);
			self [[ level.gtd_call ]]("allowSpectateTeam", "freelook", true);
			self [[ level.gtd_call ]]("allowSpectateTeam", "none", true);

			self.pers["savedmodel"] = undefined;
			hud_select_destroy();

			if (!isDefined(level.arenaPlayer[arena-1]))	//arena is empty
			{
				level.arenaPlayer[arena-1] = self;
				iPrintLn(codam\_mm_mmm::namefix(self.name) + " ^7Entered arena ^1" + arena);
			}
			else
			{
				//one player is in the arena
				self.opponent = level.arenaPlayer[arena-1];
				level.arenaPlayer[arena-1].opponent = self;
				level.arenaPlayer[arena-1].score = 0;
				level.arenaPlayer[arena-1].deaths = 0;
				level.arenaPlayer[arena-1] iPrintLnBold(codam\_mm_mmm::namefix(self.name) + " ^7has entered your arena^1!");
				self iPrintLnBold(codam\_mm_mmm::namefix(level.arenaPlayer[arena-1].name) + " ^7is your enemy^1!");

				//delete bodies
				size =  level.bodies[arena-1].size;
				for (i = 0; i < size; i++)
				{
					if (isDefined(level.bodies[arena-1][i]))
					{
						level.bodies[arena-1][i] delete();
						level.bodies[arena-1][i] = undefined;
					}
				}
				self.health = 100;
				self.opponent.health = 100;
			}
			if (self.arena == 9)
			{
				//codam\utils::_debug("####### thread wawa_SpawnWeapons");
				//thread wawa_SpawnWeapons();
			}
			spawnPlayer(arena-1);
			hud_score_create_update();
			level updateArenaStatus(arena-1);
			return;
		}

		if (self attackButtonPressed())
		{
			arena++;
			if (arena == 11)
				arena = 1;
			self _show_arena(arena-1);
			self.vote_indicator.y = level.hudoffset + 60 + arena * 16;
			wait .05;
			while(self attackButtonPressed())
				wait .05;
			continue;
		}
		else if (self meleeButtonPressed())
		{
			arena--;
			
			if (arena == 0)
				arena = 10;
			
			self _show_arena(arena-1);
			self.vote_indicator.y = level.hudoffset + 60 + arena * 16;
			wait .05;
			
			while(self meleeButtonPressed())
				wait .05;
			
			continue;
		}
		wait .05;
	}
}
_show_arena(arena)
{
	spawnpoint = getent("mp_deathmatch_intermission_"+arena, "classname");
	if(isDefined(spawnpoint))
		self spawn(spawnpoint.origin, spawnpoint.angles);
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
}
updateArenaStatus(arena)
{
	players = getEntArray("player", "classname");
	for(i = 0; i < players.size; i++)
		if(isDefined(players[i].vote_hud_bgnd))
			players[i].arenahudstatus[arena] setText(level.arenastatus[level.arenaFree[arena]]);
}
getSpawnPointWawa(spawnpoints)
{
	if(!isdefined(spawnpoints))
		return undefined;
	if (isDefined(self.opponent))
		opponent = self.opponent;

	// Spawn away from players if they exist, otherwise spawn at a random spawnpoint
	if (isdefined(opponent))
	{
		j = 0;
		for (i = 0; i < spawnpoints.size; i++)
		{
			// Throw out bad spots
			if (positionWouldTelefrag(spawnpoints[i].origin))
			{
				continue;
			}
			if (isdefined(self.lastspawnpoint) && self.lastspawnpoint == spawnpoints[i])
			{
				continue;
			}
			filteredspawnpoints[j] = spawnpoints[i];
			j++;
		}

		// if no good spawnpoint, need to failsafe
		if (!isdefined(filteredspawnpoints))
			return maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

		for (i = 0; i < filteredspawnpoints.size; i++)
		{
			shortest = 1000000;
			current = distanceSquared(filteredspawnpoints[i].origin, opponent.origin);
			if (current < shortest)
			{
				shortest = current;
			}
			filteredspawnpoints[i].spawnscore = shortest + 1;
		}

		// TODO: Throw out spawnpoints with negative scores
		newsize = filteredspawnpoints.size / 3;
		if(newsize < 1)
			newsize = 1;
		total = 0;
		bestscore = 0;
		// Find the top 3rd
		for (i = 0; i < newsize; i++)
		{
			for (j = 0; j < filteredspawnpoints.size; j++)
			{
				current = filteredspawnpoints[j].spawnscore;
				if (current > bestscore)
					bestscore = current;
			}

			for (j = 0; j < filteredspawnpoints.size; j++)
			{
				if (filteredspawnpoints[j].spawnscore == bestscore)
				{
					newarray[i]["spawnpoint"] = filteredspawnpoints[j];
					newarray[i]["spawnscore"] = filteredspawnpoints[j].spawnscore;
					filteredspawnpoints[j].spawnscore = 0;
					bestscore = 0;
					total = total + newarray[i]["spawnscore"];
					break;
				}
			}
		}
		randnum = randomInt(total);

		for (i = 0; i < newarray.size; i++)
		{
			randnum = randnum - newarray[i]["spawnscore"];
			spawnpoint = newarray[i]["spawnpoint"];
			if (randnum < 0)
				break;
		}

		self.lastspawnpoint = spawnpoint;
		return spawnpoint;
	}
	else
	{
		return maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);
	}
}