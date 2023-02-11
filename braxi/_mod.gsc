#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include braxi\_common;

main()
{
    preCache();
    braxi\_dvar::init();

    setDvar( "jump_slowdownEnable", 0 );
    setDvar( "bullet_penetrationEnabled", 0 );
    setDvar( "g_speed", level.dvar["player_speed"] );
    setDvar( "jump_slowdownEnable", 0 );
    setDvar( "player_sprintTime", 12.8 );
    setDvar( "bullet_penetrationEnabled", 0 );

    game["roundStarted"] = false;

    level.freeRun = false;
    level.mapHasTimeTrigger = false;
    level.trapsDisabled = false;
    level.MYSQL_TYPE_LONG = 3;
    level.MYSQL_TYPE_VAR_STRING = 253;

    if ( !isDefined( game["db_connection"] ) )
    {
        game["db_connection"] = SQL_Connect( "127.0.0.1", 3306, "root", "123456" );
        SQL_SelectDB( "deathrun" );
    }

    critical( "mysql" );

    thread braxi\_rank::init();
    thread braxi\_menus::init();
    braxi\_maps::init();
    braxi\_teams::init();
    braxi\_killcam::init();
    braxi\_records::init();
    braxi\_mapvote::init();
    braxi\_leaderboard::init();

    if ( !isDefined( game["roundsplayed"] ) )
    {
        game["roundsplayed"] = 1;

        if ( level.dvar["freerun"] )
            level.freeRun = true;
    }

    level thread gameLogic();
    level thread fastestTime();
    level thread updateJumpersHud();
    level thread plugins\_plugins::init();
}

gameLogic()
{
    waittillframeend;

    level.timeLimit = level.dvar["time_limit_freerun"];
    thread updateGameState( "lobby" );

    if ( !level.freeRun )
    {
        level.timeLimit = level.dvar["time_limit"];

        level thread watchPlayers();
        waitForPlayers();
        roundBeginCountdown();

        // Incase a player disconnects or something we want to return back to pre round countdown
        if ( !canStartRound() )
        {
            // Reset activator since someone left
            if ( isDefined( level.activ ) && isPlayer( level.activ ) )
            {
                level.activ braxi\_teams::setTeam( "allies" );
                level.activ braxi\_teams::setLoadout();
                level.activ unLink();
                level.activ setOrigin( level.spawn["allies"][randomInt( level.spawn["allies"].size )].origin );
                level.activ = undefined;
            }

            level notify( "round_ended" );
            level thread gameLogic();
            return;
        }

        thread updateGameState( "playing" );
        level thread firstBlood();
    }
    else
        thread updateGameState( "practice" );

    players = getAllPlayers();
    for ( i = 0; i < players.size; i++ )
    {
        if ( isAlive( players[i] ) && players[i] isPlaying() )
        {
            // Unlink players from level.spawn_link
            players[i] unLink();

            if ( players[i].pers["team"] == "allies" )
                players[i] thread antiAFK();
        }
    }

	game["roundStarted"] = true;

    level notify( "round_started", game["roundsplayed"] );
    level thread watchTimeLimit();
}

watchPlayers()
{
    level endon( "round_ended" );

    while ( true )
    {
        level.jumpers = [];
        level.activators = [];
        level.players = getAllPlayers();

        if ( level.players.size )
        {
            for ( i = 0; i < level.players.size; i++ )
            {
                level.players[i] setClientDvar( "ui_time_left", level.timeLimit );

                if ( isAlive( level.players[i] ) && level.players[i] isPlaying() && !level.players[i].ghost )
                {
                    if ( level.players[i].pers["team"] == "allies" )
                        level.jumpers[level.jumpers.size] = level.players[i];
                    else
                        level.activators[level.activators.size] = level.players[i];
                }
            }

            if ( !level.freeRun && game["state"] == "playing" )
            {
                if ( level.jumpers.size == 1 && !isDefined( level.lastJumper ) )
                   level.jumpers[0] thread lastAlive();

                if ( level.jumpers.size && !level.activators.size )
                    thread endRound( "Activator Died!", "jumper" );
                else if ( !level.jumpers.size && level.activators.size )
                    thread endRound( "Jumpers Died!", "activator" );
            }
        }

        wait 0.2;
    }
}

