#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

init()
{
    level.scoreInfo = [];
    level.rankTable = [];

    preCacheString( &"MP_PLUS" );

    setScoreValue( "kill", 100 );
	setScoreValue( "headshot", 200 );
	setScoreValue( "melee", 150 );
	setScoreValue( "trap_activation", 50 );
	setScoreValue( "activator", 300 );
	setScoreValue( "win", 25 );
    setScoreValue( "jumper_died", 50 );
    setScoreValue( "finished_map", 200 );

    level.maxRank = int( tableLookup( "mp/rankTable.csv", 0, "maxrank", 1 ) );
    level.maxPrestige = int( tableLookup( "mp/rankIconTable.csv", 0, "maxprestige", 1 ) );

    rankId = 0;
    rankName = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );
    assert( isDefined( rankName ) && rankName != "" );

    while ( isDefined( rankName ) && rankName != "" )
    {
        level.rankTable[rankId][1] = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );
        level.rankTable[rankId][2] = tableLookup( "mp/ranktable.csv", 0, rankId, 2 );
        level.rankTable[rankId][3] = tableLookup( "mp/ranktable.csv", 0, rankId, 3 );
        level.rankTable[rankId][7] = tableLookup( "mp/ranktable.csv", 0, rankId, 7 );

        precacheString( tableLookupIString( "mp/ranktable.csv", 0, rankId, 16 ) );

        rankId++;
        rankName = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );
    }

    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected", player );

        player.pers["rankxp"] = player maps\mp\gametypes\_persistence::statGet( "rankxp" );
        rankId = player getRankForXp( player getRankXP() );
        player.pers["rank"] = rankId;

        player.rankUpdateTotal = 0;

        prestige = 0;
        player setRank( rankId, prestige );
        player.pers["prestige"] = prestige;

        if ( !isDefined( player.hud_rankscoreupdate ) )
        {
            player.hud_rankscoreupdate = newClientHudElem( player );
            player.hud_rankscoreupdate.horzAlign = "center";
            player.hud_rankscoreupdate.vertAlign = "middle";
            player.hud_rankscoreupdate.alignX = "center";
            player.hud_rankscoreupdate.alignY = "middle";
            player.hud_rankscoreupdate.x = 0;
            player.hud_rankscoreupdate.y = -60;
            player.hud_rankscoreupdate.font = "default";
            player.hud_rankscoreupdate.fontscale = 2.0;
            player.hud_rankscoreupdate.archived = false;
            player.hud_rankscoreupdate.color = ( 0.5, 0.5, 0.5 );
            player.hud_rankscoreupdate maps\mp\gametypes\_hud::fontPulseInit();
        }

        player thread onJoinedTeam();
		player thread onJoinedSpectators();
    }
}

onJoinedTeam()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "joined_team" );
        self thread removeRankHUD();
    }
}

onJoinedSpectators()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "joined_spectators" );
        self thread removeRankHUD();
    }
}

removeRankHUD()
{
    if ( isDefined( self.hud_rankscoreupdate ) )
        self.hud_rankscoreupdate.alpha = 0;
}

giveRankXP( type, value )
{
    self endon( "disconnect" );

    if ( !isDefined( value ) )
        value = getScoreInfoValue( type );

    // Mod isn't devmappable but just incase
    if ( value > 6000 || getDvar( "dedicated" ) == "listen server" )
        return;

    if ( level.freeRun )
        value = int( value * 0.5 );
    else if ( game["state"] != "playing" )
        value = 0;

    // XP Events
    value = value * level.xpMultipliedBy;

    self.score += value;
    self.pers["score"] = self.score;

    score = self maps\mp\gametypes\_persistence::statGet( "score" );
    self maps\mp\gametypes\_persistence::statSet( "score", score + value );

    self incRankXP( value );
    self thread updateRankScoreHUD( value );
}

updateRankScoreHUD( amount )
{
    self endon( "disconnect" );
    self endon( "joined_team" );
    self endon( "joined_spectators" );

    if ( amount == 0 )
        return;

    self notify( "update_score" );
    self endon( "update_score" );

    self.rankUpdateTotal += amount;

    wait( 0.05 );

    if ( isDefined( self.hud_rankscoreupdate ) )
    {
        if ( self.rankUpdateTotal < 0 )
        {
            self.hud_rankscoreupdate.label = &"";
            self.hud_rankscoreupdate.color = ( 1, 0, 0 );
        }
        else
        {
            self.hud_rankscoreupdate.label = &"MP_PLUS";
            self.hud_rankscoreupdate.color = ( 1, 1, 0.5 );
        }

        self.hud_rankscoreupdate setValue( self.rankUpdateTotal );
        self.hud_rankscoreupdate.alpha = 0.85;
        self.hud_rankscoreupdate thread maps\mp\gametypes\_hud::fontPulse( self );

        wait 1;

        self.hud_rankscoreupdate fadeOverTime( 0.75 );
        self.hud_rankscoreupdate.alpha = 0;

        self.rankUpdateTotal = 0;
    }
}

getRank()
{
    rankXp = self.pers["rankxp"];
    rankId = self.pers["rank"];

    if ( rankXp < ( getRankInfoMinXP( rankId ) + getRankInfoXPAmt( rankId ) ) )
        return rankId;
    else
        return self getRankForXp( rankXp );
}

