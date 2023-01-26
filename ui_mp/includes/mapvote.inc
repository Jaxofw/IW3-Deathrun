#include "ui_mp/includes/utility.inc"

#define MAPVOTE_ALIGN										1 1
#define MAPVOTE_COLOR										0.35 0.4 1 0.6
#define MAPVOTE_COLOR_WINNER								0.95 0.38 0.38 0.6

#define MAPVOTE_X											278
#define MAPVOTE_Y											75
#define MAPVOTE_W											163
#define MAPVOTE_H											90
#define MAPVOTE_X_SPACING									(MAPVOTE_W + 11)
#define MAPVOTE_Y_SPACING									(MAPVOTE_H + 25)
#define MAPVOTE_COL( column )								(( column - 0 ) % 24)
#define MAPVOTE_ROW( row )									(( row - 0 ) % 24)
#define MAPVOTE_X_POS( row )								(MAPVOTE_X + MAPVOTE_X_SPACING * MAPVOTE_COL( row ))
#define MAPVOTE_Y_POS( column )								(MAPVOTE_Y + MAPVOTE_Y_SPACING * MAPVOTE_ROW( column ))
#define MAPVOTE_ORIGIN( row, column )						MAPVOTE_X_POS( row ) MAPVOTE_Y_POS( column )
#define MAPVOTE_RECT( row, column )							MAPVOTE_ORIGIN( row, column ) MAPVOTE_W MAPVOTE_H MAPVOTE_ALIGN
#define MAPVOTE_HEADER_H									2
#define MAPVOTE_HEADER_RECT( row, column )					MAPVOTE_X_POS( row ) (MAPVOTE_Y_POS( column ) - MAPVOTE_HEADER_H)
#define MAPVOTE_FOOTER_Y( column )							(MAPVOTE_Y_POS( column ) + MAPVOTE_H)

#define MAPVOTE_COUNTDOWN \
	CREATE_SHADER( 453 (MAPVOTE_Y - 40) (MAPVOTE_W / 2) 25 MAPVOTE_ALIGN, "gradient_fadein", 0 0 0 1 ) \
	CREATE_SHADER( 534 (MAPVOTE_Y - 40) (MAPVOTE_W / 2) 25 MAPVOTE_ALIGN, "gradient", 0 0 0 1 ) \
	CREATE_TEXT( 515 (MAPVOTE_Y - 18) 36 36 1 1, dvarString( "mapvote_duration" ), 1 1 1 1, 0.4, 1 )

#define MAPVOTE( idx, row, column ) \
	CREATE_SHADER_EX( MAPVOTE_HEADER_RECT( row, column ) MAPVOTE_W MAPVOTE_HEADER_H MAPVOTE_ALIGN, "white", MAPVOTE_COLOR, 1, group idx ) \
	CREATE_SHADER_VIS( MAPVOTE_HEADER_RECT( row, column ) MAPVOTE_W MAPVOTE_HEADER_H MAPVOTE_ALIGN, "white", COLOR_ITEM_SELECTED, dvarBool( "mapvote_option_" + idx + "_selected" ) ) \
	CREATE_SHADER_VIS( MAPVOTE_HEADER_RECT( row, column ) MAPVOTE_W MAPVOTE_HEADER_H MAPVOTE_ALIGN, "white", MAPVOTE_COLOR_WINNER, dvarBool( "mapvote_option_" + idx + "_winner" ) ) \
	CREATE_SHADER( MAPVOTE_X_POS( row ) MAPVOTE_FOOTER_Y( column ) MAPVOTE_W 11 MAPVOTE_ALIGN, "menu_mapvote_footer", MAPVOTE_COLOR ) \
	CREATE_TEXT( (MAPVOTE_X_POS( row ) + 4) (MAPVOTE_FOOTER_Y( column ) + 10) 0 0 MAPVOTE_ALIGN, dvarString( "mapvote_option_" + idx + "_label" ), 1 1 1 1, 0.22, 0 ) \
	CREATE_SHADER( (MAPVOTE_X_POS( row ) + 142) (MAPVOTE_FOOTER_Y( column ) + 2.5) 6 6 MAPVOTE_ALIGN, "menu_mapvote_user", 1 1 1 1 ) \
	CREATE_TEXT( (MAPVOTE_X_POS( row ) + 154) (MAPVOTE_FOOTER_Y( column ) + 10.5) 0 0 MAPVOTE_ALIGN, dvarInt( "mapvote_option_" + idx + "_votes" ), 1 1 1 1, 0.22, 1 ) \
	CREATE_SHADER_EX( MAPVOTE_RECT( row, column ), "loadscreen" + "_" + dvarString( "mapvote_option_" + idx ) + "_1", 1 1 1 1, 1, type ITEM_TYPE_BUTTON; action { play "mouse_click"; scriptMenuResponse idx; }; mouseEnter { setitemcolor idx forecolor MAPVOTE_COLOR_SELECT; }; mouseExit { setitemcolor idx forecolor MAPVOTE_COLOR; } )

#define MAPVOTE_REPLAY \
	CREATE_SHADER( 453 (MAPVOTE_Y + 350) (MAPVOTE_W / 2) 25 1 1, "gradient_fadein", 0 0 0 1 ) \
	CREATE_SHADER( 534 (MAPVOTE_Y + 350) (MAPVOTE_W / 2) 25 1 1, "gradient", 0 0 0 1 ) \
	CREATE_TEXT_EX( 515 (MAPVOTE_Y + 350) 36 25 1 1, "Replay Map", 1 1 1 1, 0.4, 1, 1, type ITEM_TYPE_BUTTON; textaligny 21; backcolor 0 0 1 1; action { play "mouse_click"; scriptMenuResponse 9; } ) \
	CREATE_SHADER( 580 (MAPVOTE_Y + 359) 7 7 1 1, "menu_mapvote_user", 1 1 1 1 ) \
	CREATE_TEXT( 576 (MAPVOTE_Y + 367.5) 36 36 1 1, dvarInt( "mapvote_option_9_votes" ), 1 1 1 1, 0.22, 1 )