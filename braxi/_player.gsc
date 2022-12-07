playerConnect()
{
	level notify( "connected", self );

	self.guid = self getGuid();
	self.number = self getEntityNumber();
	self.statusicon = "hud_status_connecting";
	self.died = false;
	self.notifying = false;
	self.notifications = [];

	self setClientDvars(
		"bg_bobamplitudesprinting", 0,
		"bg_bobamplitudeducked", 0,
		"bg_bobamplitudeprone", 0,
		"bg_bobamplitudestanding", 0,
		"cg_drawSpectatorMessages", 1,
		"ip", getDvar( "net_ip" ),
		"port", getDvar( "net_port" ),
		"show_hud", true,
		"ui_menu_playername", self.name,
		"ui_uav_client", 0 );

	if ( self.name.size > 8 ) self setClientDvar( "ui_menu_playername", getSubStr( self.name, 0, 7 ) + "..." );

	if ( !isDefined( self.pers["team"] ) )
	{
		iPrintLn( self.name + " ^7connected" );

		self.sessionstate = "playing";
		self.team = "allies";
		self.pers["team"] = "allies";
		self.pers["score"] = 0;
		self.pers["kills"] = 0;
		self.pers["deaths"] = 0;
		self.pers["assists"] = 0;
	}
	else
	{
		self.score = self.pers["score"];
		self.kills = self.pers["kills"];
		self.assists = self.pers["assists"];
		self.deaths = self.pers["deaths"];
	}

	if ( !isDefined( level.spawn["spectator"] ) )
		level.spawn["spectator"] = level.spawn["allies"][0];

	if ( self.pers["team"] != "spectator" )
		self playerSpawn();
	else
		self playerSpawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
}

playerSpawn( origin, angles )
{
	self endon( "spawned_player" );
	self endon( "joined_spectators" );

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

	if ( isDefined( origin ) && isDefined( angles ) )
		self spawn( origin, angles );
	else
	{
		spawnPoint = level.spawn[self.pers["team"]][randomInt( level.spawn[self.pers["team"]].size )];
		self spawn( spawnPoint.origin, spawnPoint.angles );
	}

	if ( game["state"] == "lobby" ) self linkTo( level.spawn_link );

	if ( self.team != "spectator" ) self braxi\_teams::setLoadout();

	self notify( "spawned_player" );
	level notify( "player_spawn", self );
}

playerSpawnSpectator( origin, angles )
{
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

PlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	if ( self.sessionteam == "spectator" ) return;

	level notify( "player_damage", self, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

	if ( isPlayer( eAttacker ) && eAttacker.pers["team"] == self.pers["team"] ) return;

	if ( !isDefined( vDir ) ) iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	if ( !( iDFlags & level.iDFLAGS_NO_PROTECTION ) )
	{
		if ( iDamage < 1 ) iDamage = 1;
		self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
	}
}

PlayerLastStand( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	self suicide();
}

PlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	self notify( "killed_player" );
	self notify( "death" );

	if ( self.sessionteam == "spectator" ) return;

	level notify( "player_killed", self, eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );

	self.statusicon = "hud_status_dead";
	self.sessionstate = "spectator";
	self.died = true;

	if ( !level.freerun )
	{
		self.deaths++;
		self.pers["deaths"]++;
		deaths = self maps\mp\gametypes\_persistence::statGet( "deaths" );
		self maps\mp\gametypes\_persistence::statSet( "deaths", deaths + 1 );
		obituary( self, attacker, sWeapon, sMeansOfDeath );
	}

	if ( level.freerun || game["state"] != "playing" ) {
		wait .05; // No die handler fix
		self playerSpawn();
	}
}

playerDisconnect()
{
	level notify( "disconnected", self );

	if ( !isDefined( self.name ) )
		iPrintLn( self.name + " ^7disconnected" );

	logPrint( "Q;" + self getGuid() + ";" + self getEntityNumber() + ";" + self.name + "\n" );
}