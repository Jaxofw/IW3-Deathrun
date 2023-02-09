#include braxi\_common;

init()
{
    if ( !isDefined( game["leaderboard"] ) )
        game["leaderboard"] = [];
    else
    {
        level thread onPlayerConnect();
        return;
    }

    level.maxPlacement = 20;

    request = SQL_Prepare( "SELECT player, value FROM records WHERE map = ? AND name = ? ORDER BY value ASC LIMIT " + level.maxPlacement );
    SQL_BindParam( request, level.script, level.MYSQL_TYPE_VAR_STRING );
    SQL_BindParam( request, "time", level.MYSQL_TYPE_VAR_STRING );
    SQL_BindResult( request, level.MYSQL_TYPE_VAR_STRING, 50 );
    SQL_BindResult( request, level.MYSQL_TYPE_LONG );
    SQL_Execute( request );

    status = AsyncWait( request );
    rows = SQL_FetchRowsDict( request );

    if ( !isDefined( rows ) && !isDefined( rows.size ) )
        return;

    for ( j = 0; j < level.maxPlacement; j++ )
    {
        placement = rows[j];
        player = "None";
        value = 0;

        if ( isDefined( placement ) && isDefined( placement.size ) )
        {
            player = placement["player"];
            value = placement["value"];
        }

        game["leaderboard"][j]["player"] = player;
        game["leaderboard"][j]["value"] = value;
    }

    SQL_Free( request );

    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

        for ( i = 0; i < game["leaderboard"].size; i++ )
        {
            player setClientDvars(
                "ui_lb_place_" + i + "_player", game["leaderboard"][i]["player"],
                "ui_lb_place_" + i + "_value", formatTimer( game["leaderboard"][i]["value"] )
            );
        }
    }
}

getLeaderboardEntry()
{
    for ( i = 0; i < 20; i++ )
        if ( self.time < game["leaderboard"][i]["value"] || game["leaderboard"][i]["value"] == 0 )
            return i;

    return -1;
}