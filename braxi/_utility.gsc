#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

preCache()
{
	preCacheShader( "white" );
	preCacheShader( "hud_notify" );
	preCacheShader( "hud_notify_footer" );
	preCacheStatusIcon( "hud_status_connecting" );
	preCacheStatusIcon( "hud_status_dead" );
}

init_spawns()
{
	level.spawn = [];
	level.spawn["allies"] = getEntArray( "mp_jumper_spawn", "classname" );
	level.spawn["axis"] = getEntArray( "mp_activator_spawn", "classname" );
	level.spawn["spectator"] = getEntArray( "mp_global_intermission", "classname" );
	level.spawn_link = spawn( "script_model", ( 0, 0, 0 ) );

	if ( !level.spawn["allies"].size ) level.spawn["allies"] = getEntArray( "mp_dm_spawn", "classname" );
	if ( !level.spawn["axis"].size ) level.spawn["axis"] = getEntArray( "mp_tdm_spawn", "classname" );

	for ( i = 0; i < level.spawn["allies"].size; i++ ) level.spawn["allies"][i] placeSpawnPoint();
	for ( i = 0; i < level.spawn["axis"].size; i++ ) level.spawn["axis"][i] placeSpawnPoint();
}

buildJumperTable()
{
	level.model_jumper = [];
	tableName = "mp/jumperTable.csv";

	for ( idx = 1; isDefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.model_jumper[id]["rank"] = ( int( tableLookup( tableName, 0, idx, 2 ) ) - 1 );
		level.model_jumper[id]["item"] = tableLookup( tableName, 0, idx, 3 );
		level.model_jumper[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		preCacheModel( level.model_jumper[id]["item"] );
	}
}

buildActivatorTable()
{
	level.activatorModels = [];
	tableName = "mp/activatorTable.csv";

	for ( idx = 1; isDefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.model_activator[id]["rank"] = ( int( tableLookup( tableName, 0, idx, 2 ) ) - 1 );
		level.model_activator[id]["item"] = tableLookup( tableName, 0, idx, 3 );
		level.model_activator[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		preCacheModel( level.model_activator[id]["item"] );
	}
}

buildPrimaryTable()
{
	level.weapon_primary = [];
	tableName = "mp/primaryTable.csv";

	for ( idx = 1; isDefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.weapon_primary[id]["rank"] = ( int( tableLookup( tableName, 0, idx, 2 ) ) - 1 );
		level.weapon_primary[id]["item"] = ( tableLookup( tableName, 0, idx, 3 ) + "_mp" );
		level.weapon_primary[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		preCacheItem( level.weapon_primary[id]["item"] );
	}
}

buildSecondaryTable()
{
	level.weapon_secondary = [];
	tableName = "mp/secondaryTable.csv";

	for ( idx = 1; isDefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.weapon_secondary[id]["rank"] = ( int( tableLookup( tableName, 0, idx, 2 ) ) - 1 );
		level.weapon_secondary[id]["item"] = ( tableLookup( tableName, 0, idx, 3 ) + "_mp" );
		level.weapon_secondary[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		preCacheItem( level.weapon_secondary[id]["item"] );
	}
}

buildGloveTable()
{
	level.model_glove = [];
	tableName = "mp/gloveTable.csv";

	for ( idx = 1; isDefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.model_glove[id]["rank"] = ( int( tableLookup( tableName, 0, idx, 2 ) ) - 1 );
		level.model_glove[id]["item"] = tableLookup( tableName, 0, idx, 3 );
		level.model_glove[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		preCacheModel( level.model_glove[id]["item"] );
	}
}

getAllPlayers()
{
	return getEntArray( "player", "classname" );
}

isAlive()
{
	if ( self.sessionstate == "playing" ) return true;
	return false;
}

waitForPlayers( required )
{
	players = getAllPlayers();
	playersAlive = 0;

	for ( i = 0; i < players.size; i++ )
		if ( players[i] isAlive() && players[i].pers["team"] == "allies" )
			playersAlive++;

	if ( playersAlive < required )
	{
		game["state"] = "waiting";

		while ( true )
		{
			players = getAllPlayers();
			players_ready = 0;

			for ( i = 0; i < players.size; i++ )
				if ( players[i] isAlive() && players[i].pers["team"] == "allies" )
					players_ready++;

			if ( players_ready >= required )
				break;

			wait .05;
		}

		map_restart( true );
		return;
	}
}

initGame()
{
	level.splitscreen = isSplitScreen();
	level.xenon = false;
	level.ps3 = false;
	level.onlineGame = true;
	level.console = false;
	level.rankedMatch = getDvarInt( "sv_pure" );
	level.teamBased = true;
	level.oldschool = false;
	level.gameEnded = false;

	thread maps\mp\gametypes\_hud::init();
	thread maps\mp\gametypes\_hud_message::init();
	thread maps\mp\gametypes\_damagefeedback::init();
	thread maps\mp\gametypes\_clientids::init();
	thread maps\mp\gametypes\_gameobjects::init();
	thread maps\mp\gametypes\_spawnlogic::init();
	thread maps\mp\gametypes\_oldschool::deletePickups();
	thread maps\mp\gametypes\_quickmessages::init();
}

spawnCollision( origin, height, width )
{
	level.colliders[level.colliders.size] = spawn( "trigger_radius", origin, 0, width, height );
	level.colliders[level.colliders.size - 1] setContents( 1 );
	level.colliders[level.colliders.size - 1].targetname = "script_collision";
}

notification( notification, entity )
{
	if ( isPlayer( entity ) ) self endon( "disconnect" );

	if ( !entity.notifying )
	{
		entity thread showNotification( notification, entity );
		return;
	}

	entity.notifications[entity.notifications.size] = notification;
}

showNotification( notification, entity )
{
	entity.notifying = true;
	entity.notification = [];

	if ( isPlayer( entity ) )
	{
		self endon( "disconnect" );
		self.notification[0] = newClientHudElem( self );
		self.notification[1] = newClientHudElem( self );
	}
	else
	{
		level.notification[0] = newHudElem();
		level.notification[1] = newHudElem();
	}

	entity.notification[2] = braxi\_mod::addTextHud( entity, -300, 104, 1, "center", "middle", 1.4 );
	entity.notification[3] = braxi\_mod::addTextHud( entity, -300, 122, 1, "center", "middle", 1.4 );

	if ( notification.levelUp )
	{
		entity.notification[0].x = -300;
		entity.notification[0].y = 90;
		entity.notification[1].x = -300;
		entity.notification[1].y = 133;
	}
	else
	{
		entity.notification[0].x = 270;
		entity.notification[0].y = 90;
		entity.notification[1].x = 271;
		entity.notification[1].y = 133;
		entity.notification[2].x = 320;
		entity.notification[3].x = 320;
	}

	entity playSound( entity, notification.sound );

	entity.notification[0].alpha = .6;
	entity.notification[0].sort = 990;
	entity.notification[0].hideWhenInMenu = true;
	entity.notification[0].horzAlign = "fullscreen";
	entity.notification[0].vertAlign = "fullscreen";
	entity.notification[0] setShader( "hud_notify", 100, 45 );

	entity.notification[1].alpha = 1;
	entity.notification[1].sort = 993;
	entity.notification[1].hideWhenInMenu = true;
	entity.notification[1].horzAlign = "fullscreen";
	entity.notification[1].vertAlign = "fullscreen";
	entity.notification[1] setShader( "hud_notify_footer", 98, 2 );

	entity.notification[2].font = "default";
	entity.notification[2].sort = 993;
	entity.notification[2].hideWhenInMenu = true;
	entity.notification[2].horzAlign = "fullscreen";
	entity.notification[2].vertAlign = "fullscreen";
	entity.notification[2] setText( notification.title );

	entity.notification[3].font = "default";
	entity.notification[3].sort = 993;
	entity.notification[3].hideWhenInMenu = true;
	entity.notification[3].horzAlign = "fullscreen";
	entity.notification[3].vertAlign = "fullscreen";
	entity.notification[3] setText( notification.footer );

	if ( notification.levelUp )
	{
		moveNotifElements( entity, 240, 241, 290, 290, 0.2 );
		wait .3;
		moveNotifElements( entity, 300, 301, 350, 350, 3.0 );
		wait 2;
		moveNotifElements( entity, 670, 671, 720, 720, 0.2 );
	}
	else
	{
		for ( i = 0; i < entity.notification.size; i++ )
		{
			entity.notification[i].alpha = 0;
			entity.notification[i] fadeOverTime( 1 );
			if ( i == 0 ) entity.notification[i].alpha = 0.6;
			else entity.notification[i].alpha = 1;
		}

		wait 4;

		for ( i = 0; i < entity.notification.size; i++ )
		{
			entity.notification[i] fadeOverTime( 1 );
			entity.notification[i].alpha = 0;
		}
	}

	wait .8;

	for ( i = 0; i < entity.notification.size; i++ ) entity.notification[i] destroy();
	entity.notification = undefined;
	entity.notifying = false;

	if ( entity.notifications.size > 0 )
	{
		nextNotification = entity.notifications[0];

		for ( i = 1; i < entity.notifications.size; i++ )
			entity.notifications[i - 1] = entity.notifications[i];
		entity.notifications[i - 1] = undefined;

		entity thread showNotification( nextNotification );
	}
}

moveNotifElements( entity, x1, x2, x3, x4, time )
{
	for ( i = 0; i < entity.notification.size; i++ )
	{
		entity.notification[i] moveOverTime( time );
		if ( i == 0 ) entity.notification[i].x = x1;
		if ( i == 1 ) entity.notification[i].x = x2;
		if ( i == 2 ) entity.notification[i].x = x3;
		if ( i == 3 ) entity.notification[i].x = x4;
	}
}

canSpawn()
{
	if ( game["state"] == "playing" )
		return false;

	if ( level.practice )
		return true;

	if ( self.died )
		return false;

	return true;
}

updateJumperHud()
{
	for (;;)
	{
		level waittill_any( "jumper", "player_killed", "activator_chosen" );
		players = getAllPlayers();

		for ( i = 0; i < players.size; i++ )
			players[i] setClientDvar( "ui_jumpers_alive", level.jumpersAlive );
	}
}

playSound( entity, sound )
{
	if ( isPlayer( entity ) )
		self playLocalSound( sound );
	else
	{
		players = getAllPlayers();
		for ( i = 0; i < players.size; i++ )
			players[i] playLocalSound( sound );
	}
}

formatTimer( msec )
{
	msecs = msec % 10;
	useconds = int( msec / 10 );
	seconds = useconds % 60;
	minutes = int( useconds / 60 );

	if ( seconds < 10 )
		return minutes + ":0" + seconds + "." + msecs;
	else
		return minutes + ":" + seconds + "." + msecs;
}

toUpper( letter )
{
	switch ( letter )
	{
		case "a":
			return "A";
		case "b":
			return "B";
		case "c":
			return "C";
		case "d":
			return "D";
		case "e":
			return "E";
		case "f":
			return "F";
		case "g":
			return "G";
		case "h":
			return "H";
		case "i":
			return "I";
		case "j":
			return "J";
		case "k":
			return "K";
		case "l":
			return "L";
		case "m":
			return "M";
		case "n":
			return "N";
		case "o":
			return "O";
		case "p":
			return "P";
		case "q":
			return "Q";
		case "r":
			return "R";
		case "s":
			return "S";
		case "t":
			return "T";
		case "u":
			return "U";
		case "v":
			return "V";
		case "w":
			return "W";
		case "x":
			return "X";
		case "y":
			return "Y";
		case "z":
			return "Z";
		default:
			return letter;
	}
}

foundUnderscore( letter )
{
	switch ( letter )
	{
		case "_":
			return true;
		default:
			return false;
	}
}

formatMapName( map )
{
	formattedName = "";
	index = 6;

	if ( map[4] == "e" ) index = 12;

	for ( j = index; j < map.size; j++ )
	{
		if ( j == index ) formattedName += toUpper( map[j] );
		else
		{
			if ( foundUnderscore( map[j] ) )
			{
				formattedName += " " + toUpper( map[j + 1] );
				j++;
			}
			else formattedName += map[j];
		}
	}

	return formattedName;
}