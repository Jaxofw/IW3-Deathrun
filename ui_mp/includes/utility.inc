#define JUMPER 										"mp/jumperTable.csv"
#define ACTIVATOR 									"mp/activatorTable.csv"
#define PRIMARY 									"mp/primaryTable.csv"
#define SECONDARY 									"mp/secondaryTable.csv"
#define GLOVE 										"mp/gloveTable.csv"

#define RANK										int( tablelookup( "mp/rankIconTable.csv", 0, stat(252) + 1, stat(2326) ) )
#define RANK_SHADER									tablelookup( "mp/rankIconTable.csv", 0, stat(252), stat(2326) + 1 )
#define REQUIRED_XP 								(tablelookup( "mp/rankTable.csv" , 0, stat(252), 7 ) - stat(2301))
#define GAINED_XP									(stat(2301) - stat(2351)) / (stat(2352) - stat(2351))
#define ITEM_UNLOCKED( table, itemId )				( (RANK + 1) < tableLookup( table, 0, itemId, 2 ) )

#define SLIDER_W									95
#define SLIDER_H									20

#define COLOR_ARCANE								0.18 0.36 0.82
#define COLOR_XP_BAR_NORMAL							0 0.5 1
#define COLOR_XP_BAR_EVENT							1 0.8 0.4

#define CREATE_SHADER( position, texture, color ) \
	CREATE_SHADER_VIS( position, texture, color, 1 )

#define CREATE_SHADER_VIS( position, texture, color, visibility ) \
	CREATE_SHADER_EX( position, texture, color, visibility, ; )

#define CREATE_SHADER_EX( position, texture, color, visibility, extra ) \
	itemDef \
	{ \
		rect 			position \
		style 			WINDOW_STYLE_SHADER \
		forecolor 		color \
		exp 			material ( texture ) \
		visible 		when ( visibility ) \
		extra			\
	}

#define CREATE_TEXT( position, string, forecolor_, textscale_, textalign_ ) \
	CREATE_TEXT_VIS( position, string, forecolor_, textscale_, textalign_, 1 )

#define CREATE_TEXT_VIS( position, string, forecolor_, textscale_, textalign_, visibility ) \
	CREATE_TEXT_EX( position, string, forecolor_, textscale_, textalign_, visibility, ; )

#define CREATE_TEXT_EX( position, string, forecolor_, textscale_, textalign_, visibility, extra ) \
	itemDef \
	{ \
		rect 			position \
		style 			ITEM_TEXTSTYLE_NORMAL \
		forecolor 		forecolor_ \
		textfont		UI_FONT_DEFAULT \
		textscale		textscale_ \
		textalign		textalign_ \
		exp 			text ( string ) \
		visible 		when ( visibility ) \
		extra \
	}

#define CREATE_BUTTON( position, string, textscale_, action_ ) \
	CREATE_BUTTON_VIS( position, string, textscale_, action_, 1 )

#define CREATE_BUTTON_VIS( position, string, textscale_, action_, visibility ) \
	CREATE_BUTTON_EX( position, string, textscale_, action_, visibility, ; )

#define CREATE_BUTTON_EX( position, string, textscale_, action_, visibility, extra ) \
	itemDef \
	{ \
		rect 			position \
		style			WINDOW_STYLE_EMPTY \
		type			ITEM_TYPE_BUTTON \
		textscale		textscale_ \
		forecolor		1 1 1 1 \
		exp 			text ( string ) \
		visible			when ( visibility ) \
		action 			{ play "mouse_click"; action_; } \
		extra			\
	}

#undef CHOICE_SCRIPTS_ACTION
#define CHOICE_SCRIPTS_ACTION( itemIndex, actionArg ) \
	CHOICE_SCRIPTS_ALL( itemIndex, actionArg, ;, ; )

#undef CHOICE_SCRIPTS_ALL
#define CHOICE_SCRIPTS_ALL( itemIndex, actionArg, onFocusArg, leaveFocusArg ) \
	onFocus \
	{ \
		play CHOICE_FOCUS_SOUND; \
		setLocalVarInt ui_highlight itemIndex; \
		setLocalVarString ui_choicegroup CHOICE_GROUP; \				
		onFocusArg \
	} \
	leaveFocus \
	{ \
		setLocalVarInt ui_highlight 0; \
		leaveFocusArg \
	} \
	action \
	{ \
		play "mouse_click"; \
		actionArg; \
	}

#define CREATE_DVARSLIDER( position, textArg, dvarArg, defaultArg, minArg, maxArg, actionArg, extraArg, visArg ) \
	itemDef \
	{ \
		rect			position \
		type			ITEM_TYPE_SLIDER \
		style			WINDOW_STYLE_FILLED \
		dvarfloat		dvarArg defaultArg minArg maxArg \
		textaligny		4 \
		forecolor		1 1 1 0.5 \
		visible			visArg \
		extraArg 		\
		CHOICE_SCRIPTS_ACTION( idx, actionArg ) \
	}

#define CREATE_DVARFLOATLIST( position, dvarArg, strListArg, actionArg ) \
	CREATE_DVARLIST_VIS( position, dvarArg, ITEM_TYPE_MULTI, dvarFloatList strListArg, actionArg, 1 )

#define CREATE_DVARFLOATLIST_VIS( position, dvarArg, strListArg, actionArg, visArg ) \
	CREATE_DVARLIST_VIS( position, dvarArg, ITEM_TYPE_MULTI, dvarFloatList strListArg, actionArg, visArg )

#define CREATE_DVARFLOATLIST_FOCUS_VIS( position, dvarArg, strListArg, actionArg, onFocusArg, leaveFocusArg, visArg ) \
	CREATE_DVARLIST_FOCUS_VIS( position, dvarArg, ITEM_TYPE_MULTI, dvarFloatList strListArg, actionArg, onFocusArg, leaveFocusArg, visArg )

#define CREATE_DVARLIST_VIS( position, dvarArg, listTypeArg, listArg, actionArg, visArg ) \
	CREATE_DVARLIST_FOCUS_VIS( position, dvarArg, listTypeArg, listArg, actionArg, ;, ;, visArg )

#define CREATE_DVARLIST_FOCUS_VIS( position, dvarArg, listTypeArg, listArg, actionArg, onFocusArg, leaveFocusArg, visArg ) \
	itemDef \
	{ \
		rect			position \
		type			listTypeArg \
		style			WINDOW_STYLE_FILLED \
		dvar			dvarArg \
		textalign		2 \
		textaligny		19.5 \
		textscale		0.3 \
		textstyle 		ITEM_TEXTSTYLE_SHADOWED \
		forecolor		1 1 1 0.5 \
		visible			visArg ; \
		listArg 		\
		CHOICE_SCRIPTS_ALL( itemIndex, actionArg, onFocusArg, leaveFocusArg ) \
	}