endRound( reason, winner )
{
    if ( !game["roundStarted"] )
        return;

    level notify( "round_ended" );

    game["state"] = "endround";
    game["roundsplayed"]++;

    players = getAllPlayers();

	if ( winner == "jumper" )
    {
		for ( i = 0; i < players.size; i++ )
        {
            if ( players[i].pers["team"] == "allies" )
			    players[i] thread braxi\_rank::giveRankXp( "win" );
        }
    }

    if ( isDefined( level.activ ) && isPlayer( level.activ ) )
	{
		// Set previous activator back to a jumper
		level.activ braxi\_teams::setTeam( "allies" );

		if ( winner == "activator" )
			level.activ thread braxi\_rank::giveRankXp( "win" );
	}

    if ( game["roundsplayed"] > level.dvar["round_limit"] )
    {
        level endMap();
        return;
    }
    else
    {
        iPrintLnBold( reason );
        iPrintLnBold( "Starting Round ^8" + game["roundsplayed"] + "/" + level.dvar["round_limit"] );

        for ( i = 0; i < players.size; i++ )
            players[i] setClientDvars( "ui_rounds_played", game["roundsplayed"] );
    }

    wait 1;

    if ( level.killcamStarted )
        wait 8;
    else
        wait 4;

	map_restart( true );
}

endMap()
{
	game["state"] = "endmap";

    setDvar( "g_deadChat", 1 );
    
    wait 1;

    if ( level.killcamStarted )
        wait 8;
    else
        wait 4;

    players = getAllPlayers();
    for ( i = 0; i < players.size; i++ )
    {
        players[i] closeMenu();
        players[i] closeInGameMenu();
        players[i] spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
		players[i] allowSpectateTeam( "allies", false );
		players[i] allowSpectateTeam( "axis", false );
		players[i] allowSpectateTeam( "freelook", false );
		players[i] allowSpectateTeam( "none", true );
        players[i] setClientDvar( "show_hud", false );
    }

    braxi\_records::displayMapRecords();
    level thread braxi\_mapvote::mapVoteLogic();

    if ( isDefined( game["db_connection"] ) )
		SQL_Close(); // Disconnect from database
}

firstBlood()
{
    level waittill( "player_killed", who );

    // Prevent activator from showing as first blood
    if ( level.activ == who )
        return;

    if ( who.ghost )
    {
        level thread firstBlood();
        return;
    }

    level thread playSound( "first_blood" );

    firstBlood = addTextHud( level, 320, 220, 0, "center", "middle", 2.4 );
    firstBlood.glowColor = ( 0.7, 0, 0 );
    firstBlood.glowAlpha = 1;
    firstBlood SetPulseFX( 30, 100000, 700 );
    firstBlood setText( "First victim of this round is " + who.name );

    firstBlood fadeOverTime( 0.5 );
    firstBlood.alpha = 1;

    wait 2.6;

    firstBlood fadeOverTime( 0.4 );
    firstBlood.alpha = 0;

    wait 0.4;

    firstBlood destroy();
}

lastAlive()
{
    // We don't want this to show when there's 2 people in the server
    if ( level.players.size == 2 )
        return;

    level.lastJumper = true;
    level thread playSound( "last_alive" );

    lastAlive = addTextHud( level, 320, 240, 0, "center", "middle", 2.4 );
    lastAlive setText( self.name + " is the last Jumper alive" );

    lastAlive.glowColor = ( 0.7, 0, 0 );
    lastAlive.glowAlpha = 1;
    lastAlive SetPulseFX( 30, 100000, 700 );

    lastAlive fadeOverTime( 0.5 );
    lastAlive.alpha = 1;

    wait 2.6;

    lastAlive fadeOverTime( 0.4 );
    lastAlive.alpha = 0;

    wait 0.4;

    lastAlive destroy();
}

