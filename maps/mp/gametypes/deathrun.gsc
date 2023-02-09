main()
{
	thread maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	level.callbackStartGameType = ::Callback_StartGameType;
	level.callbackPlayerConnect = ::Callback_PlayerConnect;
	level.callbackPlayerDisconnect = ::Callback_PlayerDisconnect;
	level.callbackPlayerDamage = ::Callback_PlayerDamage;
	level.callbackPlayerKilled = ::Callback_PlayerKilled;
	level.callbackPlayerLastStand = ::Callback_PlayerLastStand;

	level.gametype = toLower( getDvar( "g_gametype" ) );
	level.script = toLower( getDvar( "mapname" ) );
}

Callback_StartGameType()
{
	if ( !isDefined( game["allies"] ) )
		game["allies"] = "marines";

	if ( !isDefined( game["axis"] ) )
		game["axis"] = "opfor";

	// CoD4 VARs
	level.splitscreen = false;
	level.xenon = false;
	level.ps3 = false;
	level.onlineGame = true;
	level.console = false;
	level.rankedMatch = getDvarInt( "sv_pure" );
	level.teamBased = true;
	level.oldschool = false;
	level.gameEnded = false;
	level.hardcoreMode = false;

	// CoD4 Pre-requisites
	thread maps\mp\gametypes\_hud::init();
	thread maps\mp\gametypes\_hud_message::init();
	thread maps\mp\gametypes\_damagefeedback::init();
	thread maps\mp\gametypes\_clientids::init();
	thread maps\mp\gametypes\_spawnlogic::init();
	thread maps\mp\gametypes\_quickmessages::init();

	// Init Spawn Points
	level.spawn = [];
	level.spawn["allies"] = getEntArray( "mp_jumper_spawn", "classname" );
	level.spawn["axis"] = getEntArray( "mp_activator_spawn", "classname" );
	level.spawn["spectator"] = getEntArray( "mp_global_intermission", "classname" )[0];
	level.spawn_link = spawn( "script_model", ( 0, 0, 0 ) );

	if ( !level.spawn["allies"].size )
		level.spawn["allies"] = getEntArray( "mp_dm_spawn", "classname" );
	if ( !level.spawn["axis"].size )
		level.spawn["axis"] = getEntArray( "mp_tdm_spawn", "classname" );

	for ( i = 0; i < level.spawn["allies"].size; i++ )
		level.spawn["allies"][i] placeSpawnPoint();

	for ( i = 0; i < level.spawn["axis"].size; i++ )
		level.spawn["axis"][i] placeSpawnPoint();

	thread braxi\_mod::main(); // Start Deathrun Mod

	allowed[0] = "deathrun";
	maps\mp\gametypes\_gameobjects::main( allowed );
}

Callback_PlayerConnect()
{
	thread notifyConnecting();

	self.statusicon = "hud_status_connecting";
	self waittill( "begin" );
	self braxi\_callbacks::playerConnect();
}

notifyConnecting()
{
	waittillframeend;

	if ( isDefined( self ) )
		level notify( "connecting", self );
}

Callback_PlayerDisconnect()
{
	self braxi\_callbacks::playerDisconnect();
}

Callback_PlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	self braxi\_callbacks::playerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
}

Callback_PlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	self braxi\_callbacks::playerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );
}

Callback_PlayerLastStand( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	self suicide();
}