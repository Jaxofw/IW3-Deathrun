#define JUMPER 							"mp/jumperTable.csv"
#define PRIMARY 						"mp/primaryTable.csv"
#define SECONDARY 						"mp/secondaryTable.csv"
#define GLOVE 							"mp/gloveTable.csv"

#define CURRENT_LEVEL 					(stat(2350) + 1)
#define CURRENT_LEVEL_MT 				tablelookup( "mp/rankIconTable.csv", 0, stat(252), stat(2326) + 1 )
#define CURRENT_XP 						(tablelookup( "mp/rankTable.csv" , 0, stat(252), 7 ) - stat(2301))
#define NEXT_LEVEL 						tablelookup( "mp/rankIconTable.csv", 0, stat(252) + 2, stat(2326) )
#define MAX_LEVEL						tableLookup( "mp/rankTable.csv", 0, "maxrank", 1 )

#define BUTTON_X_START 					120
#define BUTTON_Y_START 					105
#define BUTTON_X_SIZE 					200
#define BUTTON_Y_SIZE 					25
#define BUTTON_X_SPACING				( BUTTON_X_SIZE + 4 )
#define BUTTON_Y_SPACING				( BUTTON_Y_SIZE + 4 )
#define BUTTON_COL( idx )				( ( idx - 0 - ( ( idx - 0 ) % 24 ) ) / 24 )
#define BUTTON_ROW( idx )				( ( idx - 0 ) % 24 )

#define BUTTON_HEADER_X_START 			118
#define BUTTON_HEADER_X_POS( idx )		( BUTTON_HEADER_X_START + BUTTON_X_SPACING * BUTTON_COL( idx ) )

#define BUTTON_X_POS( idx )				( BUTTON_X_START + BUTTON_X_SPACING * BUTTON_COL( idx ) )
#define BUTTON_Y_POS( idx )				( BUTTON_Y_START + BUTTON_Y_SPACING * BUTTON_ROW( idx ) )

#define BUTTON_ORIGIN( idx )			BUTTON_X_POS( idx ) BUTTON_Y_POS( idx )
#define BUTTON_HEADER_ORIGIN( idx )		BUTTON_HEADER_X_POS( idx ) BUTTON_Y_POS( idx )
#define BUTTON_RECT( idx )				BUTTON_ORIGIN( idx ) 170 BUTTON_Y_SIZE 1 1
#define BUTTON_HEADER_RECT( idx )		BUTTON_HEADER_ORIGIN( idx ) 180 BUTTON_Y_SIZE 1 1

#define CREATE_SHADER( position, texture, forecolor_, visible_ ) \
	CREATE_SHADER_EX( position, texture, forecolor_, visible_, ; )

#define CREATE_SHADER_EX( position, texture, forecolor_, visible_, extra ) \
	itemDef \
	{ \
		rect 			position \
		style 			WINDOW_STYLE_SHADER \
		forecolor 		forecolor_ \
		exp 			material ( texture ) \
		visible 		when ( visible_ ) \
		extra			\
	}

#define CREATE_TEXT( position, string, forecolor_, scale, textalign_, visible_ ) \
	CREATE_TEXT_EX( position, string, forecolor_, scale, textalign_, visible_, ; )

#define CREATE_TEXT_EX( position, string, forecolor_, scale, textalign_, visible_, extra ) \
	itemDef \
	{ \
		rect 			position \
		forecolor 		forecolor_ \
		textscale		scale \
		textalign		textalign_ \
		exp 			text ( string ) \
		visible 		when ( visible_ ) \
		extra			\
	}

#define CREATE_FOOTER \
	CREATE_TEXT( 120 403 36 36 1 0, "Message of the Day", 1 1 1 1, 0.32, 0, 1 ) \
	CREATE_SHADER( 120 406 110 2 1 0, "white", 1 1 1 1, 1 ) \
	CREATE_TEXT_EX( 125 427 170 36 1 0, dvarstring( "motd" ), 1 1 1 1, 0.26, 0, 1, autowrapped )

#define MENU_XP_BAR \
	itemDef \
	{ \
		rect 			175 87 55 4 1 0 \
		style 			WINDOW_STYLE_SHADER \
		foreColor 		0.2 0.4 0.8 1 \
		background		"menu_rank_bar" \
		exp 			rect W( 87 * ((stat(2301) - stat(2351)) / (stat(2352) - stat(2351))) ) \
		visible 		when ( 1 ) \
	}

