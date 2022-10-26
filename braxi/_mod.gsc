#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include braxi\_utility;

init() {
	precache();
	init_spawns();
	thread braxi\_cod4stuff::init();

	setDvar( "g_speed", 238 );
	setDvar( "jump_slowdownEnable", 0 );
	setDvar( "bullet_penetrationEnabled", 0 );

	thread braxi\_dvar::setupDvars();
	thread braxi\_menus::init();

	level.freerun = false;
	level.spawn_link = spawn( "script_model", (0,0,0) );

	if ( !isDefined( game["rounds_played"] ) ) game["rounds_played"] = 1;

	game["state"] = "round_begin";

	if ( game["rounds_played"] == 1 ) {
		if ( level.dvar["freerun"] ) level.freerun = true;
	}

	buildJumperTable();
	buildPrimaryTable();
	buildSecondaryTable();
	buildGloveTable();

	level gameLogic();
}

precache() {
	// Shaders
	preCacheShader( "white" );

	// Icons
	preCacheStatusIcon( "hud_status_connecting" );
	preCacheStatusIcon( "hud_status_dead" );

	// Models
	preCacheModel( "body_mp_sas_urban_sniper" );

	// Weapons
	preCacheItem( "deserteaglegold_mp" );
}

gameLogic() {
	waittillframeend;

	visionSetNaked( "mpIntro", 0 );
	if ( isDefined( level.matchStartText ) ) level.matchStartText destroyElem();

	wait 0.2;

	level.matchStartText = createServerFontString( "objective", 1.5 );
	level.matchStartText setPoint( "CENTER", "CENTER", 0, 0 );
	level.matchStartText.sort = 1001;
	level.matchStartText setText( "Waiting for players..." );
	level.matchStartText.foreground = false;
	level.matchStartText.hidewheninmenu = true;

	if ( !level.freerun ) waitForPlayers( 2 );

	startTimer();

	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ ) {
		if ( players[i] isPlaying() ) players[i] unLink();
	}

	game["state"] = "playing";

	visionSetNaked( level.script, 2.0 );

	level watchTimeLimit();

	iPrintLnBold( game["rounds_played"] + "/12" );
}

watchTimeLimit() {
	if ( !level.dvar["time_limit"] ) return;
	
	time = level.dvar["time_limit"];
	if ( level.freerun ) time = level.dvar["time_limit_freerun"];

	iPrintLnBold( "Time Left: " + time );

	wait time;

	if ( game["rounds_played"] >= level.dvar["round_limit"] ) {
		level endMap( "activator" );
		return;
	}

	level endRound( "Time Limit Reached", "activator" );
}

endRound( string, winner ) {
	game["state"] = "round_end";
	game["rounds_played"]++;

	iPrintLnBold( string );

	if ( winner == "activator" ) {
		if ( isDefined( level.activ ) && isPlayer( level.activ ) ) {
			level.activ braxi\_rank::giveRankXp( "activator", 100 );
		}
	}

	wait 10;
	map_restart( true );
}

endMap( winner ) {
	setDvar( "g_deadChat", 1 );

	if ( winner == "activator" ) {
		if ( isDefined( level.activ ) && isPlayer( level.activ ) ) {
			level.activ braxi\_rank::giveRankXp( "activator", 100 );
		}
	}

	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ ) {
		players[i].sessionstate = "intermission";
		players[i] spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
		players[i] allowSpectateTeam( "allies", false );
		players[i] allowSpectateTeam( "axis", false );
		players[i] allowSpectateTeam( "freelook", true );
		players[i] allowSpectateTeam( "none", false );
	}
}

startTimer() {
	if ( isDefined( level.matchStartText ) ) level.matchStartText destroyElem();

	level.matchStartText = createServerFontString( "objective", 1.5 );
	level.matchStartText setPoint( "CENTER", "CENTER", 0, -20 );
	level.matchStartText setText( "Round begins in..." );
	level.matchStartText.sort = 1001;
	level.matchStartText.foreground = false;
	level.matchStartText.hidewheninmenu = true;
	
	level.matchStartTimer = createServerTimer( "objective", 1.4 );
	level.matchStartTimer setPoint( "CENTER", "CENTER", 0, 0 );
	level.matchStartTimer setTimer( level.dvar["spawn_time"] );
	level.matchStartTimer.sort = 1001;
	level.matchStartTimer.foreground = false;
	level.matchStartTimer.hideWhenInMenu = true;

	wait level.dvar["spawn_time"];
	
	level.matchStartText destroyElem();
	level.matchStartTimer destroyElem();
}

