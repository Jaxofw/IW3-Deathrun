init() {
	precache();
	init_spawns();
	thread braxi\_cod4stuff::init();

	setDvar( "g_speed", 220 );
	setDvar( "jump_slowdownEnable", 0 );
	setDvar( "bullet_penetrationEnabled", 0 );

	thread braxi\_dvar::setupDvars();
	thread braxi\_menus::init();
}

precache() {
	// Shaders
	precacheShader( "white" );

	// Icons
	precacheStatusIcon( "hud_status_connecting" );
	precacheStatusIcon( "hud_status_dead" );

	preCacheModel("body_mp_sas_urban_sniper");

	precacheItem("deserteaglegold_mp");
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

playerConnect() {
	level notify( "connected", self );

	self.guid = self getGuid();
	self.number = self getEntityNumber();
	self.statusicon = "hud_status_connecting";
	self.died = false;

	if (!isDefined( self.name )) self.name = "undefined name";
	if (!isDefined( self.guid )) self.guid = "undefined guid";

	// we want to show hud and we get an IP adress for "add to favourities" menu
	self setClientDvars( "show_hud", "true", "ip", getDvar("net_ip"), "port", getDvar("net_port") );
	if (!isDefined( self.pers["team"] )) {
		iPrintln( self.name + " ^7entered the game" );

		self.sessionstate = "spectator";
		self.team = "spectator";
		self.pers["team"] = "spectator";
		self.pers["score"] = 0;
		self.pers["kills"] = 0;
		self.pers["deaths"] = 0;
		self.pers["assists"] = 0;
	} else {
		self.score = self.pers["score"];
		self.kills = self.pers["kills"];
		self.assists = self.pers["assists"];
		self.deaths = self.pers["deaths"];
	}

	if (!isDefined( level.spawn["spectator"] )) level.spawn["spectator"] = level.spawn["allies"][0];

	self setClientDvars(
		"cg_drawSpectatorMessages", 1,
		"player_sprintTime", 12.8,
		"ui_hud_hardcore", 1,
		"ui_menu_playername", self.name,
		"ui_uav_client", 0
	);

	if (self.name.size > 8) self setClientDvar( "ui_menu_playername", getSubStr( self.name, 0, 7 ) + "..." );
	
	self openMenu( game["menu_team"] );
}

playerDisconnect() {
	level notify( "disconnected", self );

	if ( !isDefined( self.name ) ) self.name = "no name";
	iPrintln( self.name + " ^7left the game" );

	logPrint( "Q;" + self getGuid() + ";" + self getEntityNumber() + ";" + self.name + "\n" );
}


PlayerLastStand(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration) {
	self suicide();
}

PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime) {
	if ( self.sessionteam == "spectator" ) return;

	level notify( "player_damage", self, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

	if ( isPlayer( eAttacker ) && eAttacker.pers["team"] == self.pers["team"] ) return;

	// damage modifier
	if ( sMeansOfDeath != "MOD_MELEE" ) {
		if ( isPlayer( eAttacker ) && eAttacker.pers["ability"] == "specialty_bulletdamage" ) iDamage = int( iDamage * 1.1 );
		modifier = getDvarFloat( "dr_damageMod_" + sWeapon );
		if (modifier <= 2.0 && modifier >= 0.1 && sMeansOfDeath != "MOD_MELEE" ) iDamage = int( iDamage * modifier );
	}

	if ( isPlayer( eAttacker ) && eAttacker != self ) {
		eAttacker iPrintln( "You hit " + self.name + " ^7for ^2" + iDamage + " ^7damage." );
		self iPrintln( eAttacker.name + " ^7hit you for ^2" + iDamage + " ^7damage." );
	}

	if ( !isDefined(vDir) ) iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	if ( !( iDFlags & level.iDFLAGS_NO_PROTECTION )) {
		if ( iDamage < 1 ) iDamage = 1;
		self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
	}
}

PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration) {
	self endon( "spawned" );
	self notify( "killed_player" );
	self notify( "death" );

	if ( self.sessionteam == "spectator" ) return;

	level notify( "player_killed", self, eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );

	if ( sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE" ) {
		sMeansOfDeath = "MOD_HEAD_SHOT";
	}

	self.sessionstate = "dead";
	self.statusicon = "hud_status_dead";
	self.sessionstate =  "spectator";

	if (isPlayer( attacker )) {
		if ( attacker != self ) {
			braxi\_rank::processXpReward( sMeansOfDeath, attacker, self );
			attacker.kills++;
			attacker.pers["kills"]++;
		}
	}

	deaths = self maps\mp\gametypes\_persistence::statGet( "deaths" );
	self maps\mp\gametypes\_persistence::statSet( "deaths", deaths + 1 );
	self.deaths++;
	self.pers["deaths"]++;
	self.died = true;

	obituary( self, attacker, sWeapon, sMeansOfDeath );

	if ( self.pers["team"] == "axis" ) self thread braxi\_teams::setTeam( "allies" );
	else self respawnPlayer();
}

spawnPlayer( origin, angles ) {
	level notify( "jumper", self );
	resettimeout();

	self.team = self.pers["team"];
	self.sessionteam = self.team;
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.statusicon = "";

	self setModel( "body_mp_sas_urban_sniper" );

	if ( isDefined( origin ) && isDefined( angles ) ) self spawn( origin,angles );
	else {
		spawnPoint = level.spawn[self.pers["team"]][randomInt( level.spawn[self.pers["team"]].size )];
		self spawn( spawnPoint.origin, spawnPoint.angles );
	}

	self giveWeapon( "deserteaglegold_mp" );
	self setSpawnWeapon( "deserteaglegold_mp" );
	self giveMaxAmmo( "deserteaglegold_mp" );

	self thread braxi\_teams::setHealth();
	self thread braxi\_teams::setSpeed();

	self notify( "spawned_player" );
	level notify( "player_spawn", self );
}

respawnPlayer() {
	self endon( "disconnect" );
	self endon( "spawned_player" );
	self endon( "joined_spectators" );
	
	if ( level.freerun ) self spawnPlayer();
}

spawnSpectator( origin, angles ) {
	if ( !isDefined( origin ) ) origin = (0,0,0);
	if ( !isDefined( angles ) ) angles = (0,0,0);

	self notify( "joined_spectators" );

	resettimeout();
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.statusicon = "";
	self spawn( origin, angles );
	self braxi\_teams::setSpectatePermissions();

	level notify( "player_spectator", self );
}