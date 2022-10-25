init() {
    game["menu_team"] = "team_marinesopfor";
    game["menu_customize"] = "customization";
    game["menu_primary"] = "primary";
    game["menu_primary2"] = "primary2";
    game["menu_secondary"] = "secondary";
    game["menu_secondary2"] = "secondary2";
    game["menu_gloves"] = "gloves";
    game["menu_gloves2"] = "gloves2";

    precacheMenu( game["menu_team"] );
    precacheMenu( game["menu_customize"] );
    precacheMenu( game["menu_primary"] );
    precacheMenu( game["menu_primary2"] );
    precacheMenu( game["menu_secondary"] );
    precacheMenu( game["menu_secondary2"] );
    precacheMenu( game["menu_gloves"] );
    precacheMenu( game["menu_gloves2"] );

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
		} else if ( menu == game["menu_primary"] || menu == game["menu_primary2"] ) {
			id = int(response) - 1;
			self giveWeapon( level.primaryWeaps[id]["item"] );
			self switchToWeapon( level.primaryWeaps[id]["item"] );
		} else if ( menu == game["menu_secondary"] || menu == game["menu_secondary2"] ) {
			id = int(response) - 1;
			self giveWeapon( level.secondaryWeaps[id]["item"] );
			self switchToWeapon( level.secondaryWeaps[id]["item"] );
		} else if ( menu == game["menu_gloves"] || menu == game["menu_gloves2"] ) {
			id = int(response) - 1;
			self setViewModel( level.gloveModels[id]["item"] );
			//self iPrintLnBold( level.gloveModels[id]["item"] );
		}
    }
}