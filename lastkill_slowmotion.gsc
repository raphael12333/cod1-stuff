// 1. Put this file in the "codam" folder of the "main" server folder.
// 2. Add the below line to "modlist.gsc":
// [[register]]("Last kill slow motion", codam\lastkill_slowmotion::main);

main(phase, register)
{
    //printLn("##### Last kill slow motion/main");
    switch(phase)
    {
        case "init": _init(register); break;
    }
}
_init(register)
{
    //printLn("##### Last kill slow motion/_init");
    if(isDefined(level.lastkill_slowmotion))
        return;
    level.lastkill_slowmotion = true;

    [[register]]("StartGameType", ::initTimescale, "thread");

    if(getCvar("g_gametype") == "sd")
        [[register]]("finishPlayerKilled", ::checkLastKill, "thread");
}

initTimescale(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b2, b4, b5, b6, b7, b8, b9)
{
    // This is to prevent the timescale from getting stuck below 1.
    setCvar("timescale", "1");
}
checkLastKill(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    //printLn("##### Last kill slow motion/checkLastKill");
    
    gametype = getCvar("g_gametype");
    scorelimit = getCvarInt("scr_" + gametype + "_scorelimit");
    if(scorelimit)
    {
        if(gametype == "sd")
        {
            if(!isDefined(attacker) || !isPlayer(attacker))
                return;
            if(attacker == self)
                return;
            if(sMeansOfDeath == "MOD_GRENADE_SPLASH" || sMeansOfDeath == "MOD_FALLING")
                return;
            
            // Check if killed last player in the team.
            victimTeam = self.sessionteam;
            theTeamIsDead = true;
            players = getEntArray("player", "classname");
            for(i = 0; i < players.size; i++)
            {
                player = players[i];
                team = player.sessionteam;
                if(team == victimTeam)
                {
                    if(isAlive(player))
                    {
                        theTeamIsDead = false;
                        break;
                    }
                }
            }

            if(!theTeamIsDead)
                return;
            
            matchIsOver = false;
            if((victimTeam == "allies" && game["axisscore"] == scorelimit -1)
                || (victimTeam == "axis" && game["alliedscore"] == scorelimit -1))
            {
                if(level.bombplanted && (victimTeam == game["attackers"]))
                    return;
                matchIsOver = true;
            }

            if(!matchIsOver)
                return;

            level slowMotion();
        }
    }
}
slowMotion()
{
    // Thanks to MiscMod for this code to change timescale smoothly.
    setCvar("timescale", "0.5");
    wait 0.25;
    for(x = .5; x < 1; x+= .05)
    {
        wait (0.1 / x);
        setCvar("timescale", x);
    }
    setCvar("timescale", "1");
}