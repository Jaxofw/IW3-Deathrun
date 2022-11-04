#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include braxi\_utility;

init() {
	initGame();
	preCache();
	init_spawns();

	level.players = [];
	level.activ = [];
	level.weapons = [];
	level.freerun = false;
	if ( !isDefined( game["rounds_played"] ) ) game["rounds_played"] = 0;

	buildJumperTable();
	buildPrimaryTable();
	buildSecondaryTable();
	buildGloveTable();

	thread braxi\_dvar::setupDvars();
	thread braxi\_rank::init();
	thread braxi\_menus::init();
	thread braxi\_maps::init();
	thread braxi\_teams::init();

	setDvar( "g_speed", level.dvar["player_speed"] );
	setDvar( "jump_slowdownEnable", 0 );
	setDvar( "player_sprintTime", 12.8 );
	setDvar( "bullet_penetrationEnabled", 0 );
	setDvar( "bg_bobAmplitudeSprinting", 0 );
	setDvar( "bg_bobAmplitudeDucked", 0 );
	setDvar( "bg_bobAmplitudeProne", 0 );
	setDvar( "bg_bobAmplitudeStanding", 0 );

	if ( game["rounds_played"] == 0 ) {
		if ( level.dvar["freerun"] ) level.freerun = true;
	}

	game["state"] = "lobby";

	visionSetNaked( level.script, 2.0 );

	level gameLogic();
}

gameLogic() {
	waittillframeend;

	if ( !level.freerun ) {
		game["state"] = "waiting";
		waitForPlayers( 2 );
		tpJumpersToSpawn();
		startTimer();
		releaseJumpers();
	}

	game["state"] = "playing";

	if ( !level.freerun ) pickRandomActivator();

	watchTimeLimit();
}

tpJumpersToSpawn() {
	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ ) {
		if ( players[i] isPlaying() ) {
			randomSpawn = level.spawn["allies"][randomInt(level.spawn["allies"].size)].origin;
			players[i] setOrigin( randomSpawn );
			players[i] linkTo( level.spawn_link );
		}
	}
}

releaseJumpers() {
	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ ) {
		if ( players[i] isPlaying() ) players[i] unLink();
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

pickRandomActivator() {
	level.players = getAllPlayers();
	level.activ = level.players[randomInt( level.players.size )];
	
	if ( level.activ.pers["team"] != "allies" ) level thread pickRandomActivator();

	iPrintLnBold( "^7" + level.activ.name + " was chosen to ^5Activate!" );

	level.activ.pers["activator"]++;
	level.activ braxi\_teams::setTeam( "axis" );
	level.activ spawnPlayer();

	// Give activator xp being for chosen
	level.activ braxi\_rank::giveRankXP( "activator" );
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

	self setModel( "body_mp_sas_urban_sniper" );

	if ( isDefined(origin) && isDefined(angles) ) self spawn( origin, angles );
	else {
		spawnPoint = level.spawn[self.pers["team"]][randomInt( level.spawn[self.pers["team"]].size )];
		self spawn( spawnPoint.origin, spawnPoint.angles );
	}

	self giveWeapon( "beretta_mp" );
	self setSpawnWeapon( "beretta_mp" );
	self giveMaxAmmo( "beretta_mp" );

	self thread braxi\_teams::setHealth();
	self thread braxi\_teams::setSpeed();

	self notify( "spawned_player" );
	level notify( "player_spawn", self );
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
	iPrintLnBold( (game["rounds_played"] + 1) + "/12" );
}

endRound( string, winner ) {
	game["state"] = "round_end";
	game["rounds_played"]++;

	iPrintLnBold( string );

	if ( winner == "activator" ) {
		if (isDefined( level.activ ) && isPlayer( level.activ )) {
			level.activ braxi\_rank::giveRankXp( "activator" );
		}
	}

	wait 4;
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
		players[i] allowSpectateTeam( "none", true );
	}
}

spawnSpectator( origin, angles ) {
	if (!isDefined( origin )) origin = (0,0,0);
	if (!isDefined( angles )) angles = (0,0,0);

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