//MAX (ARCHIVED HUD/CLIENTHUD + NONARCHIVED HUD/CLIENTHUD) = 62
//MAX LOCALIZEDSTRINGS CHARS = 256
init()
{
	level.mapVote_mapRandom = &" [random]";
	level.mapVote_mapList = &" mp_brecourt \n\n mp_carentan \n\n mp_dawnville \n\n mp_depot \n\n mp_harbor \n\n mp_hurtgen \n\n mp_pavlov \n\n mp_powcamp \n\n mp_railyard \n\n mp_rocket";
	level.mapVote_instruction = &"^1FIRE ^7to vote";
	level.mapVote_titleVotes = &"Votes";

	precacheShader("white");
	precacheShader("black");

	level.mapVote_gametype = getCvar("g_gametype");

	level.mapVote_enabled = false;
	if(getCvar("scr_mm_mapvote") != "" && getCvarInt("scr_mm_mapvote") > 0)
		level.mapVote_enabled = true;

	level.mapVote_timer = 15;
	if(getCvar("scr_mm_mapvotetime") != "" && getCvarInt("scr_mm_mapvotetime") >= 10)
		level.mapVote_timer = getCvarInt("scr_mm_mapvotetime");

	if(level.mapVote_timer > 60)
		level.mapVote_timer = 60;
}

mapvote()
{
	if(!level.mapVote_enabled)
		return;
	
	wait 0.5;
	createHud();
	thread runMapVote();
	level waittill("voting_complete");
	destroyHud();
}