roundBeginCountdown()
{
    visionSetNaked( "mpIntro", 0 );

    if ( isDefined( level.matchStartText ) )
        level.matchStartText destroyElem();

    level.matchStartText = createServerFontString( "objective", 1.5 );
    level.matchStartText setPoint( "CENTER", "CENTER", 0, -20 );
    level.matchStartText.sort = 1001;
    level.matchStartText.foreground = false;
    level.matchStartText.hidewheninmenu = true;
    level.matchStartText setText( "Round begins in" );

    level.matchStartTimer = createServerTimer( "objective", 1.9 );
    level.matchStartTimer setPoint( "CENTER", "CENTER", 0, 4 );
    level.matchStartTimer.sort = 1001;
    level.matchStartTimer.foreground = false;
    level.matchStartTimer.hideWhenInMenu = true;
    level.matchStartTimer.color = ( 1, 1, 0.25 );
    level.matchStartTimer setValue( level.dvar["spawn_time"] );
    level.matchStartTimer maps\mp\gametypes\_hud::fontPulseInit();

	level thread pickActivator();

    for ( i = level.dvar["spawn_time"] - 1; i >= 0; i-- )
    {
        wait 1;
        level.matchStartTimer setValue( i );
        level.matchStartTimer thread maps\mp\gametypes\_hud::fontPulse( level );
    }

    level.matchStartTimer fadeOverTime( 0.5 );
    level.matchStartTimer.alpha = 0;
    level.matchStartText fadeOverTime( 0.5 );
    level.matchStartText.alpha = 0;

    visionSetNaked( level.script, 2.0 );

    wait 0.5;

    level.matchStartText destroyElem();
    level.matchStartTimer destroyElem();
}

pickActivator()
{
    if ( !isDefined( game["pastActivators"] ) )
        game["pastActivators"] = [];

    if ( !isDefined( game["lastActivator"] ) )
        game["lastActivator"] = "";

    level.activ = level.jumpers[randomInt( level.jumpers.size )];

    // while ( hasBeenActivator( level.activ ) )
    //     level.activ = level.jumpers[randomInt( level.jumpers.size )];

    wait level.dvar["spawn_time"] / 2;

	level.activ braxi\_teams::setTeam( "axis" );
	level.activ braxi\_teams::setPlayerModel();
    level.activ braxi\_teams::setLoadout();

    // Update jumpers alive hud
    level notify( "activator_chosen" );

    iPrintLnBold( level.activ.name + " ^7was picked to ^8Activate!" );

    // Show activator in lobby
    wait level.dvar["spawn_time"] / 2;

    level.activ unLink();
    level.activ setOrigin( level.spawn["axis"][randomInt( level.spawn["axis"].size )].origin );
    level.activ linkTo( level.spawn_link );

    // Prevent activator from being chosen often
    game["pastActivators"][game["pastActivators"].size] = level.activ.guid;
    game["lastActivator"] = level.activ.guid;

    level.activ thread freeRunChoice();
}

freeRunChoice()
{
	self endon( "disconnect" );
	self endon( "spawned_player" );
	self endon( "joined_spectators" );
	self endon( "death" );

	if( !level.dvar["freerun_choice"] || level.trapsDisabled )
		return;

	self.hud_freeround = newClientHudElem( self );
	self.hud_freeround.elemType = "font";
	self.hud_freeround.x = 320;
	self.hud_freeround.y = 370;
	self.hud_freeround.alignX = "center";
	self.hud_freeround.alignY = "middle";
	self.hud_freeround.alpha = 1;
	self.hud_freeround.font = "default";
	self.hud_freeround.fontScale = 1.8;
	self.hud_freeround.sort = 0;
	self.hud_freeround.foreground = true;
	self.hud_freeround setText( "Press ^9[{+attack}] ^7to ^8Disable ^7Traps" );

	self.hud_freeround_time = newClientHudElem( self );
	self.hud_freeround_time.elemType = "font";
	self.hud_freeround_time.x = 320;
	self.hud_freeround_time.y = 390;
	self.hud_freeround_time.alignX = "center";
	self.hud_freeround_time.alignY = "middle";
	self.hud_freeround_time.alpha = 1;
	self.hud_freeround_time.font = "default";
	self.hud_freeround_time.fontScale = 1.8;
	self.hud_freeround_time.sort = 0;
    self.hud_freeround_time.foreground = true;
    self.hud_freeround_time setTimer( level.dvar["freerun_choice_timer"] );

    for ( i = 0; i < 10 * level.dvar["freerun_choice_timer"]; i++ )
    {
        if ( isDefined( level.canCallFreerun ) )
        {
            self.hud_freeround destroy();
			self.hud_freeround_time destroy();
            break;
        }

        if ( self attackButtonPressed() )
        {
            level thread braxi\_maps::disableTraps();
            break;
        }

        wait 0.1;
    }

    if( isDefined( self.hud_freeround ) )
		self.hud_freeround destroy();

	if( isDefined( self.hud_freeround_time ) )
		self.hud_freeround_time destroy();
}

