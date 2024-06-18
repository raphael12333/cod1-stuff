// 1. Put this file in the "codam" folder of the "main" server folder.
// 2. Add the below line to "modlist.gsc":
// [[register]]("Spawn weapons", codam\spawn_weapons::main);

main(phase, register)
{
    //printLn("##### Spawn weapons/main");
    switch(phase) 
    {
        case "init": _init(register); break;
    }
}
_init(register)
{
    //printLn("##### Spawn weapons/_init");
    if(isDefined(level.spawn_weapons))
        return;
    level.spawn_weapons = true;

    [[register]]("StartGameType", ::spawnWeapons, "thread");
}

spawnWeapons(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b2, b4, b5, b6, b7, b8, b9)
{
    //printLn("##### Spawn weapons: spawnWeapons");
    
    gametype = getCvar("g_gametype");
    mapname = getCvar("mapname");
    if(gametype == "sd" && mapname == "mp_harbor")
    {
        if(!isDefined(game["spawnedWeapons"]))
        {
            spawnWeapons = false;
            if(!isDefined(game["spawnWeaponsAtScore"]))
            {
                randomInt(1); // The first random always returns 1, so I generate without using the returned value, as a fix.
                scoreLimit = getCvarInt("scr_sd_scorelimit");

                if(isDefined(game["doMeleeRoundAtScore"]))
                {
                    while(!isDefined(game["spawnWeaponsAtScore"]))
                    {
                        random = randomIntRange(1, scoreLimit);
                        if(random == game["doMeleeRoundAtScore"])
                            continue; // Don't spawn weapons during melee round.
                        game["spawnWeaponsAtScore"] = random;
                    }
                }
                else
                {
                    game["spawnWeaponsAtScore"] = randomIntRange(1, scoreLimit);
                }
            }
            printLn("##### spawnWeaponsAtScore = " + game["spawnWeaponsAtScore"]);

            if(game["alliedscore"] == game["spawnWeaponsAtScore"] || game["axisscore"] == game["spawnWeaponsAtScore"])
            {
                spawnWeapons = true;
            }
            if(spawnWeapons)
            {
                printLn("##### spawnWeapons: spawning weapons");
                wait .05;

                weaponRussians_origin = (-7356, -7752, 228);
                weaponRussians = spawn("mpweapon_ppsh", weaponRussians_origin);
                weaponRussians.angles = (weaponRussians.angles[0], 70, weaponRussians.angles[2]);
                
                weaponGermans_origin = (-9037, -6711, 262);
                weaponGermans = spawn("mpweapon_mp44", weaponGermans_origin);
                weaponGermans.angles = (315, weaponGermans.angles[1], weaponGermans.angles[2]);

                game["spawnedWeapons"] = true;

                wait .75;
                codam\_mm_commands::message("^5INFO: ^7Automatic weapons spawned!");
            }
        }
    }
}