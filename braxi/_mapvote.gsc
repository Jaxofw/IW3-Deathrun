#include braxi\_common;

init()
{
    level.maps = [];
    level.mapsVotable = [];
    level.mapsInVote = 10;
    level.voteDuration = 15;

    level.maps[level.maps.size] = "mp_deathrun_bricky";
    level.maps[level.maps.size] = "mp_deathrun_cherry";
    level.maps[level.maps.size] = "mp_deathrun_colourful";
    level.maps[level.maps.size] = "mp_deathrun_coyote";
    level.maps[level.maps.size] = "mp_deathrun_coyotev2";
    level.maps[level.maps.size] = "mp_deathrun_crystal";
    level.maps[level.maps.size] = "mp_deathrun_diehard";
    level.maps[level.maps.size] = "mp_deathrun_dragonball";
    level.maps[level.maps.size] = "mp_deathrun_epicfail";
    level.maps[level.maps.size] = "mp_deathrun_familyguy";
    level.maps[level.maps.size] = "mp_deathrun_fluxx";
    level.maps[level.maps.size] = "mp_deathrun_framey_v2";
    level.maps[level.maps.size] = "mp_deathrun_godfather";
    level.maps[level.maps.size] = "mp_deathrun_gold";
    level.maps[level.maps.size] = "mp_deathrun_grassy_v4";
    level.maps[level.maps.size] = "mp_deathrun_hop";
    level.maps[level.maps.size] = "mp_deathrun_liferun";
    level.maps[level.maps.size] = "mp_deathrun_minecraft";
    level.maps[level.maps.size] = "mp_deathrun_nightrun";
    level.maps[level.maps.size] = "mp_deathrun_portal_v3";
    level.maps[level.maps.size] = "mp_deathrun_qube";
    level.maps[level.maps.size] = "mp_deathrun_saw";
    level.maps[level.maps.size] = "mp_deathrun_scoria";
    level.maps[level.maps.size] = "mp_deathrun_semtex";
    level.maps[level.maps.size] = "mp_deathrun_skypillar";
    level.maps[level.maps.size] = "mp_deathrun_sonic";
    level.maps[level.maps.size] = "mp_deathrun_spaceball";
    level.maps[level.maps.size] = "mp_deathrun_underworld";
    level.maps[level.maps.size] = "mp_deathrun_waterworld";
    level.maps[level.maps.size] = "mp_deathrun_winter";
    level.maps[level.maps.size] = "mp_dr_anotherworld";
    level.maps[level.maps.size] = "mp_dr_bananaphone";
    level.maps[level.maps.size] = "mp_dr_bounce";
    level.maps[level.maps.size] = "mp_dr_caution";
    level.maps[level.maps.size] = "mp_dr_construct";
    level.maps[level.maps.size] = "mp_dr_crosscode";
    level.maps[level.maps.size] = "mp_dr_darmuhv2";
    level.maps[level.maps.size] = "mp_dr_deadzone";
    level.maps[level.maps.size] = "mp_dr_digital";
    level.maps[level.maps.size] = "mp_dr_disco";
    level.maps[level.maps.size] = "mp_dr_edgeville";
    level.maps[level.maps.size] = "mp_dr_famous";
    level.maps[level.maps.size] = "mp_dr_glass2";
    level.maps[level.maps.size] = "mp_dr_gooby";
    level.maps[level.maps.size] = "mp_dr_guest_list";
    level.maps[level.maps.size] = "mp_dr_h2o";
    level.maps[level.maps.size] = "mp_dr_hardest_game";
    level.maps[level.maps.size] = "mp_dr_harrypotter";
    level.maps[level.maps.size] = "mp_dr_imaginary";
    level.maps[level.maps.size] = "mp_dr_indipyramid";
    level.maps[level.maps.size] = "mp_dr_jurapark";
    level.maps[level.maps.size] = "mp_dr_laboratory";
    level.maps[level.maps.size] = "mp_dr_lovelyplanet";
    level.maps[level.maps.size] = "mp_dr_lucidskyv2";
    level.maps[level.maps.size] = "mp_dr_merry_xmas";
    level.maps[level.maps.size] = "mp_dr_mew";
    level.maps[level.maps.size] = "mp_dr_mirrors_edge";
    level.maps[level.maps.size] = "mp_dr_neon";
    level.maps[level.maps.size] = "mp_dr_nighty";
    level.maps[level.maps.size] = "mp_dr_pool";
    level.maps[level.maps.size] = "mp_dr_quarry";
    level.maps[level.maps.size] = "mp_dr_shipment";
    level.maps[level.maps.size] = "mp_dr_skydeath";
    level.maps[level.maps.size] = "mp_dr_skypower";
    level.maps[level.maps.size] = "mp_dr_slayv2";
    level.maps[level.maps.size] = "mp_dr_sm64";
    level.maps[level.maps.size] = "mp_dr_spedex";
    level.maps[level.maps.size] = "mp_dr_undertale";
    level.maps[level.maps.size] = "mp_dr_vistic_castle";
    level.maps[level.maps.size] = "mp_dr_watercity";
    level.maps[level.maps.size] = "mp_dr_winter_wipeout";
    level.maps[level.maps.size] = "mp_dr_wtf";
}

