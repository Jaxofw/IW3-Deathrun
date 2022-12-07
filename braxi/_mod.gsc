#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include braxi\_utility;

init()
{
	initGame();
	preCache();
	init_spawns();

	level.activ = [];
	level.freerun = false;
	level.lastJumper = false;
	if ( !isDefined( game["rounds_played"] ) ) game["rounds_played"] = 0;
	level.notifying = false;
	level.notifications = [];

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

	if ( game["rounds_played"] == 0 )
		if ( level.dvar["freerun"] ) level.freerun = true;

	visionSetNaked( level.script, 2.0 );
	level thread gameLogic();
}

gameLogic()
{
	game["state"] = "waiting";

	if ( !level.freerun )
	{
		waitForPlayers( 2 );
		tpJumpersToSpawn();
		visionSetNaked( "mpIntro", 0 );
		game["state"] = "lobby";
		startTimer();
	}

	visionSetNaked( level.script, 2.0 );

	level notify( "round_started", game["rounds_played"] );
	game["state"] = "playing";

	level thread watchTimeLimit();

	while ( game["state"] == "playing" )
	{
		wait .3;

		level.players = getAllPlayers();
		level.jumpers = [];
		level.activators = [];

		if ( level.players.size > 0 )
		{
			for ( i = 0; i < level.players.size; i++ )
			{
				if ( isDefined( level.players[i].team ) )
				{
					if ( level.players[i] isAlive() )
					{
						if ( level.players[i].team == "allies" )
							level.jumpers[level.jumpers.size] = level.players[i];

						if ( level.players[i].team == "axis" )
							level.activators[level.activators.size] = level.players[i];
					}
				}
			}

			if ( !level.freerun )
			{
				if ( level.players.size > 2 && level.jumpers.size == 1 )
					level.jumpers[0] thread lastJumperAlive();

				if ( level.jumpers.size == 0 && level.activators.size > 0 )
					level endRound( "Jumpers Died!", "activator" );

				else if ( level.activators.size == 0 && level.jumpers.size > 0 )
					level endRound( "Activator Died!" );
			}
		}
	}
}

tpJumpersToSpawn()
{
	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		if ( players[i] isAlive() )
		{
			randomSpawn = level.spawn["allies"][randomInt( level.spawn["allies"].size )].origin;
			players[i] setOrigin( randomSpawn );
			players[i] linkTo( level.spawn_link );
		}
	}
}

startTimer()
{
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

	releasePlayers();

	level.matchStartText destroyElem();
	level.matchStartTimer destroyElem();
}

releasePlayers()
{
	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ )
		if ( players[i] isAlive() ) players[i] unLink();
}

pickRandomActivator()
{
	level.players = getAllPlayers();
	level.activ = level.players[randomInt( level.players.size )];

	if ( level.activ.pers["team"] != "allies" ) pickRandomActivator();

	iPrintLnBold( "^7" + level.activ.name + " was chosen to ^5Activate!" );

	level.activ braxi\_teams::setTeam( "axis" );
	level.activ braxi\_player::playerSpawn();

	// Give activator xp being for chosen
	level.activ braxi\_rank::giveRankXP( "activator" );
}

lastJumperAlive()
{
	if ( level.lastJumper ) return;
	level.lastJumper = true;
	iPrintLnBold( "^1" + self.name + " ^7is the last Jumper alive!" );
}

watchTimeLimit()
{
	if ( !level.dvar["time_limit"] ) return;

	time = level.dvar["time_limit"];
	if ( level.freerun ) time = level.dvar["time_limit_freerun"];

	iPrintLnBold( "Time Left: " + time );

	wait time;

	level thread endRound( "Time Limit Reached", "activator" );
}

endRound( string, winner )
{
	if ( game["state"] == "roundEnd" ) return;

	game["state"] = "roundEnd";
	game["rounds_played"]++;

	if ( game["rounds_played"] >= level.dvar["round_limit"] )
	{
		level thread endMap();
		return;
	}

	if ( winner == "activator" )
	{
		if ( isDefined( level.activ ) && isPlayer( level.activ ) )
			level.activ thread braxi\_rank::giveRankXp( "activator" );
	}

	iPrintLnBold( string );
	iPrintLnBold( "Starting Round " + ( game["rounds_played"] + 1 ) + "/" + level.dvar["round_limit"] );

	wait 4;

	// Set previous activator back to a jumper
	if ( isDefined ( level.activ ) && isPlayer( level.activ ) )
		level.activ braxi\_teams::setTeam( "allies" );

	map_restart( true );
}

endMap()
{
	setDvar( "g_deadChat", 1 );

	level thread braxi\_mapvote::mapVoteLogic();

	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[i].sessionstate = "intermission";
		players[i] braxi\_player::playerSpawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
		players[i] allowSpectateTeam( "allies", false );
		players[i] allowSpectateTeam( "axis", false );
		players[i] allowSpectateTeam( "freelook", true );
		players[i] allowSpectateTeam( "none", true );
		players[i] thread braxi\_mapvote::playerLogic();
	}
}

addTextHud( who, x, y, alpha, alignX, alignY, fontScale )
{
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