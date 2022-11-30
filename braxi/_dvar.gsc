setupDvars() {
    level.dvar = [];

    addDvar( "motd", "string", "Visit discord.gg/ArcaneNW" );
    makeDvarServerInfo( "motd", level.dvar["motd"] );

	addDvar( "player_speed", "int", 190, 190, 300 );

	addDvar( "time_limit", "int", 5, 5, 600 );
	addDvar( "time_limit_freerun", "int", 5, 5, 180 );

	addDvar( "freerun", "int", 1, 0, 1 );
	addDvar( "spawn_time", "int", 5, 1, 10 );

	addDvar( "round_limit", "int", 12, 2, 100 );

    addDvar( "ui_menu_playername", "string", "Player" );
}

// Originally from Bell's AWE mod for CoD 1
addDvar( varname, type, vardefault, min, max ) {
	if ( type == "int" ) {
		if ( getdvar(varname) == "" ) definition = vardefault;
		else definition = getdvarint( varname );
	} else if ( type == "float" ) {
		if ( getdvar(varname) == "" ) definition = vardefault;
		else definition = getdvarfloat( varname );
	} else {
		if ( getdvar(varname) == "" ) definition = vardefault;
		else definition = getdvar( varname );
	}

	if ( type != "string" ) {
		if ( ( type == "int" || type == "float" ) && min != 0 && definition < min ) definition = min;
		makeDvarServerInfo( "netaddr", getDvar("net_ip") );
		if ( ( type == "int" || type == "float" ) && max != 0 && definition > max ) definition = max;
	}
	
	if ( getdvar( varname ) == "" ) setdvar( varname, definition );

	level.dvar[varname] = definition;
}