createHud()
{
	if (isDefined(level.clock))
	{
		level.clock destroy();
	}
	if (isDefined(level._bombcountdown))
    {
        level._bombcountdown destroy();
    }

	if (level.ham_hudscores)
	{
		if ( isdefined( level.gtd_call ) )
			teams = [[ level.gtd_call ]]( "teamsPlaying" );
		if ( !isdefined( teams ) || ( teams.size < 1 ) )
		{
			teams = [];
			teams[ teams.size ] = "allies";
			teams[ teams.size ] = "axis";
		}
		for ( i = 0; i < teams.size + 2; i++ )
		{
			if ( isdefined( level.ham_score[ "actual" ] ) &&
			     isdefined( level.ham_score[ "actual" ][ i ] ) )
				level.ham_score[ "actual" ][ i ] destroy();
			if ( isdefined( level.ham_score[ "numteam" ] ) &&
			     isdefined( level.ham_score[ "numteam" ][ i ] ) )
				level.ham_score[ "numteam" ][ i ] destroy();
			if ( isdefined( level.ham_score[ "alive" ] ) &&
			     isdefined( level.ham_score[ "alive" ][ i ] ) )
				level.ham_score[ "alive" ][ i ] destroy();
			if ( isdefined( level.ham_score[ "icon" ] ) &&
			     isdefined( level.ham_score[ "icon" ][ i ] ) )
				level.ham_score[ "icon" ][ i ] destroy();
		}
	}

	level.voteTimer = newHudElem();
	level.voteTimer.x = 320;
    level.voteTimer.y = 464;
	level.voteTimer.alignX = "center";
	level.voteTimer.alignY = "middle";
	level.voteTimer.font = "bigfixed";
	level.voteTimer.color = (0, 1, 0);
	level.voteTimer setTimer(level.mapVote_timer + (0.2 + 0.1 + 0.05 + 1));

	level.xMapName = 260;
	level.yMapName = 160;
	xMapVotes = level.xMapName + 100;
	yTitles = level.yMapName - 23;
	level.distanceBetween = 20;
	level.backgroundWidth = 139;

	//INSTRUCTION
	level.vote_instruction = newHudElem();
	level.vote_instruction.x = level.xMapName - 2;
	level.vote_instruction.y = yTitles;
	level.vote_instruction.fontscale = .8;
	level.vote_instruction.label = level.mapVote_instruction;
	level.vote_instruction.sort = 2;
	//VOTES TITLE
    level.vote_votes = newHudElem();
	level.vote_votes.x = xMapVotes - 7;
	level.vote_votes.y = yTitles;
	level.vote_votes.fontscale = .8;
	level.vote_votes.label = level.mapVote_titleVotes;
	level.vote_votes.sort = 2;
	//HEADER
	level.vote_header = newHudElem();
	level.vote_header.alpha = .9;
	level.vote_header.x = level.xMapName - 9;
	level.vote_header.y = yTitles - 4;
	level.vote_header.color = (0.37, 0.37, 0.16);
	level.vote_header setShader("white", level.backgroundWidth, 17);
	level.vote_header.sort = 1;
	//BACKGROUND
	level.vote_hud_bgnd = newHudElem();
	level.vote_hud_bgnd.alpha = .9;
	level.vote_hud_bgnd.x = level.xMapName - 9;
	level.vote_hud_bgnd.y = level.vote_header.y + 17.5;
	level.vote_hud_bgnd setShader("black", level.backgroundWidth, 230);
	level.vote_hud_bgnd.sort = 1;

	//RANDOM MAP
	level.vote_mapRandom = newHudElem();
	level.vote_mapRandom.x = level.xMapName;
	level.vote_mapRandom.y = level.yMapName;
    level.vote_mapRandom setText(level.mapVote_mapRandom);
	level.vote_mapRandom.fontscale = .9;
	level.vote_mapRandom.sort = 4;

	level.vote_mapRandom_votes = newHudElem();
	level.vote_mapRandom_votes.x = xMapVotes;
	level.vote_mapRandom_votes.y = level.yMapName;
	level.vote_mapRandom_votes setValue(0);
	level.vote_mapRandom_votes.fontscale = .9;
	level.vote_mapRandom_votes.sort = 4;

	//MAP NAMES
	level.vote_mapList = newHudElem();
	level.vote_mapList.x = level.xMapName;
	level.vote_mapList.y = level.vote_mapRandom_votes.y + level.distanceBetween;
    level.vote_mapList setText(level.mapVote_mapList);
	level.vote_mapList.fontscale = .9;
	level.vote_mapList.sort = 4;

	//VOTES COUNTS
	level.vote_map1_votes = newHudElem();
	level.vote_map1_votes.x = xMapVotes;
	level.vote_map1_votes.y = level.vote_mapRandom_votes.y + level.distanceBetween;
	level.vote_map1_votes setValue(0);
	level.vote_map1_votes.fontscale = .9;
	level.vote_map1_votes.sort = 4;

	level.vote_map2_votes = newHudElem();
	level.vote_map2_votes.x = xMapVotes;
	level.vote_map2_votes.y = level.vote_map1_votes.y + level.distanceBetween;
	level.vote_map2_votes setValue(0);
	level.vote_map2_votes.fontscale = .9;
	level.vote_map2_votes.sort = 4;

	level.vote_map3_votes = newHudElem();
	level.vote_map3_votes.x = xMapVotes;
	level.vote_map3_votes.y = level.vote_map2_votes.y + level.distanceBetween;
	level.vote_map3_votes setValue(0);
	level.vote_map3_votes.fontscale = .9;
	level.vote_map3_votes.sort = 4;

	level.vote_map4_votes = newHudElem();
	level.vote_map4_votes.x = xMapVotes;
	level.vote_map4_votes.y = level.vote_map3_votes.y + level.distanceBetween;
	level.vote_map4_votes setValue(0);
	level.vote_map4_votes.fontscale = .9;
	level.vote_map4_votes.sort = 4;

	level.vote_map5_votes = newHudElem();
	level.vote_map5_votes.x = xMapVotes;
	level.vote_map5_votes.y = level.vote_map4_votes.y + level.distanceBetween;
	level.vote_map5_votes setValue(0);
	level.vote_map5_votes.fontscale = .9;
	level.vote_map5_votes.sort = 4;

	level.vote_map6_votes = newHudElem();
	level.vote_map6_votes.x = xMapVotes;
	level.vote_map6_votes.y = level.vote_map5_votes.y + level.distanceBetween;
	level.vote_map6_votes setValue(0);
	level.vote_map6_votes.fontscale = .9;
	level.vote_map6_votes.sort = 4;

	level.vote_map7_votes = newHudElem();
	level.vote_map7_votes.x = xMapVotes;
	level.vote_map7_votes.y = level.vote_map6_votes.y + level.distanceBetween;
	level.vote_map7_votes setValue(0);
	level.vote_map7_votes.fontscale = .9;
	level.vote_map7_votes.sort = 4;

	level.vote_map8_votes = newHudElem();
	level.vote_map8_votes.x = xMapVotes;
	level.vote_map8_votes.y = level.vote_map7_votes.y + level.distanceBetween;
	level.vote_map8_votes setValue(0);
	level.vote_map8_votes.fontscale = .9;
	level.vote_map8_votes.sort = 4;

	level.vote_map9_votes = newHudElem();
	level.vote_map9_votes.x = xMapVotes;
	level.vote_map9_votes.y = level.vote_map8_votes.y + level.distanceBetween;
	level.vote_map9_votes setValue(0);
	level.vote_map9_votes.fontscale = .9;
	level.vote_map9_votes.sort = 4;

	level.vote_map10_votes = newHudElem();
	level.vote_map10_votes.x = xMapVotes;
	level.vote_map10_votes.y = level.vote_map9_votes.y + level.distanceBetween;
	level.vote_map10_votes setValue(0);
	level.vote_map10_votes.fontscale = .9;
	level.vote_map10_votes.sort = 4;
}
destroyHud()
{
	level.voteTimer destroy();
	level.vote_instruction destroy();
	level.vote_votes destroy();
	level.vote_header destroy();
	level.vote_hud_bgnd destroy();
	level.vote_mapRandom destroy();
	level.vote_mapRandom_votes destroy();
	level.vote_mapList destroy();
	level.vote_map1_votes destroy();
	level.vote_map2_votes destroy();
	level.vote_map3_votes destroy();
	level.vote_map4_votes destroy();
	level.vote_map5_votes destroy();
	level.vote_map6_votes destroy();
	level.vote_map7_votes destroy();
	level.vote_map8_votes destroy();
	level.vote_map9_votes destroy();
	level.vote_map10_votes destroy();

	players = getEntArray("player", "classname");
	for(i = 0; i < players.size; i++)
		if(isDefined(players[i].vote_indicator))
			players[i].vote_indicator destroy();
}

