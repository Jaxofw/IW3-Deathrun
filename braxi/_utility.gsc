#include maps\mp\gametypes\_hud_util;

preCache() {
	preCacheShader( "white" );
	preCacheShader( "hud_notify" );
	preCacheShader( "hud_notify_footer" );
	preCacheStatusIcon( "hud_status_connecting" );
	preCacheStatusIcon( "hud_status_dead" );
	preCacheModel( "body_mp_sas_urban_sniper" );
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
		level.primaryWeaps[id]["rank"] = (int(tableLookup( tableName, 0, idx, 2 )) - 1);
		level.primaryWeaps[id]["item"] = (tableLookup( tableName, 0, idx, 3 ) + "_mp");
		level.primaryWeaps[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		
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
		level.secondaryWeaps[id]["rank"] = (int(tableLookup( tableName, 0, idx, 2 )) - 1);
		level.secondaryWeaps[id]["item"] = (tableLookup( tableName, 0, idx, 3 ) + "_mp");
		level.secondaryWeaps[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		
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
		level.gloveModels[id]["rank"] = (int(tableLookup( tableName, 0, idx, 2 )) - 1);
		level.gloveModels[id]["model"] = tableLookup( tableName, 0, idx, 3 );
		level.gloveModels[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		
		preCacheModel( level.gloveModels[id]["model"] );
		level.numGloves++;
	}
}

getAllPlayers() {
	return getEntArray( "player", "classname" );
}

isAlive() {
	if ( self.sessionstate == "playing" ) return true;
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
			if ( players[i] isAlive() && players[i].pers["team"] == "allies" ) players_ready++;
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

addTextHud( who, x, y, alpha, alignX, alignY, fontScale ) {
	if ( isPlayer( who ) ) hud = newClientHudElem( who );
	else hud = newHudElem();

	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.alignX = alignX;
	hud.alignY = alignY;
	hud.fontScale = fontScale;
	return hud;
}

notification( notification ) {
	self endon( "disconnect" );

	if ( !self.notifying ) {
		self thread showNotification( notification );
		return;
	}

	self.notifications[self.notifications.size] = notification;
}

showNotification( notification ) {
	self endon( "disconnect" );

	self.notifying = true;
	self.notification = [];
	self.notification[0] = newClientHudElem( self );
	self.notification[1] = newClientHudElem( self );
	self.notification[2] = addTextHud( self, -300, 104, 1, "center", "middle", 1.4 );
	self.notification[3] = addTextHud( self, -300, 122, 1, "center", "middle", 1.4 );
	self playLocalSound( notification.sound );

	if ( notification.levelUp ) {
		self.notification[0].x = -300;
		self.notification[0].y = 90;
		self.notification[1].x = -300;
		self.notification[1].y = 133;
	} else {
		self.notification[0].x = 270;
		self.notification[0].y = 90;
		self.notification[1].x = 271;
		self.notification[1].y = 133;
		self.notification[2].x = 320;
		self.notification[3].x = 320;
	}

	self.notification[0].alpha = .6;
	self.notification[0].sort = 990;
	self.notification[0].hideWhenInMenu = true;
	self.notification[0].horzAlign = "fullscreen";
	self.notification[0].vertAlign = "fullscreen";
	self.notification[0] setShader( "hud_notify", 100, 45 );

	self.notification[1].alpha = 1;
	self.notification[1].sort = 993;
	self.notification[1].hideWhenInMenu = true;
	self.notification[1].horzAlign = "fullscreen";
	self.notification[1].vertAlign = "fullscreen";
	self.notification[1] setShader( "hud_notify_footer", 98, 2 );

	self.notification[2].font = "default";
	self.notification[2].sort = 993;
	self.notification[2].hideWhenInMenu = true;
	self.notification[2].horzAlign = "fullscreen";
	self.notification[2].vertAlign = "fullscreen";
	self.notification[2] setText( notification.title );

	self.notification[3].font = "default";
	self.notification[3].sort = 993;
	self.notification[3].hideWhenInMenu = true;
	self.notification[3].horzAlign = "fullscreen";
	self.notification[3].vertAlign = "fullscreen";
	self.notification[3] setText( notification.footer );

	if ( notification.levelUp ) {
		moveNotifElements( 240, 241, 290, 290, 0.2 );
		wait .3;
		moveNotifElements( 300, 301, 350, 350, 3.0 );
		wait 2;
		moveNotifElements( 670, 671, 720, 720, 0.2 );
	} else {
		for ( i = 0; i < self.notification.size; i++ ) {
			self.notification[i].alpha = 0;
			self.notification[i] fadeOverTime( 1 );
			if ( i == 0 ) self.notification[i].alpha = 0.6;
			else self.notification[i].alpha = 1;
		}

		wait 4;

		for ( i = 0; i < self.notification.size; i++ ) {
			self.notification[i] fadeOverTime( 1 );
			self.notification[i].alpha = 0;
		}
	}

	wait .8;

	for ( i = 0; i < self.notification.size; i++ ) self.notification[i] destroy();
	self.notification = undefined;
	self.notifying = false;

	if ( self.notifications.size > 0 ) {
		nextNotification = self.notifications[0];
		
		for ( i = 1; i < self.notifications.size; i++ )
			self.notifications[i-1] = self.notifications[i];
			self.notifications[i-1] = undefined;
		
		self thread showNotification( nextNotification );
	}
}

moveNotifElements(x1, x2, x3, x4, time) {
	for ( i = 0; i < self.notification.size; i++ ) {
		self.notification[i] moveOverTime( time );
		if ( i == 0 ) self.notification[i].x = x1;
		if ( i == 1 ) self.notification[i].x = x2;
		if ( i == 2 ) self.notification[i].x = x3;
		if ( i == 3 ) self.notification[i].x = x4;
	}
}