getRankForXp( xpVal )
{
    rankId = 0;
    rankName = level.rankTable[rankId][1];
    assert( isDefined( rankName ) );

    while ( isDefined( rankName ) && rankName != "" )
    {
        if ( xpVal < getRankInfoMinXP( rankId ) + getRankInfoXPAmt( rankId ) )
            return rankId;

        rankId++;

        if ( isDefined( level.rankTable[rankId] ) )
            rankName = level.rankTable[rankId][1];
        else
            rankName = undefined;
    }

    rankId--;
    return rankId;
}

incRankXP( amount )
{
    xp = self getRankXP();
    newXp = ( xp + amount );

    if ( self.pers["rank"] == level.maxRank && newXp >= getRankInfoMaxXP( level.maxRank ) )
        newXp = getRankInfoMaxXP( level.maxRank );

    self.pers["rankxp"] = newXp;
    self maps\mp\gametypes\_persistence::statSet( "rankxp", newXp );

    rankId = self getRankForXp( self getRankXP() );

    self updateRank( rankId );
}

updateRank( rankId )
{
    if ( getRankInfoMaxXP( self.pers["rank"] ) <= self getRankXP() && self.pers["rank"] < level.maxRank )
    {
        rankId = self getRankForXp( self getRankXP() );
        self setRank( rankId, 0 );
        self.pers["rank"] = rankId;
        self updateRankAnnounceHUD();
    }

    updateRankStats( self, rankId );
}

updateRankStats( player, rankId )
{
    player maps\mp\gametypes\_persistence::statSet( "rank", rankId );
    player maps\mp\gametypes\_persistence::statSet( "minxp", getRankInfoMinXp( rankId ) );
    player maps\mp\gametypes\_persistence::statSet( "maxxp", getRankInfoMaxXp( rankId ) );

    if ( rankId > level.maxRank )
        player setStat( 252, level.maxRank );
    else
        player setStat( 252, rankId );
}

updateRankAnnounceHUD()
{
    self endon( "disconnect" );

    self notify( "update_rank" );
    self endon( "update_rank" );

    team = self.pers["team"];

    if ( !isdefined( team ) )
        return;

    rankUp = spawnStruct();
    rankUp.title = "You Leveled Up!";
    rankUp.footer = "Level " + ( self.pers["rank"] + 1 );
    rankUp.sound = "mp_level_up";
    rankUp.levelUp = true;

    self thread braxi\_common::notification( rankUp );

    iPrintLn( self.name + " ^7was promoted to ^8Level " + ( self.pers["rank"] + 1 ) + "^7!" );
}

processXpReward( sMeansOfDeath, attacker, victim )
{
    if ( attacker.pers["team"] == victim.pers["team"] )
        return;

    kills = attacker maps\mp\gametypes\_persistence::statGet( "kills" );
    attacker maps\mp\gametypes\_persistence::statSet( "kills", kills + 1 );

    if ( victim.pers["team"] == "allies" )
    {
        kills = attacker maps\mp\gametypes\_persistence::statGet( "KILLED_JUMPERS" );
        attacker maps\mp\gametypes\_persistence::statSet( "KILLED_JUMPERS", kills + 1 );
    }
    else
    {
        kills = attacker maps\mp\gametypes\_persistence::statGet( "KILLED_ACTIVATORS" );
        attacker maps\mp\gametypes\_persistence::statSet( "KILLED_ACTIVATORS", kills + 1 );
    }

    switch ( sMeansOfDeath )
    {
        case "MOD_HEAD_SHOT":
            attacker.pers["headshots"]++;
            attacker braxi\_rank::giveRankXP( "headshot" );
            hs = attacker maps\mp\gametypes\_persistence::statGet( "headshots" );
            attacker maps\mp\gametypes\_persistence::statSet( "headshots", hs + 1 );
            break;
        case "MOD_MELEE":
            attacker.pers["knifes"]++;
            attacker braxi\_rank::giveRankXP( "melee" );
            knife = attacker maps\mp\gametypes\_persistence::statGet( "MELEE_KILLS" );
            attacker maps\mp\gametypes\_persistence::statSet( "MELEE_KILLS", knife + 1 );
            break;
        default:
            pistol = attacker maps\mp\gametypes\_persistence::statGet( "PISTOL_KILLS" );
            attacker maps\mp\gametypes\_persistence::statSet( "PISTOL_KILLS", pistol + 1 );
            attacker braxi\_rank::giveRankXP( "kill" );
            break;
    }
}

setScoreValue( type, value )
{
    level.scoreInfo[type]["value"] = value;
}

getRankXP()
{
    return self.pers["rankxp"];
}

getScoreInfoValue( type )
{
    return ( level.scoreInfo[type]["value"] );
}

getRankInfoMinXP( rankId )
{
    return int( level.rankTable[rankId][2] );
}

getRankInfoXPAmt( rankId )
{
    return int( level.rankTable[rankId][3] );
}

getRankInfoMaxXp( rankId )
{
    return int( level.rankTable[rankId][7] );
}

isItemUnlocked( table, id )
{
	if ( id >= table.size || id <= -1 )
		return false;

	if ( self.pers["rank"] >= table[id]["rank"] )
		return true;

	return false;
}