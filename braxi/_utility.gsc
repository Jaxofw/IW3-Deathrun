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

buildPrimaryTable() {
	level.primaryWeaps = [];
	level.numPrimaries = 0;
	
	tableName = "mp/primaryTable.csv";

	for ( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ ) {
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.primaryWeaps[id]["item"] = (tableLookup( tableName, 0, idx, 2 ) + "_mp");
		level.primaryWeaps[id]["name"] = tableLookup( tableName, 0, idx, 3 );
		
		precacheItem( level.primaryWeaps[id]["item"] );
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
		
		precacheItem( level.secondaryWeaps[id]["item"] );
		level.numSecondaries++;
	}
}