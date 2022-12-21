#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include braxi\_utility;

init()
{
	initGame();
	preCache();
	init_spawns();

	level.practice = false;
	level.lastJumper = false;
	level.notifying = false;
	level.activ = [];
	level.jumpers = [];
	level.activators = [];
	level.notifications = [];
	level.jumpersAlive = 0;

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

	visionSetNaked( level.script, 2.0 );

	if ( !isDefined( game["roundsplayed"] ) )
	{
		game["roundsplayed"] = 0;
		if ( level.dvar["practice"] ) level.practice = true;
	}

	if ( level.practice )
	{
		game["state"] = "practice";
		level.timeLeft = level.dvar["time_limit_practice"];
	}
	else
		level.timeLeft = level.dvar["time_limit"];

	level thread watchPlayers();
	level thread gameLogic();
	level thread updateJumperHud();
}

watchPlayers()
{
	while ( true )
	{
		level.jumpers = [];
		level.activators = [];
		level.players = getAllPlayers();

		if ( level.players.size > 0 )
		{
			for ( i = 0; i < level.players.size; i++ )
			{
				if ( level.players[i] isAlive() )
				{
					if ( level.players[i].pers["team"] == "allies" )
						level.jumpers[level.jumpers.size] = level.players[i];
					else
						level.activators[level.activators.size] = level.players[i];
				}

				level.players[i] setClientDvars(
					"ui_game_state", game["state"],
					"ui_time_left", level.timeLeft
				);
			}

			if ( !level.practice && game["state"] == "playing" )
			{
				if ( level.jumpers.size == 1 && !level.lastJumper )
					level.jumpers[0] thread lastAlive();

				if ( level.jumpers.size == 0 && level.activators.size > 0 )
				{
					level endRound( "Jumpers Died!", "activator" );
					break;
				}
				else if ( level.activators.size == 0 && level.jumpers.size > 0 )
				{
					level endRound( "Activator Died!", "jumper" );
					break;
				}
			}
		}

		wait .2;
	}
}

gameLogic()
{
	waittillframeend;

	if ( !level.practice )
	{
		waitForPlayers( 2 );
		game["state"] = "lobby";

		setupPlayers();
		startTimer();

		if ( level.jumpers.size + level.activators.size < 2 )
		{
			if ( isDefined( level.activ ) && isPlayer( level.activ ) )
			{
				level.activ braxi\_teams::setTeam( "allies" );
				level.activ setOrigin( level.spawn["allies"][randomInt( level.spawn["allies"].size )].origin );
				level.activ = undefined;
			}

			level thread gameLogic();
			return;
		}

		game["state"] = "playing";
	}
	else
		game["state"] = "practice";

	level notify( "round_started", game["roundsplayed"] );
	level thread watchTime();
}

setupPlayers()
{
	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[i] linkTo( level.spawn_link );
		players[i] braxi\_teams::setLoadout();
	}
}

startTimer()
{
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

	wait level.dvar["spawn_time"] / 2;
	level thread pickRandomActivator();
	wait level.dvar["spawn_time"] / 2;

	// Release jumpers from spawn_link
	for ( i = 0; i < level.players.size; i++ )
		level.players[i] unLink();

	level.matchStartText destroyElem();
	level.matchStartTimer destroyElem();
}

pickRandomActivator()
{
	player = level.jumpers[randomInt( level.jumpers.size )];

	if ( !isDefined( game["lastActivator"] ) )
		game["lastActivator"] = player.guid;
	else
	{
		for ( i = 0; i < level.jumpers.size; i++ )
		{
			if ( level.jumpers[i].guid != game["lastActivator"] )
			{
				game["lastActivator"] = level.jumpers[i].guid;
				player = level.jumpers[i];
				break;
			}
		}
	}

	level.activ = player;

	level.activ unLink();
	level.activ setOrigin( level.spawn["axis"][randomInt( level.spawn["axis"].size )].origin );
	level.activ linkTo( level.spawn_link );
	wait .1;
	level.activ braxi\_teams::setTeam( "axis" );
	level notify( "activator_chosen" );
	level.activ braxi\_teams::setPlayerModel();

	iPrintLnBold( "^7" + level.activ.name + " ^7was chosen to ^5Activate!" );

	level.activ takeWeapon( level.activ.pers["primary"] );
	level.activ switchToWeapon( level.activ.pers["secondary"] );

	// Give activator xp being for chosen
	level.activ braxi\_rank::giveRankXP( "activator" );
}

watchTime()
{
	level.time = level.timeLeft;

	for ( i = level.time; i >= 0; i-- )
	{
		level.timeLeft = i;
		wait 1;
	}

	level thread endRound( "Time Limit Reached", "activator" );
}

lastAlive()
{
	level.lastJumper = true;
	iPrintLnBold( "^5" + self.name + " ^7 is the last Jumper Alive!" );
}

endRound( reason, winner )
{
	game["state"] = "endround";
	game["roundsplayed"]++;

	if ( game["roundsplayed"] >= level.dvar["roundslimit"] )
	{
		level thread endMap();
		return;
	}

	iPrintLnBold( reason );
	iPrintLnBold( "Starting Round " + ( game["roundsplayed"] + 1 ) + "/" + level.dvar["roundslimit"] );

	wait 3;

	if ( isDefined( level.activ ) && isPlayer( level.activ ) )
	{
		// Set previous activator back to a jumper
		level.activ braxi\_teams::setTeam( "allies" );

		if ( winner == "activator" )
			level.activ thread braxi\_rank::giveRankXp( "win" );
	}

	if ( winner == "jumper" )
		for ( i = 0; i < level.jumpers.size; i++ )
			level.jumpers[i] thread braxi\_rank::giveRankXp( "win" );

	map_restart( true );
}

endMap()
{
	game["state"] = "endmap";
	setDvar( "g_deadChat", 1 );

	level thread braxi\_mapvote::mapVoteLogic();

	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[i].sessionstate = "spectator";
		players[i] braxi\_player::playerSpawnSpectator( level.spawn["spectator"][0].origin, level.spawn["spectator"][0].angles );
		players[i] braxi\_teams::setSpectatePermissions( false, false, true, true );
		players[i] thread braxi\_mapvote::playerLogic();
	}
}

addTextHud( who, x, y, alpha, alignX, alignY, fontScale )
{
	if ( isPlayer( who ) )
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