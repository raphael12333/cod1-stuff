//1. Put this file in the "codam" folder of the "main" server folder.
//2. Add the below line to "modlist.gsc", not before MiscMod:
//[[register]]("Sprint", codam\sprint::main);

main(phase, register)
{
	switch(phase)
	{
        case "init":
            _init(register);
        break;
		case "load":
            _load();
        break;
	}
}
_init(register)
{
    if(isDefined(level.sprint))
		return;
	level.sprint = true;

    [[register]]("spawnPlayer", ::disableSprint, "thread");
}
_load()
{
	if(isDefined(level.sprint2))
		return;
	level.sprint2 = true;

    commands(72, level.prefix + "sprint", ::cmd_sprint, "Toggle sprint. [" + level.prefix + "sprint]");
}
commands(id, cmd, func, desc)
{
    if(!isDefined(level.commands[cmd]))
        level.help[level.help.size]["cmd"] = cmd;

    level.commands[cmd]["func"] = func;
    level.commands[cmd]["desc"] = desc;
    level.commands[cmd]["id"]   = id;
}

cmd_sprint(args)
{
    if (args.size != 1) {
        codam\_mm_commands::message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }
    
    if(isDefined(self.sprinting))
    {
        if(self.sprinting)
            self disableSprint();
        else
            self enableSprint();
    }
}
disableSprint(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    g_speed = getCvarInt("g_speed");
    self setSpeed(g_speed);
    self.sprinting = false;
}
enableSprint()
{
    sprint_speed = getCvarInt("sprint_speed");
    if(sprint_speed)
    {
        self setSpeed(sprint_speed);
        self.sprinting = true;
    }
}