#define XP_UNTIL_NEXT_LEVEL \
	CREATE_TEXT( 175 83 36 36 1 0, CURRENT_XP + " XP Left Until Level " + NEXT_LEVEL, 1 1 1 1, 0.24, 0, CURRENT_LEVEL < MAX_LEVEL ) \
	CREATE_TEXT( 175 83 36 36 1 0, CURRENT_XP + " XP Left Until Prestige 1", 1 1 1 1, 0.24, 0, (CURRENT_LEVEL - 1) == MAX_LEVEL )

#define ARCANE_INGAME_MENU( blurworld_ ) \
	focuscolor 			1 1 1 1 \
	blurworld 			blurworld_ \
	CREATE_SHADER( 107 -4 200 640 1 0, "white", 0 0 0 0.5, 1 ) \
	CREATE_SHADER( 307 -4 2 640 1 0, "menu_button_border", 0.2 0.4 0.8 1, 1 ) \
	CREATE_SHADER( 120 50 48 48 1 0, "menu_rank_bg", 0 0 0 0.5, 1 ) \
	CREATE_SHADER( 126.5 56.5 35 35 1 0, CURRENT_LEVEL_MT, 1 1 1 1, 1 ) \
	CREATE_TEXT( 175 71 36 36 1 0, "Welcome " + dvarstring( "ui_menu_playername" ), 1 1 1 1, 0.3, 0, 1 ) \
	XP_UNTIL_NEXT_LEVEL \
	CREATE_SHADER( 175 87 105 4 1 0, "menu_rank_bar", 0 0 0 0.2, 1 ) \
	MENU_XP_BAR

#define CREATE_BUTTON( idx, string, action_, visible_ ) \
	itemDef \
	{ \
		rect 			BUTTON_X_POS( idx ) BUTTON_Y_POS( idx ) 5 BUTTON_Y_SIZE 1 1 \
		style			WINDOW_STYLE_SHADER \
		visible			when ( visible_ ) \
		forecolor		0 0.502 1 1 \
		exp 			material ( "menu_button_border" ) \
	} \
	itemDef \
	{ \
		rect 			BUTTON_RECT( idx ) \
		type			ITEM_TYPE_BUTTON \
		style			WINDOW_STYLE_FILLED \
		visible			when ( visible_ ) \
		exp 			text ( string ) \
		exp 			material ( "grey_button_shit" ) \
		forecolor		1 1 1 1 \
		backcolor		0 0 0 0.5 \
		textaligny		19 \
		textalignx		8 \
		textscale		0.3 \
		action 			{ play "mouse_click"; action_; } \
	}

#define PAGE_BUTTON( position, string, action_, visible_ ) \
	itemDef \
	{ \
		rect 			position \
		type			ITEM_TYPE_BUTTON \
		style			WINDOW_STYLE_FILLED \
		visible			when ( visible_ ) \
		exp 			text ( string ) \
		forecolor		1 1 1 1 \
		backcolor		0 0 0 0 \
		textalignx		6 \
		textaligny		14 \
		textscale		0.26 \
		mouseEnter 		{ play "mouse_over"; } \
		action 			{ play "mouse_click"; close self action_; } \
	}

#define UNLOCKABLE( idx, table, action_, visible_ ) \
	CREATE_SHADER( BUTTON_X_POS( idx ) BUTTON_Y_POS( idx ) 5 BUTTON_Y_SIZE 1 1, "menu_button_border", 0 0.502 1 1, 1 ) \
	itemDef \
	{ \
		rect 			BUTTON_RECT( idx ) \
		type			ITEM_TYPE_BUTTON \
		style			WINDOW_STYLE_FILLED \
		visible			when ( visible_ ) \
		exp 			text ( tableLookup( table, 0, action_, 4 ) ) \
		exp 			material ( "grey_button_shit" ) \
		forecolor		1 1 1 1 \
		backcolor		0 0 0 0.5 \
		textaligny		19 \
		textalignx		8 \
		textscale		0.3 \
		action 			{ play "mouse_click"; scriptMenuResponse action_; } \
	} \
	CREATE_TEXT( \
		(BUTTON_X_POS( idx ) + 119) (BUTTON_Y_POS( idx ) + 17.5) 36 36 1 0, \
		"^1(" + tableLookup( table, 0, action_, 2 ) + ")", \
		1 1 1 1, 0.25, 1, \
		CURRENT_LEVEL < tableLookup( table, 0, action_, 2 ) \
	) \
	CREATE_SHADER( (BUTTON_X_POS( idx ) + 150) (BUTTON_Y_POS( idx ) + 7) 10 10 1 1, "menu_lock", 1 1 1 1, CURRENT_LEVEL < tableLookup( table, 0, action_, 2 ) )