fastestTime()
{
	trig = getEntArray( "endmap_trig", "targetname" );

	if ( !trig.size || trig.size > 1 )
		return;

    level.mapHasTimeTrigger = true;
	trig = trig[0];

    level waittill( "round_started" );

	while ( game["state"] == "playing" )
	{
		trig waittill( "trigger", player );

		if ( player.pers["team"] == "axis" )
			continue;
		
		if ( !isDefined( level.jumperFinished ) )
			level.jumperFinished = true;
			
		player thread endTimer();
	}
}

watchTimeLimit()
{
    for ( i = level.timeLimit; i > 0; i-- )
    {
        wait 1;
        level.timeLimit = i;
    }

    level thread endRound( "Time Limit Reached", "activator" );
}

spawnPlayer( origin, angles )
{
    if ( game["state"] == "endmap" )
        return;

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
    self.finishedMap = false;
    self.ghost = false;

    self braxi\_teams::setPlayerModel();

    if ( isDefined( origin ) && isDefined( angles ) )
        self spawn( origin, angles );
    else
    {
        spawnPoint = level.spawn[self.pers["team"]][randomInt( level.spawn[self.pers["team"]].size )];
        self spawn( spawnPoint.origin, spawnPoint.angles );
    }

    self braxi\_teams::setHealth();
    self braxi\_teams::setSpeed();
    self braxi\_teams::setLoadout();
    self thread afterFirstFrame();

    self notify( "spawned_player" );
    level notify( "player_spawn", self );
}

afterFirstFrame()
{
    self endon( "disconnect" );
    self endon( "joined_spectators" );
    self endon( "death" );

    waittillframeend;
    wait 0.1;

    if ( !self isPlaying() )
        return;

    // Prevent players from moving before the round starts
    if ( game["state"] == "lobby" )
        self linkTo( level.spawn_link );

    self thread playerTimer();
    self thread watchPlayerHealth();
    self thread drawSpray();
    self thread drawTrail();
}

spawnSpectator( origin, angles )
{
    if ( !isDefined( origin ) )
        origin = ( 0, 0, 0 );

    if ( !isDefined( angles ) )
        angles = ( 0, 0, 0 );

    self notify( "joined_spectators" );

    resettimeout();
    self.sessionstate = "spectator";
    self.spectatorclient = -1;
    self.statusicon = "";

    self spawn( origin, angles );
    self braxi\_teams::setSpectatePermissions();

    level notify( "player_spectator", self );
}

respawnPlayer()
{
    self endon( "disconnect" );
    self endon( "spawned_player" );
    self endon( "joined_spectators" );

    if ( level.freeRun || !game["roundStarted"] )
    {
        wait 0.1;
        self spawnPlayer();
        return;
    }

    if ( game["state"] != "playing" )
        return;

    self iPrintLnBold( "Press ^8G ^7to Practice" );

    if ( self canSpawn() )
    {
        self iPrintLnBold( "Press ^8F ^7to Spawn" );

        while ( true )
        {
            if ( self useButtonPressed() )
                self spawnPlayer();

            if ( self fragButtonPressed() )
                self thread plugins\_ghostrun::spawnGhost();

            wait 0.05;
        }
    }
    else
    {
        while ( true )
        {
            if ( self fragButtonPressed() )
                self thread plugins\_ghostrun::spawnGhost();

            wait 0.05;
        }
    }
}

