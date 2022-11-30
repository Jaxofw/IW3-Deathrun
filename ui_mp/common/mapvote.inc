#include "ui_mp/common/game.inc"

#define MAPVOTE_X_START 				278
#define MAPVOTE_Y_START 				75
#define MAPVOTE_WIDTH 					163
#define MAPVOTE_HEIGHT					90
#define	MAPVOTE_SPACING					MAPVOTE_WIDTH + 11
#define MAPVOTE_COLOR					0.35 0.4 1 0.75
#define MAPVOTE_COLOR_SELECT			0.1 0.8 0.5 1

#define MAPVOTE_HEADER_HEIGHT			5
#define MAPVOTE_FOOTER_START_Y			MAPVOTE_Y_START + MAPVOTE_HEIGHT

#define MAPVOTE_BUTTON( id, idx, idy, map, maplabel ) \
	CREATE_SHADER_EX( (MAPVOTE_X_START + idx) (MAPVOTE_Y_START + idy - 2) MAPVOTE_WIDTH 2 1 1, "white", 0.35 0.4 1 0.75, 1, group id ) \
	CREATE_SHADER( (MAPVOTE_X_START + idx) (MAPVOTE_FOOTER_START_Y + idy) MAPVOTE_WIDTH 11 1 1, "menu_mapvote_footer", 0.35 0.4 1 0.75, 1 ) \
	CREATE_TEXT( (MAPVOTE_X_START + idx + 4) (MAPVOTE_FOOTER_START_Y + idy + 10) 36 36 1 1, maplabel, 1 1 1 1, 0.22, 0, 1 ) \
	CREATE_SHADER( (MAPVOTE_X_START + idx + 140) (MAPVOTE_FOOTER_START_Y + idy + 2) 6 6 1 1, "menu_mapvote_user", 1 1 1 1, 1 ) \
	CREATE_TEXT( (MAPVOTE_X_START + idx + 134) (MAPVOTE_FOOTER_START_Y + idy + 10) 36 36 1 1, dvarint( "mapvote_option_" + id + "_votes" ), 1 1 1 1, 0.22, 1, 1 ) \
	itemDef \
	{ \
		rect 			(MAPVOTE_X_START + idx) (MAPVOTE_Y_START + idy) MAPVOTE_WIDTH MAPVOTE_HEIGHT 1 1 \
		type			ITEM_TYPE_BUTTON \
		style			WINDOW_STYLE_FILLED \
		visible			1 \
		exp 			material ( loadscreen + "_" + map ) \
		backcolor		1 1 1 1 \
		action 			{ play "mouse_click"; scriptMenuResponse id; } \
		mouseEnter		{ setitemcolor id forecolor MAPVOTE_COLOR_SELECT; } \
		mouseExit		{ setitemcolor id forecolor MAPVOTE_COLOR; } \
	}

#define MAPVOTE_COUNTDOWN \
	CREATE_SHADER( 453 (MAPVOTE_Y_START - 40) (MAPVOTE_WIDTH / 2) 25 1 1, "gradient_fadein", 0 0 0 1, 1 ) \
	CREATE_SHADER( 534 (MAPVOTE_Y_START - 40) (MAPVOTE_WIDTH / 2) 25 1 1, "gradient", 0 0 0 1, 1 ) \
	CREATE_TEXT( 515 (MAPVOTE_Y_START - 18) 36 36 1 1, dvarstring( "mapvote_duration" ), 1 1 1 1, 0.4, 1, 1 )

#define MAPVOTE_RESTART \
	CREATE_SHADER( 453 (MAPVOTE_Y_START + 350) (MAPVOTE_WIDTH / 2) 25 1 1, "gradient_fadein", 0 0 0 1, 1 ) \
	CREATE_SHADER( 534 (MAPVOTE_Y_START + 350) (MAPVOTE_WIDTH / 2) 25 1 1, "gradient", 0 0 0 1, 1 ) \
	CREATE_TEXT_EX( 515 (MAPVOTE_Y_START + 350) 36 25 1 1, "Replay Map", 1 1 1 1, 0.4, 1, 1, type ITEM_TYPE_BUTTON; textaligny 21; backcolor 0 0 1 1; action { play "mouse_click"; scriptMenuResponse 10; } ) \
	CREATE_SHADER( 580 (MAPVOTE_Y_START + 359) 7 7 1 1, "menu_mapvote_user", 1 1 1 1, 1 ) \
	CREATE_TEXT( 576 (MAPVOTE_Y_START + 367.5) 36 36 1 1, dvarint( "mapvote_option_10_votes" ), 1 1 1 1, 0.22, 1, 1 )