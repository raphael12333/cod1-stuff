// 1. Put this file in the "codam" folder of the "main" server folder.
// 2. Add the below line to "modlist.gsc":
// [[register]]("Set melee round", codam\set_melee_round::main);

main(phase, register)
{
    //printLn("##### Set melee round/main");
    switch(phase) 
    {
        case "init": _init(register); break;
    }
}
_init(register)
{
    //printLn("##### Set melee round/_init");
    if(isDefined(level.set_melee_round))
        return;
    level.set_melee_round = true;

    [[register]]("StartGameType", ::setMeleeRound, "thread");
    [[register]]("spawnPlayer", ::emptyWeapons, "thread");
}

setMeleeRound(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b2, b4, b5, b6, b7, b8, b9)
{
    //printLn("##### Set melee round: setMeleeRound");
    
    if(getCvar("g_gametype") == "sd")
    {
        if(!isDefined(game["didMeleeRound"]))
        {
            doMeleeRound = false;
            if(!isDefined(game["doMeleeRoundAtScore"]))
            {
                randomInt(1); // The first random always returns 1, so I generate without using the returned value, as a fix.
                scoreLimit = getCvarInt("scr_sd_scorelimit");

                if(isDefined(game["spawnWeaponsAtScore"]))
                {
                    while(!isDefined(game["doMeleeRoundAtScore"]))
                    {
                        random = randomIntRange(1, scoreLimit);
                        if(random == game["spawnWeaponsAtScore"])
                            continue; // Don't set melee round when spawning extra weapons.
                        game["doMeleeRoundAtScore"] = random;
                    }
                }
                else
                {
                    game["doMeleeRoundAtScore"] = randomIntRange(1, scoreLimit);
                }
            }
            printLn("##### doMeleeRoundAtScore = " + game["doMeleeRoundAtScore"]);

            if(game["alliedscore"] == game["doMeleeRoundAtScore"] || game["axisscore"] == game["doMeleeRoundAtScore"])
            {
                doMeleeRound = true;
            }
            if(doMeleeRound)
            {
                //printLn("##### setMeleeRound: doMeleeRound");
                wait .05;

                game["didMeleeRound"] = true;
                level.meleeRoundActive = true;

                wait .75;
                codam\_mm_commands::message("^5INFO: ^7Melee round!");
            }
        }
    }
}
emptyWeapons(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b2, b4, b5, b6, b7, b8, b9)
{
    //printLn("##### Set melee round: emptyWeapons");

    if(isDefined(level.meleeRoundActive))
    {
        wait .05;

        primary = self getWeaponSlotWeapon("primary");
        primaryb = self getWeaponSlotWeapon("primaryb");
        pistol = self getWeaponSlotWeapon("pistol");
        if(isDefined(primary))
        {
            self setWeaponSlotAmmo("primary", 0);
            self setWeaponSlotClipAmmo("primary", 0);
        }
        if(isDefined(primaryb))
        {
            self setWeaponSlotAmmo("primaryb", 0);
            self setWeaponSlotClipAmmo("primaryb", 0);
        }
        if(isDefined(pistol))
        {
            self setWeaponSlotAmmo("pistol", 0);
            self setWeaponSlotClipAmmo("pistol", 0);
        }

        self iPrintLnBold("Melee round!");
    }
}