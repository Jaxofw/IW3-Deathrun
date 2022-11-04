main() {
	thread maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	level.callbackStartGameType = ::Callback_StartGameType;
	level.callbackPlayerConnect = ::Callback_PlayerConnect;
	level.callbackPlayerDisconnect = ::Callback_PlayerDisconnect;
	level.callbackPlayerDamage = ::Callback_PlayerDamage;
	level.callbackPlayerKilled = ::Callback_PlayerKilled;
	level.callbackPlayerLastStand = ::Callback_PlayerLastStand;

	level.script = toLower( getDvar( "mapname" ) );
	level.gametype = toLower( getDvar( "g_gametype" ) );
	
	level.allies = ::allies;
	level.axis = ::axis;
	level.spectator = ::spectator;
}

Callback_StartGameType() {
	if ( !isDefined( game["allies"] ) ) game["allies"] = "marines";
	if ( !isDefined( game["axis"] ) ) game["axis"] = "opfor";

	thread braxi\_mod::init();

	allowed[0] = "war";
	maps\mp\gametypes\_gameobjects::main(allowed);	
}

notifyConnecting() {
	waittillframeend;
	if ( isDefined( self ) ) level notify( "connecting", self );
}

Callback_PlayerConnect() {
	thread notifyConnecting();
	self.statusicon = "";
	self waittill( "begin" );
	self braxi\_callbacks::playerConnect();
}

Callback_PlayerDisconnect() {
	self braxi\_callbacks::playerDisconnect();
}

Callback_PlayerLastStand(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration) {
	self braxi\_callbacks::PlayerLastStand(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);
}

Callback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime) {
	self braxi\_callbacks::PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
}

Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration) {
	self braxi\_callbacks::PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);
}

allies() { self braxi\_teams::setTeam( "allies" ); }
axis() { self braxi\_teams::setTeam( "axis" ); }
spectator() { self braxi\_teams::setTeam( "spectator" ); }