#include "ui_mp/includes/utility.inc"

#define SPECTATING                  spectatingclient()

#define ITEM_ALIGN					HORIZONTAL_ALIGN_LEFT VERTICAL_ALIGN_SUBTOP
#define PLAYER_VIS                  dvarBool( "ui_player_vis" )
#define JUMPERS_VIS                 dvarBool( "ui_jumpers_vis" )
#define WEAPON_VIS                  dvarBool( "ui_weapon_vis" )
#define ROUNDS_VIS                  dvarBool( "ui_rounds_vis" )
#define KEYS_VIS                    dvarBool( "ui_spec_keys_vis" )
#define FPS_VIS                     dvarBool( "ui_spec_fps_vis" )

#define GAME_STATE                  dvarString( "ui_game_state" )
#define ROUND_CURRENT               dvarInt( "ui_rounds_played" )
#define ROUND_MAX                   dvarInt( "ui_rounds_limit" )
#define TIME_LEFT                   secondsAsCountdown( dvarInt( "ui_time_left" ) )
#define JUMPERS_ALIVE               dvarInt( "ui_jumpers_alive" )

#define WEAPON_NAME                 dvarString( "ui_weapon_current_name" )
#define WEAPON_NAME_LENGTH          dvarInt( "ui_weapon_current_size" )
#define WEAPON_CLIP                 dvarString( "ui_weapon_current_clip" )
#define WEAPON_STOCK                dvarString( "ui_weapon_current_stock" )

#define VALID_WEAPON                (WEAPON_NAME != "N")
#define TIMER_TEXT                  dvarString( "ui_player_timer" )
#define HEALTH_TEXT                 dvarInt( "ui_health_value" )
#define HEALTH_BAR                  dvarFloat( "ui_health_bar" )

#define SPEEDMETER_TEXT             dvarString( "ui_player_speed" )
#define SPEEDMETER_VIS              dvarBool( "ui_player_speed_vis" )
#define ROUND_STARTED               (GAME_STATE == "lobby" || GAME_STATE == "playing")

#define ROUND_X                     17
#define ROUND_Y                     27
#define ROUND_H                     25
#define ROUND_TEXT_X                (ROUND_X + 8)
#define ROUND_TEXT_Y                46.5
#define JUMPERS_Y                   (ROUND_Y * 2)
#define JUMPERS_TEXT_Y              73.5

#define PLAYER_INFO_X               17
#define PLAYER_INFO_Y               438
#define PLAYER_INFO_W               47.5
#define PLAYER_INFO_H               25
#define PLAYER_INFO_TEXT_Y          (PLAYER_INFO_Y + 18)
#define PLAYER_INFO_DIVIDER_X       (PLAYER_INFO_X + PLAYER_INFO_W)

#define WEAPON_X                    698
#define WEAPON_Y                    430
#define WEAPON_W                    89
#define WEAPON_H                    25
#define WEAPON_TEXT_Y               450

#define ROUND_STATUS_TEXT \
    CREATE_TEXT_VIS( ROUND_TEXT_X ROUND_TEXT_Y 0 0 ITEM_ALIGN, "Practice", 1 1 1 1, 0.3, 0, GAME_STATE == "practice" && ROUNDS_VIS ) \
    CREATE_TEXT_VIS( ROUND_TEXT_X ROUND_TEXT_Y 0 0 ITEM_ALIGN, "Waiting", 1 1 1 1, 0.3, 0, GAME_STATE == "waiting" && ROUNDS_VIS ) \
    CREATE_TEXT_VIS( ROUND_TEXT_X ROUND_TEXT_Y 0 0 ITEM_ALIGN, "Round " + ROUND_CURRENT + "/" + ROUND_MAX, 1 1 1 1, 0.3, 0, GAME_STATE != "waiting" && GAME_STATE != "practice" && ROUNDS_VIS )

#define HUD_ROUND_INFO \
    CREATE_SHADER_VIS( ROUND_X ROUND_Y 74 ROUND_H ITEM_ALIGN, "black", 1 1 1 0.6, ROUNDS_VIS ) \
    CREATE_SHADER_VIS( ROUND_X ROUND_Y 2 ROUND_H ITEM_ALIGN, "white", COLOR_ARCANE 1, ROUNDS_VIS ) \
    CREATE_SHADER_VIS( (ROUND_X + 74) ROUND_Y 34 ROUND_H ITEM_ALIGN, "hud_square_round_right", 0 0 0 0.7, ROUNDS_VIS ) \
    ROUND_STATUS_TEXT \
    ROUND_STATUS_TEXT \
    CREATE_TEXT_VIS( 107 46.5 0 0 1 1, TIME_LEFT, 1 1 1 1, 0.3, 1, ROUNDS_VIS )

