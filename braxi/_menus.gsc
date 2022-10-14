init() {
    game["menu_team"] = "team_marinesopfor";
    game["menu_customize"] = "customization";

    precacheMenu( game["menu_team"] );
    precacheMenu( game["menu_customize"] );

    level thread onPlayerConnect();
}

onPlayerConnect() {
	for(;;) {
		level waittill( "connecting", player );
		player setClientDvar( "g_scriptMainMenu", game["menu_team"] );
		player onMenuResponse();
	}
}

onMenuResponse() {
	self endon("disconnect");
	
	for(;;) {
		self waittill( "menuresponse", menu, response );

		if ( menu == game["menu_team"] ) {
			self closeMenu();
			self closeInGameMenu();

			switch ( response ) {
				case "autoassign":
					if ( self.pers["team"] == "axis" || self.sessionstate == "playing" ) continue;
					self braxi\_teams::setTeam( "allies" );
					self braxi\_mod::spawnPlayer();
					break;
				case "spectate":
					if ( self.pers["team"] == "axis" || self.sessionstate == "spectator" ) continue;
					self braxi\_teams::setTeam( "spectator" );
					self braxi\_mod::spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
					break;
				case "challenges":
				case "leaderboard":
					self iPrintLnBold( "Coming Soon..." );
					break;
			}
		}
    }
}