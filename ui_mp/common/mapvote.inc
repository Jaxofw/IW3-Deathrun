#include "ui_mp/common/game.inc"

#define MAPVOTE_START_X 				278
#define MAPVOTE_START_Y 				75
#define MAPVOTE_WIDTH 					163
#define MAPVOTE_HEIGHT					90
#define	MAPVOTE_SPACING					(MAPVOTE_WIDTH + 11)
#define MAPVOTE_FOOTER_START_Y			MAPVOTE_START_Y + MAPVOTE_HEIGHT
#define MAPVOTE_COLOR					0.35 0.4 1 0.75
#define MAPVOTE_COLOR_SELECT			0.1 0.8 0.5 1
#define MAPVOTE_COLOR_WINNER			0.95 0.38 0.38 1
#define MAPVOTE_GRADIENT_HEIGHT			25

#define MAPVOTE_BUTTON( id, x, y ) \
	CREATE_SHADER_EX( (MAPVOTE_START_X + x) (MAPVOTE_START_Y + y - 2) MAPVOTE_WIDTH 2 1 1, "white", MAPVOTE_COLOR, 1, group id ) \
	CREATE_SHADER( (MAPVOTE_START_X + x) (MAPVOTE_START_Y + y - 2) MAPVOTE_WIDTH 2 1 1, "white", MAPVOTE_COLOR_SELECT, dvarInt( "mapvote_option_" + id + "_selected" ) ) \
	CREATE_SHADER( (MAPVOTE_START_X + x) (MAPVOTE_START_Y + y - 2) MAPVOTE_WIDTH 2 1 1, "white", MAPVOTE_COLOR_WINNER, dvarInt( "mapvote_option_" + id + "_winner" ) ) \
	CREATE_SHADER( (MAPVOTE_START_X + x) (MAPVOTE_FOOTER_START_Y + y) MAPVOTE_WIDTH 11 1 1, "menu_mapvote_footer", MAPVOTE_COLOR, 1 ) \
	CREATE_TEXT( (MAPVOTE_START_X + x + 4) (MAPVOTE_FOOTER_START_Y + y + 10) 0 0 1 1, dvarString( "mapvote_option_" + id + "_label" ), 1 1 1 1, 0.22, 0, 1 ) \
	CREATE_SHADER( (MAPVOTE_START_X + x + 150) (MAPVOTE_FOOTER_START_Y + y + 2) 6 6 1 1, "menu_mapvote_user", 1 1 1 1, 1 ) \
	CREATE_TEXT( (MAPVOTE_START_X + x + 144) (MAPVOTE_FOOTER_START_Y + y + 10) 0 0 1 1, dvarInt( "mapvote_option_" + id + "_votes" ), 1 1 1 1, 0.22, 1, 1 ) \
	itemDef \
	{ \
		rect 			(MAPVOTE_START_X + x) (MAPVOTE_START_Y + y) MAPVOTE_WIDTH MAPVOTE_HEIGHT 1 1 \
		type			ITEM_TYPE_BUTTON \
		style			WINDOW_STYLE_FILLED \
		visible			1 \
		exp 			material ( loadscreen + "_" + dvarString( "mapvote_option_" + id ) ) \
		backcolor		1 1 1 1 \
		action 			{ play "mouse_click"; scriptMenuResponse id; } \
		mouseEnter		{ setitemcolor id forecolor MAPVOTE_COLOR_SELECT; } \
		mouseExit		{ setitemcolor id forecolor MAPVOTE_COLOR; } \
	}

#define MAPVOTE_COUNTDOWN \
	CREATE_SHADER( 453 (MAPVOTE_START_Y - 40) (MAPVOTE_WIDTH / 2) MAPVOTE_GRADIENT_HEIGHT 1 1, "gradient_fadein", 0 0 0 1, 1 ) \
	CREATE_SHADER( 534 (MAPVOTE_START_Y - 40) (MAPVOTE_WIDTH / 2) MAPVOTE_GRADIENT_HEIGHT 1 1, "gradient", 0 0 0 1, 1 ) \
	CREATE_TEXT( 515 (MAPVOTE_START_Y - 18) 36 36 1 1, dvarString( "mapvote_duration" ), 1 1 1 1, 0.4, 1, 1 )

#define MAPVOTE_RESTART \
	CREATE_SHADER( 453 (MAPVOTE_START_Y + 350) (MAPVOTE_WIDTH / 2) MAPVOTE_GRADIENT_HEIGHT 1 1, "gradient_fadein", 0 0 0 1, 1 ) \
	CREATE_SHADER( 534 (MAPVOTE_START_Y + 350) (MAPVOTE_WIDTH / 2) MAPVOTE_GRADIENT_HEIGHT 1 1, "gradient", 0 0 0 1, 1 ) \
	CREATE_TEXT_EX( 515 (MAPVOTE_START_Y + 350) 36 25 1 1, "Replay Map", 1 1 1 1, 0.4, 1, 1, type ITEM_TYPE_BUTTON; textaligny 21; backcolor 0 0 1 1; action { play "mouse_click"; scriptMenuResponse 9; } ) \
	CREATE_SHADER( 580 (MAPVOTE_START_Y + 359) 7 7 1 1, "menu_mapvote_user", 1 1 1 1, 1 ) \
	CREATE_TEXT( 576 (MAPVOTE_START_Y + 367.5) 36 36 1 1, dvarInt( "mapvote_option_9_votes" ), 1 1 1 1, 0.22, 1, 1 )