#define HUD_JUMPER_INFO \
    CREATE_SHADER_VIS( ROUND_X JUMPERS_Y 68 ROUND_H ITEM_ALIGN, "black", 1 1 1 0.6, ROUND_STARTED && JUMPERS_VIS ) \
    CREATE_SHADER_VIS( ROUND_X JUMPERS_Y 2 ROUND_H ITEM_ALIGN, "white", COLOR_ARCANE 1, ROUND_STARTED && JUMPERS_VIS ) \
    CREATE_TEXT_VIS( ROUND_TEXT_X JUMPERS_TEXT_Y 0 0 ITEM_ALIGN, "Jumpers", 1 1 1 1, 0.3, 0, ROUND_STARTED && JUMPERS_VIS ) \
    CREATE_TEXT_VIS( ROUND_TEXT_X JUMPERS_TEXT_Y 0 0 ITEM_ALIGN, "Jumpers", 1 1 1 1, 0.3, 0, ROUND_STARTED && JUMPERS_VIS ) \
    CREATE_SHADER_VIS( (ROUND_X + 68) 54 23 ROUND_H ITEM_ALIGN, "hud_square_round_right", 0 0 0 0.7, ROUND_STARTED && JUMPERS_VIS ) \
    CREATE_TEXT_VIS( (ROUND_X + 79) JUMPERS_TEXT_Y 0 0 ITEM_ALIGN, JUMPERS_ALIVE, 1 1 1 1, 0.3, 1, ROUND_STARTED && JUMPERS_VIS )

#define WEAPON_NAME_INFO \
    CREATE_SHADER_VIS( WEAPON_X WEAPON_Y WEAPON_W WEAPON_H ITEM_ALIGN, "hud_square_round_left", 0 0 0 0.5, WEAPON_NAME_LENGTH >= 10 && VALID_WEAPON ) \
    CREATE_SHADER_VIS( (WEAPON_X + 22) WEAPON_Y 67 WEAPON_H ITEM_ALIGN, "hud_square_round_left", 0 0 0 0.5, WEAPON_NAME_LENGTH > 7 && WEAPON_NAME_LENGTH < 10 && VALID_WEAPON ) \
    CREATE_SHADER_VIS( (WEAPON_X + 34) 430 55 WEAPON_H ITEM_ALIGN, "hud_square_round_left", 0 0 0 0.5, WEAPON_NAME_LENGTH <= 7 && VALID_WEAPON ) \
    CREATE_TEXT_VIS( 743 WEAPON_TEXT_Y 0 0 ITEM_ALIGN, WEAPON_NAME, 1 1 1 1, 0.32, 1, WEAPON_NAME_LENGTH >= 10 && VALID_WEAPON ) \
    CREATE_TEXT_VIS( 743 WEAPON_TEXT_Y 0 0 ITEM_ALIGN, WEAPON_NAME, 1 1 1 1, 0.32, 1, WEAPON_NAME_LENGTH >= 10 && VALID_WEAPON ) \
    CREATE_TEXT_VIS( 752 WEAPON_TEXT_Y 0 0 ITEM_ALIGN, WEAPON_NAME, 1 1 1 1, 0.32, 1, WEAPON_NAME_LENGTH > 7 && WEAPON_NAME_LENGTH < 10 && VALID_WEAPON ) \
    CREATE_TEXT_VIS( 752 WEAPON_TEXT_Y 0 0 ITEM_ALIGN, WEAPON_NAME, 1 1 1 1, 0.32, 1, WEAPON_NAME_LENGTH > 7 && WEAPON_NAME_LENGTH < 10 && VALID_WEAPON ) \
    CREATE_TEXT_VIS( 760 WEAPON_TEXT_Y 0 0 ITEM_ALIGN, WEAPON_NAME, 1 1 1 1, 0.32, 1, WEAPON_NAME_LENGTH <= 7 && VALID_WEAPON ) \
    CREATE_TEXT_VIS( 760 WEAPON_TEXT_Y 0 0 ITEM_ALIGN, WEAPON_NAME, 1 1 1 1, 0.32, 1, WEAPON_NAME_LENGTH <= 7 && VALID_WEAPON )

#define WEAPON_INFO \
    WEAPON_NAME_INFO \
    CREATE_SHADER_VIS( (WEAPON_X + 89) WEAPON_Y 50 WEAPON_H ITEM_ALIGN, "hud_square_round_right", 0 0 0 0.7, VALID_WEAPON ) \
    CREATE_TEXT_VIS( (WEAPON_X + 113.5) WEAPON_TEXT_Y 0 0 ITEM_ALIGN, WEAPON_CLIP + "/" + WEAPON_STOCK, 1 1 1 1, 0.32, 1, VALID_WEAPON )

