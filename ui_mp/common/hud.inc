#include "ui_mp/common/game.inc"

#define ROUND_STATUS        (dvarString( "ui_game_state" ))
#define ROUND_CURRENT       (dvarInt( "ui_rounds_played" ) + 1)
#define ROUND_MAX           (dvarInt( "ui_rounds_limit" ))
#define TIME_LEFT           (secondsAsCountdown( dvarInt( "ui_time_left" ) ))
#define JUMPERS_ALIVE       (dvarInt( "ui_jumpers_alive" ))

#define WEAPON_NAME         (dvarString( "ui_weapon_current_name" ))
#define WEAPON_NAME_LENGTH  (dvarInt( "ui_weapon_current_size" ))
#define WEAPON_CLIP         (dvarString( "ui_weapon_current_clip" ))
#define WEAPON_STOCK        (dvarString( "ui_weapon_current_stock" ))

#define VALID_WEAPON        (WEAPON_NAME != "N")
#define TIMER_TEXT          (dvarString( "ui_player_timer" ))
#define HEALTH_TEXT         (dvarInt( "ui_health_text" ))
#define HEALTH_BAR          (dvarFloat( "ui_health_bar" ))

#define SPEEDMETER_TEXT     (dvarString( "ui_player_speed" ))
#define SPEEDMETER_VIS      (dvarInt( "ui_player_speed_vis" ))

#define ROUND_TEXT \
    CREATE_TEXT( 25 46.5 0 0 1 1, "Practice", 1 1 1 1, 0.3, 0, ROUND_STATUS == "practice" ) \
    CREATE_TEXT( 25 46.5 0 0 1 1, "Round " + ROUND_CURRENT + "/" + ROUND_MAX, 1 1 1 1, 0.3, 0, ROUND_STATUS != "practice" )

#define HUD_ROUND_INFO \
    CREATE_SHADER( 17 27 2 25 1 1, "white", COLOR_ARCANE 1, 1 ) \
    CREATE_SHADER( 19 27 72 25 1 1, "black", 1 1 1 0.6, 1 ) \
    ROUND_TEXT \
    ROUND_TEXT \
    CREATE_SHADER( 91 27 34 25 1 1, "hud_square_round_right", 0 0 0 0.7, 1 ) \
    CREATE_TEXT( 107 46.5 0 0 1 1, TIME_LEFT, 1 1 1 1, 0.3, 1, 1 )

#define HUD_JUMPER_INFO \
    CREATE_SHADER( 17 54 2 25 1 0, "white", COLOR_ARCANE 1, ROUND_STATUS == "lobby" || ROUND_STATUS == "playing" ) \
    CREATE_SHADER( 19 54 66 25 1 0, "black", 1 1 1 0.6, ROUND_STATUS == "lobby" || ROUND_STATUS == "playing" ) \
    CREATE_TEXT( 25 73.5 0 0 1 1, "Jumpers", 1 1 1 1, 0.3, 0, ROUND_STATUS == "lobby" || ROUND_STATUS == "playing" ) \
    CREATE_TEXT( 25 73.5 0 0 1 1, "Jumpers", 1 1 1 1, 0.3, 0, ROUND_STATUS == "lobby" || ROUND_STATUS == "playing" ) \
    CREATE_SHADER( 85 54 23 25 1 0, "hud_square_round_right", 0 0 0 0.7, ROUND_STATUS == "lobby" || ROUND_STATUS == "playing" ) \
    CREATE_TEXT( 96 73.5 0 0 1 1, JUMPERS_ALIVE, 1 1 1 1, 0.3, 1, ROUND_STATUS == "lobby" || ROUND_STATUS == "playing" )

#define WEAPON_NAME_INFO \
    CREATE_SHADER( 698 430 89 25 1 1, "hud_square_round_left", 0 0 0 0.5, WEAPON_NAME_LENGTH >= 10 && VALID_WEAPON ) \
    CREATE_SHADER( 720 430 67 25 1 1, "hud_square_round_left", 0 0 0 0.5, WEAPON_NAME_LENGTH > 7 && WEAPON_NAME_LENGTH < 10 && VALID_WEAPON ) \
    CREATE_SHADER( 732 430 55 25 1 1, "hud_square_round_left", 0 0 0 0.5, WEAPON_NAME_LENGTH <= 7 && VALID_WEAPON ) \
    CREATE_TEXT( 743 450 0 0 1 1, WEAPON_NAME, 1 1 1 1, 0.32, 1, WEAPON_NAME_LENGTH >= 10 && VALID_WEAPON ) \
    CREATE_TEXT( 743 450 0 0 1 1, WEAPON_NAME, 1 1 1 1, 0.32, 1, WEAPON_NAME_LENGTH >= 10 && VALID_WEAPON ) \
    CREATE_TEXT( 752 450 0 0 1 1, WEAPON_NAME, 1 1 1 1, 0.32, 1, WEAPON_NAME_LENGTH > 7 && WEAPON_NAME_LENGTH < 10 && VALID_WEAPON ) \
    CREATE_TEXT( 752 450 0 0 1 1, WEAPON_NAME, 1 1 1 1, 0.32, 1, WEAPON_NAME_LENGTH > 7 && WEAPON_NAME_LENGTH < 10 && VALID_WEAPON ) \
    CREATE_TEXT( 760 450 0 0 1 1, WEAPON_NAME, 1 1 1 1, 0.32, 1, WEAPON_NAME_LENGTH <= 7 && VALID_WEAPON ) \
    CREATE_TEXT( 760 450 0 0 1 1, WEAPON_NAME, 1 1 1 1, 0.32, 1, WEAPON_NAME_LENGTH <= 7 && VALID_WEAPON )

#define WEAPON_INFO \
    WEAPON_NAME_INFO \
    CREATE_SHADER( 787 430 50 25 1 1, "hud_square_round_right", 0 0 0 0.7, VALID_WEAPON ) \
    CREATE_TEXT( 811.5 450 0 0 1 1, WEAPON_CLIP + "/" + WEAPON_STOCK, 1 1 1 1, 0.32, 1, VALID_WEAPON )

#define PLAYER_INFO \
    CREATE_SHADER( 17 438 47.5 25 1 1, "hud_square_round_left", 0 0 0 0.6, 1 ) \
    CREATE_SHADER( 64.5 438 47.5 25 1 1, "hud_square_round_right", 0 0 0 0.6, 1 ) \
    CREATE_TEXT( 40 456 0 0 1 1, TIMER_TEXT, 1 1 1 1, 0.28, 1, 1 ) \
    CREATE_SHADER( 64 442 2 15 1 1, "ui_hud_divider", 1 1 1 1, 1 ) \
    CREATE_TEXT( 88.5 456 0 0 1 1, HEALTH_TEXT, 1 1 1 1, 0.28, 1, 1 ) \
    CREATE_SHADER_EX( 17 460 95 3 1 1, "hud_notify_footer", 1 1 1 1, 1, exp	rect W( 95 * HEALTH_BAR ) )

#define SPEED_METER \
    CREATE_TEXT_EX( 426 475 0 0 1 1, SPEEDMETER_TEXT, COLOR_ARCANE 1, 0.36, 1, SPEEDMETER_VIS, textstyle ITEM_TEXTSTYLE_SHADOWED )