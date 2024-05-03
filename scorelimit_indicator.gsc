//1. Put this file in the "codam" folder of the "main" server folder.
//2. Add the below line to "modlist.gsc":
//[[register]]("Score limit indicator", codam\scorelimit_indicator::main);

main(phase, register)
{
    //printLn("##### Score limit indicator/main");

	switch(phase)
    {
		case "init": _init(register); break;
	}
}

_init(register)
{
    //printLn("##### Score limit indicator/_init");

	if(isDefined(level.scorelimitindicator))
		return;
	level.scorelimitindicator = true;

    [[register]]("StartGameType", ::indicateScoreLimit, "thread");
}

indicateScoreLimit(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1,	b2, b2,	b4, b5,	b6, b7,	b8, b9)
{
    //printLn("##### Score limit indicator/indicateScoreLimit");
    
    gametype = getCvar("g_gametype");
    scorelimitCvar = getCvar("scr_" + gametype + "_scorelimit");

    if(scorelimitCvar != "")
    {
        //printLn("##### scorelimitCvar = " + scorelimitCvar);
        
        hudScoreLimit = newHudElem();
        hudScoreLimit.x = 632;
        hudScoreLimit.y = 56;
        hudScoreLimit.alignX = "right";
		hudScoreLimit.alignY = "middle";
        hudScoreLimit.fontScale = 0.9;
        hudScoreLimit.label = &"Score limit: ";
        hudScoreLimit setValue(scorelimitCvar);
    }
}