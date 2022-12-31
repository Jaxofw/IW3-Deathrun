init()
{
    for (;;)
    {
        level waittill( "connected", player );
        player thread fetchFov();
        player thread fetchSpeedMeter();
        player thread fetchHitmarkers();
    }
}

fetchFov()
{
    if ( self getStat( 992 ) == 0 )
        self setClientDvar( "cg_fovscale", 1 );
    else if ( self getStat( 992 ) == 2 )
        self setClientDvar( "cg_fovscale", 2 );
    else
        self setClientDvar( "cg_fovscale", 1 + ( self getStat( 992 ) / 10 ) );
}

fetchSpeedMeter()
{
    self setClientDvar( "ui_player_speed_vis", self getStat( 993 ) );
}

fetchHitmarkers()
{
    self setClientDvar( "ui_hitmarkers", self getStat( 994 ) );
}