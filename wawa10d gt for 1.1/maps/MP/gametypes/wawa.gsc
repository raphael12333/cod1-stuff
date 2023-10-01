
main()
{
	// HAM HACK: attempting to fix problem when performing a map_restart
	// and going from retail to CoDaM-enhanced.
	if ( !isdefined( game[ "gamestarted" ] ) )
	{
		precacheModel( "xmodel/weapon_fg42" );
		precacheModel( "xmodel/viewmodel_fg42" );
		precacheModel( "xmodel/weapon_panzerfaust_ammo" );
		precacheModel( "xmodel/weapon_panzerfaust_rocket" );
		precacheModel( "xmodel/viewmodel_panzerfaust" );
		precacheModel( "xmodel/health_medium" );
	}
	// END HACK.

	codam\modtype::main( "wawa" );

	return;
}
