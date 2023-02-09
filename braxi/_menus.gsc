#include braxi\_common;

init()
{
    // Prevent game from precaching menus multiple times
    if ( !isDefined( game["roundsplayed"] ) )
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
        game["menu_trails"] = "trails";
        game["menu_trails2"] = "trails2";
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
        preCacheMenu( game["menu_trails"] );
        preCacheMenu( game["menu_trails2"] );
        preCacheMenu( game["menu_maprecords"] );
        preCacheMenu( game["menu_mapvote"] );
        preCacheMenu( game["menu_leaderboard"] );
        preCacheMenu( game["menu_leaderboard2"] );
        preCacheMenu( game["menu_quickstuff"] );
        preCacheMenu( game["menu_clientcmd"] );
    }

    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

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

                    if ( self.sessionstate == "playing" )
                        continue;

                    if ( self canSpawn() )
                        self braxi\_mod::spawnPlayer();
                    break;
                case "spectate":
					if ( self.pers["team"] != "allies" )
						continue;

					self braxi\_teams::setTeam( "spectator" );
					self braxi\_mod::spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
					break;
                case "challenges":
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

				if ( self.pers["team"] == "allies" )
                    self braxi\_teams::setPlayerModel();
			}
		}
		else if ( menu == game["menu_activators"] )
		{
			id = int( response ) - 1;
			if ( self braxi\_rank::isItemUnlocked( level.model_activator, id ) )
			{
				self setStat( 980, id );

				if ( self.pers["team"] == "axis" )
                    self braxi\_teams::setPlayerModel();
			}
		}
		else if ( menu == game["menu_primary"] || menu == game["menu_primary2"] || menu == game["menu_primary3"] )
		{
			id = int( response ) - 1;
			if ( self braxi\_rank::isItemUnlocked( level.weapon_primary, id ) )
			{
				self setStat( 981, id );

				if ( isAlive( self ) && self isPlaying() )
				{
					if ( self.pers["team"] == "axis" )
						continue;

					if ( !self.finishedMap )
					{
						self takeWeapon( self.pers["primary"] );
						self.pers["primary"] = level.weapon_primary[id]["item"];
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

				if ( isAlive( self ) && self isPlaying() )
				{
					if ( self.pers["team"] == "axis" && isDefined( level.jumperFinished ) )
						continue;

					if ( !self.finishedMap )
					{
						self takeWeapon( self.pers["secondary"] );
						self.pers["secondary"] = level.weapon_secondary[id]["item"];
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
		else if ( menu == game["menu_trails"] || menu == game["menu_trails2"] )
		{
			id = int( response ) - 1;

			if ( self braxi\_rank::isItemUnlocked( level.fx_trail, id ) )
			{
				self setStat( 985, id );
				self thread braxi\_mod::drawTrail();
			}
		}
		else if ( menu == game["menu_settings"] || menu == game["menu_settings2"] )
		{
			switch ( response )
			{
				case "fovscale":
					fov = toFloat( self getUserInfo( "cg_fovscale" ) );
					self setStat( 992, int( fov * 100 ) );
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
				case "keys":
					if ( self getStat( 1001 ) == 0 )
						self setStat( 1001, 1 );
					else
						self setStat( 1001, 0 );

					self setClientDvar( "ui_spec_keys_vis", self getStat( 1001 ) );
					break;
				case "fps_counter":
					if ( self getStat( 1002 ) == 0 )
						self setStat( 1002, 1 );
					else
						self setStat( 1002, 0 );

					self setClientDvar( "ui_spec_fps_vis", self getStat( 1002 ) );
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
						self iPrintLn( "Third Person ^2Enabled" );
						self setClientDvar( "cg_thirdperson", 1 );
						self setStat( 988, 1 );
					}
					else
					{
						self iPrintLn( "Third Person ^1Disabled" );
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
						self iPrintLn( "Fullbright ^2Enabled" );
						self setClientDvar( "r_fullbright", 1 );
						self setStat( 989, 1 );
					}
					else
					{
						self iPrintLn( "Fullbright ^1Disabled" );
						self setClientDvar( "r_fullbright", 0 );
						self setStat( 989, 0 );
					}
					break;
				case "effects":
					if ( self getStat( 990 ) == 0 )
					{
						self iPrintLn( "Effects ^2Enabled" );
						self setClientDvar( "fx_enable", 1 );
						self setStat( 990, 1 );
					}
					else
					{
						self iPrintLn( "Effects ^1Disabled" );
						self setClientDvar( "fx_enable", 0 );
						self setStat( 990, 0 );
					}
					break;
				case "togglemusic":
					if ( self getStat( 991 ) == 0 )
					{
						self iPrintLn( "Music ^1Disabled" );
						self thread clientCmd( "snd_stopambient" );
						self setStat( 991, 1 );
					}
					else
					{
						self iPrintLn( "Music ^2Enabled" );
						self setStat( 991, 0 );
					}
					break;
				case "speedmeter":
					if ( self getStat( 993 ) == 0 )
					{
						self iPrintLn( "Meter ^2Enabled" );
						self setClientDvar( "ui_player_speed_vis", 1 );
						self setStat( 993, 1 );
					}
					else
					{
						self iPrintLn( "Meter ^1Disabled" );
						self setClientDvar( "ui_player_speed_vis", 0 );
						self setStat( 993, 0 );
					}
					break;
				case "hitmarkers":
					if ( self getStat( 994 ) == 0 )
					{
						self setClientDvar( "ui_hitmarkers", 0 );
						self setStat( 994, 1 );
						self iPrintLn( "Hitmarkers ^9Enemy" );
					}
					else if ( self getStat( 994 ) == 1 )
					{
						self setClientDvar( "ui_hitmarkers", 1 );
						self setStat( 994, 2 );
						self iPrintLn( "Hitmarkers ^8Friendly" );
					}
					else if ( self getStat( 994 ) == 2 )
					{
						self setClientDvar( "ui_hitmarkers", 2 );
						self setStat( 994, 0 );
						self iPrintLn( "Hitmarkers ^2All" );
					}
					break;
			}
		}
		else
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