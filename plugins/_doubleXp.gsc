init()
{
    level.xpEvent = false;
    level.xpPrevious = [];

    // Index is amount to multiply xp by
    level.xpPlayersNeeded[2] = 2;
    level.xpPlayersNeeded[3] = 20;
    level.xpPlayersNeeded[4] = 30;

    if ( !level.xpEvent )
        thread watchPlayerCount();
    else
        setXpValues( 2 );
}

watchPlayerCount()
{
    while ( true )
    {
        if ( level.players.size >= level.xpPlayersNeeded[2] )
        {
            if ( !level.xpEvent )
            {
                level.xpEvent = true;

                for ( i = level.xpPlayersNeeded.size + 2; i > 1; i-- )
                {
                    if ( isDefined( level.xpPlayersNeeded[i] ) )
                    {
                        if ( level.players.size == level.xpPlayersNeeded[i] )
                        {
                            for ( j = 0; j < level.players.size; j++ )
                                level.players[j] setClientDvar( "ui_exp_event", true );
                            
                            level waittill( "round_started" );
                            setXpValues( i );
                        }
                    }
                }
            }
        }
        else
        {
            if ( level.xpEvent )
            {
                level.xpEvent = false;
                setXpValues();
            }
        }

        wait .5;
    }
}

setXpValues( number )
{
    for ( i = 0; i < level.scoreInfo.size; i++ )
    {
        if ( !isDefined( level.xpPrevious[level.xpPrevious.size] ) )
        {
            xpId = level.xpPrevious.size;
            level.xpPrevious[xpId]["value"] = level.scoreInfo[i]["value"];
        }

        iPrintLn( number );

        if ( isDefined( number ) )
            braxi\_rank::setScoreValue( level.scoreInfo[i]["type"], level.scoreInfo[i]["value"] * number, i );
        else
            braxi\_rank::setScoreValue( level.scoreInfo[i]["type"], level.xpPrevious[i]["value"], i );
    }
}