#include braxi\_common;

init()
{
    for (;;)
    {
        level waittill( "connected", player );

        player thread fetchFov();
        player thread fetchSpeedMeter();
        player thread fetchHitmarkers();
        player thread fetchHud();
    }
}

fetchFov()
{
    if ( !isDefined( self.pers["init_fov_save"] ) )
    {
        self clientCmd( "setfromdvar temp cg_fovscale; setu cg_fovscale 1; setfromdvar cg_fovscale temp" );
        self.pers["init_fov_save"] = true;
    }

    self setClientDvar( "cg_fovscale", self getStat( 992 ) / 100 );
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
    self setClientDvars(
        "ui_rounds_vis", 1,
        "ui_jumpers_vis", 1,
        "ui_player_vis", 1,
        "ui_weapon_vis", 1,
        "ui_exp_bar_vis", 1,
        "ui_compass_vis", self getStat( 1000 ),
        "ui_spec_keys_vis", self getStat( 1001 ),
        "ui_spec_fps_vis", self getStat( 1002 ),
        "ui_practice_controls_vis", self getStat( 1003 ),
        "ui_time_wr_vis", self getStat( 1004 )
    );
}