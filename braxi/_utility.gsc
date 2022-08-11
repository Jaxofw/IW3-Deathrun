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