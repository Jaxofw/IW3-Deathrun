#include braxi\_common;

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

setTeam( team )
{
    if ( self.pers["team"] == team )
        return;

    self.pers["team"] = team;
	self.team = team;
	self.sessionteam = team;

	if ( !self isPlaying() )
		self.statusicon = "hud_status_dead";
}

setPlayerModel()
{
	self detachAll();

	if ( self.pers["team"] == "allies" )
		self setModel( level.model_jumper[self getStat( 979 )]["item"] );
	else if ( self.pers["team"] == "axis" )
		self setModel( level.model_activator[self getStat( 980 )]["item"] );
}

setLoadout()
{
	self takeAllWeapons();

	self.pers["secondary"] = level.weapon_secondary[self getStat( 982 )]["item"];
	gloves = level.model_glove[self getStat( 983 )]["item"];

	self giveWeapon( self.pers["secondary"] );
	self setViewModel( gloves );

	self thread braxi\_weapons::watchWeapons();

	if ( self.pers["team"] == "allies" )
	{
		self.pers["primary"] = level.weapon_primary[self getStat( 981 )]["item"];
		self giveWeapon( self.pers["primary"] );
		self setSpawnWeapon( self.pers["primary"] );
		self giveMaxAmmo( self.pers["primary"] );
	}
	else if ( self.pers["team"] == "axis" )
	{
		level.activ takeWeapon( self.pers["primary"] );
		level.activ switchToWeapon( self.pers["secondary"] );
		level.activ giveWeapon( "t5_ballistic_knife_mp" );
	}
}

setHealth()
{
	self.maxhealth = 100;
	self.health = self.maxhealth;
	self setClientDvars( "ui_health_value", self.health, "ui_health_bar", 1 );
}

setSpeed()
{
	self setMoveSpeedScale( 1.0 );
}

setSpectatePermissions()
{
	self allowSpectateTeam( "allies", true );
	self allowSpectateTeam( "axis", true );
	self allowSpectateTeam( "none", false );
}