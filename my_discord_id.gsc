//1. Put this file in the "codam" folder of the "main" server folder.
//2. Add the below line to "modlist.gsc":
//[[register]]("My Discord ID", codam\my_discord_id::main);

main(phase, register)
{
    //printLn("##### My Discord ID/main");

	switch(phase)
    {
		case "init": _init(register); break;
	}
}

_init(register)
{
    //printLn("##### My Discord ID/_init");

	if(isDefined(level.my_discord_id))
		return;
	level.my_discord_id = true;

    [[register]]("StartGameType", ::displayDiscordId, "thread");
}

displayDiscordId(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1,	b2, b2,	b4, b5,	b6, b7,	b8, b9)
{
    //printLn("##### My Discord ID: displayDiscordId");

    discordId = getCvar("discordId");
    if(discordId != "")
    {
        hud_myDiscordId_text = "My Discord ID: " + discordId;
        hud_myDiscordId = newHudElem();
        hud_myDiscordId.x = 422;
        hud_myDiscordId.y = 472;
        hud_myDiscordId.alignX = "center";
        hud_myDiscordId.alignY = "middle";
        hud_myDiscordId.fontScale = 0.7;
        hud_myDiscordId_textLocalized = makeLocalizedString(hud_myDiscordId_text);
        hud_myDiscordId setText(hud_myDiscordId_textLocalized);
    }
}