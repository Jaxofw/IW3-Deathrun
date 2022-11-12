setupDvars() {
    level.dvar = [];

    addDvar( "motd", "Visit discord.gg/ArcaneNW", "", "", "string" );
    makeDvarServerInfo( "motd", level.dvar["motd"] );

	addDvar( "player_speed", 190, 190, 300, "int" );

	addDvar( "time_limit", 5, 5, 600, "int" );
	addDvar( "time_limit_freerun", 5, 5, 180, "int" );

	addDvar( "freerun", 1, 0, 1, "int" );
	addDvar( "spawn_time", 5, 1, 10, "int" );

	addDvar( "round_limit", 12, 2, 100, "int" );

    addDvar( "ui_menu_playername", "Player", "", "", "string" );
}

// Originally from Bell's AWE mod for CoD 1
addDvar( varname, vardefault, min, max, type ) {
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

	if ( ( type == "int" || type == "float" ) && min != 0 && definition < min ) definition = min;
	makeDvarServerInfo( "netaddr", getDvar("net_ip") );
	if ( ( type == "int" || type == "float" ) && max != 0 && definition > max ) definition = max;
	if ( getdvar( varname ) == "" ) setdvar( varname, definition );

	level.dvar[varname] = definition;
}