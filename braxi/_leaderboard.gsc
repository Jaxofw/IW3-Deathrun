#include braxi\_utility;

init()
{
    if ( !isDefined( game["leaderboard"] ) )
        game["leaderboard"] = [];
    else
    {
        level thread onPlayerConnect();
        return;
    }

    level.max_placements = 20;

    critical_enter( "mysql" );

    request = SQL_Prepare( "SELECT player, value FROM records WHERE map = ? AND name = ? ORDER BY value ASC LIMIT " + level.max_placements );
    SQL_BindParam( request, level.script, level.MYSQL_TYPE_VAR_STRING );
    SQL_BindParam( request, "time", level.MYSQL_TYPE_VAR_STRING );
    SQL_BindResult( request, level.MYSQL_TYPE_VAR_STRING, 50 );
    SQL_BindResult( request, level.MYSQL_TYPE_LONG );
    SQL_Execute( request );

    status = AsyncWait( request );
    rows = SQL_FetchRowsDict( request );

    if ( !isDefined( rows ) && !isDefined( rows.size ) )
        return;

    for ( j = 0; j < level.max_placements; j++ )
    {
        placement = rows[j];
        player = "None";
        value = 0;

        if ( isDefined( placement ) && isDefined( placement.size ) )
        {
            player = placement["player"];
            value = placement["value"];
        }

        game["leaderboard"][j + 1]["player"] = player;
        game["leaderboard"][j + 1]["value"] = value;
    }

    SQL_Free( request );
    critical_leave( "mysql" );

    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

        for ( i = 1; i <= game["leaderboard"].size; i++ )
        {
            player setClientDvars(
                "ui_lb_place_" + i + "_player", game["leaderboard"][i]["player"],
                "ui_lb_place_" + i + "_value", formatTimer( game["leaderboard"][i]["value"] )
            );
        }
    }
}