mapVoteLogic()
{
    for ( i = 0; i < level.mapsInVote; i++ )
        getRandomMap();

    players = getAllPlayers();

    for ( i = 0; i < players.size; i++ )
        players[i] thread braxi\_mapvote::playerLogic();

    for ( i = level.voteDuration; i >= 0; i-- )
    {
        for ( j = 0; j < players.size; j++ )
            players[j] setClientDvar( "mapvote_duration", i + " Seconds" );

        wait 1;
    }

    changeToWinningMap();
}

getRandomMap()
{
    id = level.mapsVotable.size;
    randomMap = "";

    if ( ( id + 1 ) == level.mapsInVote )
        randomMap = level.script;
    else
    {
        while ( randomMap == "" || randomMap == level.script || isMapinVotes( randomMap ) )
            randomMap = level.maps[randomInt( level.maps.size )];
    }

    level.mapsVotable[id]["name"] = randomMap;
    level.mapsVotable[id]["votes"] = 0;

    players = getAllPlayers();
    for ( j = 0; j < players.size; j++ )
    {
        players[j] setClientDvars(
            "mapvote_option_" + id, randomMap,
            "mapvote_option_" + id + "_label", formatMapName( level.mapsVotable[id]["name"] ),
            "mapvote_option_" + id + "_votes", level.mapsVotable[id]["votes"],
            "mapvote_option_" + id + "_selected", false,
            "mapvote_option_" + id + "_winner", false
        );
    }
}

isMapinVotes( mapName )
{
    for ( i = 0; i < level.mapsVotable.size; i++ )
        if ( mapName == level.mapsVotable[i]["name"] )
            return true;

    return false;
}

changeToWinningMap()
{
    topVote = level.mapsVotable[0];
    players = getAllPlayers();

    for ( i = 0; i < level.mapsVotable.size; i++ )
    {
        if ( level.mapsVotable[i]["votes"] > topVote["votes"] )
        {
            topVote = level.mapsVotable[i];
            for ( j = 0; j < players.size; j++ )
                players[j] setClientDvar( "mapvote_option_" + i + "_winner", true );
        }
    }

    wait 2;

    for ( i = 0; i < players.size; i++ )
    {
        players[i] closeMenu();
        players[i] closeInGameMenu();
    }

    iPrintLnBold( "Changing map to ^8" + formatMapName( topVote["name"] ) );

    wait 4;

    setDvar( "sv_maprotationcurrent", "gametype deathrun map " + topVote["name"] );
    exitLevel( false );
}

playerLogic()
{
    self endon( "disconnect" );
    self openMenu( game["menu_mapvote"] );

    self.vote = -1;

    for (;;)
    {
        self waittill( "menuresponse", menu, response );

        if ( menu == game["menu_mapvote"] )
        {
            mapId = int( response );

            if ( mapId != self.vote )
            {
                players = getAllPlayers();

                if ( self.vote != -1 )
                {
                    level.mapsVotable[self.vote]["votes"]--;
                    self setClientDvar( "mapvote_option_" + self.vote + "_selected", false );

                    for ( i = 0; i < players.size; i++ )
                        players[i] setClientDvar( "mapvote_option_" + self.vote + "_votes", level.mapsVotable[self.vote]["votes"] );
                }

                self.vote = mapId;
                level.mapsVotable[mapId]["votes"]++;
                self setClientDvar( "mapvote_option_" + self.vote + "_selected", true );

                for ( i = 0; i < players.size; i++ )
                    players[i] setClientDvar( "mapvote_option_" + mapId + "_votes", level.mapsVotable[mapId]["votes"] );
            }
        }
    }
}