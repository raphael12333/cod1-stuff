//1. Put this file in the "codam" folder of the "main" server folder.
//2. Add the below line to "modlist.gsc", not before MiscMod:
//[[register]]("Sprint", codam\sprint::main);

main(phase, register)
{
	switch(phase)
	{
		case "load": _load(); break;
	}
}
_load()
{
	if(isDefined(level.sprint))
		return;
	level.sprint = true;

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

    server_speed = getCvarInt("g_speed");
    if(isDefined(self.sprinting))
    {
        self setSpeed(server_speed);
        self.sprinting = undefined;
    }
    else
    {
        self setSpeed(265);
        self.sprinting = true;
    }
}