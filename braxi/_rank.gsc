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

	switch( sMeansOfDeath )
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

giveRankXP( type, value ) {
	self endon("disconnect");

	self.score += value;
	self.pers["score"] = self.score;

	score = self maps\mp\gametypes\_persistence::statGet( "score" );
	self maps\mp\gametypes\_persistence::statSet( "score", score + value );
}