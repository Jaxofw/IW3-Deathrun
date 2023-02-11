preCache()
{
	preCacheItem( "claymore_mp" );
	preCacheShader( "white" );
	preCacheShader( "hud_notify" );
	preCacheShader( "ui_footer" );
    preCacheStatusIcon( "hud_status_connecting" );
	preCacheStatusIcon( "hud_status_dead" );

	// Death FX
	level.fx = [];
	level.fx["death_gib"] = loadFx( "death/gib_splat" );

    buildJumperTable();
	buildActivatorTable();
	buildPrimaryTable();
	buildSecondaryTable();
	buildGloveTable();
	buildSprayTable();
	buildTrailTable();
}

buildJumperTable()
{
	level.model_jumper = [];
	tableName = "mp/jumperTable.csv";

	for ( idx = 1; isDefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.model_jumper[id]["rank"] = ( int( tableLookup( tableName, 0, idx, 2 ) ) - 1 );
		level.model_jumper[id]["item"] = tableLookup( tableName, 0, idx, 3 );
		level.model_jumper[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		preCacheModel( level.model_jumper[id]["item"] );
	}
}

buildActivatorTable()
{
	level.activatorModels = [];
	tableName = "mp/activatorTable.csv";

	for ( idx = 1; isDefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.model_activator[id]["rank"] = ( int( tableLookup( tableName, 0, idx, 2 ) ) - 1 );
		level.model_activator[id]["item"] = tableLookup( tableName, 0, idx, 3 );
		level.model_activator[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		preCacheModel( level.model_activator[id]["item"] );
	}
}

buildPrimaryTable()
{
	level.weapon_primary = [];
	tableName = "mp/primaryTable.csv";

	for ( idx = 1; isDefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.weapon_primary[id]["rank"] = ( int( tableLookup( tableName, 0, idx, 2 ) ) - 1 );
		level.weapon_primary[id]["item"] = ( tableLookup( tableName, 0, idx, 3 ) + "_mp" );
		level.weapon_primary[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		preCacheItem( level.weapon_primary[id]["item"] );
	}
}

buildSecondaryTable()
{
	level.weapon_secondary = [];
	tableName = "mp/secondaryTable.csv";

	for ( idx = 1; isDefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.weapon_secondary[id]["rank"] = ( int( tableLookup( tableName, 0, idx, 2 ) ) - 1 );
		level.weapon_secondary[id]["item"] = ( tableLookup( tableName, 0, idx, 3 ) + "_mp" );
		level.weapon_secondary[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		preCacheItem( level.weapon_secondary[id]["item"] );
	}
}

buildGloveTable()
{
	level.model_glove = [];
	tableName = "mp/gloveTable.csv";

	for ( idx = 1; isDefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.model_glove[id]["rank"] = ( int( tableLookup( tableName, 0, idx, 2 ) ) - 1 );
		level.model_glove[id]["item"] = tableLookup( tableName, 0, idx, 3 );
		level.model_glove[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		preCacheModel( level.model_glove[id]["item"] );
	}
}

buildSprayTable()
{
	level.fx_spray = [];
	tableName = "mp/sprayTable.csv";

	for ( idx = 1; isDefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.fx_spray[id]["rank"] = ( int( tableLookup( tableName, 0, idx, 2 ) ) - 1 );
		level.fx_spray[id]["item"] = loadFx( tableLookup( tableName, 0, idx, 3 ) );
	}
}

buildTrailTable()
{
	level.fx_trail = [];
	tableName = "mp/trailTable.csv";

	for ( idx = 1; isDefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.fx_trail[id]["rank"] = ( int( tableLookup( tableName, 0, idx, 2 ) ) - 1 );
		level.fx_trail[id]["item"] = loadFx( tableLookup( tableName, 0, idx, 3 ) );
		level.fx_trail[id]["name"] = tableLookup( tableName, 0, idx, 4 );
		level.fx_trail[id]["geo"] = int( tableLookup( tableName, 0, idx, 5 ) );
	}
}

waitForPlayers()
{
	playersNeeded = 2;
	playersReady = 0;

	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		if ( players[i] isPlaying() )
			playersReady++;
	}

	if ( playersReady >= playersNeeded )
		return;

	if ( !level.freeRun )
		thread updateGameState( "waiting" );

	while ( true )
	{
		players = getAllPlayers();
		playersReady = 0;

		for ( i = 0; i < players.size; i++ )
		{
			if ( players[i] isPlaying() )
				playersReady++;			
		}

		if ( playersReady >= playersNeeded )
			break;

		wait 0.1;
	}

	map_restart( true );
}

updateGameState( state )
{
	game["state"] = state;

	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ )
		players[i] setClientDvar( "ui_game_state", state );
}

getAllPlayers()
{
	return getEntArray( "player", "classname" );
}

isPlaying()
{
	return self.sessionstate == "playing";
}

canSpawn()
{
	if ( level.freeRun || self.pers["lifes"] )
		return true;

	if ( game["state"] == "playing" || game["state"] == "endround" || game["state"] == "endmap" )
		return false;

	if ( self.died )
		return false;

	return true;
}

canStartRound()
{
    players = getAllPlayers();
    playersReady = 0;

    for ( i = 0; i < players.size; i++ )
    {
        if ( isAlive( players[i] ) && players[i] isPlaying() )
       		playersReady++;
    }

    return playersReady >= 2;
}

hasBeenActivator( player )
{
	if ( game["pastActivators"].size >= level.jumpers.size )
		game["pastActivators"] = [];

	if ( game["lastActivator"] == player.guid )
		return true;

	for ( i = 0; i < game["pastActivators"].size; i++ )
		if ( game["pastActivators"][i] == player.guid )
			return true;

	return false;
}

formatTimer( msec )
{
	msecs = msec % 10;
	useconds = int( msec / 10 );
	seconds = useconds % 60;
	minutes = int( useconds / 60 );

	if ( seconds < 10 )
		return minutes + ":0" + seconds + "." + msecs;
	else
		return minutes + ":" + seconds + "." + msecs;
}

spawnCollision( origin, height, width )
{
	id = level.colliders.size;
	level.colliders[id] = spawn( "trigger_radius", origin, 0, width, height );
	level.colliders[id].targetname = "script_collision";
	level.colliders[id] setContents( 1 );
}

clientCmd( dvar )
{
	self setClientDvar( "clientcmd", dvar );
	self openMenu( game["menu_clientcmd"] );

	if ( isDefined( self ) )
		self closeMenu( game["menu_clientcmd"] );
}

// https://gist.github.com/atrX/038af95994b868b7c641
toFloat( in )
{
	// Don't accept arrays or undefined, return 0
	if ( isArray( in ) || !isDefined( in ) )
		return 0;

	// Return original argument, it's not a string so doesn't need any special type conversion algorithm
	if ( !isString( in ) )
		return in;

	// Split string into 2 seperate strings
	if ( isSubStr( in, "," ) ) // Would be great if people wouldn't use fucking commas for decimals where I live
		num = strTok( in, "," );
	else
		num = strTok( in, "." );

	// Don't need to execute extra logic if the number isn't a decimal and therefore wasn't split into a multi-element array
	if ( num.size <= 1 )
		return int( num[0] );

	pwr = 10;
	// Multiply by 10 for each extra character
	// Initialize i as 1, we don't need to multiply on the first index
	for ( i = 1; i < num[1].size; i++ )
		pwr *= 10;

	return int( num[0] ) + int( num[1] ) / pwr;
}

notification( notification )
{
	self endon( "disconnect" );

	if ( !self.notifying )
	{
		self thread showNotification( notification );
		return;
	}

	self.notifications[self.notifications.size] = notification;
}

showNotification( notification )
{
	self endon( "disconnect" );

	self.notifying = true;
	self.notification = [];

	self.notification[0] = newClientHudElem( self );
	self.notification[1] = newClientHudElem( self );
	self.notification[2] = braxi\_mod::addTextHud( self, -300, 104, 1, "center", "middle", 1.4 );
	self.notification[3] = braxi\_mod::addTextHud( self, -300, 122, 1, "center", "middle", 1.4 );

	if ( isDefined( notification.levelUp ) )
	{
		self.notification[0].x = -300;
		self.notification[0].y = 90;
		self.notification[1].x = -300;
		self.notification[1].y = 133;
	}
	else
	{
		self.notification[0].x = 270;
		self.notification[0].y = 70;
		self.notification[1].x = 271;
		self.notification[1].y = 113;
		self.notification[2].x = 320;
		self.notification[2].y = 84;
		self.notification[3].x = 320;
		self.notification[3].y = 102;
	}

	if ( isDefined( notification.sound ) )
		self playSound( notification.sound );

	self.notification[0].alpha = .6;
	self.notification[0].sort = 990;
	self.notification[0].hideWhenInMenu = true;
	self.notification[0].horzAlign = "fullscreen";
	self.notification[0].vertAlign = "fullscreen";
	self.notification[0] setShader( "hud_notify", 100, 45 );

	self.notification[1].alpha = 1;
	self.notification[1].sort = 991;
	self.notification[1].hideWhenInMenu = true;
	self.notification[1].horzAlign = "fullscreen";
	self.notification[1].vertAlign = "fullscreen";
	self.notification[1] setShader( "ui_footer", 98, 2 );

	self.notification[2].font = "default";
	self.notification[2].sort = 992;
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

	if ( isDefined( notification.levelUp ) )
	{
		self moveNotifElements( 240, 241, 290, 290, 0.2 );
		wait .3;
		self moveNotifElements( 300, 301, 350, 350, 3.0 );
		wait 2;
		self moveNotifElements( 670, 671, 720, 720, 0.2 );
	}
	else
	{
		for ( i = 0; i < self.notification.size; i++ )
		{
			self.notification[i].alpha = 0;
			self.notification[i] fadeOverTime( 1 );

			if ( i == 0 )
				self.notification[i].alpha = 0.6;
			else
				self.notification[i].alpha = 1;
		}

		wait 4;

		for ( i = 0; i < self.notification.size; i++ )
		{
			self.notification[i] fadeOverTime( 1 );
			self.notification[i].alpha = 0;
		}
	}

	wait .8;

	for ( i = 0; i < self.notification.size; i++ )
		self.notification[i] destroy();

	self.notification = undefined;
	self.notifying = false;

	if ( self.notifications.size > 0 )
	{
		nextNotification = self.notifications[0];

		for ( i = 1; i < self.notifications.size; i++ )
			self.notifications[i - 1] = self.notifications[i];

		self.notifications[i - 1] = undefined;
		self thread showNotification( nextNotification );
	}
}

moveNotifElements( x1, x2, x3, x4, time )
{
	for ( i = 0; i < self.notification.size; i++ )
	{
		self.notification[i] moveOverTime( time );
		if ( i == 0 ) self.notification[i].x = x1;
		if ( i == 1 ) self.notification[i].x = x2;
		if ( i == 2 ) self.notification[i].x = x3;
		if ( i == 3 ) self.notification[i].x = x4;
	}
}

isKnifingWall( attacker, victim )
{
	return !bulletTracePassed( attacker getEye(), victim getEye(), false, attacker );
}

drawHitmarker()
{
	self playLocalSound( "MP_hit_alert" );
	self.hud_damagefeedback.alpha = 1;
	self.hud_damagefeedback fadeOverTime( 1 );
	self.hud_damagefeedback.alpha = 0;
}

playSound( sound, entity )
{
	if ( isDefined( entity ) && isPlayer( entity ) )
		entity playLocalSound( sound );
	else
	{
		players = getAllPlayers();
		for ( i = 0; i < players.size; i++ )
			players[i] playLocalSound( sound );
	}
}

new_ending_hud( align, fade_in_time, x_off, y_off )
{
	hud = newHudElem();

	hud.foreground = true;
	hud.x = x_off;
	hud.y = y_off;
	hud.alignX = align;
	hud.alignY = "middle";
	hud.horzAlign = align;
	hud.vertAlign = "middle";
	hud.fontScale = 2.5;
	hud.color = ( 1, 1, 1 );
	hud.font = "objective";
	hud.glowColor = ( 0.2, 0.6, 0.9 );
	hud.glowAlpha = 1;
	hud.hidewheninmenu = true;
	hud.sort = 10;

	hud.alpha = 0;
	hud fadeovertime( fade_in_time );
	hud.alpha = 1;

	return hud;
}

bounce( pos, power )
{
	oldhp = self.health;
	self.health = self.health + power;
	self setClientDvars( "bg_viewKickMax", 0, "bg_viewKickMin", 0, "bg_viewKickRandom", 0, "bg_viewKickScale", 0 );
	self finishPlayerDamage( self, self, power, 0, "MOD_PROJECTILE", "none", undefined, pos, "none", 0 );
	self.health = oldhp;
	self thread bounce2();
}

bounce2()
{
	self endon( "disconnect" );
	wait .05;
	self setClientDvars( "bg_viewKickMax", 90, "bg_viewKickMin", 5, "bg_viewKickRandom", 0.4, "bg_viewKickScale", 0.2 );
}

getHitLocHeight( sHitLoc )
{
    switch ( sHitLoc )
    {
        case "helmet":
        case "object":
        case "neck":
            return 60;
        case "torso_upper":
        case "right_arm_upper":
        case "left_arm_upper":
        case "right_arm_lower":
        case "left_arm_lower":
        case "right_hand":
        case "left_hand":
        case "gun":
            return 48;
        case "torso_lower":
            return 40;
        case "right_leg_upper":
        case "left_leg_upper":
            return 32;
        case "right_leg_lower":
        case "left_leg_lower":
            return 10;
        case "right_foot":
        case "left_foot":
            return 5;
    }

    return 48;
}

formatMapName( map )
{
	formattedName = "";
	index = 6;

	if ( map[4] == "e" ) index = 12;

	for ( j = index; j < map.size; j++ )
	{
		if ( j == index ) formattedName += toUpper( map[j] );
		else
		{
			if ( foundUnderscore( map[j] ) )
			{
				formattedName += " " + toUpper( map[j + 1] );
				j++;
			}
			else formattedName += map[j];
		}
	}

	return formattedName;
}

foundUnderscore( letter )
{
	switch ( letter )
	{
		case "_":
			return true;
		default:
			return false;
	}
}

toUpper( letter )
{
	switch ( letter )
	{
		case "a":
			return "A";
		case "b":
			return "B";
		case "c":
			return "C";
		case "d":
			return "D";
		case "e":
			return "E";
		case "f":
			return "F";
		case "g":
			return "G";
		case "h":
			return "H";
		case "i":
			return "I";
		case "j":
			return "J";
		case "k":
			return "K";
		case "l":
			return "L";
		case "m":
			return "M";
		case "n":
			return "N";
		case "o":
			return "O";
		case "p":
			return "P";
		case "q":
			return "Q";
		case "r":
			return "R";
		case "s":
			return "S";
		case "t":
			return "T";
		case "u":
			return "U";
		case "v":
			return "V";
		case "w":
			return "W";
		case "x":
			return "X";
		case "y":
			return "Y";
		case "z":
			return "Z";
		default:
			return letter;
	}
}

waitTillNotMoving()
{
	prevorigin = self.origin;
	while ( isDefined( self ) )
	{
		wait .15;

		if ( self.origin == prevorigin )
			break;

		prevorigin = self.origin;
	}
}

critical( id )
{
	CriticalSection( id );
}

critical_enter( id )
{
	while ( !EnterCriticalSection( id ) )
		wait 0.05;
}

critical_leave( id )
{
	LeaveCriticalSection( id );
}

AsyncWait( request )
{
	status = AsyncStatus( request );

	while ( status <= 1 )
	{
		wait 0.05;
		status = AsyncStatus( request );
	}

	return status;
}