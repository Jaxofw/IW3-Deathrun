#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include braxi\_utility;

init() {
	initGame();
	preCache();
	init_spawns();

	level.activ = [];
	level.freerun = false;
	level.lastJumper = false;
	if ( !isDefined( game["rounds_played"] ) ) game["rounds_played"] = 0;

	buildJumperTable();
	buildActivatorTable();
	buildPrimaryTable();
	buildSecondaryTable();
	buildGloveTable();

	braxi\_dvar::setupDvars();
	thread braxi\_rank::init();
	thread braxi\_menus::init();
	braxi\_maps::init();
	braxi\_teams::init();
	braxi\_mapvote::init();

	setDvar( "g_speed", level.dvar["player_speed"] );
	setDvar( "jump_slowdownEnable", 0 );
	setDvar( "player_sprintTime", 12.8 );
	setDvar( "bullet_penetrationEnabled", 0 );

	if ( game["rounds_played"] == 0 ) {
		if ( level.dvar["freerun"] ) level.freerun = true;
	}

	game["state"] = "lobby";

	visionSetNaked( level.script, 2.0 );
	level thread gameLogic();
}

gameLogic() {
	waittillframeend;
	game["state"] = "waiting";

	if ( !level.freerun ) {
		waitForPlayers( 2 );
		tpJumpersToSpawn();
		startTimer();
	}

	level notify( "round_started", game["rounds_played"] );
	game["state"] = "playing";

	level thread watchTimeLimit();

	while ( game["state"] == "playing" ) {
		wait .2;

		level.jumpers = [];
		level.jumpersAlive = 0;
		level.activatorsAlive = 0;
		level.players = getAllPlayers();

		if ( level.players.size > 0 ) {
			for ( i = 0; i < level.players.size; i++ ) {
				if ( isDefined( level.players[i].team ) ) {
					if ( level.players[i] isAlive() ) {
						if ( level.players[i].team == "allies" ) {
							level.jumpersAlive++;
							level.jumpers[level.jumpers.size] = level.players[i];
						}

						if ( level.players[i].team == "axis" ) level.activatorsAlive++;
					}
				}
			}

			if ( !level.freerun ) {
				if ( level.players.size > 2 && level.jumpersAlive == 1 ) level.jumpers[0] thread lastJumperAlive();
				if ( !level.jumpersAlive && level.activatorsAlive ) {
					level endRound( "Jumpers Died!", "activator" );
					return;
				} else if ( !level.activatorsAlive && level.jumpersAlive ) {
					level endRound( "Activator Died!", "jumper" );
					return;
				}
			}
		}
	}
}

tpJumpersToSpawn() {
	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ ) {
		if ( players[i] isAlive() ) {
			randomSpawn = level.spawn["allies"][randomInt( level.spawn["allies"].size )].origin;
			players[i] setOrigin( randomSpawn );
		}
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

	level thread pickRandomActivator();

	wait level.dvar["spawn_time"];

	releaseJumpers();

	level.matchStartText destroyElem();
	level.matchStartTimer destroyElem();
}

releaseJumpers() {
	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ )
		if ( players[i] isAlive() ) players[i] unLink();
}

pickRandomActivator() {
	level.players = getAllPlayers();
	level.activ = level.players[randomInt( level.players.size )];

	if ( level.activ.pers["team"] != "allies" ) pickRandomActivator();

	iPrintLnBold( "^7" + level.activ.name + " was chosen to ^5Activate!" );

	level.activ braxi\_teams::setTeam( "axis" );
	level.activ spawnPlayer();

	// Give activator xp being for chosen
	level.activ braxi\_rank::giveRankXP( "activator" );
}

lastJumperAlive() {
	if ( level.lastJumper ) return;
	level.lastJumper = true;

	hud = addTextHud( level, 320, 240, 0, "center", "middle", 2.4 );
	hud setText( self.name + " is the last Jumper alive" );

	hud.glowColor = ( 0.7, 0, 0 );
	hud.glowAlpha = 1;
	hud SetPulseFX( 30, 100000, 700 );

	hud fadeOverTime( 0.5 );
	hud.alpha = 1;

	wait 2.6;

	hud fadeOverTime( 0.4 );
	hud.alpha = 0;
	wait 0.4;

	hud destroy();
}

spawnPlayer( origin, angles ) {
	level notify( "jumper", self );
	resettimeout();

	// Set activator from previous round to jumper if time limit ran out
	if ( game["state"] == "lobby" && self.pers["team"] == "axis" ) self.pers["team"] = "allies";

	self.team = self.pers["team"];
	self.sessionteam = self.team;
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.statusicon = "";

	if ( isDefined( origin ) && isDefined( angles ) ) self spawn( origin, angles );
	else {
		spawnPoint = level.spawn[self.pers["team"]][randomInt( level.spawn[self.pers["team"]].size )];
		self spawn( spawnPoint.origin, spawnPoint.angles );
	}

	if ( game["state"] == "lobby" ) self linkTo( level.spawn_link );
	if ( self.team != "spectator" ) self braxi\_teams::setLoadout();

	self notify( "spawned_player" );
	level notify( "player_spawn", self );
}

watchTimeLimit() {
	if ( !level.dvar["time_limit"] ) return;

	time = level.dvar["time_limit"];
	if ( level.freerun ) time = level.dvar["time_limit_freerun"];

	iPrintLnBold( "Time Left: " + time );

	wait time;

	level thread endRound( "Time Limit Reached", "activator" );
}

endRound( string, winner ) {
	game["rounds_played"]++;

	if ( game["rounds_played"] >= level.dvar["round_limit"] ) {
		level thread endMap();
		return;
	}

	if ( winner == "activator" ) {
		if ( isDefined( level.activ ) && isPlayer( level.activ ) ) {
			level.activ thread braxi\_rank::giveRankXp( "activator" );
		}
	}

	iPrintLnBold( string );
	iPrintLnBold( "Starting Round " + ( game["rounds_played"] + 1 ) + "/" + level.dvar["round_limit"] );

	wait 4;
	map_restart( true );
}

endMap() {
	setDvar( "g_deadChat", 1 );

	level thread braxi\_mapvote::mapVoteLogic();

	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ ) {
		players[i].sessionstate = "intermission";
		players[i] spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
		players[i] allowSpectateTeam( "allies", false );
		players[i] allowSpectateTeam( "axis", false );
		players[i] allowSpectateTeam( "freelook", true );
		players[i] allowSpectateTeam( "none", true );
		players[i] thread braxi\_mapvote::playerLogic();
	}
}

spawnSpectator( origin, angles ) {
	if ( !isDefined( origin ) ) origin = ( 0, 0, 0 );
	if ( !isDefined( angles ) ) angles = ( 0, 0, 0 );

	self notify( "joined_spectators" );

	resettimeout();
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.statusicon = "";
	self spawn( origin, angles );
	self braxi\_teams::setSpectatePermissions();

	level notify( "player_spectator", self );
}

respawnPlayer() {
	self endon( "disconnect" );
	self endon( "spawned_player" );
	self endon( "joined_spectators" );

	if ( level.freerun || game["state"] != "playing" ) {
		wait .05;
		self spawnPlayer();
		return;
	}
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