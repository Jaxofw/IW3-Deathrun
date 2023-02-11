init()
{	
	level.refreshTime = 3;
    level.hostname = "^5Arcane ^7Deathrun ^1BETA";
	
	setDvar( "sv_hostname", level.hostname + " ^5| ^7Round^5: ^7" + game["roundsplayed"] + "^5/^7" + level.dvar["round_limit"] );
	
	thread refreshHostname();
}

refreshHostname()
{
	while ( true )
	{
	    setDvar( "sv_hostname", level.hostname + " ^5| ^7Round^5: ^7" + game["roundsplayed"] + "^5/^7" + level.dvar["round_limit"] );
		wait level.refreshTime;
	}
}