runMapVote()
{
    maps[0] = "mp_brecourt";
    maps[1] = "mp_carentan";
    maps[2] = "mp_dawnville";
    maps[3] = "mp_depot";
    maps[4] = "mp_harbor";
    maps[5] = "mp_hurtgen";
    maps[6] = "mp_pavlov";
    maps[7] = "mp_powcamp";
	maps[8] = "mp_railyard";
	maps[9] = "mp_rocket";

	randomMap = maps[randomInt(maps.size)];
    level.mapcandidate[0]["map"] = randomMap;
    level.mapcandidate[0]["gametype"] = level.mapVote_gametype;
    level.mapcandidate[0]["votes"] = 0;

	for (i = 0; i < 11; i++)
    {
		if(!isDefined(maps[i]))
			break;

		level.mapcandidate[i+1]["map"] = maps[i];
		level.mapcandidate[i+1]["gametype"] = level.mapVote_gametype;
		level.mapcandidate[i+1]["votes"] = 0;
	}
	
	players = getEntArray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		players[i] thread playerVote();
	}
	thread voteLogic();
	wait 0.1;
}

voteLogic()
{
	for (; level.mapVote_timer >= 0; level.mapVote_timer--)
    {
		for (x = 0; x < 10; x++)
        {
			// Count votes
			for (i = 0; i < 17; i++)
            {
                level.mapcandidate[i]["votes"] = 0;
            }
			players = getEntArray("player", "classname");
			for (i = 0; i < players.size; i++)
            {
                if (isDefined(players[i].votechoice))
                {
                    level.mapcandidate[players[i].votechoice]["votes"]++;
                }
            }

			// Update HUD
			level.vote_mapRandom_votes setValue(level.mapcandidate[0]["votes"]);
			level.vote_map1_votes setValue(level.mapcandidate[1]["votes"]);
			level.vote_map2_votes setValue(level.mapcandidate[2]["votes"]);
			level.vote_map3_votes setValue(level.mapcandidate[3]["votes"]);
			level.vote_map4_votes setValue(level.mapcandidate[4]["votes"]);
			level.vote_map5_votes setValue(level.mapcandidate[5]["votes"]);
            level.vote_map6_votes setValue(level.mapcandidate[6]["votes"]);
            level.vote_map7_votes setValue(level.mapcandidate[7]["votes"]);
            level.vote_map8_votes setValue(level.mapcandidate[8]["votes"]);
            level.vote_map9_votes setValue(level.mapcandidate[9]["votes"]);
            level.vote_map10_votes setValue(level.mapcandidate[10]["votes"]);

			wait 0.1;
		}
	}

	wait 0.2;

	nextmapnum  = 0;
	topvotes = 0;

	for (i = 0; i < 11; i++)
    {
		if (level.mapcandidate[i]["votes"] > topvotes)
        {
			nextmapnum = i;
			topvotes = level.mapcandidate[i]["votes"];
		}
	}
	setMapWinner(nextmapnum);
}

