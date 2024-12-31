// 1. Put this file in the "codam" folder of the "main" server folder.
// 2. Add the below line to "modlist.gsc":
// [[register]]("Gravity tubes", codam\gravity_tubes::main);

main(phase, register)
{
    //printLn("##### Gravity tubes/main");
    switch(phase) 
    {
        case "init": _init(register); break;
    }
}
_init(register)
{
    //printLn("##### Gravity tubes/_init");
    if(isDefined(level.gravity_tubes))
        return;
    level.gravity_tubes = true;

    [[register]]("StartGameType", ::setupTubes, "thread");
    [[register]]("spawnPlayer", ::initPlayerData, "thread");
}

setupTubes(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b2, b4, b5, b6, b7, b8, b9)
{
    //printLn("##### Gravity tubes: setupTubes");

    mapname = getCvar("mapname");
    if (mapname == "mp_harbor" && game["state"] != "intermission")
    {
        level.tubes = [];

        level.tubes[0]["fxId"] = loadfx("fx/tube.efx");
        level.tubes[0]["life"] = 1000;
        level.tubes[0]["origin"] = (-9513, -7654, 0);
        level.tubes[0]["startSize"] = 135;

        level.tubes[1]["fxId"] = level.tubes[0]["fxId"];
        level.tubes[1]["life"] = level.tubes[0]["life"];
        level.tubes[1]["origin"] = (-7220, -8989, 0);
        level.tubes[1]["startSize"] = level.tubes[0]["startSize"];

        thread playTubes();
        thread checkPlayersInTubes();
    }
}

playTubes()
{
    //printLn("##### Gravity tubes: playTube");

    for (i = 0; i < level.tubes.size; i++)
    {
        playLoopedFX(level.tubes[i]["fxId"], level.tubes[i]["life"] / 1000, level.tubes[i]["origin"]);
    }
}

checkPlayersInTubes()
{
    level endon("intermission");

    for (;;)
    {
        players = getEntArray("player", "classname");
        for (i = 0; i < players.size; i++)
        {
            player = players[i];
            
            // Ignore origin z for distance
            player_origin_noZ = (player.origin[0], player.origin[1], 0);
            
            if (!isDefined(player.inATube))
            {
                if (isAlive(player))
                {
                    for (j = 0; j < level.tubes.size; j++)
                    {
                        if (distance(level.tubes[j]["origin"], player_origin_noZ) <= level.tubes[j]["startSize"])
                        {
                            // Entered
                            player setGravity(40);
                            player.inATube = true;
                            continue;
                        }
                    }
                }
            }
            else
            {
                default_gravity = getCvarInt("g_gravity");

                if (isAlive(player))
                {
                    stillInATube = false;

                    for (j = 0; j < level.tubes.size; j++)
                    {
                        if (distance(level.tubes[j]["origin"], player_origin_noZ) <= level.tubes[j]["startSize"])
                        {
                            stillInATube = true;
                            continue;
                        }
                    }

                    if (!stillInATube)
                    {
                        // Left
                        player setGravity(default_gravity);
                        player.inATube = undefined;

                        /*if (!(player isOnGround()))
                        {
                            player.willLandFromTube = true;
                        }*/
                    }
                }
                else
                {
                    // Died in
                    player setGravity(default_gravity);
                    player.inATube = undefined;
                }
            }
        }
        wait .05;
    }
}

initPlayerData(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b2, b4, b5, b6, b7, b8, b9)
{
    // Reset for if was in while map restarted
    default_gravity = getCvarInt("g_gravity");
    self setGravity(default_gravity);
    self.inATube = undefined;
    self.willLandFromTube = undefined;
}