#define PLAYER_INFO \
    CREATE_SHADER_VIS( PLAYER_INFO_X PLAYER_INFO_Y PLAYER_INFO_W PLAYER_INFO_H ITEM_ALIGN, "hud_square_round_left", 0 0 0 0.6, PLAYER_VIS ) \
    CREATE_SHADER_VIS( (PLAYER_INFO_X + PLAYER_INFO_W) PLAYER_INFO_Y PLAYER_INFO_W PLAYER_INFO_H ITEM_ALIGN, "hud_square_round_right", 0 0 0 0.6, PLAYER_VIS ) \
    CREATE_TEXT_VIS( (PLAYER_INFO_X + 23) PLAYER_INFO_TEXT_Y 0 0 ITEM_ALIGN, TIMER_TEXT, 1 1 1 1, 0.28, 1, PLAYER_VIS ) \
    CREATE_SHADER_VIS( PLAYER_INFO_DIVIDER_X (PLAYER_INFO_Y + 4) 2 15 ITEM_ALIGN, "ui_hud_divider", 1 1 1 1, PLAYER_VIS ) \
    CREATE_TEXT_VIS( (PLAYER_INFO_X + 71.5) PLAYER_INFO_TEXT_Y 0 0 ITEM_ALIGN, HEALTH_TEXT, 1 1 1 1, 0.28, 1, PLAYER_VIS ) \
    CREATE_SHADER_EX( PLAYER_INFO_X (PLAYER_INFO_Y + 22) 95 3 ITEM_ALIGN, "ui_footer", 1 1 1 1, PLAYER_VIS, exp rect W( 95 * HEALTH_BAR ) )

#define SPEED_METER \
    CREATE_TEXT_EX( 427 475 0 0 ITEM_ALIGN, SPEEDMETER_TEXT, COLOR_ARCANE 1, 0.36, 1, SPEEDMETER_VIS, textstyle ITEM_TEXTSTYLE_SHADOWED )

#define KEY_W \
    CREATE_SHADER_VIS( 414 340 25 22 ITEM_ALIGN, "ui_key_w", 0 0 0 0.6, KEYS_VIS && SPECTATING && !dvarBool( "ui_key_w_active" ) ) \
    CREATE_SHADER_VIS( 414 340 25 22 ITEM_ALIGN, "ui_key_w", 0 0 0 1, KEYS_VIS && SPECTATING && dvarBool( "ui_key_w_active" ) ) \
    CREATE_TEXT_VIS( 426 358 0 0 ITEM_ALIGN, "W", 1 1 1 1, .28, 1, KEYS_VIS && SPECTATING )

#define KEY_A \
    CREATE_SHADER_VIS( 385 366 25 22 ITEM_ALIGN, "ui_key_a", 0 0 0 0.6, KEYS_VIS && SPECTATING && !dvarBool( "ui_key_a_active" ) ) \
    CREATE_SHADER_VIS( 385 366 25 22 ITEM_ALIGN, "ui_key_a", 0 0 0 1, KEYS_VIS && SPECTATING && dvarBool( "ui_key_a_active" ) ) \
    CREATE_TEXT_VIS( 397 384 0 0 ITEM_ALIGN, "A", 1 1 1 1, .28, 1, KEYS_VIS && SPECTATING )

#define KEY_S \
    CREATE_SHADER_VIS( 414 366 25 22 ITEM_ALIGN, "ui_key_s", 0 0 0 0.6, KEYS_VIS && SPECTATING && !dvarBool( "ui_key_s_active" ) ) \
    CREATE_SHADER_VIS( 414 366 25 22 ITEM_ALIGN, "ui_key_s", 0 0 0 1, KEYS_VIS && SPECTATING && dvarBool( "ui_key_s_active" ) ) \
    CREATE_TEXT_VIS( 426 384 0 0 ITEM_ALIGN, "S", 1 1 1 1, .28, 1, KEYS_VIS && SPECTATING )

#define KEY_D \
    CREATE_SHADER_VIS( 443 366 25 22 ITEM_ALIGN, "ui_key_d", 0 0 0 0.6, KEYS_VIS && SPECTATING && !dvarBool( "ui_key_d_active" ) ) \
    CREATE_SHADER_VIS( 443 366 25 22 ITEM_ALIGN, "ui_key_d", 0 0 0 1, KEYS_VIS && SPECTATING && dvarBool( "ui_key_d_active" ) ) \
    CREATE_TEXT_VIS( 455 384 0 0 ITEM_ALIGN, "D", 1 1 1 1, .28, 1, KEYS_VIS && SPECTATING )

#define KEY_SPACE \
    CREATE_SHADER_VIS( 385 392 84 20 ITEM_ALIGN, "ui_key_space", 0 0 0 0.6, KEYS_VIS && SPECTATING && !dvarBool( "ui_key_space_active" ) ) \
    CREATE_SHADER_VIS( 385 392 84 20 ITEM_ALIGN, "ui_key_space", 0 0 0 1, KEYS_VIS && SPECTATING && dvarBool( "ui_key_space_active" ) ) \
    CREATE_TEXT_VIS( 427 409 0 0 ITEM_ALIGN, "SPACE", 1 1 1 1, .28, 1, KEYS_VIS && SPECTATING )

#define SPECTATOR_KEYS \
    KEY_W \
    KEY_A \
    KEY_S \
    KEY_D \
    KEY_SPACE

#define SPECTATOR_FPS \
    CREATE_TEXT_VIS( 120 458 0 0 ITEM_ALIGN, dvarInt( "ui_fps_counter" ), 1 1 1 1, 0.36, 0, FPS_VIS && SPECTATING )