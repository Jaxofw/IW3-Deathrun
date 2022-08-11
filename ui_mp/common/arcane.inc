#define CREATE_SHADER( position, texture, forecolor, visibility ) \
	itemDef \
	{ \
		rect 			position \
		style 			WINDOW_STYLE_SHADER \
		foreColor 		forecolor \
		exp 			material ( texture ) \
		visible 		when ( visibility ) \
	}

#define CREATE_TEXT( position, string, forecolor, scale, visibility ) \
	itemDef \
	{ \
		rect 			position \
		foreColor 		forecolor \
		textscale		scale \
		exp 			text ( string ) \
		visible 		when ( visibility ) \
	}

#define CREATE_FOOTER \
	CREATE_TEXT( 120 403 36 36 1 0, "Message of the Day", 1 1 1 1, 0.32, 1 ) \
	CREATE_SHADER( 120 406 110 2 1 0, "white", 1 1 1 1, 1 ) \
	itemDef \
	{ \
		rect 			125 427 170 36 1 0 \
		foreColor 		1 1 1 1 \
		autowrapped \
		exp 			text ( dvarstring( "motd" ) ) \
		textscale		0.26 \
		textalign		ITEM_ALIGN_LEFT \
		visible 		when ( 1 ) \
	}

#define ARCANE_INGAME_MENU \
	focuscolor 			1 1 1 1 \
	blurworld 			2 \
	CREATE_SHADER( 107 -4 200 640 1 0, "white", 0 0 0 0.5, 1 ) \
	CREATE_SHADER( 120 50 48 48 1 0, "menu_rank_bg", 0 0 0 0.5, 1 ) \
	CREATE_SHADER( 124 55 40 40 1 0, "menu_rank_placeholder", 1 1 1 1, 1 ) \
	CREATE_TEXT( 175 71 36 36 1 0, "Welcome " + dvarstring( "ui_menu_playername" ), 1 1 1 1, 0.3, 1 ) \
	CREATE_TEXT( 175 83 36 36 1 0, "0000 XP Left Until Level 000", 1 1 1 1, 0.24, 1 ) \
	CREATE_SHADER( 175 87 105 4 1 0, "menu_rank_bar", 0 0 0 0.2, 1 ) \
	CREATE_SHADER( 175 87 55 4 1 0, "menu_rank_bar", 0.2 0.4 0.8 1, 1 )

#define BUTTON_X_START 					120
#define BUTTON_Y_START 					115
#define BUTTON_X_SIZE 					200
#define BUTTON_Y_SIZE 					25
#define BUTTON_X_SPACING				( BUTTON_X_SIZE + 4 )
#define BUTTON_Y_SPACING				( BUTTON_Y_SIZE + 4 )
#define BUTTON_ROW( idx )				( ( idx - 0 ) % 24 )
#define BUTTON_COL( idx )				( ( idx - 0 - ( ( idx - 0 ) % 24 ) ) / 24 )

#define BUTTON_HEADER_X_START 			118
#define BUTTON_HEADER_X_POS( idx )		( BUTTON_HEADER_X_START + BUTTON_X_SPACING * BUTTON_COL( idx ) )

#define BUTTON_X_POS( idx )				( BUTTON_X_START + BUTTON_X_SPACING * BUTTON_COL( idx ) )
#define BUTTON_Y_POS( idx )				( BUTTON_Y_START + BUTTON_Y_SPACING * BUTTON_ROW( idx ) )

#define BUTTON_ORIGIN( idx )			BUTTON_X_POS( idx ) BUTTON_Y_POS( idx )
#define BUTTON_HEADER_ORIGIN( idx )		BUTTON_HEADER_X_POS( idx ) BUTTON_Y_POS( idx )
#define BUTTON_RECT( idx )				BUTTON_ORIGIN( idx ) 170 BUTTON_Y_SIZE 1 1
#define BUTTON_HEADER_RECT( idx )		BUTTON_HEADER_ORIGIN( idx ) 180 BUTTON_Y_SIZE 1 1

#define CREATE_BUTTON( idx, string, action_, visibility ) \
	itemDef \
	{ \
		rect 			BUTTON_HEADER_RECT( idx ) \
		style			WINDOW_STYLE_SHADER \
		visible			when ( visibility ) \
		exp material	( "blue_button_shit" ) \
	} \
	itemDef \
	{ \
		rect 			BUTTON_RECT( idx ) \
		type			ITEM_TYPE_BUTTON \
		style			WINDOW_STYLE_FILLED \
		visible			when ( visibility ) \
		exp text		( string ) \
		exp material	( "grey_button_shit" ) \
		forecolor		1 1 1 1 \
		backcolor		0 0 0 0.5 \
		textaligny		19 \
		textalignx		8 \
		textscale		0.3 \
		action \
		{ \
			play "mouse_click"; action_ \
		} \
	}