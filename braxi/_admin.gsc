#include braxi\_common;

init()
{
    makeDvarServerInfo( "admin", "" );
    makeDvarServerInfo( "adm", "" );

    level.fx["bombexplosion"] = loadfx( "explosions/tanker_explosion" );

    while ( true )
    {
        wait 0.15;

        admin = strTok( getDvar( "admin" ), ":" );

        if ( isDefined( admin[0] ) && isDefined( admin[1] ) )
        {
            adminCommands( admin, "number" );
            setDvar( "admin", "" );
        }

        admin = strTok( getDvar( "adm" ), ":" );

        if ( isDefined( admin[0] ) && isDefined( admin[1] ) )
        {
            adminCommands( admin, "nickname" );
            setDvar( "adm", "" );
        }
    }
}

adminCommands( admin, pickingType )
{
    if ( !isDefined( admin[1] ) )
        return;

    arg0 = admin[0]; // command

    if ( pickingType == "number" )
        arg1 = int( admin[1] );	// player
    else
        arg1 = admin[1];

    switch ( arg0 )
    {
        case "say":
        case "msg":
        case "message":
            iPrintLnBold( admin[1] );
            break;

        case "kill":
            player = getPlayer( arg1, pickingType );
            if ( isDefined( player ) && player isPlaying() )
            {
                player suicide();
                player iPrintLnBold( "^1You were killed by the Admin" );
                iPrintLn( "^3[admin]:^7 " + player.name + " ^7killed." );
            }
            break;

        case "wtf":
            player = getPlayer( arg1, pickingType );
            if ( isDefined( player ) && player isPlaying() )
            {
                player thread cmd_wtf();
            }
            break;

        case "teleport":
            player = getPlayer( arg1, pickingType );
            if ( isDefined( player ) && player isPlaying() )
            {
                origin = level.spawn[player.pers["team"]][randomInt( player.pers["team"].size )].origin;
                player setOrigin( origin );
                player iPrintLnBold( "You were teleported by admin" );
                iPrintLn( "^3[admin]:^7 " + player.name + " ^7was teleported to spawn point." );
            }
            break;

        case "kick":
            player = getPlayer( arg1, pickingType );
            if ( isDefined( player ) )
            {
                player setClientDvar( "ui_dr_info", "You were ^1KICKED ^7from server." );
                if ( isDefined( admin[2] ) )
                {
                    iPrintLn( "^3[admin]:^7 " + player.name + " ^7got kicked from server. ^3Reason: " + admin[2] + "^7." );
                    // player setClientDvar( "ui_dr_info2", "Reason: " + admin[2] + "^7." );
                }
                else
                {
                    iPrintLn( "^3[admin]:^7 " + player.name + " ^7got kicked from server." );
                    // player setClientDvar( "ui_dr_info2", "Reason: admin decission." );
                }

                kick( player getEntityNumber() );
            }
            break;

        case "cmd":
            player = getPlayer( arg1, pickingType );
            if ( isDefined( player ) && isDefined( admin[2] ) )
            {

                iPrintLn( "^3[admin]:^7 executed dvar '^3" + admin[2] + "^7' on " + player.name );
                player iPrintLnBold( "Admin executed dvar '" + admin[2] + "^7' on you." );
                player clientCmd( admin[2] );
            }
            break;

        case "warn":
            player = getPlayer( arg1, pickingType );
            if ( isDefined( player ) && isDefined( admin[2] ) )
            {
                warns = player getStat( level.dvar["warns_stat"] );
                player setStat( level.dvar["warns_stat"], warns + 1 );

                iPrintLn( "^3[admin]: ^7" + player.name + " ^7warned for " + admin[2] + " ^1^1(" + ( warns + 1 ) + "/" + level.dvar["warns_max"] + ")^7." );
                player iPrintLnBold( "Admin warned you for " + admin[2] + "." );

                if ( 0 > warns )
                    warns = 0;
                if ( warns > level.dvar["warns_max"] )
                    warns = level.dvar["warns_max"];

                if ( ( warns + 1 ) >= level.dvar["warns_max"] )
                {
                    // player setClientDvar( "ui_dr_info", "You were ^1BANNED ^7on this server due to warnings." );
                    iPrintLn( "^3[admin]: ^7" + player.name + " ^7got ^1BANNED^7 on this server due to warnings." );
                    player setStat( level.dvar["warns_stat"], 0 );
                    ban( player getEntityNumber() );
                }
            }
            break;

        case "rw":
            player = getPlayer( arg1, pickingType );
            if ( isDefined( player ) )
            {
                player setStat( level.dvar["warns_stat"], 0 );
                iPrintLn( "^3[admin]: ^7" + "Removed warnings from " + player.name + "^7." );
            }
            break;

        case "row":
            player = getPlayer( arg1, pickingType );
            if ( isDefined( player ) )
            {
                warns = player getStat( level.dvar["warns_stat"] ) - 1;
                if ( 0 > warns )
                    warns = 0;
                player setStat( level.dvar["warns_stat"], warns );
                iPrintLn( "^3[admin]: ^7" + "Removed one warning from " + player.name + "^7." );
            }
            break;

        case "ban":
            player = getPlayer( arg1, pickingType );
            if ( isDefined( player ) )
            {
                // player setClientDvar( "ui_dr_info", "You were ^1BANNED ^7on this server." );
                if ( isDefined( admin[2] ) )
                {
                    iPrintLn( "^3[admin]: ^7" + player.name + " ^7got ^1BANNED^7 on this server. ^3Reason: " + admin[2] + "." );
                    // player setClientDvar( "ui_dr_info2", "Reason: " + admin[2] + "^7." );
                }
                else
                {
                    iPrintLn( "^3[admin]: ^7" + player.name + " ^7got ^1BANNED^7 on this server." );
                    // player setClientDvar( "ui_dr_info2", "Reason: admin decission." );
                }
                ban( player getEntityNumber() );
            }
            break;

        case "restart":
            if ( int( arg1 ) > 0 )
            {
                iPrintLnBold( "Round restarting in 3 seconds..." );
                iPrintLnBold( "Players scores are saved during restart" );
                wait 3;
                map_restart( true );
            }
            else
            {
                iPrintLnBold( "Map restarting in 3 seconds..." );
                wait 3;
                map_restart( false );
            }
            break;

        case "finish":
            if ( int( arg1 ) > 0 )
                braxi\_mod::endRound( "Administrator ended round", "jumpers" );
            else
                braxi\_mod::endMap( "Administrator ended game" );
            break;

        case "bounce":
            player = getPlayer( arg1, pickingType );
            if ( isDefined( player ) && player isPlaying() )
            {
                for ( i = 0; i < 2; i++ )
                    player bounce( vectorNormalize( player.origin - ( player.origin - ( 0, 0, 20 ) ) ), 200 );

                player iPrintLnBold( "^3You were bounced by the Admin" );
                iPrintLn( "^3[admin]: ^7Bounced " + player.name + "^7." );
            }
            break;

        case "drop":
            player = getPlayer( arg1, pickingType );
            if ( isDefined( player ) && player isPlaying() )
            {
                player dropItem( player getCurrentWeapon() );
            }
            break;

        case "takeall":
            player = getPlayer( arg1, pickingType );
            if ( isDefined( player ) && player isPlaying() )
            {
                player takeAllWeapons();
                player iPrintLnBold( "^1You were disarmed by the Admin" );
                iPrintLn( "^3[admin]: ^7" + player.name + "^7 disarmed." );
            }
            break;

        case "heal":
            player = getPlayer( arg1, pickingType );
            if ( isDefined( player ) && player isPlaying() && player.health != player.maxhealth )
            {
                player.health = player.maxhealth;
                player iPrintLnBold( "^2Your health was restored by Admin" );
                iPrintLn( "^3[admin]: ^7Restored " + player.name + "^7's health to maximum." );
            }
            break;

        case "spawn":
            player = getPlayer( arg1, pickingType );
            if ( isDefined( player ) && !player isPlaying() )
            {
                if ( !isDefined( player.pers["team"] ) || isDefined( player.pers["team"] ) && player.pers["team"] == "spectator" )
                    player braxi\_teams::setTeam( "allies" );

                player braxi\_mod::spawnPlayer();
                player iPrintLnBold( "^1You were respawned by the Admin" );
                iPrintLn( "^3[admin]:^7 " + player.name + " ^7respawned." );
            }
            break;
    }
}

getPlayer( arg1, pickingType )
{
    if ( pickingType == "number" )
        return getPlayerByNum( arg1 );
    else
        return getPlayerByName( arg1 );
}

getPlayerByNum( pNum )
{
    players = getAllPlayers();
    for ( i = 0; i < players.size; i++ )
    {
        if ( players[i] getEntityNumber() == pNum )
            return players[i];
    }
}

getPlayerByName( nickname )
{
    players = getAllPlayers();
    for ( i = 0; i < players.size; i++ )
    {
        if ( isSubStr( toLower( players[i].name ), toLower( nickname ) ) )
            return players[i];
    }
}

cmd_wtf()
{
    self endon( "disconnect" );
    self endon( "death" );

    self playSound( "wtf" );

    wait 0.8;

    if ( !self isPlaying() )
        return;

    playFx( level.fx["bombexplosion"], self.origin );
    self finishPlayerDamage( self, self, self.health + 1, 0, "MOD_EXPLOSIVE", "none", self.origin, self.origin, "none", 0 );
    self suicide();
}