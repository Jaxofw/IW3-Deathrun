#include braxi\_common;

init()
{
    if ( !isDefined( game["records"] ) )
        game["records"] = [];
    else
        return;

    createRecord( "kills" );
    createRecord( "deaths" );
    createRecord( "headshots" );
    createRecord( "score" );
    createRecord( "knifes" );
    createRecord( "time" );

    queries[0] = "SELECT name, player, MAX(value) AS value FROM records WHERE name != ? AND map = ? GROUP BY name, player";
    queries[1] = "SELECT name, player, MIN(value) AS value FROM records WHERE name = ? AND map = ? GROUP BY name, player";

    for ( i = 0; i < queries.size; i++ )
    {
        request = SQL_Prepare( queries[i] );

        SQL_BindParam( request, "time", level.MYSQL_TYPE_VAR_STRING );
        SQL_BindParam( request, level.script, level.MYSQL_TYPE_VAR_STRING );
        SQL_BindResult( request, level.MYSQL_TYPE_VAR_STRING, 10 );
        SQL_BindResult( request, level.MYSQL_TYPE_VAR_STRING, 50 );
        SQL_BindResult( request, level.MYSQL_TYPE_LONG );
        SQL_Execute( request );

        status = AsyncWait( request );
        rows = SQL_FetchRowsDict( request );

        if ( !isDefined( rows ) && !isDefined( rows.size ) )
            continue;

        for ( j = 0; j < rows.size; j++ )
        {
            record = rows[j];

            if ( !isDefined( record ) && !isDefined( record.size ) )
                continue;

            for ( k = 0; k < game["records"].size; k++ )
            {
                if ( i == 1 )
                    k = game["records"].size - 1;

                if ( record["name"] == game["records"][k]["name"] )
                {
                    game["records"][k]["player"] = record["player"];
                    game["records"][k]["value"] = record["value"];
                }
            }
        }

        SQL_Free( request );
    }
}

createRecord( name )
{
    id = game["records"].size;
    game["records"][id]["name"] = name;
    game["records"][id]["player"] = " ";
    game["records"][id]["value"] = 0;
    game["records"][id]["updated"] = false;
}

displayMapRecords()
{
    players = getAllPlayers();

    for ( i = 0; i < game["records"].size; i++ )
    {
        record = game["records"][i]["name"];
        currentHolder = game["records"][i]["player"];
        value = game["records"][i]["value"];
        bestPlayer = getRecordBestPlayer( record );
        text = "None";

        if ( currentHolder != " " )
        {
            text = currentHolder + " - ";

            if ( record == "time" )
                text += formatTimer( value );
            else
                text += value;
        }

        if ( record == "time" && value == 0 )
            value = 99999;

        if ( isDefined( bestPlayer ) && isDefined( bestPlayer.pers[record] ) )
        {
            new_value = bestPlayer.pers[record];

            if ( ( record == "time" && new_value < value ) || ( record != "time" && new_value > value ) )
            {
                updateRecord( i, bestPlayer );
                text = bestPlayer.name + " - ";

                if ( record == "time" )
                    text += formatTimer( bestPlayer.pers[record] );
                else
                    text += bestPlayer.pers[record];
            }
        }

        for ( j = 0; j < players.size; j++ )
        {
            players[j] setClientDvars(
                "ui_record_name_" + i, statToString( record ),
                "ui_record_holder_" + i, text,
                "ui_record_updated_" + i, game["records"][i]["updated"]
            );
        }
    }

    wait .1;

    for ( i = 0; i < players.size; i++ )
    {
        players[i] closeMenu();
        players[i] closeInGameMenu();
        players[i] setClientDvars( "ui_records_map", formatMapName( level.script ) );
        players[i] openMenu( game["menu_maprecords"] );
    }

    mapvoteDuration = 10;

    for ( i = mapvoteDuration; i >= 0; i-- )
    {
        for ( j = 0; j < players.size; j++ )
            players[j] setClientDvar( "ui_records_countdown", "Mapvote in " + i + " sec(s)" );

        wait 1;
    }
}

getRecordBestPlayer( stat )
{
    value = 0;

    if ( stat == "time" )
        value = 99999;

    player = undefined;
    players = getAllPlayers();

    for ( i = 0; i < players.size; i++ )
    {
        if ( ( stat == "time" && players[i].pers[stat] >= value ) || ( stat != "time" && players[i].pers[stat] <= value ) )
            continue;

        value = players[i].pers[stat];
        player = players[i];
    }

    return player;
}

updateRecord( id, player )
{
    game["records"][id]["player"] = player.name;
    game["records"][id]["value"] = player.pers[game["records"][id]["name"]];
    game["records"][id]["updated"] = true;

    request = SQL_Prepare( "INSERT INTO records (name, player, value, map) VALUES (?, ?, ?, ?)" );
    SQL_BindParam( request, game["records"][id]["name"], level.MYSQL_TYPE_VAR_STRING );
    SQL_BindParam( request, game["records"][id]["player"], level.MYSQL_TYPE_VAR_STRING );
    SQL_BindParam( request, game["records"][id]["value"], level.MYSQL_TYPE_LONG );
    SQL_BindParam( request, level.script, level.MYSQL_TYPE_VAR_STRING );
    SQL_Execute( request );

    status = AsyncWait( request );
    SQL_Free( request );
}

statToString( stat )
{
    switch ( stat )
    {
        case "kills":
            return "Kill";
        case "deaths":
            return "Death";
        case "headshots":
            return "Headshot";
        case "score":
            return "Score";
        case "knifes":
            return "Knife";
        case "time":
            return "Time";
        default:
            return stat;
    }
}