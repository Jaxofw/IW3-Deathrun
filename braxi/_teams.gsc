#include braxi\_utility;

init()
{
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

setSpectatePermissions()
{
	self allowSpectateTeam( "allies", true );
	self allowSpectateTeam( "axis", true );
	self allowSpectateTeam( "none", false );
}

setHealth()
{
	self.maxhealth = 100;
	self.health = self.maxhealth;
}

setSpeed()
{
	self setMoveSpeedScale( 1.0 );
}

setTeam( team )
{
	if ( self.pers["team"] == team ) return;

	if ( isAlive( self ) ) self suicide();

	self.pers["weapon"] = "none";
	self.pers["team"] = team;
	self.team = team;
	self.sessionteam = team;
}

setLoadout()
{
	primary = level.weapon_primary[self getStat( 981 )]["item"];
	secondary = level.weapon_secondary[self getStat( 982 )]["item"];
	gloves = level.model_glove[self getStat( 983 )]["item"];

	self setPlayerModel();
	self setViewModel( gloves );

	self giveWeapon( primary );
	self giveWeapon( secondary );
	self setSpawnWeapon( primary );
	self giveMaxAmmo( primary );

	self setHealth();
	self setSpeed();
}

setPlayerModel()
{
	self detachAll();
	if ( self.team == "allies" ) self setModel( level.model_jumper[self getStat( 979 )]["item"] );
	if ( self.team == "axis" ) self setModel( level.model_activator[self getStat( 980 )]["item"] );
}