#include braxi\_utility;

init()
{
	game["menu_team"] = "team_marinesopfor";
	game["menu_customize"] = "customization";
	game["menu_jumpers"] = "jumpers";
	game["menu_jumpers2"] = "jumpers2";
	game["menu_activators"] = "activators";
	game["menu_primary"] = "primary";
	game["menu_primary2"] = "primary2";
	game["menu_primary3"] = "primary3";
	game["menu_secondary"] = "secondary";
	game["menu_secondary2"] = "secondary2";
	game["menu_gloves"] = "gloves";
	game["menu_gloves2"] = "gloves2";
	game["menu_mapvote"] = "mapvote";

	preCacheMenu( game["menu_team"] );
	preCacheMenu( game["menu_customize"] );
	preCacheMenu( game["menu_jumpers"] );
	preCacheMenu( game["menu_jumpers2"] );
	preCacheMenu( game["menu_activators"] );
	preCacheMenu( game["menu_primary"] );
	preCacheMenu( game["menu_primary2"] );
	preCacheMenu( game["menu_primary3"] );
	preCacheMenu( game["menu_secondary"] );
	preCacheMenu( game["menu_secondary2"] );
	preCacheMenu( game["menu_gloves"] );
	preCacheMenu( game["menu_gloves2"] );
	preCacheMenu( game["menu_mapvote"] );

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connecting", player );

		player setClientDvar( "ui_3dwaypointtext", 1 );
		player.enable3DWaypoints = true;
		player setClientDvar( "ui_deathicontext", 0 );
		player.enableDeathIcons = false;
		player.classType = undefined;
		player.selectedClass = false;

		player setClientDvar( "g_scriptMainMenu", game["menu_team"] );
		player thread onMenuResponse();
	}
}

onMenuResponse()
{
	self endon( "disconnect" );

	for (;;)
	{
		self waittill( "menuresponse", menu, response );

		if ( menu == game["menu_team"] )
		{
			self closeMenu();
			self closeInGameMenu();

			switch ( response )
			{
				case "autoassign":
					if ( self.pers["team"] == "axis" )
						continue;

					self braxi\_teams::setTeam( "allies" );

					if ( self.sessionstate == "playing" || game["state"] == "endround" )
						continue;

					if ( self canSpawn() )
						self braxi\_player::playerSpawn();
					break;
				case "spectate":
					if ( self.pers["team"] != "allies" )
						continue;

					self braxi\_teams::setTeam( "spectator" );
					self braxi\_player::playerSpawnSpectator( level.spawn["spectator"][0].origin, level.spawn["spectator"][0].angles );
					break;
				case "challenges":
				case "leaderboard":
					self iPrintLnBold( "Coming Soon..." );
					break;
			}
		}
		else if ( menu == game["menu_jumpers"] || menu == game["menu_jumpers2"] )
		{
			id = int( response ) - 1;
			if ( self braxi\_rank::isItemUnlocked( level.model_jumper, id ) )
			{
				self setStat( 979, id );
				if ( self.pers["team"] == "allies" ) self braxi\_teams::setPlayerModel();
			}
		}
		else if ( menu == game["menu_activators"] )
		{
			id = int( response ) - 1;
			if ( self braxi\_rank::isItemUnlocked( level.model_activator, id ) )
			{
				self setStat( 980, id );
				if ( self.pers["team"] == "axis" ) self braxi\_teams::setPlayerModel();
			}
		}
		else if ( menu == game["menu_primary"] || menu == game["menu_primary2"] || menu == game["menu_primary3"] )
		{
			id = int( response ) - 1;
			if ( self braxi\_rank::isItemUnlocked( level.weapon_primary, id ) )
			{
				prevPrimary = self.pers["primary"];
				self setStat( 981, id );
				self.pers["primary"] = level.weapon_primary[id]["item"];

				if ( self isAlive() )
				{
					if ( self.pers["team"] == "axis" )
						continue;

					if ( !isDefined( self.finishedMap ) )
					{
						self takeWeapon( prevPrimary );
						self giveWeapon( self.pers["primary"] );
						self giveMaxAmmo( self.pers["primary"] );
						self switchToWeapon( self.pers["primary"] );
					}
				}
			}
		}
		else if ( menu == game["menu_secondary"] || menu == game["menu_secondary2"] )
		{
			id = int( response ) - 1;
			if ( self braxi\_rank::isItemUnlocked( level.weapon_secondary, id ) )
			{
				prevSecondary = self.pers["secondary"];
				self setStat( 982, id );
				self.pers["secondary"] = level.weapon_secondary[id]["item"];

				if ( self isAlive() )
				{
					if ( self.pers["team"] == "axis" && level.jumperFinished )
						continue;

					if ( !isDefined( self.finishedMap ) )
					{
						self takeWeapon( prevSecondary );
						self giveWeapon( self.pers["secondary"] );
						self giveMaxAmmo( self.pers["secondary"] );
						self switchToWeapon( self.pers["secondary"] );
					}
				}
			}
		}
		else if ( menu == game["menu_gloves"] || menu == game["menu_gloves2"] )
		{
			id = int( response ) - 1;
			if ( self braxi\_rank::isItemUnlocked( level.model_glove, id ) )
			{
				self setStat( 983, id );
				self setViewModel( level.model_glove[id]["item"] );
			}
		}
	}
}