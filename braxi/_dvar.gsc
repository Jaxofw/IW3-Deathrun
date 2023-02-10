init()
{
    level.dvar = [];

    addDvar( "player_speed", "int", 190, 190, 300 );
    addDvar( "freerun", "int", 1, 0, 1 );

    addDvar( "spawn_time", "int", 5, 1, 10 );

    addDvar( "time_limit_freerun", "int", 5000, 5000, 5000 );
    addDvar( "time_limit", "int", 5, 5, 600 );

    addDvar( "round_limit", "int", 12, 2, 100 );

    addDvar( "freerun_choice", "int", 1, 0, 1 );
    addDvar( "freerun_choice_timer", "int", 5, 3, 10 );

    addDvar( "spray_delay", "int", 4, 1, 5 );

    addDvar( "motd", "string", "Visit discord.gg/ArcaneNW" );
}

// From Bell's CoD1 AWE mod
addDvar( varname, type, vardefault, min, max )
{
    if ( type == "int" )
    {
        if ( getDvar( varname ) == "" )
            definition = vardefault;
        else
            definition = getDvarInt( varname );
    }
    else if ( type == "float" )
    {
        if ( getDvar( varname ) == "" )
            definition = vardefault;
        else
            definition = getDvarFloat( varname );
    }
    else
    {
        if ( getDvar( varname ) == "" )
            definition = vardefault;
        else
            definition = getDvar( varname );
    }

    if ( ( type == "int" || type == "float" ) && min != 0 && definition < min )
        definition = min;

    if ( ( type == "int" || type == "float" ) && max != 0 && definition > max )
        definition = max;

    if ( getDvar( varname ) == "" )
        setDvar( varname, definition );

    level.dvar[varname] = definition;
}