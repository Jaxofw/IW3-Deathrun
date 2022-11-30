init() {
	setDvar( "g_TeamName_Allies", "^7Jumpers" );
	setDvar( "g_TeamIcon_Allies", "killiconfalling" );
	setDvar( "g_TeamColor_Allies", "0.2 0.6 0.9" );
	setDvar( "g_ScoresColor_Allies", "0.2 0.5 0.8" );

	setDvar( "g_TeamName_Axis", "^1Activator" );
	setDvar( "g_TeamIcon_Axis", "killiconsuicide" );
	setDvar( "g_TeamColor_Axis", "0.874 0.262 0.305" );
	setDvar( "g_ScoresColor_Axis", "0.874 0.262 0.305" );

	setDvar( "g_ScoresColor_Spectator", ".25 .25 .25" );
	setDvar( "g_ScoresColor_Free", ".76 .78 .10" );
	setDvar( "g_teamColor_MyTeam", "0.2 0.6 0.9" );
	setDvar( "g_teamColor_EnemyTeam", "1 .45 .5" );
}

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