//1. Put this file in the "codam" folder of the "main" server folder.
//2. Add the below line to "modlist.gsc":
//[[register]]("FPS Display", codam\fps_display::main);

main(phase, register)
{
    //printLn("##### FPS Display/main");

	switch(phase)
    {
		case "init": _init(register); break;
	}
}

_init(register)
{
    //printLn("##### FPS Display/_init");

	if(isDefined(level.fpsdisplay))
		return;
	level.fpsdisplay = true;

    [[register]]("PlayerConnect", ::displayPlayerFps, "thread");
}

displayPlayerFps(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1,	b2, b2,	b4, b5,	b6, b7,	b8, b9)
{
    //printLn("##### FPS Display/displayPlayerFps");

    if(game["state"] == "intermission") {
        return;
    }

    self.hud_fps = newClientHudElem(self);
    self.hud_fps.sort = -1;
    self.hud_fps.x = 540;
    self.hud_fps.y = 25;
    self.hud_fps.fontScale = 0.8;
    self.hud_fps.color = (1, 1, 0);
    self.hud_fps.label = &"Public FPS: ";

    for(;;)
    {
        if(game["state"] == "intermission") {
            if(isDefined(self.hud_fps))
                self.hud_fps destroy();
            return;
        }

        fps = self getFPS();
        if(isDefined(self.hud_fps))
            self.hud_fps setValue(fps);
        wait .05;
    }
}