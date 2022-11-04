#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include braxi\_utility;

init() {
	precache();
	init_spawns();
	thread braxi\_cod4stuff::init();

	setDvar( "cg_fovscale", 1.15 );

	setDvar( "bg_bobamplitudesprinting", 0 );
	setDvar( "bg_bobamplitudeducked", 0 );
	setDvar( "bg_bobamplitudeprone", 0 );
	setDvar( "bg_bobamplitudestanding", 0 );
	setDvar( "g_speed", 230 );
	setDvar( "jump_slowdownEnable", 0 );
	setDvar( "bullet_penetrationEnabled", 0 );

	thread braxi\_dvar::setupDvars();
	thread braxi\_menus::init();
	thread braxi\_teams::init();

	level.freerun = false;
	level.spawn_link = spawn( "script_model", (0,0,0) );
	level.players = [];
	level.activators = [];
	level.activator = [];

	if (!isDefined( game["rounds_played"])) game["rounds_played"] = 1;

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

gameLogic() {
	waittillframeend;

	visionSetNaked( "mpIntro", 0 );
	if (isDefined( level.matchStartText )) level.matchStartText destroyElem();

	wait 0.2;

	// DVAR Changes
	setDvar( "player_sprintTime", 12.8 );

	level.matchStartText = createServerFontString( "objective", 1.5 );
	level.matchStartText setPoint( "CENTER", "CENTER", 0, 0 );
	level.matchStartText.sort = 1001;
	level.matchStartText setText( "Waiting for players..." );
	level.matchStartText.foreground = false;
	level.matchStartText.hidewheninmenu = true;

	if ( !level.freerun ) waitForPlayers( 2 );

	level startTimer();

	game["state"] = "playing";

	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ ) {
		if ( players[i] isPlaying() ) {
			players[i] unLink();
			level.players[i] = players[i];
		}
	}

	visionSetNaked( level.script, 2.0 );
	level pickRandomActivator();
	level watchTimeLimit();

	iPrintLnBold( game["rounds_played"] + "/12" );
}

pickRandomActivator() {
	randomPlayer = randomInt( level.players.size );
	playerChosen = level.players[randomPlayer];

	if ( playerChosen.pers["team"] != "allies" ) level thread pickRandomActivator();

	level.activator = playerChosen;
	playerChosen.pers["activator"]++;
	playerChosen braxi\_teams::setTeam( "axis" );

	iPrintLnBold("^7" + playerChosen.name + " was chosen to ^5Activate!");
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
	if (isDefined( level.matchStartText )) level.matchStartText destroyElem();

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

	self giveWeapon( "beretta_mp" );
	self setSpawnWeapon( "beretta_mp" );
	self giveMaxAmmo( "beretta_mp" );

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