#include braxi\_common;

init()
{
    level.xpEvent = false;
    level.xpMultipliedBy = 1;

    if ( !level.xpEvent )
        thread watchPlayerCount();
}

watchPlayerCount()
{
    while ( true )
    {
        players = getAllPlayers();
        playersPlaying = 0;

        for ( i = 0; i < players.size; i++ )
        {
            if ( players[i] isPlaying() )
                playersPlaying++;
        }

        xpEvent = isXpEventAvailable( playersPlaying );

        if ( xpEvent )
        {
            if ( !level.xpEvent )
                level.xpEvent = true;
        }
        else
        {
            if ( level.xpEvent )
                level.xpEvent = false;
        }

        for ( i = 0; i < players.size; i++ )
            players[i] setClientDvar( "ui_exp_event", xpEvent );

        wait 0.5;
    }
}

isXpEventAvailable( players )
{
    if ( players < 10 )
        return false;

    if ( players >= 10 && players <= 20 )
        level.xpMultipliedBy = 2;
    else if ( players >= 20 && players <= 30 )
        level.xpMultipliedBy = 3;
    else if ( players > 30 )
        level.xpMultipliedBy = 4;

    return true;
}