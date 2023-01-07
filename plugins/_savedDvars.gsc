#include braxi\_utility;

init()
{
    for (;;)
    {
        level waittill( "connected", player );
        player thread fetchFov();
        player thread fetchSpeedMeter();
        player thread fetchHitmarkers();
        player thread fetchHud();

        player clientCmd("setfromdvar temp cg_fovscale; setu cg_fovscale 1; setu cg_fovscale 2; setfromdvar cg_fovscale temp");
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

fetchHud()
{
	self setClientDvar( "ui_rounds_vis", self getStat( 995 ) );
	self setClientDvar( "ui_jumpers_vis", self getStat( 996 ) );
	self setClientDvar( "ui_player_vis", self getStat( 997 ) );
	self setClientDvar( "ui_weapon_vis", self getStat( 998 ) );
	self setClientDvar( "ui_exp_bar_vis", self getStat( 999 ) );
	self setClientDvar( "ui_compass_vis", self getStat( 1000 ) );
}