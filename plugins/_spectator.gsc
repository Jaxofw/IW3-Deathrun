#include braxi\_common;

init()
{
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected", player );
        
        if ( !isDefined( player.init_spec_hud ) )
        {
            player clientCmd( "setfromdvar temp ui_player_timer; setu ui_player_timer 1; setfromdvar ui_player_timer temp; setfromdvar temp ui_player_speed; setu ui_player_speed 1; setfromdvar ui_player_speed temp; setfromdvar temp ui_weapon_current_name; setu ui_weapon_current_name 1; setfromdvar ui_weapon_current_name temp; setfromdvar temp ui_weapon_current_size; setu ui_weapon_current_size 1; setfromdvar ui_weapon_current_size temp; setfromdvar temp ui_weapon_current_clip; setu ui_weapon_current_clip 1; setfromdvar ui_weapon_current_clip temp; setfromdvar temp ui_weapon_current_stock; setu ui_weapon_current_stock 1; setfromdvar ui_weapon_current_stock temp; setfromdvar temp com_maxfps; setu com_maxfps 1; setfromdvar com_maxfps temp;" );
            player.init_spec_hud = true;
        }

        player thread watchSpectatorClient();
    }
}

watchSpectatorClient()
{
    self endon( "disconnect" );

    while ( true )
    {
        if ( !self isPlaying() )
        {
            playerSpectating = self getSpectatorClient();

            if ( isDefined( playerSpectating ) )
            {
                self setClientDvars(
                    "ui_key_w_active", playerSpectating forwardbuttonpressed(),
                    "ui_key_a_active", playerSpectating moveleftbuttonpressed(),
                    "ui_key_s_active", playerSpectating backbuttonpressed(),
                    "ui_key_d_active", playerSpectating moverightbuttonpressed(),
                    "ui_key_space_active", playerSpectating jumpbuttonpressed(),
                    "ui_player_timer", playerSpectating getUserInfo( "ui_player_timer" ),
                    "ui_health_value", playerSpectating.health,
                    "ui_health_bar", playerSpectating.health / 100,
                    "ui_fps_counter", playerSpectating getUserInfo( "com_maxfps" ),
                    "ui_weapon_current_name", playerSpectating getUserInfo( "ui_weapon_current_name" ),
                    "ui_weapon_current_size", playerSpectating getUserInfo( "ui_weapon_current_size" ),
                    "ui_weapon_current_clip", playerSpectating getUserInfo( "ui_weapon_current_clip" ),
                    "ui_weapon_current_stock", playerSpectating getUserInfo( "ui_weapon_current_stock" ),
                    "ui_player_speed", playerSpectating getUserInfo( "ui_player_speed" )
                );
            }

            wait 0.05;
        }
        else
            wait 1;
    }
}