playerTimer()
{
	self endon( "disconnect" );
	self endon( "death" );

    if ( !level.mapHasTimeTrigger || self.finishedMap )
        return;

    self.time = 0;

    while ( game["state"] != "playing" )
        wait 0.05;

    if ( level.activ == self )
        return;

    while ( game["state"] == "playing" && !self.finishedMap )
    {
        self.time += 1;
        self setClientDvar( "ui_player_timer", formatTimer( self.time ) );
        wait .1;
    }
}

endTimer()
{
    if ( self.finishedMap || game["state"] != "playing" )
        return;

    self.finishedMap = true;

    // TODO: FINISHING PLACE IN PRINTLN

    self iPrintLnBold( "You finished the map in ^8" + formatTimer( self.time ) + " ^7seconds" );

    if ( self.ghost )
    {
        // Prevent ghosts from getting finishing xp more than once
        if ( !isDefined( self.finishedMapOnce ) )
        {
            self.finishedMapOnce = true;
            self braxi\_rank::giveRankXP( "finished_map" );
        }

        self suicide();
        return;
    }

    self braxi\_rank::giveRankXP( "finished_map" );

    if ( self.time < self.pers["time"] )
        self.pers["time"] = self.time;

    entry = self braxi\_leaderboard::getLeaderboardEntry();

    if ( entry != -1 )
    {
        if ( entry == 1 )
            iPrintLnBold( "New WR has been set by " + self.name );

        for ( i = 20; i > entry; i-- )
            game["leaderboard"][i] = game["leaderboard"][i - 1];

        game["leaderboard"][entry]["player"] = self.name;
        game["leaderboard"][entry]["value"] = self.time;
    }

    // update dvars so players can see new records
    players = getAllPlayers();
    for ( i = 0; i < game["leaderboard"].size; i++ )
    {
        for ( j = 0; j < players.size; j++ )
        {
            players[j] setClientDvars(
                "ui_lb_place_" + i + "_player", game["leaderboard"][i]["player"],
                "ui_lb_place_" + i + "_value", formatTimer( game["leaderboard"][i]["value"] )
            );
        }
    }
}

watchPlayerHealth()
{
    self endon( "disconnect" );

    while ( true )
    {
        self waittill_any( "damage", "death" );

        health = ( self.health / self.maxhealth );

        if ( health > 1 )
            health = 1;

        self setClientDvars(
            "ui_health_value", health * self.maxhealth,
            "ui_health_bar", health
        );

        if ( !isAlive( self ) )
            break;
    }
}

updateJumpersHud()
{
    for (;;)
    {
        level waittill_any( "jumper", "player_killed", "activator_chosen" );

        jumpersAlive = 0;
        players = getAllPlayers();

        for ( i = 0; i < players.size; i++ )
        {
            if ( players[i] isPlaying() && players[i].pers["team"] == "allies" && !players[i].ghost )
                jumpersAlive++;
        }

        for ( i = 0; i < players.size; i++ )
            players[i] setClientDvar( "ui_jumpers_alive", jumpersAlive );
    }
}

drawSpray()
{
	self endon( "disconnect" );

    level waittill( "round_started" );

	while ( isAlive( self ) && self isPlaying() )
	{
		while ( !self fragButtonPressed() )
			wait 0.2;

        if ( self.ghost )
            break;

		if ( !self isOnGround() )
		{
			wait 0.2;
			continue;
		}

		angles = self getPlayerAngles();
		eye = self getTagOrigin( "j_head" );
		forward = eye + vector_scale( anglesToForward( angles ), 70 );
		trace = bulletTrace( eye, forward, false, self );

		// Didn't hit a wall or floor
		if ( trace["fraction"] == 1 )
		{
			wait 0.1;
			continue;
		}

		position = trace["position"] - vector_scale( anglesToForward( angles ), -2 );
		angles = vectorToAngles( eye - position );
		forward = anglesToForward( angles );
		up = anglesToUp( angles );

		sprayNum = self getStat( 984 );
		playFx( level.fx_spray[sprayNum]["item"], position, forward, up );
		self playSound( "sprayer" );

		if ( sprayNum == 10 ) // Level up spray
			self thread braxi\_rank::giveRankXP( undefined, 1 );

		self notify( "spray", sprayNum, position, forward, up );
		wait level.dvar["spray_delay"];
	}
}

