main()
{
	if ( getDvar( "mapname" ) == "mp_background" ) return;

	maps\mp\gametypes\_callbacksetup::SetupCallbacks();

	printLn( "Warning: g_gametype is \""+gametype+"\", should be \"deathrun\" " );
	printLn( "Trying to load correct gametype!" );

	setDvar( "g_gametype", "deathrun" );
	exitLevel( false );
}

Callback_StartGameType()
{
	if ( !isDefined( game["allies"] ) ) game["allies"] = "marines";
	if ( !isDefined( game["axis"] ) ) game["axis"] = "opfor";
}