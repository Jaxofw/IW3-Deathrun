#include "ui_mp/includes/utility.inc"

#define ITEM_ALIGN											HORIZONTAL_ALIGN_LEFT VERTICAL_ALIGN_SUBTOP
#define MENU_X												107
#define MENU_Y												-4
#define MENU_W												200
#define MENU_H												640
#define MENU_ALIGN											HORIZONTAL_ALIGN_LEFT VERTICAL_ALIGN_SUBTOP
#define MENU_RECT											MENU_X MENU_Y MENU_W MENU_H MENU_ALIGN
#define MENU_BORDER_RECT									(MENU_X + MENU_W) MENU_Y 2 MENU_H MENU_ALIGN

#define HEADER_X											120
#define HEADER_Y											50
#define HEADER_RANK_BG_RECT									HEADER_X HEADER_Y 48 48 ITEM_ALIGN
#define HEADER_RANK_MT_RECT									(HEADER_X + 6.5) (HEADER_Y + 6.5) 35 35 ITEM_ALIGN
#define HEADER_TEXT_RECT									(HEADER_X + 55) (HEADER_Y + 21) 0 0 ITEM_ALIGN
#define HEADER_TEXT											"Welcome " + dvarString( "ui_menu_playername" )
#define HEADER_NEXT_RANK_RECT								(HEADER_X + 55) (HEADER_Y + 33) 36 36 ITEM_ALIGN
#define HEADER_XP_BAR_X										(HEADER_X + 55)
#define HEADER_XP_BAR_Y										(HEADER_Y + 37)
#define HEADER_XP_BAR_BG_RECT								HEADER_XP_BAR_X HEADER_XP_BAR_Y 105 4 ITEM_ALIGN
#define HEADER_XP_BAR_RECT									HEADER_XP_BAR_X HEADER_XP_BAR_Y 55 4 ITEM_ALIGN

#define FOOTER_Y											384
#define FOOTER_W											116
#define FOOTER_H											25
#define FOOTER_TEXT_Y										(FOOTER_Y + 18)

#define ARCANE_BUTTON_X										(MENU_X + 13)
#define ARCANE_BUTTON_Y										105
#define ARCANE_BUTTON_W										170
#define ARCANE_BUTTON_H										25
#define ARCANE_BUTTON_X_SPACING								0
#define ARCANE_BUTTON_Y_SPACING								(ARCANE_BUTTON_H + 5)
#define ARCANE_BUTTON_COL									0
#define ARCANE_BUTTON_ROW( idx )							( ( idx - 0 ) % 24 )
#define ARCANE_BUTTON_X_POS									(ARCANE_BUTTON_X + ARCANE_BUTTON_X_SPACING * ARCANE_BUTTON_COL)
#define ARCANE_BUTTON_Y_POS( idx )							(ARCANE_BUTTON_Y + ARCANE_BUTTON_Y_SPACING * ARCANE_BUTTON_ROW( idx ))
#define ARCANE_BUTTON_ORIGIN( idx )							ARCANE_BUTTON_X_POS ARCANE_BUTTON_Y_POS( idx )
#define ARCANE_BUTTON_RECT( idx )							ARCANE_BUTTON_ORIGIN( idx ) ARCANE_BUTTON_W ARCANE_BUTTON_H ITEM_ALIGN

#define ARCANE_UNLOCKABLE_RANK_RECT( idx )					(ARCANE_BUTTON_X_POS + 145) (ARCANE_BUTTON_Y_POS( idx ) + 18) 0 0 ITEM_ALIGN
#define ARCANE_UNLOCKABLE_LOCK_SHADER_RECT( idx )			(ARCANE_BUTTON_X_POS + 149) (ARCANE_BUTTON_Y_POS( idx ) + 6) 13 12 ITEM_ALIGN

#define ARCANE_MENU( blurworld_ ) \
	focuscolor 			1 1 1 1 \
	blurworld 			blurworld_ \
	CREATE_SHADER( MENU_RECT, "white", 0 0 0 0.5 ) \
	CREATE_SHADER( MENU_BORDER_RECT, "menu_button_border", COLOR_ARCANE 1 )

#define HEADER \
	CREATE_SHADER( HEADER_RANK_BG_RECT, "menu_rank_bg", 0 0 0 0.5 ) \
	CREATE_SHADER( HEADER_RANK_MT_RECT, RANK_SHADER, 1 1 1 1 ) \
	CREATE_TEXT( HEADER_TEXT_RECT, HEADER_TEXT, 1 1 1 1, 0.3, 0 ) \
	CREATE_TEXT_VIS( HEADER_NEXT_RANK_RECT, REQUIRED_XP + " XP Left Until Level " + (RANK + 1), 1 1 1 1, 0.24, 0, CAN_RANK_UP && PRESTIGE_NEXT == 0 ) \
	CREATE_TEXT_VIS( HEADER_NEXT_RANK_RECT, REQUIRED_XP + " XP Left Until Prestige " + (stat(2326) + 1), 1 1 1 1, 0.24, 0, CAN_RANK_UP && PRESTIGE_NEXT ) \
	CREATE_SHADER( HEADER_XP_BAR_BG_RECT, "menu_rank_bar", 0 0 0 0.2 ) \
	CREATE_SHADER_EX( HEADER_XP_BAR_RECT, "menu_rank_bar", COLOR_XP_BAR_NORMAL 1, !dvarBool( "ui_exp_event" ), exp rect W( 55 * GAINED_XP ) ) \
	CREATE_SHADER_EX( HEADER_XP_BAR_RECT, "menu_rank_bar", COLOR_XP_BAR_EVENT 1, dvarBool( "ui_exp_event" ), exp rect W( 55 * GAINED_XP ) )