drawTrail()
{
	self endon( "disconnect" );

	if ( self.pers["team"] == "spectator" || self.ghost )
		return;

	id = self getStat( 985 );
	self.pers["trail"] = level.fx_trail[id];

	if ( isDefined( self.trail ) )
	{
		self.trail unlink();
		self.trail delete();
	}

	if ( self.pers["trail"]["geo"] )
	{
		self.trail = spawn( "script_model", self.origin );
		self.trail setModel( "tag_origin_bitchface" );
		self.trail linkTo( self );

		wait 0.05;

		if ( isDefined( self.trail ) )
			playFxOnTag( self.pers["trail"]["item"], self.trail, "tag_origin" );
	}
	else
	{
		while ( isAlive( self ) && self isPlaying() && level.fx_trail[id] == self.pers["trail"] && id > 0 )
		{
			playFx( self.pers["trail"]["item"], ( self.origin + ( 0, 0, 8 ) ) );

			if ( id == 5 || id == 6 || id == 9 )
				wait 0.4;
			else
				wait 0.05;
		}
	}
}

delayStartRagdoll( ent, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath )
{
    if ( isDefined( ent ) )
    {
        deathAnim = ent getcorpseanim();
        if ( animhasnotetrack( deathAnim, "ignore_ragdoll" ) )
            return;
    }

    wait( 0.2 );

    if ( !isDefined( vDir ) )
        vDir = ( 0, 0, 0 );

    explosionPos = ent.origin + ( 0, 0, getHitLocHeight( sHitLoc ) );
    explosionPos -= vDir * 20;
    explosionRadius = 40;
    explosionForce = .75;

    if ( sMeansOfDeath == "MOD_IMPACT" || sMeansOfDeath == "MOD_EXPLOSIVE" || isSubStr( sMeansOfDeath, "MOD_GRENADE" ) || isSubStr( sMeansOfDeath, "MOD_PROJECTILE" ) || sHitLoc == "object" || sHitLoc == "helmet" )
        explosionForce = 2.9;

    ent startragdoll( 1 );

    wait .05;

    if ( !isDefined( ent ) )
        return;

    // apply extra physics force to make the ragdoll go crazy
    physicsExplosionSphere( explosionPos, explosionRadius, explosionRadius / 2, explosionForce );
    return;
}

deathEffect( fx, sound )
{
    playFx( fx, self.origin + ( 0, 0, 20 ) );
    self playSound( sound );
    self delete();
}

antiAFK()
{
    self endon( "disconnect" );
    self endon( "spawned_player" );
    self endon( "joined_spectators" );

    time = 0;
    oldOrigin = self.origin - ( 0, 0, 50 );
    warnDelay = 20;
    killDelay = 25;

    while ( self isPlaying() )
    {
        wait 0.2;

        if ( distance( oldOrigin, self.origin ) <= 10 )
            time++;
        else
            time = 0;

        if ( time == ( warnDelay * 5 ) )
            self iPrintlnBold( "Move or you will be killed due to AFK" );

        if ( time == ( killDelay * 5 ) )
        {
            iPrintln( self.name + " was killed due to AFK." );
            self suicide();
            break;
        }

        oldOrigin = self.origin;
    }
}

addTextHud( who, x, y, alpha, alignX, alignY, fontScale, fontType )
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

drawInformation( start_offset, movetime, mult, text )
{
	start_offset *= mult;

	hud = new_ending_hud( "center", 0.1, start_offset, 90 );
	hud setText( text );
	hud moveOverTime( movetime );
	hud.x = 0;

	wait( movetime );
	wait( 3 );

	hud moveOverTime( movetime );
	hud.x = start_offset * -1;

	wait movetime;

	hud destroy();
}