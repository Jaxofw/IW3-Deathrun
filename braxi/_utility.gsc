getAllPlayers() {
	return getEntArray( "player", "classname" );
}

isPlaying() {
    if ( self.sessionstate == "playing" && self.pers["team"] == "allies" ) return true;
    return false;
}

waitForPlayers( required ) {
	while ( true ) {
		wait 0.5;
		players = getAllPlayers();
        if ( players.size > required ) {
            for ( i = 0; i < players.size; i++ ) {
                if ( players[i] isPlaying() ) return true;
            }
        }
    }
}

init_spawns() {
	level.spawn = [];
	level.spawn["allies"] = getEntArray( "mp_jumper_spawn", "classname" );
	level.spawn["axis"] = getEntArray( "mp_activator_spawn", "classname" );
	level.spawn["spectator"] = getEntArray( "mp_global_intermission", "classname" )[0];

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
		level.jumperModels[id]["model"] = tableLookup( tableName, 0, idx, 2 );
		level.jumperModels[id]["name"] = tableLookup( tableName, 0, idx, 3 );
		
		preCacheModel( level.jumperModels[id]["model"] );
		level.numJumpers++;
	}
}

buildPrimaryTable() {
	level.primaryWeaps = [];
	level.numPrimaries = 0;
	
	tableName = "mp/primaryTable.csv";

	for ( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ ) {
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.primaryWeaps[id]["item"] = (tableLookup( tableName, 0, idx, 2 ) + "_mp");
		level.primaryWeaps[id]["name"] = tableLookup( tableName, 0, idx, 3 );
		
		preCacheItem( level.primaryWeaps[id]["item"] );
		level.numPrimaries++;
	}
}

buildSecondaryTable() {
	level.secondaryWeaps = [];
	level.numSecondaries = 0;
	
	tableName = "mp/secondaryTable.csv";

	for ( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ ) {
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.secondaryWeaps[id]["item"] = (tableLookup( tableName, 0, idx, 2 ) + "_mp");
		level.secondaryWeaps[id]["name"] = tableLookup( tableName, 0, idx, 3 );
		
		preCacheItem( level.secondaryWeaps[id]["item"] );
		level.numSecondaries++;
	}
}

buildGloveTable() {
	level.gloveModels = [];
	level.numGloves = 0;
	
	tableName = "mp/gloveTable.csv";

	for ( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ ) {
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.gloveModels[id]["model"] = tableLookup( tableName, 0, idx, 2 );
		level.gloveModels[id]["name"] = tableLookup( tableName, 0, idx, 3 );
		
		preCacheModel( level.gloveModels[id]["model"] );
		level.numGloves++;
	}
}