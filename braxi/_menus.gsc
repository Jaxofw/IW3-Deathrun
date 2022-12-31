#include braxi\_utility;

init()
{
	game["menu_team"] = "team_marinesopfor";
	game["menu_customize"] = "customization";
	game["menu_settings"] = "settings";
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
	game["menu_quickstuff"] = "quickstuff";
	game["menu_clientcmd"] = "clientcmd";

	preCacheMenu( game["menu_team"] );
	preCacheMenu( game["menu_customize"] );
	preCacheMenu( game["menu_settings"] );
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
	preCacheMenu( game["menu_quickstuff"] );
	preCacheMenu( game["menu_clientcmd"] );

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for ( ;;)
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

	for ( ;;)
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
		else if ( menu == game["menu_settings"] )
		{
			wait .3;
			if ( response == "updateFovScale" )
			{
				fov = getDvarFloat( "cg_fovscale" );

				if ( fov == 1.0 )
					self setStat( 992, 0 );
				else if ( fov == 2.0 )
					self setStat( 992, 2 );
				else
				{
					fov = int( fov * 10 ) % 10;
					self setStat( 992, fov );
				}
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