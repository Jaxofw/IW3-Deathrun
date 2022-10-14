precache() {
	precacheShader("white");
	precacheStatusIcon("hud_status_connecting");
	precacheStatusIcon("hud_status_dead");
	precacheModel("body_mp_sas_urban_sniper");
	precacheItem("deserteaglegold_mp");
}

getAllPlayers() {
	return getEntArray( "player", "classname" );
}

isPlaying() {
    if ( self.sessionstate == "playing" && self.pers["team"] == "allies" ) return true;
    return false;
}

waitForPlayers( required ) {
	while ( true ) {
		wait 0.5;
		players = getAllPlayers();
        if ( players.size > required ) {
            for ( i = 0; i < players.size; i++ )
                if ( players[i] isPlaying() ) return true;
        }
    }
}