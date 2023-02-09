#include braxi\_common;

init()
{
	level.killcamStarted = false;
	level thread watchForKillcam();
}

watchForKillcam()
{
	if ( level.freeRun )
		return;

	while ( true )
	{
		level waittill( "player_killed", who, eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );

		if ( !isDefined( who ) || !isDefined( attacker ) || !isDefined( eInflictor ) || !isPlayer( who ) || !isPlayer( attacker ) || who == attacker )
			continue;

		// Needed for level.jumpers and level.activators to calculate correctly
		wait 0.2;

		if ( level.jumpers.size > 0 && level.activators.size > 0 )
			continue;

		level startKillcam( attacker, sWeapon );
		return;
	}
}

startKillcam( attacker, sWeapon )
{
	level.killcamStarted = true;

	wait 2; // delay before killcam starts

	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ )
		players[i] thread killcam( attacker GetEntityNumber(), -1, sWeapon, 0, 0, 0, 8, undefined, attacker );
}

killcam(
	attackerNum, // entity number of the attacker
	killcamentity, // entity number of the attacker's killer entity aka helicopter or airstrike
	sWeapon, // killing weapon
	predelay, // time between player death and beginning of killcam
	offsetTime, // something to do with how far back in time the killer was seeing the world when he made the kill; latency related, sorta
	respawn, // will the player be allowed to respawn after the killcam?
	maxtime, // time remaining until map ends; the killcam will never last longer than this. undefined = no limit
	perks, // the perks the attacker had at the time of the kill
	attacker // entity object of attacker
)
{
	self endon( "disconnect" );
	self endon( "spawned" );
	level endon( "game_ended" );

	if ( attackerNum < 0 )
		return;

	// length from killcam start to killcam end
	camtime = 7.0;

	if ( isdefined( maxtime ) )
	{
		if ( camtime > maxtime )
			camtime = maxtime;
		if ( camtime < .05 )
			camtime = .05;
	}

	// time after player death that killcam continues for
	postdelay = 0;

	/* timeline:

	|        camtime       |      postdelay      |
	|                      |   predelay    |

	^ killcam start        ^ player death        ^ killcam end
										   ^ player starts watching killcam

	*/

	killcamlength = camtime + postdelay;

	// don't let the killcam last past the end of the round.
	if ( isDefined( maxtime ) && killcamlength > maxtime )
	{
		// first trim postdelay down to a minimum of 1 second.
		// if that doesn't make it short enough, trim camtime down to a minimum of 1 second.
		// if that's still not short enough, cancel the killcam.
		if ( maxtime < 2 )
			return;

		if ( maxtime - camtime >= 1 )
		{
			// reduce postdelay so killcam ends at end of match
			postdelay = maxtime - camtime;
		}
		else
		{
			// distribute remaining time over postdelay and camtime
			postdelay = 1;
			camtime = maxtime - 1;
		}

		// recalc killcamlength
		killcamlength = camtime + postdelay;
	}

	killcamoffset = camtime + predelay;

	self notify( "begin_killcam", getTime() );

	self.sessionstate = "spectator";
	self.spectatorclient = attackerNum;
	self.killcamentity = killcamentity;
	self.archivetime = killcamoffset;
	self.killcamlength = killcamlength;
	self.psoffsettime = offsetTime;

	// ignore spectate permissions
	self allowSpectateTeam( "allies", true );
	self allowSpectateTeam( "axis", true );
	self allowSpectateTeam( "freelook", true );
	self allowSpectateTeam( "none", true );

	// wait till the next server frame to allow code a chance to update archivetime if it needs trimming
	wait 0.05;

	if ( self.archivetime <= predelay ) // if we're not looking back in time far enough to even see the death, cancel
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;

		return;
	}

	self.killcam = true;
	self waittill( "end_killcam" );
	self endKillcam();

	self.sessionstate = "dead";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
}

endKillcam()
{
	self.killcam = undefined;
}