#define BUTTON_ARCANE_SHADER( idx ) \
	CREATE_SHADER( ARCANE_BUTTON_RECT( idx ), "ui_menu_button", 0 0 0 0.5 ) \
	CREATE_SHADER( ARCANE_BUTTON_ORIGIN( idx ) 2 ARCANE_BUTTON_H ITEM_ALIGN, "white", COLOR_ARCANE 1 )

#define BUTTON_ARCANE( idx, string, action ) \
	BUTTON_ARCANE_SHADER( idx ) \
	CREATE_BUTTON_EX( ARCANE_BUTTON_RECT( idx ), string, 0.3, action, 1, textalignx 10 textaligny 19.5 )

#define BUTTON_PAGE( position, string, action ) \
	CREATE_BUTTON_EX( position ITEM_ALIGN, string, 0.26, close self; open action, 1, textalignx 6 textaligny 14 )

#define BUTTON_PAGE_PREV( idx, previousMenu ) \
	CREATE_SHADER( ARCANE_BUTTON_X_POS ARCANE_BUTTON_Y_POS( idx + .5 ) ( ARCANE_BUTTON_W + 2 ) 17 ITEM_ALIGN, "gradient", 0 0 0 0.5 ) \
	BUTTON_PAGE( ARCANE_BUTTON_X_POS ARCANE_BUTTON_Y_POS( idx + .5 ) 46 17, "@MENU_PAGE_PREVIOUS", previousMenu )

#define BUTTON_PAGE_NEXT( idx, previousMenu, nextMenu ) \
	CREATE_SHADER( ARCANE_BUTTON_X_POS ARCANE_BUTTON_Y_POS( idx + .5 ) ( ARCANE_BUTTON_W + 2 ) 17 ITEM_ALIGN, "gradient_center", 0 0 0 0.5 ) \
	BUTTON_PAGE( ARCANE_BUTTON_X_POS ARCANE_BUTTON_Y_POS( idx + .5 ) 46 17, "@MENU_PAGE_PREVIOUS", previousMenu ) \
	BUTTON_PAGE( (ARCANE_BUTTON_X_POS + 120) ARCANE_BUTTON_Y_POS( idx + .5 ) 52 17, "@MENU_PAGE_NEXT", nextMenu )

#define BUTTON_UNLOCKABLE( idx, table, itemId ) \
	BUTTON_ARCANE_SHADER( idx ) \
	CREATE_BUTTON_EX( ARCANE_BUTTON_RECT( idx ), tableLookup( table, 0, itemId, 4 ), 0.3, scriptMenuResponse itemId, 1, textalignx 10 textaligny 19.5 ) \
	CREATE_TEXT_VIS( ARCANE_UNLOCKABLE_RANK_RECT( idx ), "^1(" + tableLookup( table, 0, itemId, 2 ) + ")", 1 1 1 1, 0.25, 2, ITEM_UNLOCKED( table, itemId ) ) \
	CREATE_SHADER_VIS( ARCANE_UNLOCKABLE_LOCK_SHADER_RECT( idx ), "menu_lock", 1 1 1 1, ITEM_UNLOCKED( table, itemId ) )

#define ARCANE_DVARSLIDER( idx, textArg, dvarArg, defaultArg, minArg, maxArg, actionArg, extraArg, visArg ) \
	BUTTON_ARCANE_SHADER( idx ) \
	CREATE_TEXT( (ARCANE_BUTTON_X_POS + 10) (ARCANE_BUTTON_Y_POS( idx ) + 19.5) 0 0 ITEM_ALIGN, textArg, 1 1 1 1, 0.3, 0 ) \
	CREATE_DVARSLIDER( (ARCANE_BUTTON_X_POS + 70) ARCANE_BUTTON_Y_POS( idx ) SLIDER_W SLIDER_H ITEM_ALIGN, textArg, dvarArg, defaultArg, minArg, maxArg, actionArg, extraArg, visArg )

#define ARCANE_DVARFLOATLIST( idx, textArg, dvarArg, strListArg, actionArg ) \
	BUTTON_ARCANE_SHADER( idx ) \
	CREATE_TEXT( (ARCANE_BUTTON_X_POS + 10) (ARCANE_BUTTON_Y_POS( idx ) + 19.5) 0 0 ITEM_ALIGN, textArg, 1 1 1 1, 0.3, 0 ) \
	CREATE_DVARFLOATLIST( (ARCANE_BUTTON_X_POS + 75) ARCANE_BUTTON_Y_POS( idx ) 85 ARCANE_BUTTON_H ITEM_ALIGN, dvarArg, strListArg, actionArg )

#define FOOTER \
	CREATE_SHADER( ARCANE_BUTTON_X FOOTER_Y (FOOTER_W / 2) FOOTER_H ITEM_ALIGN, "hud_square_round_left", 0 0 0 0.5 ) \
	CREATE_SHADER( ( ARCANE_BUTTON_X + (FOOTER_W / 2) ) FOOTER_Y (FOOTER_W / 2) FOOTER_H ITEM_ALIGN, "hud_square_round_right", 0 0 0 0.5 ) \
	CREATE_SHADER( ARCANE_BUTTON_X (FOOTER_Y + FOOTER_H - 3) FOOTER_W 3 ITEM_ALIGN, "hud_notify_footer", 1 1 1 1 ) \
	CREATE_TEXT( (ARCANE_BUTTON_X + 10) FOOTER_TEXT_Y 0 0 ITEM_ALIGN, "Message of the Day", 1 1 1 1, 0.32, 0 ) \
	CREATE_TEXT_EX( (ARCANE_BUTTON_X + 5) (FOOTER_TEXT_Y + FOOTER_H + 3) 170 0 ITEM_ALIGN, dvarString( "motd" ), 1 1 1 1, 0.26, 0, 1, autowrapped )