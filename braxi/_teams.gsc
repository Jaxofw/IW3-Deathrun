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

setSpectatePermissions( allies, axis, freelook, none )
{
	self allowSpectateTeam( "allies", allies );
	self allowSpectateTeam( "axis", axis );
	self allowSpectateTeam( "freelook", freelook );
	self allowSpectateTeam( "none", none );
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
	if ( self.pers["team"] == team )
		return;

	self.pers["weapon"] = "none";
	self.pers["team"] = team;
	self.team = team;
	self.sessionteam = team;

	if ( self.pers["team"] == "spectator" )
		self suicide();
	else if ( self.pers["team"] == "axis" )
		level.jumpersAlive--;
}

setLoadout()
{
	self takeAllWeapons();

	self.pers["primary"] = level.weapon_primary[self getStat( 981 )]["item"];
	self.pers["secondary"] = level.weapon_secondary[self getStat( 982 )]["item"];
	gloves = level.model_glove[self getStat( 983 )]["item"];

	self setPlayerModel();
	self setViewModel( gloves );

	self giveWeapon( self.pers["primary"] );
	self setSpawnWeapon( self.pers["primary"] );
	self giveMaxAmmo( self.pers["primary"] );
	self giveWeapon( self.pers["secondary"] );

	self setHealth();
	self setSpeed();
}

setPlayerModel()
{
	self detachAll();

	if ( self.pers["team"] == "allies" )
		self setModel( level.model_jumper[self getStat( 979 )]["item"] );
	else if ( self.pers["team"] == "axis" )
		self setModel( level.model_activator[self getStat( 980 )]["item"] );
}