setMapWinner(val)
{
	map = level.mapcandidate[val]["map"];
	gametype = level.mapcandidate[val]["gametype"];

	setCvar("sv_mapRotationCurrent", " gametype " + gametype + " map " + map);

	wait 0.1;
	level notify("voting_done");
	wait 0.05;

	iPrintLnBold(" ");
	iPrintLnBold(" ");
	iPrintLnBold(" ");
	iPrintLnBold("The winner is");
	iPrintLnBold("^2" + map);
	iPrintLnBold(" ");

	level.voteTimer fadeOverTime(1);
	level.vote_instruction fadeOverTime(1);
	level.vote_votes fadeOverTime(1);
	level.vote_header fadeOverTime(1);
	level.vote_hud_bgnd fadeOverTime(1);
	level.vote_mapRandom fadeOverTime(1);
    level.vote_mapRandom_votes fadeOverTime(1);
	level.vote_mapList fadeOverTime(1);
	level.vote_map1_votes fadeOverTime(1);
	level.vote_map2_votes fadeOverTime(1);
	level.vote_map3_votes fadeOverTime(1);
	level.vote_map4_votes fadeOverTime(1);
	level.vote_map5_votes fadeOverTime(1);
	level.vote_map6_votes fadeOverTime(1);
	level.vote_map7_votes fadeOverTime(1);
	level.vote_map8_votes fadeOverTime(1);
	level.vote_map9_votes fadeOverTime(1);
	level.vote_map10_votes fadeOverTime(1);

	level.voteTimer.alpha = 0;
	level.vote_instruction.alpha = 0;
	level.vote_votes.alpha = 0;
	level.vote_header.alpha = 0;
	level.vote_hud_bgnd.alpha = 0;
    level.vote_mapRandom.alpha = 0;
	level.vote_mapRandom_votes.alpha = 0;
	level.vote_mapList.alpha = 0;
	level.vote_map1_votes.alpha = 0;
	level.vote_map2_votes.alpha = 0;
	level.vote_map3_votes.alpha = 0;
	level.vote_map4_votes.alpha = 0;
	level.vote_map5_votes.alpha = 0;
	level.vote_map6_votes.alpha = 0;
	level.vote_map7_votes.alpha = 0;
	level.vote_map8_votes.alpha = 0;
	level.vote_map9_votes.alpha = 0;
	level.vote_map10_votes.alpha = 0;

	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
    {
		if (isDefined(players[i].vote_indicator))
        {
			players[i].vote_indicator fadeOverTime(1);
			players[i].vote_indicator.alpha = 0;
		}
	}
	wait 4;
	level notify("voting_complete");
}

playerVote()
{
	level endon("voting_done");
	self endon("disconnect");

	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	resettimeout();
	self setClientCvar("g_scriptMainMenu", "main");
	self closeMenu();
	
	self.vote_indicator = newClientHudElem(self);
	self.vote_indicator.archived = false;
	self.vote_indicator.x = level.xMapName - 5;
	self.vote_indicator.alpha = 0;
	self.vote_indicator.color = (0.20, 1, 0.76);
	self.vote_indicator setShader("white", level.backgroundWidth - 8, 16);
	self.vote_indicator.sort = 3;

	hasVoted = false;

	for (;;)
    {
		wait 0.01;

		if (self attackButtonPressed())
        {
			if (!hasVoted)
            {
				self.vote_indicator.alpha = 0.3;
				self.votechoice = 0;
				hasVoted = true;
			}
            else
            {
				self.votechoice++;
			}

			if(self.votechoice >= 11)
				self.votechoice = 0;

			self.vote_indicator.y = (level.yMapName - 2) + (self.votechoice * level.distanceBetween);
		}

		while(self attackButtonPressed())
			wait 0.01;
	}
}