playerConnect() {
	level notify( "connected", self );

	self.guid = self getGuid();
	self.number = self getEntityNumber();
	self.statusicon = "hud_status_connecting";
	self.died = false;

	if ( !isDefined( self.name ) ) self.name = "undefined name";
	if ( !isDefined( self.guid ) ) self.guid = "undefined guid";

	// we want to show hud and we get an IP adress for "add to favourities" menu
	self setClientDvars( "show_hud", "true", "ip", getDvar("net_ip"), "port", getDvar("net_port") );
	if ( !isDefined( self.pers["team"] ) ) {
		iPrintLn( self.name + " ^7entered the game" );

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

	if ( !isDefined( level.spawn["spectator"] ) ) level.spawn["spectator"] = level.spawn["allies"][0];

	self setClientDvars(
		"cg_drawSpectatorMessages", 1,
		"player_sprintTime", 12.8,
		"ui_hud_hardcore", 1,
		"ui_menu_playername", self.name,
		"ui_uav_client", 0
	);

	if ( self.name.size > 8 ) self setClientDvar( "ui_menu_playername", getSubStr(self.name, 0, 7) + "..." );
	
	self openMenu( game["menu_team"] );
}

playerDisconnect() {
	level notify( "disconnected", self );

	if (!isDefined( self.name )) self.name = "no name";
	iPrintLn( self.name + " ^7left the game" );

	logPrint( "Q;" + self getGuid() + ";" + self getEntityNumber() + ";" + self.name + "\n" );
}


PlayerLastStand(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration) {
	self suicide();
}

PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime) {
	if ( self.sessionteam == "spectator" ) return;

	level notify( "player_damage", self, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

	if ( isPlayer( eAttacker ) && eAttacker.pers["team"] == self.pers["team"] ) return;

	if ( !isDefined( vDir ) ) iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	if (!( iDFlags & level.iDFLAGS_NO_PROTECTION )) {
		if ( iDamage < 1 ) iDamage = 1;
		self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
	}
}

PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration) {
	self endon( "spawned" );
	self notify( "killed_player" );
	self notify( "death" );

	if ( self.sessionteam == "spectator" ) return;

	level notify( "player_killed", self, eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );

	self.statusicon = "hud_status_dead";
	self.sessionstate = "spectator";
	self.died = true;

	if ( !level.freerun ) {
		deaths = self maps\mp\gametypes\_persistence::statGet("deaths");
		self maps\mp\gametypes\_persistence::statSet( "deaths", deaths + 1 );
		self.deaths++;
		self.pers["deaths"]++;
		obituary( self, attacker, sWeapon, sMeansOfDeath );
	}

	if ( self.pers["team"] == "axis" ) {
		self thread braxi\_teams::setTeam("allies");
		return;
	}

	self respawnPlayer();
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

	if ( isDefined(origin) && isDefined(angles) ) self spawn( origin,angles );
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

	if ( game["state"] == "round_begin" ) self linkTo( level.spawn_link );
}

respawnPlayer() {
	self endon( "disconnect" );
	self endon( "spawned_player" );
	self endon( "joined_spectators" );

	if ( level.freeRun ) {
		wait 0.05;
		self spawnPlayer();
		return;
	}
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

addTextHud( who, x, y, alpha, alignX, alignY, fontScale )
{
    if( isPlayer( who ) )
        hud = newClientHudElem( who );
    else
        hud = newHudElem();

    hud.x = x;
    hud.y = y;
    hud.alpha = alpha;
    hud.alignX = alignX;
    hud.alignY = alignY;
    hud.fontScale = fontScale;
    return hud;
}