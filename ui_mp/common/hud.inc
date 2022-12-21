#include "ui_mp/common/game.inc"

#define ROUND_STATUS        (dvarString( "ui_game_state" ))
#define ROUND_CURRENT       (dvarInt( "ui_rounds_played" ) + 1)
#define ROUND_MAX           (dvarInt( "ui_rounds_limit" ))
#define TIME_LEFT           (secondsAsCountdown( dvarInt( "ui_time_left" ) ))
#define JUMPERS_ALIVE       (dvarInt( "ui_jumpers_alive" ))

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