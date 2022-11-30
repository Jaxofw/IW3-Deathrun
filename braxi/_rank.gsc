#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include braxi\_utility;

init() {
	level.rankTable = [];
	level.scoreInfo = [];

	level.maxRank = int( tableLookup( "mp/rankTable.csv", 0, "maxrank", 1 ) );

	setScoreValue( "activator", 200 );
	setScoreValue( "trap", 200 );

	rankId = 0;
	rankName = tableLookup( "mp/rankTable.csv", 0, rankId, 1 );
	assert( isDefined( rankName ) && rankName != "" );

	while ( isDefined( rankName ) && rankName != "" ) {
		level.rankTable[rankId][1] = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );
		level.rankTable[rankId][2] = tableLookup( "mp/ranktable.csv", 0, rankId, 2 );
		level.rankTable[rankId][3] = tableLookup( "mp/ranktable.csv", 0, rankId, 3 );
		level.rankTable[rankId][7] = tableLookup( "mp/ranktable.csv", 0, rankId, 7 );

		preCacheString( tableLookupIString( "mp/ranktable.csv", 0, rankId, 16 ) );

		rankId++;
		rankName = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );
	}

	level thread onPlayerConnect();
}

onPlayerConnect() {
	for (;;) {
		level waittill( "connected", player );

		player.pers["rankxp"] = player maps\mp\gametypes\_persistence::statGet( "rankxp" );
		rankId = player getRankForXp( player.pers["rankxp"] );
		player.pers["rank"] = rankId;

		player.rankUpdateTotal = 0;

		prestige = 0;
		player setRank( rankId, prestige );
		player.pers["prestige"] = prestige;

		if ( !isDefined( player.hud_rankscoreupdate ) ) {
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
			player.hud_rankscoreupdate.alpha = 0;
		}
	}
}

processXpReward( sMeansOfDeath, attacker, victim ) {
	if ( attacker.pers["team"] == victim.pers["team"] ) return;

	kills = attacker maps\mp\gametypes\_persistence::statGet( "kills" );
	attacker maps\mp\gametypes\_persistence::statSet( "kills", kills + 1 );

	if ( victim.pers["team"] == "allies" ) {
		kills = attacker maps\mp\gametypes\_persistence::statGet( "KILLED_JUMPERS" );
		attacker maps\mp\gametypes\_persistence::statSet( "KILLED_JUMPERS", kills + 1 );
	} else {
		kills = attacker maps\mp\gametypes\_persistence::statGet( "KILLED_ACTIVATORS" );
		attacker maps\mp\gametypes\_persistence::statSet( "KILLED_ACTIVATORS", kills + 1 );
	}

	switch ( sMeansOfDeath ) {
		case "MOD_HEAD_SHOT":
			attacker.pers["headshots"]++;
			attacker braxi\_rank::giveRankXp( "headshot" );
			hs = attacker maps\mp\gametypes\_persistence::statGet( "headshots" );
			attacker maps\mp\gametypes\_persistence::statSet( "headshots", hs + 1 );
			break;
		case "MOD_MELEE":
			attacker.pers["knifes"]++;
			attacker braxi\_rank::giveRankXp( "melee" );
			knife = attacker maps\mp\gametypes\_persistence::statGet( "MELEE_KILLS" );
			attacker maps\mp\gametypes\_persistence::statSet( "MELEE_KILLS", knife + 1 );
			break;
		default:
			pistol = attacker maps\mp\gametypes\_persistence::statGet( "PISTOL_KILLS" );
			attacker maps\mp\gametypes\_persistence::statSet( "PISTOL_KILLS", pistol + 1 );
			attacker braxi\_rank::giveRankXp( "kill" );
			break;
	}
}

giveRankXp( type, value ) {
	self endon( "disconnect" );

	if ( !isDefined( value ) ) value = getScoreValue( type );

	self.score += value;
	self.pers["score"] = self.score;

	score = self maps\mp\gametypes\_persistence::statGet( "score" );
	self maps\mp\gametypes\_persistence::statSet( "score", score + value );

	self increaseLevelXp( value );
	self updateRankScoreHUD( value );
}

