#include maps\mp\gametypes\_hud_util;

preCache() {
	preCacheShader( "white" );
	preCacheStatusIcon( "hud_status_connecting" );
	preCacheStatusIcon( "hud_status_dead" );
	preCacheModel( "body_mp_sas_urban_sniper" );
	preCacheItem( "deserteaglegold_mp" );
}

init_spawns() {
	level.spawn = [];
	level.spawn["allies"] = getEntArray( "mp_jumper_spawn", "classname" );
	level.spawn["axis"] = getEntArray( "mp_activator_spawn", "classname" );
	level.spawn["spectator"] = getEntArray( "mp_global_intermission", "classname" )[0];
	level.spawn_link = spawn( "script_model", (0,0,0) );

	if ( !level.spawn["allies"].size ) level.spawn["allies"] = getEntArray( "mp_dm_spawn", "classname" );
	if ( !level.spawn["axis"].size ) level.spawn["axis"] = getEntArray( "mp_tdm_spawn", "classname" );

	for ( i = 0; i < level.spawn["allies"].size; i++ ) level.spawn["allies"][i] placeSpawnPoint();
	for ( i = 0; i < level.spawn["axis"].size; i++ ) level.spawn["axis"][i] placeSpawnPoint();
}

buildJumperTable() {
	level.jumperModels = [];
	level.numJumpers = 0;
	
	tableName = "mp/jumperTable.csv";

	for ( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ ) {
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.jumperModels[id]["rank"] = (int(tableLookup( tableName, 0, idx, 2 )) - 1);
		level.jumperModels[id]["model"] = tableLookup( tableName, 0, idx, 3 );
		level.jumperModels[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		
		// preCacheModel( level.jumperModels[id]["model"] );
		level.numJumpers++;
	}
}

buildPrimaryTable() {
	level.primaryWeaps = [];
	level.numPrimaries = 0;
	
	tableName = "mp/primaryTable.csv";

	for ( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ ) {
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.primaryWeaps[id]["rank"] = (int(tableLookup( tableName, 0, idx, 2 )) - 1);
		level.primaryWeaps[id]["item"] = (tableLookup( tableName, 0, idx, 3 ) + "_mp");
		level.primaryWeaps[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		
		// preCacheItem( level.primaryWeaps[id]["item"] );
		level.numPrimaries++;
	}
}

buildSecondaryTable() {
	level.secondaryWeaps = [];
	level.numSecondaries = 0;
	
	tableName = "mp/secondaryTable.csv";

	for ( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ ) {
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.secondaryWeaps[id]["rank"] = (int(tableLookup( tableName, 0, idx, 2 )) - 1);
		level.secondaryWeaps[id]["item"] = (tableLookup( tableName, 0, idx, 3 ) + "_mp");
		level.secondaryWeaps[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		
		// preCacheItem( level.secondaryWeaps[id]["item"] );
		level.numSecondaries++;
	}
}

buildGloveTable() {
	level.gloveModels = [];
	level.numGloves = 0;
	
	tableName = "mp/gloveTable.csv";

	for ( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ ) {
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.gloveModels[id]["rank"] = (int(tableLookup( tableName, 0, idx, 2 )) - 1);
		level.gloveModels[id]["model"] = tableLookup( tableName, 0, idx, 3 );
		level.gloveModels[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		
		// preCacheModel( level.gloveModels[id]["model"] );
		level.numGloves++;
	}
}

getAllPlayers() {
	return getEntArray( "player", "classname" );
}

isPlaying() {
    if ( self.sessionstate == "playing" && self.pers["team"] == "allies" ) return true;
    return false;
}

waitForPlayers( required ) {
	level.matchStartText = createServerFontString( "objective", 1.5 );
	level.matchStartText setPoint( "CENTER", "TOP", 0, 10 );
	level.matchStartText.sort = 1001;
	level.matchStartText setText( "Waiting for players..." );
	level.matchStartText.foreground = false;
	level.matchStartText.hidewheninmenu = true;

	while ( true ) {
		players = getAllPlayers();
		players_ready = 0;

		for ( i = 0; i < players.size; i++ ) {
			if ( players[i] isPlaying() ) players_ready++;
		}

		if ( players_ready >= required ) break;
		wait 1;
	}
}

initGame() {
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

spawnCollision( origin, height, width ) {
	level.colliders[level.colliders.size] = spawn( "trigger_radius", origin, 0, width, height );
	level.colliders[level.colliders.size-1] setContents( 1 );
	level.colliders[level.colliders.size-1].targetname = "script_collision";
}