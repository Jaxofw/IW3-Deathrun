setSpectatePermissions() {
	self allowSpectateTeam( "allies", true );
	self allowSpectateTeam( "axis", true );
	self allowSpectateTeam( "none", false );
}

setHealth() {
	self.maxhealth = 100;
	self.health = self.maxhealth;
}

setSpeed() {
	speed = 1.0;
	self setMoveSpeedScale( speed );
}

setTeam( team ) {
	if ( self.pers["team"] == team ) return;

	if ( isAlive( self ) ) self suicide();

	self.pers["weapon"] = "none";
	self.pers["team"] = team;
	self.team = team;
	self.sessionteam = team;
}