increaseLevelXp( amount ) {
	self.pers["rankxp"] += amount;
	self maps\mp\gametypes\_persistence::statSet( "rankxp", self.pers["rankxp"] );
	rankId = self getRankForXp( self.pers["rankxp"] );
	self updateRank( rankId );
}

updateRank( rankId ) {
	if ( getRankMaxXp( self.pers["rank"] ) <= self.pers["rankxp"] && self.pers["rank"] < level.maxRank ) {
		self setRank( rankId, 0 );
		self.pers["rank"] = rankId;
		self displayRankUp();
	}

	updateRankStats( self, rankId );
}

displayRankUp() {
	self endon( "disconnect" );

	rankUp = spawnStruct();
	rankUp.title = "You Leveled Up!";
	rankUp.footer = "Level " + ( self.pers["rank"] + 1 );
	rankUp.sound = "mp_level_up";
	rankUp.levelUp = true;

	self thread braxi\_utility::notification( rankUp );
}

updateRankStats( player, rankId ) {
	player maps\mp\gametypes\_persistence::statSet( "rank", rankId );
	player maps\mp\gametypes\_persistence::statSet( "minxp", getRankMinXp( rankId ) );
	player maps\mp\gametypes\_persistence::statSet( "maxxp", getRankMaxXp( rankId ) );

	if ( rankId > level.maxRank ) player setStat( 252, level.maxRank );
	else player setStat( 252, rankId );
}

updateRankScoreHUD( amount ) {
	self endon( "disconnect" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );

	if ( amount == 0 ) return;

	self notify( "update_score" );
	self endon( "update_score" );

	self.rankUpdateTotal += amount;

	wait .05;

	if ( isDefined( self.hud_rankscoreupdate ) ) {
		if ( self.rankUpdateTotal < 0 ) {
			self.hud_rankscoreupdate.label = &"";
			self.hud_rankscoreupdate.color = ( 1, 0, 0 );
		} else {
			self.hud_rankscoreupdate.label = &"MP_PLUS";
			self.hud_rankscoreupdate.color = ( 1, 1, 0.5 );
		}

		self.hud_rankscoreupdate setValue( self.rankUpdateTotal );
		self.hud_rankscoreupdate.alpha = 0.85;
		self.hud_rankscoreupdate thread maps\mp\gametypes\_hud::fontPulse( self );

		wait 2;
		self.hud_rankscoreupdate fadeOverTime( 0.75 );
		self.hud_rankscoreupdate.alpha = 0;
		self.rankUpdateTotal = 0;
	}
}

getRankForXp( xpVal ) {
	rankId = 0;
	rankName = level.rankTable[rankId][1];
	assert( isDefined( rankName ) );

	while ( isDefined( rankName ) && rankName != "" ) {
		if ( xpVal < getRankMinXp( rankId ) + getRankXpAmount( rankId ) ) return rankId;
		rankId++;
		if ( isDefined( level.rankTable[rankId] ) ) rankName = level.rankTable[rankId][1];
		else rankName = undefined;
	}

	rankId--;
	return rankId;
}

getRankXp() {
	return self.pers["rankxp"];
}

getRankMinXp( rank ) {
	return int( level.rankTable[rank][2] );
}

getRankXpAmount( rank ) {
	return int( level.rankTable[rank][3] );
}

getRankMaxXp( rank ) {
	return int( level.rankTable[rank][7] );
}

getRankIcon( rank, prestige ) {
	return tableLookup( "mp/rankIconTable.csv", 0, rank, prestige + 1 );
}

setScoreValue( type, value ) {
	level.scoreInfo[type]["value"] = value;
}

getScoreValue( type ) {
	return ( level.scoreInfo[type]["value"] );
}

isItemUnlocked( table, id ) {
	if ( id >= table.size || id <= -1 ) return false;
	if ( self.pers["rank"] >= table[id]["rank"] ) return true;
	return false;
}