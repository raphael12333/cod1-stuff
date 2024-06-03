// 1. Put this file in the "codam" folder of the "main" server folder.
// 2. Add the below line to "modlist.gsc":
// [[register]]("Last kill slow motion", codam\lastkill_slowmotion::main);

// Thanks to MiscMod for the code to change timescale smoothly.

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

    [[register]]("finishPlayerKilled", ::checkLastKill);
}

checkLastKill(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b2, b4, b5, b6, b7, b8, b9)
{
    //printLn("##### Last kill slow motion/checkLastKill");
    
    gametype = getCvar("g_gametype");
    scorelimit = getCvarInt("scr_" + gametype + "_scorelimit");
    if(scorelimit)
    {
        if(gametype == "sd")
        {
            if(game["alliedscore"] == scorelimit -1 || game["axisscore"] == scorelimit -1)
            {
                setCvar("timescale", "0.5");
                wait 0.25;
                for(x = .5; x < 1; x+= .05)
                {
                    wait (0.1 / x);
                    setCvar("timescale", x);
                }
                setCvar("timescale", "1");
            }
        }
    }
}