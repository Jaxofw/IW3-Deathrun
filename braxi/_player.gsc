#include maps\mp\_utility;
#include common_scripts\utility;
#include braxi\_utility;

PlayerConnect()
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
		self.pers["time"] = 99999;
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

	if ( self getStat( 991 ) == 1 )
		self thread clientCmd( "snd_stopambient" );

	self setClientDvars(
		"bg_bobamplitudesprinting", 0,
		"bg_bobamplitudeducked", 0,
		"bg_bobamplitudeprone", 0,
		"bg_bobamplitudestanding", 0,
		"cg_drawSpectatorMessages", 1,
		"ip", getDvar( "net_ip" ),
		"player_sprintTime", 12.8,
		"port", getDvar( "net_port" ),
		"show_hud", true,
		"ui_exp_event", level.xpEvent,
		"ui_menu_playername", self.name,
		"ui_player_timer", formatTimer( 0 ),
		"ui_rounds_limit", level.dvar["roundslimit"],
		"ui_rounds_played", game["roundsplayed"],
		"ui_spray_selected", self getStat( 984 ),
		"ui_uav_client", 0
	);

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

	if ( game["state"] == "lobby" )
		self linkTo( level.spawn_link );

	self braxi\_teams::setLoadout();
	self thread braxi\_weapons::watchWeapons();
	self thread watchHealth();
	self thread sprayLogo();
	self thread trailFx();

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

	if ( isDefined( eAttacker ) && isPlayer( eAttacker ) )
	{
		if ( eAttacker.pers["team"] == self.pers["team"] )
		{
			if ( eAttacker getStat( 994 ) == 0 || eAttacker getStat( 994 ) == 2 )
				eAttacker thread hitmarker();
			return;
		}
		else
		{
			if ( eAttacker getStat( 994 ) == 0 || eAttacker getStat( 994 ) == 1 )
				eAttacker thread hitmarker();
		}
	}

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

	if ( isDefined( self.trail ) )
	{
		self.trail unlink();
		self.trail delete();
	}

	level notify( "player_killed", self, eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );

	if ( self.sessionteam == "spectator" || game["state"] == "endmap" )
		return;

	self.statusicon = "hud_status_dead";
	self.sessionstate = "spectator";
	self.died = true;

	if ( sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE" )
		sMeansOfDeath = "MOD_HEAD_SHOT";

	if ( game["state"] == "playing" )
	{
		obituary( self, attacker, sWeapon, sMeansOfDeath );
		self.deaths++;
		self.pers["deaths"]++;
		deaths = self maps\mp\gametypes\_persistence::statGet( "deaths" );
		self maps\mp\gametypes\_persistence::statSet( "deaths", deaths + 1 );
	}

	if ( isPlayer( attacker ) )
	{
		if ( attacker != self )
		{
			braxi\_rank::processXpReward( sMeansOfDeath, attacker, self );
			attacker.kills++;
			attacker.pers["kills"]++;
		}
	}

	if ( game["state"] == "endround" )
		return;

	if ( level.practice || game["state"] == "waiting" || game["state"] == "lobby" )
	{
		wait .05; // No die handler fix
		self playerSpawn();
	}
}

PlayerDisconnect()
{
	level notify( "disconnected", self );

	logPrint( "Q;" + self getGuid() + ";" + self getEntityNumber() + ";" + self.name + "\n" );
}

watchHealth()
{
	self endon( "disconnect" );
	self setClientDvar( "ui_health_text", 100 );
	self setClientDvar( "ui_health_bar", 1 );

	while ( 1 )
	{
		self waittill( "damage", amount );
		health = ( self.health / self.maxhealth );
		if ( health > 1 ) health = 1;

		self setClientDvars(
			"ui_health_text", health * 100,
			"ui_health_bar", health
		);
	}
}

playerTimer()
{
	self endon( "disconnect" );
	self endon( "death" );

	if ( !level.mapHasTimeTrigger || isDefined( self.finishedMap ) || self.pers["team"] == "axis" )
		return;

	while ( game["state"] != "playing" )
		wait .05;

	self.time = 0;

	while ( game["state"] == "playing" && !isDefined( self.finishedMap ) )
	{
		self.time += 1;
		self setClientDvar( "ui_player_timer", formatTimer( self.time ) );
		wait .1;
	}
}

endTimer()
{
	if ( isDefined( self.finishedMap ) || game["state"] != "playing" )
		return;

	self.finishedMap = true;

	self iPrintLn( "Your Time: " + formatTimer( self.time ) );

	if ( self.time < self.pers["time"] )
		self.pers["time"] = self.time;
}

hitmarker()
{
	self playLocalSound( "MP_hit_alert" );
	self.hud_damagefeedback.alpha = 1;
	self.hud_damagefeedback fadeOverTime( 1 );
	self.hud_damagefeedback.alpha = 0;
}

sprayLogo()
{
	self endon( "disconnect" );

	while ( game["state"] != "playing" )
		wait .05;

	while ( self isAlive() )
	{
		while ( !self fragButtonPressed() )
			wait .2;

		if ( !self isOnGround() )
		{
			wait .2;
			continue;
		}

		angles = self getPlayerAngles();
		eye = self getTagOrigin( "j_head" );
		forward = eye + vector_scale( anglesToForward( angles ), 70 );
		trace = bulletTrace( eye, forward, false, self );

		// Didn't hit a wall or floor
		if ( trace["fraction"] == 1 )
		{
			wait .1;
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
			self thread braxi\_rank::giveRankXP( "", 1 );

		self notify( "spray", sprayNum, position, forward, up );
		wait level.dvar["spray_delay"];
	}
}

trailFx()
{
	self endon( "disconnect" );

	if ( self.pers["team"] == "spectator" )
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

		wait .05;

		if ( isDefined( self.trail ) )
			playFxOnTag( self.pers["trail"]["item"], self.trail, "tag_origin" );
	}
	else
	{
		while ( self isAlive() && level.fx_trail[id] == self.pers["trail"] && id > 0 )
		{
			playFx( self.pers["trail"]["item"], ( self.origin + ( 0, 0, 8 ) ) );

			if ( id == 5 || id == 6 || id == 9 )
				wait .4;
			else
				wait .05;
		}
	}
}