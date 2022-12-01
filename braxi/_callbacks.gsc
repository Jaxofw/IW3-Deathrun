playerConnect() {
	level notify( "connected", self );

	self.guid = self getGuid();
	self.number = self getEntityNumber();
	self.statusicon = "hud_status_connecting";
	self.died = false;
	self.notifying = false;
	self.notifications = [];

	if ( !isDefined( self.name ) ) self.name = "undefined name";
	if ( !isDefined( self.guid ) ) self.guid = "undefined guid";

	self setClientDvars(
		"show_hud", true,
		"ip", getDvar( "net_ip" ),
		"port", getDvar( "net_port" ),
		"cg_drawSpectatorMessages", 1,
		"ui_menu_playername", self.name,
		"ui_uav_client", 0
	);

	if ( self.name.size > 8 ) self setClientDvar( "ui_menu_playername", getSubStr( self.name, 0, 7 ) + "..." );

	if ( !isDefined( self.pers["team"] ) ) {
		iPrintLn( self.name + " ^7entered the game" );

		self.sessionstate = "playing";
		self.team = "allies";
		self.pers["team"] = "allies";
		self.pers["score"] = 0;
		self.pers["kills"] = 0;
		self.pers["deaths"] = 0;
		self.pers["assists"] = 0;
	} else {
		self.score = self.pers["score"];
		self.kills = self.pers["kills"];
		self.assists = self.pers["assists"];
		self.deaths = self.pers["deaths"];
	}

	if ( !isDefined( level.spawn["spectator"] ) ) level.spawn["spectator"] = level.spawn["allies"][0];

	if ( self.pers["team"] != "spectator" ) self braxi\_mod::spawnPlayer();
	else self braxi\_mod::spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
}

playerDisconnect() {
	level notify( "disconnected", self );

	if ( !isDefined( self.name ) ) iPrintLn( self.name + " ^7left the game" );

	logPrint( "Q;" + self getGuid() + ";" + self getEntityNumber() + ";" + self.name + "\n" );
}


PlayerLastStand( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration ) {
	self suicide();
}

PlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime ) {
	if ( self.sessionteam == "spectator" ) return;

	level notify( "player_damage", self, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

	if ( isPlayer( eAttacker ) && eAttacker.pers["team"] == self.pers["team"] ) return;

	if ( !isDefined( vDir ) ) iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	if ( !( iDFlags & level.iDFLAGS_NO_PROTECTION ) ) {
		if ( iDamage < 1 ) iDamage = 1;
		self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
	}
}

PlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration ) {
	self notify( "killed_player" );
	self notify( "death" );

	if ( self.sessionteam == "spectator" ) return;

	level notify( "player_killed", self, eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );

	self.statusicon = "hud_status_dead";
	self.sessionstate = "spectator";
	self.died = true;

	if ( !level.freerun ) {
		self.deaths++;
		self.pers["deaths"]++;
		deaths = self maps\mp\gametypes\_persistence::statGet( "deaths" );
		self maps\mp\gametypes\_persistence::statSet( "deaths", deaths + 1 );
	}

	obituary( self, attacker, sWeapon, sMeansOfDeath );

	if ( self.pers["team"] == "axis" ) {
		self thread braxi\_teams::setTeam( "allies" );
		return;
	}

	self braxi\_mod::respawnPlayer();
}