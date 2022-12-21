#include braxi\_utility;

playerConnect()
{
	level notify( "connected", self );

	self.guid = self getGuid();
	self.number = self getEntityNumber();
	self.statusicon = "hud_status_connecting";
	self.died = false;
	self.notifying = false;
	self.notifications = [];

	if ( !isDefined( self.pers["team"] ) )
	{
		iPrintln( self.name + " ^7entered the game" );

		self.sessionstate = "spectator";
		self.team = "spectator";
		self.pers["team"] = "spectator";

		self.pers["score"] = 0;
		self.pers["kills"] = 0;
		self.pers["deaths"] = 0;
		self.pers["assists"] = 0;
		self.pers["headshots"] = 0;
		self.pers["knifes"] = 0;
	}
	else
	{
		self.score = self.pers["score"];
		self.kills = self.pers["kills"];
		self.assists = self.pers["assists"];
		self.deaths = self.pers["deaths"];
	}

	if ( !isDefined( level.spawn["spectator"][0] ) )
		level.spawn["spectator"][0] = level.spawn["allies"][0];

	self setClientDvars(
		"bg_bobamplitudesprinting", 0,
		"bg_bobamplitudeducked", 0,
		"bg_bobamplitudeprone", 0,
		"bg_bobamplitudestanding", 0,
		"cg_drawSpectatorMessages", 1,
		"g_scriptMainMenu", game["menu_team"],
		"ip", getDvar( "net_ip" ),
		"player_sprintTime", 12.8,
		"port", getDvar( "net_port" ),
		"show_hud", true,
		"ui_menu_playername", self.name,
		"ui_rounds_limit", level.dvar["roundslimit"],
		"ui_rounds_played", game["roundsplayed"],
		"ui_uav_client", 0
	);

	self setClientDvar( "cg_fovscale", 1.15 );

	if ( self.name.size > 8 )
		self setClientDvar( "ui_menu_playername", getSubStr( self.name, 0, 7 ) + "..." );

	if ( game["state"] == "endmap" )
	{
		self playerSpawnSpectator( level.spawn["spectator"][0].origin, level.spawn["spectator"][0].angles );
		return;
	}

	if ( isDefined( self.pers["weapon"] ) && self.pers["team"] != "spectator" )
	{
		self thread braxi\_teams::setTeam( "allies" );
		playerSpawn();
	}
	else
	{
		self playerSpawnSpectator( level.spawn["spectator"][0].origin, level.spawn["spectator"][0].angles );
		wait .05;
		self openMenu( game["menu_team"] );
		logPrint( "J;" + self.guid + ";" + self.number + ";" + self.name + "\n" );
	}
}

playerSpawn( origin, angles )
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
	level.jumpersAlive++;

	self braxi\_teams::setPlayerModel();

	if ( isDefined( origin ) && isDefined( angles ) )
		self spawn( origin, angles );
	else
	{
		spawnPoint = level.spawn[self.pers["team"]][randomInt( level.spawn[self.pers["team"]].size )];
		self spawn( spawnPoint.origin, spawnPoint.angles );
	}

	self braxi\_teams::setLoadout();

	self notify( "spawned_player" );
	level notify( "player_spawn", self );
}

playerSpawnSpectator( origin, angles )
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
	self braxi\_teams::setSpectatePermissions( true, true, true, true );

	level notify( "player_spectator", self );
}

PlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	if ( self.sessionteam == "spectator" ) return;

	level notify( "player_damage", self, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

	if ( isPlayer( eAttacker ) && eAttacker.pers["team"] == self.pers["team"] ) return;

	if ( !isDefined( vDir ) )
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

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

	if ( self isAlive() && self.pers["team"] != "axis" )
		level.jumpersAlive--;

	level notify( "player_killed", self, eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );

	if ( self.sessionteam == "spectator" ) return;

	self.statusicon = "hud_status_dead";
	self.sessionstate = "spectator";
	self.died = true;

	if ( isPlayer( attacker ) )
	{
		if ( attacker != self )
		{
			braxi\_rank::processXpReward( sMeansOfDeath, attacker, self );
			attacker.kills++;
			attacker.pers["kills"]++;
		}
	}

	if ( level.practice )
	{
		wait .05; // No die handler fix
		self playerSpawn();
	}
	else if ( !level.practice && game["state"] == "playing" )
	{
		self.deaths++;
		self.pers["deaths"]++;
		deaths = self maps\mp\gametypes\_persistence::statGet( "deaths" );
		self maps\mp\gametypes\_persistence::statSet( "deaths", deaths + 1 );
		obituary( self, attacker, sWeapon, sMeansOfDeath );
	}
}

playerDisconnect()
{
	level notify( "disconnected", self );

	logPrint( "Q;" + self getGuid() + ";" + self getEntityNumber() + ";" + self.name + "\n" );
}