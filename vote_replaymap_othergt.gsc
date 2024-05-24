//Thanks to Cato

//1. Edit MiscMod according to MM Github issue #5.
//2. Put this file in the "codam" folder of the "main" server folder.
//3. Add the below line to "modlist.gsc" :
//[[register]]("Vote replay map other GT", codam\vote_replaymap_othergt::main);

main(phase, register)
{
    printLn("##### Vote replay map other GT/main");

	switch(phase) 
    {
		case "init": _init(register); break;
	}
}

_init(register)
{
    printLn("##### Vote replay map other GT/_init");

	if(isDefined(level.vote_replaymap_othergt))
		return;
	level.vote_replaymap_othergt = true;

    [[register]]("StartGameType", ::precacheModels, "thread");
}

precacheModels(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1,	b2, b2,	b4, b5,	b6, b7,	b8, b9)
{
    printLn("##### Vote replay map other GT: precacheModels");

    gametype = getCvar("g_gametype");
    if(gametype == "dm" || gametype == "tdm" || gametype == "bel")
    {
        printLn("##### Vote replay map other GT: precaching sd xmodels");

        precacheModel("xmodel/mp_bomb1_defuse");
        precacheModel("xmodel/mp_bomb1");
    }
}