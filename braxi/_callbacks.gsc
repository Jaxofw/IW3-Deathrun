#include braxi\_common;

playerConnect()
{
	level notify( "connected", self );

	self.guid = self getGuid();
	self.number = self getEntityNumber();
	self.statusicon = "";
	self.died = false;
	self.notifying = false;
	self.notifications = [];

	if ( !isDefined( self.pers["team"] ) )
	{
		iPrintLn( self.name + " ^7entered the game" );

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
		self.pers["lifes"] = 0;
	}
	else
	{
		// Prevent from being auto assigned to opfor
		if ( self.pers["team"] != "spectator" )
			self braxi\_teams::setTeam( "allies" );

		self.score = self.pers["score"];
		self.kills = self.pers["kills"];
		self.assists = self.pers["assists"];
		self.deaths = self.pers["deaths"];
	}

	if ( !isDefined( level.spawn["spectator"] ) )
		level.spawn["spectator"] = level.spawn["allies"][0];

	if ( self.name.size > 8 )
		self setClientDvar( "ui_menu_playername", getSubStr( self.name, 0, 7 ) + "..." );

	if ( self getStat( 991 ) == 1 )
		self thread clientCmd( "snd_stopambient" );

	if ( game["state"] == "endmap" )
	{
		self braxi\_mod::spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
		self.sessionstate = "intermission";
		return;
	}

	if ( self.pers["team"] == "allies" )
		self braxi\_mod::spawnPlayer();
	else
	{
		self braxi\_mod::spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
		wait 0.05; // Needed for menu_team to open
		self openMenu( game["menu_team"] );
	}

	self setClientDvars(
		"bg_bobamplitudesprinting", 0,
		"bg_bobamplitudeducked", 0,
		"bg_bobamplitudeprone", 0,
		"bg_bobamplitudestanding", 0,
		"cg_drawSpectatorMessages", 1,
		"motd", level.dvar["motd"],
		"player_sprintTime", 12.8,
		"show_hud", true,
		"ui_menu_playername", self.name,
		"ui_game_state", game["state"],
		"ui_rounds_played", game["roundsplayed"],
		"ui_rounds_limit", level.dvar["round_limit"],
		"ui_spray_selected", self getStat( 984 ),
		"ui_time_left", level.dvar["time_limit"],
		"ui_player_timer", formatTimer( 0 )
	);
}

playerDisconnect()
{
	level notify( "disconnected", self );

	iPrintLn( self.name + " ^7left the game" );
}

playerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	if ( self.sessionteam == "spectator" || game["state"] == "endmap" )
		return;

	if ( self.ghost )
	{
		if ( sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_UNKNOWN" || sMeansofDeath == "MOD_TRIGGER_HURT" || sMeansofDeath == "MOD_SUICIDE" )
		{
			if ( sMeansOfDeath == "MOD_FALLING" && iDamage < 50 )
				return;

			origin = level.spawn["allies"][randomInt( level.spawn["allies"].size )].origin;
			self setOrigin( origin );
			return;
		}
		else
			return;
	}

	if ( isPlayer( eAttacker ) )
	{
		if ( eAttacker.pers["team"] == self.pers["team"] )
		{
			if ( eAttacker getStat( 994 ) == 0 || eAttacker getStat( 994 ) == 2 )
				eAttacker thread drawHitmarker();

			return;
		}
		else
		{
			if ( eAttacker getStat( 994 ) == 0 || eAttacker getStat( 994 ) == 1 )
				eAttacker thread drawHitmarker();
		}
	}

	if ( isPlayer( eAttacker ) && sMeansOfDeath == "MOD_MELEE" && isKnifingWall( eAttacker, self ) )
		return;

	// Prevent taking damage before round starts
	if ( !game["roundStarted"] )
		return;

	level notify( "player_damage", self, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

	if ( !isDefined( vDir ) )
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	if ( !( iDFlags & level.iDFLAGS_NO_PROTECTION ) )
	{
		if ( iDamage < 1 )
			iDamage = 1;

		self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
	}
}

playerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	self endon( "spawned" );
	self notify( "killed_player" );
	self notify( "death" );

	if ( isDefined( self.trail ) )
	{
		self.trail unlink();
		self.trail delete();
	}

	if ( self.ghost )
	{
		self.ghost = false;
		self setClientDvar( "ui_practice_state", false );
	}

	if ( self.sessionteam == "spectator" || game["state"] == "endmap" )
		return;

	level notify( "player_killed", self, eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );

	if ( !level.trapsDisabled )
	{
		if ( isDefined( level.activ ) && level.activ != self && level.activ isPlaying() && !self.ghost )
		{
			if ( sMeansOfDeath == "MOD_UNKNOWN" || sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_SUICIDE" || sMeansOfDeath == "MOD_TRIGGER_HURT" )
				level.activ braxi\_rank::giveRankXP( "jumper_died" );
		}
	}

	if ( sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE" )
		sMeansOfDeath = "MOD_HEAD_SHOT";

	body = self clonePlayer( deathAnimDuration );

	if ( iDamage >= self.maxhealth && sMeansOfDeath != "MOD_MELEE" && sMeansOfDeath != "MOD_RIFLE_BULLET" && sMeansOfDeath != "MOD_PISTOL_BULLET" && sMeansOfDeath != "MOD_SUICIDE" && sMeansOfDeath == "MOD_HEAD_SHOT" )
		body braxi\_mod::deathEffect( level.fx["death_gib"], "gib_splat" );
	else
	{
		if ( self isOnLadder() || self isMantling() )
			body startRagDoll();

		thread braxi\_mod::delayStartRagdoll( body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath );
	}

	self.statusicon = "hud_status_dead";
	self.sessionstate = "spectator";

	if ( isPlayer( attacker ) && attacker != self )
	{
		braxi\_rank::processXpReward( sMeansOfDeath, attacker, self );

		attacker.kills++;
		attacker.pers["kills"]++;

		if ( self.pers["team"] == "axis" )
			attacker braxi\_mod::giveLife();
	}

	self.died = true;

	if ( !level.freeRun && !self.ghost )
	{
		deaths = self maps\mp\gametypes\_persistence::statGet( "deaths" );
		self maps\mp\gametypes\_persistence::statSet( "deaths", deaths + 1 );
		self.deaths++;
		self.pers["deaths"]++;
		obituary( self, attacker, sWeapon, sMeansOfDeath );
	}

	if ( self.pers["team"] == "axis" )
	{
		if ( isPlayer( attacker ) && attacker.pers["team"] == "allies" )
		{
			text = attacker.name + " ^7killed Activator";
			thread braxi\_mod::drawInformation( 800, 0.8, -1, text );
		}
	}

	if ( self.pers["team"] == "allies" )
		self thread braxi\_mod::respawnPlayer();
}