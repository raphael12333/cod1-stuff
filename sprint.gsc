// 1. Put this file in the "codam" folder of the "main" server folder.
// 2. Add the below line to "modlist.gsc", not before MiscMod:
// [[register]]("Sprint", codam\sprint::main);

// Use the "sprint_speed" cvar, e.g.: set sprint_speed "250"

// Thanks to MiscMod for the technique to save pers variables.

main(phase, register)
{
    switch(phase)
    {
        case "init": _init(register); break;
        case "load": _load(); break;
    }
}
_init(register)
{
    if(isDefined(level.sprint))
        return;
    level.sprint = true;

    [[register]]("PlayerConnect", ::checkSprint, "thread");
    [[register]]("PlayerDisconnect", ::removeSprint, "thread");
    [[register]]("spawnPlayer", ::initSprint, "thread");
}
_load()
{
    if(isDefined(level.sprint2))
        return;
    level.sprint2 = true;

    commands(72, level.prefix + "sprint", ::cmd_sprint, "Toggle sprint. [" + level.prefix + "sprint <|auto>]");
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
    enableSprint = false;
    setAutoMode = false;
    
    if(args.size == 2)
    {
        if(args[1] != "auto")
        {
            codam\_mm_commands::message_player("^1ERROR: ^7Invalid argument.");
            return;
        }
        setAutoMode = true;
    }
    else if(args.size != 1)
    {
        codam\_mm_commands::message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }
    
    if(!isDefined(self.pers["sprint"]))
        enableSprint = true;
    self toggleSprint(enableSprint, setAutoMode);
}

checkSprint(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    self waittill("begin");

    if(isDefined(self.pers["sprint"]))
        return;

    sprinters = getCvar("tmp_sprint");
    if(sprinters != "") {
        sprinters = strTok(sprinters, ";");
        for(i = 0; i < sprinters.size; i++) {
            num = self getEntityNumber();
            user = strTok(sprinters[i], "|");

            if(user[1] == num) {
                self.pers["sprint"] = user[0];
                if(self.pers["sprint"] == "auto")
                {
                    enableSprint = true;
                    setAutoMode = true;
                    self toggleSprint(enable, setAutoMode);
                }
                break;
            }
        }
    }
}
removeSprint(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    num = self getEntityNumber();
    sprinters = getCvar("tmp_sprint");
    if(sprinters != "") {
        sprinters = strTok(sprinters, ";");
        validuser = false;

        rSTR = "";
        for(i = 0; i < sprinters.size; i++) {
            user = strTok(sprinters[i], "|");
            if(user[1] == num) {
                validuser = true;
                continue;
            }

            rSTR += sprinters[i];
            rSTR += ";";
        }

        if(validuser)
            setCvar("tmp_sprint", rSTR);
    }
}

initSprint(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
    enableSprint = false;
    setAutoMode = false;

    if(isDefined(self.pers["sprint"]) && self.pers["sprint"] == "auto")
    {
        enableSprint = true;
        setAutoMode = true;
    }
    self toggleSprint(enableSprint, setAutoMode);
}

toggleSprint(enable, autoMode)
{
    g_speed = getCvarInt("g_speed");
    mode = "toggle";
    if(autoMode)
    {
        enable = true;
        mode = "auto";
    }
    if(enable)
    {
        sprint_speed = getCvarInt("sprint_speed");
        self setSpeed(sprint_speed);
        self.pers["sprint"] = mode;
        if(autoMode)
        {
            clientnum = self getEntityNumber();
            removeSprint(clientnum);

            rSTR = "";
            if(getCvar("tmp_sprint") != "")
                rSTR += getCvar("tmp_sprint");

            rSTR += mode;
            rSTR += "|" + clientnum;
            rSTR += ";";

            setCvar("tmp_sprint", rSTR);
        }
    }
    else
    {
        self setSpeed(g_speed);
        self.pers["sprint"] = undefined;
    }
}