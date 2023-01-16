#include braxi\_utility;

init()
{
    level.statDvar = "dr_info_" + level.script;
    level.mapRecords = [];
    level.map_record_duration = 10;

    createRecord( "kills" );
    createRecord( "deaths" );
    createRecord( "headshots" );
    createRecord( "score" );
    createRecord( "knifes" );
    createRecord( "time" );

    braxi\_dvar::addDvar( "best_scores", level.statDvar, "string", "" );
    records = strTok( level.dvar["best_scores"], ";" );

    if ( !records.size ) return;

    for ( i = 0; i < records.size; i++ )
    {
        record = strTok( records[i], "," );

        if ( !isDefined( record[0] ) )
        {
            iPrintLn( "^1Error reading " + level.script + " records!" );
            continue;
        }

        for ( j = 0; j < level.mapRecords.size; j++ )
        {
            if ( level.mapRecords[j]["name"] == record[0] )
            {
                level.mapRecords[j]["value"] = record[1];
                level.mapRecords[j]["player"] = record[2];
            }
        }
    }

    logPrint( "COPY TO CFG: set dr_info_" + level.script + " \"" + level.dvar["best_scores"] + "\"\n" );
}

createRecord( name )
{
    id = level.mapRecords.size;
    level.mapRecords[id]["name"] = name;
    level.mapRecords[id]["value"] = 0;
    level.mapRecords[id]["player"] = " ";
    level.mapRecords[id]["updated"] = false;
}

fetchMapRecords()
{
    if ( !level.mapRecords.size )
    {
        iPrintLn( "No Records have been found!" );
        return;
    }

    players = getAllPlayers();

    for ( i = 0; i < level.mapRecords.size; i++ )
    {
        record = level.mapRecords[i]["name"];
        record_player = level.mapRecords[i]["player"];
        record_value = int( level.mapRecords[i]["value"] );
        best_player = getBestStatPlayer( record );
        holder = "None";

        if ( record == "time" && record_value == 0 )
            record_value = 99999;

        if ( isDefined( best_player ) && isDefined( best_player.pers[record] ) )
        {
            if (
                ( record == "time" && best_player.pers[record] < record_value ) ||
                ( record != "time" && best_player.pers[record] > record_value )
            ) {
                updateRecord( i, best_player );
                holder = best_player.name + " - ";

                if ( record == "time" )
                    holder += formatTimer( best_player.pers[record] );
                else
                    holder += best_player.pers[record];
            }
            else
            {
                if ( record_player != " " )
                {
                    holder = record_player + " - ";

                    if ( record == "time" )
                        holder += formatTimer( record_value );
                    else
                        holder += record_value;
                }
            }
        }

        for ( j = 0; j < players.size; j++ )
        {
            players[j] setClientDvars(
                "ui_record_name_" + i, statToString( record ),
                "ui_record_holder_" + i, holder,
                "ui_record_updated_" + i, level.mapRecords[i]["updated"]
            );
        }
    }

    wait .1;

    for ( i = 0; i < players.size; i++ )
    {
        players[i] setClientDvars( "ui_records_map", formatMapName( level.script ) );
        players[i] openMenu( game["menu_maprecords"] );
    }

    players = getAllPlayers();
    for ( i = level.map_record_duration; i >= 0; i-- )
    {
        for ( j = 0; j < players.size; j++ )
            if ( isDefined( players[j] ) )
                players[j] setClientDvar( "ui_records_countdown", "Mapvote in " + i + " sec(s)" );
        wait 1;
    }
}

getBestStatPlayer( stat )
{
    value = 0;
    if ( stat == "time" ) value = 99999;
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
    level.mapRecords[id]["value"] = player.pers[level.mapRecords[id]["name"]];
    level.mapRecords[id]["player"] = player.name;
    level.mapRecords[id]["updated"] = true;
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