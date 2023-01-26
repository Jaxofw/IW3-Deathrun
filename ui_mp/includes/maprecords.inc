#include "ui_mp/includes/utility.inc"

#define RECORD_ALIGN								1 1

#define RECORD_COLOR								0.18 0.36 0.82
#define RECORD_COLOR_NEW							0.47 0.71 0.12

#define RECORD_HEADER_X								469
#define RECORD_HEADER_Y								105
#define RECORD_HEADER_W								130
#define RECORD_HEADER_H								40
#define RECORD_HEADER_O								RECORD_HEADER_X RECORD_HEADER_Y
#define RECORD_HEADER_RECT							RECORD_HEADER_W RECORD_HEADER_H RECORD_ALIGN

#define RECORD_X									364
#define RECORD_Y									164
#define RECORD_W									150
#define RECORD_H									46
#define RECORD_X_SPACING							95
#define RECORD_Y_SPACING							68

#define RECORD_COL( column )						(( column - 0 ) % 24)
#define RECORD_ROW( row )							(( row - 0 ) % 24)
#define RECORD_X_POS( row )							(RECORD_X + RECORD_X_SPACING * RECORD_COL( row ))
#define RECORD_Y_POS( column )						(RECORD_Y + RECORD_Y_SPACING * RECORD_ROW( column ))
#define RECORD_ORIGIN( row, column )				RECORD_X_POS( row ) RECORD_Y_POS( column )
#define RECORD_RECT( row, column )					RECORD_ORIGIN( row, column ) RECORD_W RECORD_H RECORD_ALIGN

#define RECORD_FOOTER_H								3
#define RECORD_FOOTER_ORIGIN( row, column )			(RECORD_X_POS( row ) + 1) (RECORD_Y_POS( column ) + RECORD_H - 3)
#define RECORD_FOOTER_RECT( row, column )			RECORD_FOOTER_ORIGIN( row, column) (RECORD_W - 2 ) RECORD_FOOTER_H RECORD_ALIGN

#define RECORD_MT_BG_X( row )						(RECORD_X_POS( row ) + 5)
#define RECORD_MT_BG_Y( column )					(RECORD_Y_POS( column ) + 5)
#define RECORD_MT_BG_W								37
#define RECORD_MT_BG_H								35
#define RECORD_MT_BG_ORIGIN( row, column )			RECORD_MT_BG_X( row ) RECORD_MT_BG_Y( column )
#define RECORD_MT_BG_RECT( row, column )			RECORD_MT_BG_ORIGIN( row, column ) RECORD_MT_BG_W RECORD_MT_BG_H RECORD_ALIGN

#define RECORD_MT_W									27
#define RECORD_MT_H									27
#define RECORD_MT_ORIGIN( row, column )				(RECORD_MT_BG_X( row ) + 5) (RECORD_MT_BG_Y( column ) + 4 )
#define RECORD_MT_RECT( row, column )				RECORD_MT_ORIGIN( row, column ) RECORD_MT_W RECORD_MT_H RECORD_ALIGN

#define RECORD_TITLE_X( row )						(RECORD_MT_BG_X( row ) + RECORD_MT_BG_W + 8)
#define RECORD_TITLE_Y( column )					(RECORD_MT_BG_Y( column ) + 19)
#define RECORD_TITLE_ORIGIN( row, column )			RECORD_TITLE_X( row ) RECORD_TITLE_Y( column )
#define RECORD_TITLE_RECT							0 0 RECORD_ALIGN

#define RECORD_HOLDER_ORIGIN( row, column )			RECORD_TITLE_X( row) (RECORD_TITLE_Y( column ) + 11 )
#define RECORD_UPDATED_ORIGIN( row, column )		(RECORD_X_POS( row ) + RECORD_W - 28) (RECORD_Y_POS( column ) + 16)

#define RECORD_COUNTDOWN_X							825
#define RECORD_COUNTDOWN_Y							450
#define RECORD_COUNTDOWN_W							60
#define RECORD_COUNTDOWN_H							22

#define RECORD_COUNTDOWN_TEXT						dvarString( "ui_records_countdown" )
#define RECORD_COUNTDOWN_TEXT_Y						18

#define RECORD_COUNTDOWN \
	CREATE_SHADER( RECORD_COUNTDOWN_X RECORD_COUNTDOWN_Y RECORD_COUNTDOWN_W RECORD_COUNTDOWN_H RECORD_ALIGN, "hud_square_round_left", 0 0 0 0.6 ) \
	CREATE_SHADER( (RECORD_COUNTDOWN_X + 60 ) RECORD_COUNTDOWN_Y RECORD_COUNTDOWN_W RECORD_COUNTDOWN_H RECORD_ALIGN, "hud_square_round_right", 0 0 0 0.6 ) \
	CREATE_TEXT( (RECORD_COUNTDOWN_X + 60) (RECORD_COUNTDOWN_Y + RECORD_COUNTDOWN_TEXT_Y) 0 0 RECORD_ALIGN, RECORD_COUNTDOWN_TEXT, 1 1 1 1, 0.3, 1 ) \
	CREATE_TEXT( (RECORD_COUNTDOWN_X + 60) (RECORD_COUNTDOWN_Y + RECORD_COUNTDOWN_TEXT_Y) 0 0 RECORD_ALIGN, RECORD_COUNTDOWN_TEXT, 1 1 1 1, 0.3, 1 )

#define RECORD_HEADER \
	CREATE_SHADER( RECORD_HEADER_O RECORD_HEADER_RECT, "hud_notify", 1 1 1 0.65 ) \
	CREATE_TEXT( (RECORD_HEADER_X + 65) (RECORD_HEADER_Y + 21) 0 0 RECORD_ALIGN, "BEST PLAYERS OF", 1 1 1 1, 0.38, 1 ) \
	CREATE_TEXT( (RECORD_HEADER_X + 65) (RECORD_HEADER_Y + 37) 0 0 RECORD_ALIGN, dvarString( "ui_records_map" ), 1 1 1 1, 0.36, 1 )

#define RECORD( id, row, column, material ) \
	CREATE_SHADER( RECORD_RECT( row, column ), "hud_notify", 1 1 1 0.65 ) \
	CREATE_SHADER( RECORD_FOOTER_RECT( row, column ), "ui_footer_round", RECORD_COLOR 1 ) \
	CREATE_SHADER( RECORD_MT_BG_RECT( row, column ), "ui_square_round", 0 0 0 0.3 ) \
	CREATE_SHADER( RECORD_MT_RECT( row, column ), material, 1 1 1 1 ) \
	CREATE_TEXT( RECORD_TITLE_ORIGIN( row, column ) RECORD_TITLE_RECT, dvarString( "ui_record_name_" + id ), 1 1 1 1, 0.28, 0 ) \
	CREATE_TEXT( RECORD_HOLDER_ORIGIN( row, column ) RECORD_TITLE_RECT, dvarString( "ui_record_holder_" + id ), 1 1 1 1, 0.28, 0 ) \
	CREATE_TEXT_VIS( RECORD_UPDATED_ORIGIN( row, column ) RECORD_TITLE_RECT, "NEW", RECORD_COLOR_NEW 1, 0.28, 0, dvarBool( "ui_record_updated_" + id ) ) \
	CREATE_TEXT_VIS( RECORD_UPDATED_ORIGIN( row, column ) RECORD_TITLE_RECT, "NEW", RECORD_COLOR_NEW 1, 0.28, 0, dvarBool( "ui_record_updated_" + id ) )