#include braxi\_utility;

init()
{
	game["menu_team"] = "team_marinesopfor";
	game["menu_customize"] = "customization";
	game["menu_settings"] = "settings";
	game["menu_settings2"] = "settings2";
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
	game["menu_sprays"] = "sprays";
	game["menu_sprays2"] = "sprays2";
	game["menu_maprecords"] = "maprecords";
	game["menu_mapvote"] = "mapvote";
	game["menu_leaderboard"] = "leaderboard";
	game["menu_leaderboard2"] = "leaderboard2";
	game["menu_quickstuff"] = "quickstuff";
	game["menu_clientcmd"] = "clientcmd";

	preCacheMenu( game["menu_team"] );
	preCacheMenu( game["menu_customize"] );
	preCacheMenu( game["menu_settings"] );
	preCacheMenu( game["menu_settings2"] );
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
	preCacheMenu( game["menu_sprays"] );
	preCacheMenu( game["menu_sprays2"] );
	preCacheMenu( game["menu_maprecords"] );
	preCacheMenu( game["menu_mapvote"] );
	preCacheMenu( game["menu_leaderboard"] );
	preCacheMenu( game["menu_leaderboard2"] );
	preCacheMenu( game["menu_quickstuff"] );
	preCacheMenu( game["menu_clientcmd"] );

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
				self setStat( 981, id );

				if ( self isAlive() )
				{
					if ( self.pers["team"] == "axis" )
						continue;

					if ( !isDefined( self.finishedMap ) )
					{
						prevPrimary = self.pers["primary"];
						self.pers["primary"] = level.weapon_primary[id]["item"];

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
				self setStat( 982, id );

				if ( self isAlive() )
				{
					if ( self.pers["team"] == "axis" && level.jumperFinished )
						continue;

					if ( !isDefined( self.finishedMap ) )
					{
						prevSecondary = self.pers["secondary"];
						self.pers["secondary"] = level.weapon_secondary[id]["item"];

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
		else if ( menu == game["menu_sprays"] || menu == game["menu_sprays2"] )
		{
			id = int( response ) - 1;

			if ( self braxi\_rank::isItemUnlocked( level.fx_spray, id ) )
			{
				self setStat( 984, id );
				self setClientDvar( "ui_spray_selected", id );
			}
		}
		else if ( menu == game["menu_settings"] )
		{
			switch ( response )
			{
				case "fovscale":
					wait .8;
					fov = toFloat( self getUserInfo( "cg_fovscale" ) );

					if ( fov == 1 )
						self setStat( 992, 0 );
					else if ( fov == 2 )
						self setStat( 992, 2 );
					else
					{
						fov = int( fov * 10 ) % 10;
						self setStat( 992, fov );
					}
					break;
				case "round":
					if ( self getStat( 995 ) == 0 )
						self setStat( 995, 1 );
					else
						self setStat( 995, 0 );

					self setClientDvar( "ui_rounds_vis", self getStat( 995 ) );
					break;
				case "jumper":
					if ( self getStat( 996 ) == 0 )
						self setStat( 996, 1 );
					else
						self setStat( 996, 0 );

					self setClientDvar( "ui_jumpers_vis", self getStat( 996 ) );
					break;
				case "player":
					if ( self getStat( 997 ) == 0 )
						self setStat( 997, 1 );
					else
						self setStat( 997, 0 );

					self setClientDvar( "ui_player_vis", self getStat( 997 ) );
					break;
				case "weapon":
					if ( self getStat( 998 ) == 0 )
						self setStat( 998, 1 );
					else
						self setStat( 998, 0 );

					self setClientDvar( "ui_weapon_vis", self getStat( 998 ) );
					break;
				case "xpbar":
					if ( self getStat( 999 ) == 0 )
						self setStat( 999, 1 );
					else
						self setStat( 999, 0 );

					self setClientDvar( "ui_exp_bar_vis", self getStat( 999 ) );
					break;
				case "compass":
					if ( self getStat( 1000 ) == 0 )
						self setStat( 1000, 1 );
					else
						self setStat( 1000, 0 );

					self setClientDvar( "ui_compass_vis", self getStat( 1000 ) );
					break;
			}
		}
		else if ( menu == game["menu_quickstuff"] )
		{
			switch ( response )
			{
				case "3rdperson":
					if ( self getStat( 988 ) == 0 )
					{
						self iPrintln( "Third Person ^2Enabled" );
						self setClientDvar( "cg_thirdperson", 1 );
						self setStat( 988, 1 );
					}
					else
					{
						self iPrintln( "Third Person ^1Disabled" );
						self setClientDvar( "cg_thirdperson", 0 );
						self setStat( 988, 0 );
					}
					break;
				case "suicide":
					if ( game["state"] == "endround" || game["state"] == "endmap" )
						continue;

					if ( self.pers["team"] == "allies" )
						self suicide();
					break;
				case "fullbright":
					if ( self getStat( 989 ) == 0 )
					{
						self iPrintln( "Fullbright ^2Enabled" );
						self setClientDvar( "r_fullbright", 1 );
						self setStat( 989, 1 );
					}
					else
					{
						self iPrintln( "Fullbright ^1Disabled" );
						self setClientDvar( "r_fullbright", 0 );
						self setStat( 989, 0 );
					}
					break;
				case "effects":
					if ( self getStat( 990 ) == 0 )
					{
						self iPrintln( "Effects ^2Enabled" );
						self setClientDvar( "fx_enable", 1 );
						self setStat( 990, 1 );
					}
					else
					{
						self iPrintln( "Effects ^1Disabled" );
						self setClientDvar( "fx_enable", 0 );
						self setStat( 990, 0 );
					}
					break;
				case "togglemusic":
					if ( self getStat( 991 ) == 0 )
					{
						self iPrintln( "Music ^1Disabled" );
						self thread clientCmd( "snd_stopambient" );
						self setStat( 991, 1 );
					}
					else
					{
						self iPrintln( "Music ^2Enabled" );
						self setStat( 991, 0 );
					}
					break;
				case "speedmeter":
					if ( self getStat( 993 ) == 0 )
					{
						self iPrintln( "Meter ^2Enabled" );
						self setClientDvar( "ui_player_speed_vis", 1 );
						self setStat( 993, 1 );
					}
					else
					{
						self iPrintln( "Meter ^1Disabled" );
						self setClientDvar( "ui_player_speed_vis", 0 );
						self setStat( 993, 0 );
					}
					break;
				case "hitmarkers":
					if ( self getStat( 994 ) == 0 )
					{
						self setClientDvar( "ui_hitmarkers", 0 );
						self setStat( 994, 1 );
						self iPrintln( "Hitmarkers ^9Enemy" );
					}
					else if ( self getStat( 994 ) == 1 )
					{
						self setClientDvar( "ui_hitmarkers", 1 );
						self setStat( 994, 2 );
						self iPrintln( "Hitmarkers ^8Friendly" );
					}
					else if ( self getStat( 994 ) == 2 )
					{
						self setClientDvar( "ui_hitmarkers", 2 );
						self setStat( 994, 0 );
						self iPrintln( "Hitmarkers ^2All" );
					}
					break;
			}
		}
		else if ( !level.console )
		{
			if ( menu == game["menu_quickcommands"] )
				maps\mp\gametypes\_quickmessages::quickcommands( response );
			else if ( menu == game["menu_quickstatements"] )
				maps\mp\gametypes\_quickmessages::quickstatements( response );
			else if ( menu == game["menu_quickresponses"] )
				maps\mp\gametypes\_quickmessages::quickresponses( response );
		}
	}
}