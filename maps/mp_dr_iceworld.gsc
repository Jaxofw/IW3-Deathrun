// Garry's Mod Iceworld made by METZ & FIBBS
// Remade in cod4 for Arcane deathrun by Mist & alexbubu7
// https://discord.gg/ArcaneNW

main() {
	maps\mp\_load::main();

    // Disables Fall Damage
    setdvar( "bg_fallDamageMaxHeight","999999999" );
    setdvar( "bg_fallDamageMinHeight","9999999" );

    // Testing
    //setdvar( "cg_fovscale","1.2" );
    //setdvar( "g_speed", "230" );

    setdvar( "bg_bobamplitudesprinting", "0" );
    setdvar( "bg_bobamplitudeducked", "0" );
    setdvar( "bg_bobamplitudeprone", "0" );
    setdvar( "bg_bobamplitudestanding", "0" );

    level.classic = getEnt( "old_trig", "targetname" );
    level.sniper = getEnt( "sniper_trig", "targetname" );
    level.jump = getEnt( "jump_trig", "targetname" );
    level.knife = getEnt( "knife_trig", "targetname" );
    level.strafe = getEnt( "strafe_trig", "targetname" );
    level.rope = getEnt( "rope_trig", "targetname" );

    level.sniper_sign = getEnt( "sniper_sign", "targetname" );
    level.jump_sign = getEnt( "jump_sign", "targetname" );
    level.knife_sign = getEnt( "knife_sign", "targetname" );
    level.strafe_sign = getEnt( "strafe_sign", "targetname" );
    level.rope_sign = getEnt( "rope_sign", "targetname" );

    level.snow = loadfx( "dr_iceworld/snow_fx" );
    level.barrel = loadfx( "dr_iceworld/barrel_fx" );
	level.vent_smoke = loadfx( "dr_iceworld/vent_smoke" );
	level.tp_blue = loadfx( "dr_iceworld/teleport_blue" );
	level.tp_red = loadfx( "dr_iceworld/teleport_red" );
    
    level.inroom = false;

    preCacheItem( "m40a3_mp" );
    preCacheItem( "remington700_mp" );
    preCacheItem( "ak47_mp" );
    preCacheItem( "deserteagle_mp" );
    preCacheModel( "lion" );
    preCacheModel( "viewhands_lion" );


    // The Good Stuff
    thread viphands();
    thread vipcharacter();

    // Silly Shit
    thread fedzor();
    thread gun_wall();
    thread free_xp_lmao();

    // Misc
    thread music();
    thread startdoor();
    thread credits();
    thread fx();
    thread secret();
    thread secret_fail();
    thread secret_fin();

    // Acti Teleports
    thread acti_tp1();
    thread acti_tp1_back();
    thread acti_tp2();
    thread acti_tp2_back();

    // Traps
    thread trap1();
    thread trap2();
    thread trap3();
    thread trap4();
    thread trap5();
    thread trap6();
    thread trap7();
    thread trap8();
    thread trap9();
    thread trap10();
    thread trap11();
    thread trap12();
    thread trap13();

    // End Rooms
    thread classic();
    thread sniper();
    thread jump();
    thread knife();
    thread strafe();
    thread rope();

        // Trigger List
    addTriggerToList( "trap1_trig" );
    addTriggerToList( "trap2_trig" ); 
    addTriggerToList( "trap3_trig" ); 
    addTriggerToList( "trap4_trig" ); 
    addTriggerToList( "trap5_trig" ); 
    addTriggerToList( "trap6_trig" ); 
    addTriggerToList( "trap7_trig" ); 
    addTriggerToList( "trap8_trig" );
    addTriggerToList( "trap9_trig" );
    addTriggerToList( "trap10_trig" );
    addTriggerToList( "trap11_trig" );
    addTriggerToList( "trap12_trig" );
    addTriggerToList( "trap13_trig" );
}

addTriggerToList( name ) {

   if( !isDefined( level.trapTriggers ) )
      level.trapTriggers = [];
   level.trapTriggers[level.trapTriggers.size] = getEnt( name, "targetname" );
}

viphands() {
    level.vips = [];
    level.vips[level.vips.size] = "22899472"; // Mist
    level.vips[level.vips.size] = "05299624"; // Jax
    level.vips[level.vips.size] = "30421138"; // Rex109
    level.vips[level.vips.size] = "09210966"; // alexbubu7
    level.vips[level.vips.size] = "60552768"; // Zeronwad
    level.vips[level.vips.size] = "13479637"; // Emily
    level.vips[level.vips.size] = "81691487"; // Heisen
    level.vips[level.vips.size] = "00000000"; // some nigga
    
    vipTrig = getEnt( "viphands", "targetname" );
    vipTrig setHintString( "^8VIP ^7Hands" );

    while ( true )
    {
        vipTrig waittill( "trigger", player );
        guid = getSubStr( player getGuid(), 11, 19 );

        for ( i = 0; i < level.vips.size; i++ )
        {
            if ( guid == level.vips[i] )
            {
                player setViewModel( "viewhands_lion" );
                player iPrintLn( "^2Success!" );
            }
        }
    }
}

vipcharacter()
{
    vipTrig = getEnt( "vipcharacter", "targetname" );
    vipTrig setHintString( "^8VIP ^7Character" );

    while ( true )
    {
        vipTrig waittill( "trigger", player );
        guid = getSubStr( player getGuid(), 11, 19 );

        for ( i = 0; i < level.vips.size; i++ )
        {
            if ( guid == level.vips[i] )
            {
                player setModel( "lion" );
                player iPrintLn( "^2Success!" );
            }
        }
    }
}

fedzor() {
    level waittill( "round_started" );
    level.fedzor = getEnt( "fed_enter", "targetname" );
    trig = getEnt( "fed_step1", "targetname" );

    level.fedzor solid();

    trig waittill( "trigger" );
    thread fed_step2();
}

fed_step2() {
    trig = getEnt( "fed_step2", "targetname" );

    trig waittill( "trigger" );
    thread angry_green_man();
}

angry_green_man() {
    level.fedzor notsolid();
}

gun_wall() {
    trig = getEnt( "gun_door", "targetname" );
    wall = getEnt( "gun_wall", "targetname" );

    wall solid();
    trig waittill( "trigger", player );
    wall notsolid();
    thread ak47();
}

free_xp_lmao() {
    xp = getEnt( "xp_trig", "targetname" );

    while( 1 ) {
        xp waittill( "trigger", player );
        player braxi\_rank::giveRankXp(undefined, 100000);
    }
}

ak47() {
    trig = getEnt( "ak47_trig", "targetname" );
    
    while( 1 ) {
        trig waittill( "trigger", player );
        player giveWeapon( "ak47_mp" );
        player switchToWeapon( "ak47_mp" );
        player giveMaxAmmo( "ak47_mp" );
        player iPrintLnBold( "now you can shit on the activator in old" );
    }
}

music() {
    level waittill( "round_started" );
    wait 2;

	songs = [];
	songs[songs.size] = "song1";
	songs[songs.size] = "song2";
	songs[songs.size] = "song3";

	selected = songs[ Randomint( songs.size ) ];
	AmbientPlay( selected );
}

startdoor() {
    level waittill( "round_started" );
    door = getEnt( "startdoor", "targetname" );

    wait 5;
    door moveZ( -128, 3, 1, 1 );
    wait 2;
    iPrintLn( "Door opening..." );
    door notSolid();
}

credits() {
    while( 1 ) {
        iPrintLn( "Original made by METZ & FIBBS" );
        wait 8;
        iPrintLn( "Remade by Mist" );
        wait 8;
        iPrintLn( "Thanks to alexbubu7 for making the secret, knife, sniper & jump room!" );
        wait 8;
        iPrintLn( "Thanks to Rex109 for making the Jump Rope room" );
        wait 8;
    }
}

fx() {
    level waittill( "round_started" );

    // Other
    snow = getEnt( "snow_fx", "targetname" );
    barrel = getEnt( "barrel_fx", "targetname" );

    // Activator Effects
    acti_fx1 = getEnt( "tp_fx1", "targetname" );
    acti_fx2 = getEnt( "tp_fx2", "targetname" );
    acti_fx3 = getEnt( "tp_fx3", "targetname" );
    acti_fx4 = getEnt( "tp_fx4", "targetname" );

    // Jumper Effects
    jump_fx1 = getEnt( "jump_tp_fx1", "targetname" );
    jump_fx2 = getEnt( "jump_tp_fx2", "targetname" );
    jump_fx3 = getEnt( "jump_tp_fx3", "targetname" );
    jump_fx4 = getEnt( "jump_tp_fx4", "targetname" );
    jump_fx5 = getEnt( "jump_tp_fx5", "targetname" );
    jump_fx6 = getEnt( "jump_tp_fx6", "targetname" );
    jump_fx7 = getEnt( "jump_tp_fx7", "targetname" );
    
    playFX(level.snow, snow.origin);
    playFX(level.barrel, barrel.origin);

    playFX(level.tp_red, acti_fx1.origin);
    playFX(level.tp_red, acti_fx2.origin);
    playFX(level.tp_red, acti_fx3.origin);
    playFX(level.tp_red, acti_fx4.origin);

    playFX(level.tp_blue, jump_fx1.origin);
    playFX(level.tp_blue, jump_fx2.origin);
    playFX(level.tp_blue, jump_fx3.origin);
    playFX(level.tp_blue, jump_fx4.origin);
    playFX(level.tp_blue, jump_fx5.origin);
    playFX(level.tp_blue, jump_fx6.origin);
    playFX(level.tp_blue, jump_fx7.origin);
}

acti_tp1() {
    trig = getEnt( "acti_tp1", "targetname" );
    org = getEnt( "acti_tp1_org", "targetname" );

    while( 1 ) {
        trig waittill( "trigger", player );
        player freezeControls(1);
        player setorigin (org.origin);
        player setplayerangles (org.angles);
        wait .1;
        player freezeControls(0);
    }
}

acti_tp1_back() {
    trig = getEnt( "acti_tp1_back", "targetname" );
    org = getEnt( "acti_tp1_back_org", "targetname" );

    while( 1 ) {
        trig waittill( "trigger", player );
        player freezeControls(1);
        player setorigin (org.origin);
        player setplayerangles (org.angles);
        wait .1;
        player freezeControls(0);
    }
}

acti_tp2() {
    trig = getEnt( "acti_tp2", "targetname" );
    org = getEnt( "acti_tp2_org", "targetname" );

    while( 1 ) {
        trig waittill( "trigger", player );
        player freezeControls(1);
        player setorigin (org.origin);
        player setplayerangles (org.angles);
        wait .1;
        player freezeControls(0);
    }
}

acti_tp2_back() {
    trig = getEnt( "acti_tp2_back", "targetname" );
    org = getEnt( "acti_tp2_back_org", "targetname" );

    while( 1 ) {
        trig waittill( "trigger", player );
        player freezeControls(1);
        player setorigin (org.origin);
        player setplayerangles (org.angles);
        wait .1;
        player freezeControls(0);
    }
}

secret() {
    step1 = getEnt( "secret_step1", "targetname" );

    step1 waittill( "trigger" );
    iPrintLn( "how did u find this" );
    thread step2();
}

step2() {
    step2 = getEnt( "secret_step2", "targetname" );

    step2 waittill( "trigger" );
    iPrintLn( "ok u must be hackin" );
    thread door();
}

door() {
    swing1 = getEnt( "secret_open_1", "targetname" );
    swing2 = getEnt( "secret_open_2", "targetname" );

    trig = getEnt( "secret_open_trig", "targetname" );
    trig waittill( "trigger", player );

    iPrintLnBold( "^8" + player.name + " ^7Opened the secret door!" );
    swing1 rotateYaw( -80, 3, 1, 1 );
    swing2 rotateYaw( 80, 3, 1, 1 );

    wait 2;
    thread go();
}

go() {
    enter = getEnt( "secret_enter", "targetname" );
    level.secret = getEnt( "secret_org", "targetname" );

    enter setHintString( "^7Press ^8&&1 ^7To enter the secret!" );

    while( 1 ) {
        enter waittill( "trigger", player );
        player setorigin (level.secret.origin);
        player setplayerangles (level.secret.angles);
    }
}

secret_fail() {
    fail = getEnt( "secret_fail", "targetname" );

    while( 1 ) {
        fail waittill( "trigger", player );
        player setorigin (level.secret.origin);
        player setplayerangles (level.secret.angles);
    }
}

secret_fin() {
    trig = getEnt( "secret_finish", "targetname" );
    org = getEnt( "secret_finish_org", "targetname" );

    while( 1 ) {
        trig waittill( "trigger", player );
        iPrintLnBold( "^8" + player.name + " ^7has finished the secret!" );

        player freezeControls(1);
        player setorigin (org.origin);
        player setplayerangles (org.angles);
        player braxi\_rank::giveRankXp(undefined, 2500);
        wait .02;
        player freezeControls(0);
    }
}

trap1() {
    floor1 = getEnt( "trap1_1", "targetname" );
    floor2 = getEnt( "trap1_2", "targetname" );

    trig = getEnt( "trap1_trig", "targetname" );

    trig SetHintString( "^7Press ^8&&1 ^7To Activate" );
    trig waittill( "trigger", player );
    trig SetHintString( "^8Activated" );

    while( 1 ) {
        floor1 rotateRoll( 85, .5 );
        floor2 rotateRoll( -85, .5 );
        wait 5;
        floor1 rotateRoll( -85, .5 );
        floor2 rotateRoll( 85, .5 );
        wait 5;
    }
}

trap2() {
    spike1 = getEnt( "trap2_1", "targetname" );
    spike2 = getEnt( "trap2_2", "targetname" );
    spike3 = getEnt( "trap2_3", "targetname" );
    spike4 = getEnt( "trap2_4", "targetname" );
    spike5 = getEnt( "trap2_5", "targetname" );
    spike6 = getEnt( "trap2_6", "targetname" );

    clip1 = getEnt( "trap2_1_clip", "targetname" );
    clip2 = getEnt( "trap2_2_clip", "targetname" );
    clip3 = getEnt( "trap2_3_clip", "targetname" );
    clip4 = getEnt( "trap2_4_clip", "targetname" );
    clip5 = getEnt( "trap2_5_clip", "targetname" );
    clip6 = getEnt( "trap2_6_clip", "targetname" );

    hurt1 = getEnt( "trap2_1_hurt", "targetname" );
    hurt2 = getEnt( "trap2_2_hurt", "targetname" );
    hurt3 = getEnt( "trap2_3_hurt", "targetname" );
    hurt4 = getEnt( "trap2_4_hurt", "targetname" );
    hurt5 = getEnt( "trap2_5_hurt", "targetname" );
    hurt6 = getEnt( "trap2_6_hurt", "targetname" );
    
    clip1 LinkTo( spike1 );
    clip2 LinkTo( spike2 );
    clip3 LinkTo( spike3 );
    clip4 LinkTo( spike4 );
    clip5 LinkTo( spike5 );
    clip6 LinkTo( spike6 );
    
    hurt1 EnableLinkTo();
    hurt1 LinkTo( spike1 );

    hurt2 EnableLinkTo();
    hurt2 LinkTo( spike2 );

    hurt3 EnableLinkTo();
    hurt3 LinkTo( spike3 );

    hurt4 EnableLinkTo();
    hurt4 LinkTo( spike4 );

    hurt5 EnableLinkTo();
    hurt5 LinkTo( spike5 );

    hurt6 EnableLinkTo();
    hurt6 LinkTo( spike6 );
    
    trig = getEnt( "trap2_trig", "targetname" );

    trig SetHintString( "^7Press ^8&&1 ^7To Activate" );
    trig waittill( "trigger", player );
    trig SetHintString( "^8Activated" );

    spike1 moveZ( -201, .8 );
    wait .1;
    spike2 moveZ( -201, .8 );
    wait .1;
    spike3 moveZ( -201, .8 );
    wait .1;
    spike4 moveZ( -201, .8 );
    wait .1;
    spike5 moveZ( -201, .8 );
    wait .1;
    spike6 moveZ( -201, .8 );
    wait .1;
}

trap3() {
    link1 = getEnt( "trap3_1_link", "targetname" );
    link2 = getEnt( "trap3_2_link", "targetname" );
    link3 = getEnt( "trap3_3_link", "targetname" );
    link4 = getEnt( "trap3_4_link", "targetname" );

    fan1 = getEnt( "trap3_fan1", "targetname" );
    fan2 = getEnt( "trap3_fan2", "targetname" );
    fan3 = getEnt( "trap3_fan3", "targetname" );
    fan4 = getEnt( "trap3_fan4", "targetname" );
    
    hurt1 = getEnt( "trap3_1_hurt", "targetname" );
    hurt2 = getEnt( "trap3_2_hurt", "targetname" );
    hurt3 = getEnt( "trap3_3_hurt", "targetname" );
    hurt4 = getEnt( "trap3_4_hurt", "targetname" );
    
    hurt1 EnableLinkTo();
    hurt1 LinkTo( link1 );

    hurt2 EnableLinkTo();
    hurt2 LinkTo( link2 );

    hurt3 EnableLinkTo();
    hurt3 LinkTo( link3 );

    hurt4 EnableLinkTo();
    hurt4 LinkTo( link4 );

    fx1 = getEnt( "trap3_fx1", "targetname" );
    fx2 = getEnt( "trap3_fx2", "targetname" );
    fx3 = getEnt( "trap3_fx3", "targetname" );
    fx4 = getEnt( "trap3_fx4", "targetname" );

    trig = getEnt( "trap3_trig", "targetname" );
    
    trig SetHintString( "^7Press ^8&&1 ^7To Activate" );
    trig waittill( "trigger", player );
    trig SetHintString( "^8Activated" );

    link1 moveZ( 108, 3 );
    link2 moveZ( 108, 3 );
    link3 moveZ( 108, 3 );
    link4 moveZ( 108, 3 );

    playFX(level.vent_smoke, fx1.origin);
    playFX(level.vent_smoke, fx2.origin);
    playFX(level.vent_smoke, fx3.origin);
    playFX(level.vent_smoke, fx4.origin);

    while( 1 ) {
        fan1 rotateYaw( -360, 3 );
        fan2 rotateYaw( -360, 3 );
        fan3 rotateYaw( -360, 3 );
        fan4 rotateYaw( -360, 3 );
        wait 3;
    }
}

trap4() {
    door = getEnt( "trap4_door", "targetname" );
    ice = getEnt( "trap4_ice", "targetname" );
    water = getEnt( "trap4_water", "targetname" );
    ladder = getEnt( "trap4_ladder", "targetname" );
    hurt = getEnt( "trap4_hurt", "targetname" );
    link = getEnt( "trap4_link", "targetname" );
    
    ice hide();
    ice notSolid();

    hurt EnableLinkTo();
    hurt LinkTo( link );

    trig = getEnt( "trap4_trig", "targetname" );

    trig SetHintString( "^7Press ^8&&1 ^7To Activate" );
    trig waittill( "trigger", player );
    trig SetHintString( "^8Activated" );

    ice show();
    ice solid();

    link moveZ( 160, 4 );

    door delete();
    water delete();
    ladder delete();
}

trap5() {
    doors = getEnt( "trap5_doors", "targetname" );

    wall1 = getEnt( "trap5_1", "targetname" );
    wall2 = getEnt( "trap5_2", "targetname" );
    
    hurt1 = getEnt( "trap5_1_hurt", "targetname" );
    hurt2 = getEnt( "trap5_2_hurt", "targetname" );

    doors hide();
    doors notSolid();

    hurt1 EnableLinkTo();
    hurt1 LinkTo( wall1 );

    hurt2 EnableLinkTo();
    hurt2 LinkTo( wall2 );

    trig = getEnt( "trap5_trig", "targetname" );
    
    trig SetHintString( "^7Press ^8&&1 ^7To Activate" );
    trig waittill( "trigger", player );
    trig SetHintString( "^8Activated" );

    doors show();
    doors solid();

    wall1 moveY( 112, 3, 1, 1 );
    wall2 moveY( -112, 3, 1, 1 );
    wait 5;
    wall1 moveY( -112, 3, 1, 1 );
    wall2 moveY( 112, 3, 1, 1 );
    wait 2;

    doors hide();
    doors notSolid();
}

trap6() {
    fall1 = getEnt( "trap6_1", "targetname" );
    fall2 = getEnt( "trap6_2", "targetname" );
    fall3 = getEnt( "trap6_3", "targetname" );
    
    hurt1 = getEnt( "trap6_1_hurt", "targetname" );
    hurt2 = getEnt( "trap6_2_hurt", "targetname" );
    hurt3 = getEnt( "trap6_3_hurt", "targetname" );

    hurt1 EnableLinkTo();
    hurt1 LinkTo( fall1 );

    hurt2 EnableLinkTo();
    hurt2 LinkTo( fall2 );

    hurt3 EnableLinkTo();
    hurt3 LinkTo( fall3 );

    trig = getEnt( "trap6_trig", "targetname" );
    
    trig SetHintString( "^7Press ^8&&1 ^7To Activate" );
    trig waittill( "trigger", player );
    trig SetHintString( "^8Activated" );

    fall1 moveZ( -256, 1 );
    wait .3;
    fall2 moveZ( -256, 1 );
    wait .3;
    fall3 moveZ( -256, 1 );
    wait .3;
    
}

trap7() {
    plat1 = getEnt( "trap7_1", "targetname" );
    plat2 = getEnt( "trap7_2", "targetname" );
    plat3 = getEnt( "trap7_3", "targetname" );
    plat4 = getEnt( "trap7_4", "targetname" );
    
    trig = getEnt( "trap7_trig", "targetname" );
    
    trig SetHintString( "^7Press ^8&&1 ^7To Activate" );
    trig waittill( "trigger", player );
    trig SetHintString( "^8Activated" );

    plat1 moveZ( -100, 4, 1, 1 );
    wait .5;
    plat2 moveZ( -100, 4, 1, 1 );
    wait .5;
    plat3 moveZ( -100, 4, 1, 1 );
    wait .5;
    plat4 moveZ( -100, 4, 1, 1 );
    wait 6;
    plat1 moveZ( 100, 4, 1, 1 );
    wait .5;
    plat2 moveZ( 100, 4, 1, 1 );
    wait .5;
    plat3 moveZ( 100, 4, 1, 1 );
    wait .5;
    plat4 moveZ( 100, 4, 1, 1 );
}

trap8() {
    down1 = getEnt( "trap8_1", "targetname" );
    down2 = getEnt( "trap8_2", "targetname" );

    trig = getEnt( "trap8_trig", "targetname" );

    trig SetHintString( "^7Press ^8&&1 ^7To Activate" );
    trig waittill( "trigger", player );
    trig SetHintString( "^8Activated" );

    randomPart = randomInt( 2 );
        switch( randomPart ) {
        case 0:
        for( i = 0; i < down1.size; i++ ) {
            down1 moveZ( -188, 4, 1, 1 );
            wait .05;
        }
        break;
        case 1:
        for( i = 0; i < down2.size; i++ ) {
            down2 moveZ( -188, 4, 1, 1 );
            wait .05;
        }
        break;
    }
}

trap9() {
    one = getEnt( "trap9_1", "targetname" );
    two = getEnt( "trap9_2", "targetname" );
    three = getEnt( "trap9_3", "targetname" );

    trig = getEnt( "trap9_trig", "targetname" );

    trig SetHintString( "^7Press ^8&&1 ^7To Activate" );
    trig waittill( "trigger", player );
    trig SetHintString( "^8Activated" );

    randomPart = randomInt( 3 );
        switch( randomPart ) {
        case 0:
        for( i = 0; i < one.size; i++ ) {
            one delete();
            wait .05;
        }
        break;
        case 1:
        for( i = 0; i < two.size; i++ ) {
            two delete();
            wait .05;
        }
        break;
        case 2:
        for( i = 0; i < three.size; i++ ) {
            three delete();
            wait .05;
        }
        break;
    }
}

trap10() {
    laser = getEnt( "trap10_1", "targetname" );
    hurt = getEnt ( "trap10_hurt", "targetname" );

    hurt EnableLinkTo();
    hurt LinkTo( laser );

    trig = getEnt( "trap10_trig", "targetname" );

    trig SetHintString( "^7Press ^8&&1 ^7To Activate" );
    trig waittill( "trigger", player );
    trig SetHintString( "^8Activated" );

    while( 1 ) {
        laser moveX( 873, 3, 1, 1 );
        wait 4;
        laser moveX( -873, 3, 1, 1 );
        wait 4;
    }
}

trap11() {
    down1 = getEnt( "trap11_1", "targetname" );
    down2 = getEnt( "trap11_2", "targetname" );
    down3 = getEnt( "trap11_3", "targetname" );

    trig = getEnt( "trap11_trig", "targetname" );

    trig SetHintString( "^7Press ^8&&1 ^7To Activate" );
    trig waittill( "trigger", player );
    trig SetHintString( "^8Activated" );

    randomPart = randomInt( 3 );
        switch( randomPart ) {
        case 0:
        for( i = 0; i < down1.size; i++ ) {
            down1 moveZ( -188, 4, 1, 1 );
            wait .05;
        }
        break;
        case 1:
        for( i = 0; i < down2.size; i++ ) {
            down2 moveZ( -188, 4, 1, 1 );
            wait .05;
        }
        break;
        case 2:
        for( i = 0; i < down3.size; i++ ) {
            down3 moveZ( -188, 4, 1, 1 );
            wait .05;
        }
        break;
    }
}

trap12() {
    down1 = getEnt( "trap12_1", "targetname" );
    down2 = getEnt( "trap12_2", "targetname" );
    down3 = getEnt( "trap12_3", "targetname" );

    trig = getEnt( "trap12_trig", "targetname" );

    trig SetHintString( "^7Press ^8&&1 ^7To Activate" );
    trig waittill( "trigger", player );
    trig SetHintString( "^8Activated" );

    randomPart = randomInt( 3 );
        switch( randomPart ) {
        case 0:
        for( i = 0; i < down1.size; i++ ) {
            down1 moveZ( -188, 4, 1, 1 );
            wait .05;
        }
        break;
        case 1:
        for( i = 0; i < down2.size; i++ ) {
            down2 moveZ( -188, 4, 1, 1 );
            wait .05;
        }
        break;
        case 2:
        for( i = 0; i < down3.size; i++ ) {
            down3 moveZ( -188, 4, 1, 1 );
            wait .05;
        }
        break;
    }
}

trap13() {
    icy1 = getEnt( "trap13_1", "targetname" );
    icy2 = getEnt( "trap13_2", "targetname" );
    icy3 = getEnt( "trap13_3", "targetname" );

    trig = getEnt( "trap13_trig", "targetname" );

    trig SetHintString( "^7Press ^8&&1 ^7To Activate" );
    trig waittill( "trigger", player );
    trig SetHintString( "^8Activated" );

    icy1 moveZ( -300, 5, 1, 1 );
    wait 3;
    icy2 moveZ( -300, 5, 1, 1 );
    wait 3;
    icy3 moveZ( -300, 5, 1, 1 );
    wait 5;
    icy1 moveZ( 300, 3, 1, 1 );
    wait 1;
    icy2 moveZ( 300, 3, 1, 1 );
    wait 1;
    icy3 moveZ( 300, 3, 1, 1 );
}

classic() {
    door = getEnt( "olddoor", "targetname" );

    level.classic waittill( "trigger", player );

    iPrintLnBold( "^8" + player.name + " ^7chose the classic way!" );

    door moveZ( -200, 5, 1, 1 );
    level.classic delete();
    level.sniper delete();
    level.jump delete();
    level.knife delete();
    level.strafe delete();
    level.rope delete();

    level.sniper_sign delete();
    level.jump_sign delete();
    level.knife_sign delete();
    level.strafe_sign delete();
    level.rope_sign delete();

}

sniper() {
    jump = getEnt( "jump_sniper_org", "targetname" );
    acti = getEnt( "acti_sniper_org", "targetname" );

    while( 1 ) {

            level.sniper setHintString( "Press ^8&&1 ^7to choose ^8Sniper!" );        
            level.sniper waittill( "trigger", player );
            level.sniper setHintString( "^8" + player.name + " ^7is batteling it out in the sniper room with ^8" + level.activ.name + "^7!" );  // change to level.activ

            level.classic delete();
            //level.sniper delete();
            level.jump delete();
            level.knife delete();
            level.strafe delete();
            level.rope delete();

            //level.sniper_sign delete();
            level.jump_sign delete();
            level.knife_sign delete();
            level.strafe_sign delete();
            level.rope_sign delete();

            thread sniper_deag();

            if(!level.inroom) {

                level.inroom = true;

                player setOrigin( jump.origin );
                player setPlayerAngles( jump.angles );
                player TakeAllWeapons(); 
                player GiveWeapon( "m40a3_mp" );
                player giveMaxAmmo( "m40a3_mp" );
                player GiveWeapon( "remington700_mp" );
                player giveMaxAmmo( "remington700_mp" );
                player switchToWeapon( "m40a3_mp" );
                player iPrintLnBold("Get ready!");
                player.health = 100;
                
                if( isDefined( level.activ ) && isAlive( level.activ ) ) 

                    level.activ setOrigin( acti.origin );
                    level.activ setPlayerAngles( acti.angles );
                    level.activ TakeAllWeapons(); 
                    level.activ GiveWeapon( "m40a3_mp" );
                    level.activ giveMaxAmmo( "m40a3_mp" );
                    level.activ GiveWeapon( "remington700_mp" );
                    level.activ giveMaxAmmo( "remington700_mp" );
                    level.activ switchToWeapon( "m40a3_mp" );
                    level.activ iPrintLnBold("Get ready!");
                    level.activ.health = 100;   
                }

                player freezecontrols(1);
                level.activ freezecontrols(1);

                wait 3;

                player iPrintlnBold( "^13" );
                if(isDefined(level.activ) && isAlive(level.activ))
                    level.activ iPrintlnBold( "^13" );
                wait 1;
                player iPrintlnBold( "^32" );
                if(isDefined(level.activ) && isAlive(level.activ))
                    level.activ iPrintlnBold( "^32" );
                wait 1;
                player iPrintlnBold( "^51" );
                if(isDefined(level.activ) && isAlive(level.activ))
                    level.activ iPrintlnBold( "^51" );
                wait 1;
                player iPrintlnBold( "^2GO^7!" );
                player freezecontrols(0);
                if(isDefined(level.activ) && isAlive(level.activ))
                {
                    level.activ iPrintlnBold( "^2GO^7!" );
                    level.activ freezecontrols(0);
                }
                
                while( isAlive( player ) && isDefined( player ) ) 
                    wait 0.05;

                iPrintlnBold( "^8" + player.name + " ^7died in the sniper room!" );
                level.inroom = false;
    }
}

sniper_deag() {
    deagle = getEnt( "deagle", "targetname" );

    trig = getEnt( "deagle_grab", "targetname" );
    trig waittill( "trigger", player );
    trig delete();

    player giveWeapon( "deserteagle_mp" );
    player switchToWeapon( "deserteagle_mp" );
    player giveMaxAmmo( "deserteagle_mp" );
    deagle delete();
}

jump() {
    level.jump_jump = getEnt( "jump_jump_org", "targetname" );
    level.acti_jump = getEnt( "acti_jump_org", "targetname" );

    while( 1 ) {
            level.jump setHintString( "Press ^8&&1 ^7to choose ^8Bounce!" );        
            level.jump waittill( "trigger", player );
            level.jump setHintString( "^8" + player.name + " ^7is batteling it out in the bounce room with ^8" + level.activ.name + "^7!" );  // change to level.activ

            level.classic delete();
            level.sniper delete();
            //level.jump delete();
            level.knife delete();
            level.strafe delete();
            level.rope delete();

            level.sniper_sign delete();
            //level.jump_sign delete();
            level.knife_sign delete();
            level.strafe_sign delete();
            level.rope_sign delete();

            thread jump_ak();
            thread jump_fail();

            if(!level.inroom) {

                level.inroom = true;

                player setOrigin( level.jump_jump.origin );
                player setPlayerAngles( level.jump_jump.angles );
                player TakeAllWeapons(); 
                player GiveWeapon( "knife_mp" );
                player switchToWeapon( "knife_mp" );
                player iPrintLnBold("Get ready!");
                player.health = 100;
                
                
                if( isDefined( level.activ ) && isAlive( level.activ ) ) 
                {

                    level.activ setOrigin( level.acti_jump.origin );
                    level.activ setPlayerAngles( level.acti_jump.angles );
                    level.activ TakeAllWeapons(); 
                    level.activ GiveWeapon( "knife_mp" );
                    level.activ switchToWeapon( "knife_mp" );
                    level.activ iPrintLnBold("Get ready!");
                    level.activ.health = 100;   
                    
                    player iPrintLnBold(player.name + " VS " + level.activ.name);
                    level.activ iPrintLnBold(player.name + " VS " + level.activ.name);
                }
                    
                player freezecontrols(1);
                level.activ freezecontrols(1);

                wait 3;

                player iPrintlnBold( "^13" );
                if(isDefined(level.activ) && isAlive(level.activ))
                    level.activ iPrintlnBold( "^13" );
                wait 1;
                player iPrintlnBold( "^32" );
                if(isDefined(level.activ) && isAlive(level.activ))
                    level.activ iPrintlnBold( "^32" );
                wait 1;
                player iPrintlnBold( "^51" );
                if(isDefined(level.activ) && isAlive(level.activ))
                    level.activ iPrintlnBold( "^51" );
                wait 1;
                player iPrintlnBold( "^2GO^7!" );
                player freezecontrols(0);
                if(isDefined(level.activ) && isAlive(level.activ))
                {
                    level.activ iPrintlnBold( "^2GO^7!" );
                    level.activ freezecontrols(0);
                }
                
                while( isAlive( player ) && isDefined( player ) ) 
                    wait 0.05;

                iPrintlnBold( "^8" + player.name + " ^7died in the bounce room!" );
                level.inroom = false;
            }
    }
}

jump_ak() {
    trig = getEnt( "jump_wpn", "targetname" );

    while( 1 ) {
        trig waittill( "trigger", player );

        player giveWeapon( "ak47_mp" );
        player switchToWeapon( "ak47_mp" );
        player giveMaxAmmo( "ak47_mp" );

    }
}

jump_fail() {
    
    trig = getEnt( "bounce_fail", "targetname" );

    while( 1 ) {
        trig waittill( "trigger", player );

        if( player.pers["team"] == "allies" ) {
            player freezeControls( 1 );
            player SetPlayerAngles( level.jump_jump.angles );
            player SetOrigin( level.jump_jump.origin );
            player freezeControls( 0 );
        }
        else if( player.pers["team"] == "axis" ) {
            level.activ freezeControls( 1 );
            level.activ setPlayerAngles ( level.acti_jump.angles );
            level.activ setOrigin( level.acti_jump.origin );
            level.activ freezeControls( 0 );
        }
    }
}

knife() {
    jump = getEnt( "jump_knife_org", "targetname" );
    acti = getEnt( "acti_knife_org", "targetname" );

    while( 1 ) {
            level.knife setHintString( "Press ^8&&1 ^7to choose ^8Knife!" );        
            level.knife waittill( "trigger", player );
            level.knife setHintString( "^8" + player.name + " ^7is batteling it out in the knife room with ^8" + level.activ.name + "^7!" );  // change to level.activ

            level.classic delete();
            level.sniper delete();
            level.jump delete();
            //level.knife delete();
            level.strafe delete();
            level.rope delete();

            level.sniper_sign delete();
            level.jump_sign delete();
            //level.knife_sign delete();
            level.strafe_sign delete();
            level.rope_sign delete();

            if(!level.inroom) {

                level.inroom = true;

                player setOrigin( jump.origin );
                player setPlayerAngles( jump.angles );
                player TakeAllWeapons(); 
                player GiveWeapon( "knife_mp" );
                player switchToWeapon( "knife_mp" );
                player iPrintLnBold("Get ready!");
                player.health = 100;
                
                
                if( isDefined( level.activ ) && isAlive( level.activ ) ) 
                {

                    level.activ setOrigin( acti.origin );
                    level.activ setPlayerAngles( acti.angles );
                    level.activ TakeAllWeapons(); 
                    level.activ GiveWeapon( "knife_mp" );
                    level.activ switchToWeapon( "knife_mp" );
                    level.activ iPrintLnBold("Get ready!");
                    level.activ.health = 100;   
                    
                    player iPrintLnBold(player.name + " VS " + level.activ.name);
                    level.activ iPrintLnBold(player.name + " VS " + level.activ.name);
                }
                    
                player freezecontrols(1);
                level.activ freezecontrols(1);

                wait 3;

                player iPrintlnBold( "^13" );
                if(isDefined(level.activ) && isAlive(level.activ))
                    level.activ iPrintlnBold( "^13" );
                wait 1;
                player iPrintlnBold( "^32" );
                if(isDefined(level.activ) && isAlive(level.activ))
                    level.activ iPrintlnBold( "^32" );
                wait 1;
                player iPrintlnBold( "^51" );
                if(isDefined(level.activ) && isAlive(level.activ))
                    level.activ iPrintlnBold( "^51" );
                wait 1;
                player iPrintlnBold( "^2GO^7!" );
                player freezecontrols(0);
                if(isDefined(level.activ) && isAlive(level.activ))
                {
                    level.activ iPrintlnBold( "^2GO^7!" );
                    level.activ freezecontrols(0);
                }
                
                while( isAlive( player ) && isDefined( player ) ) 
                    wait 0.05;

                iPrintlnBold( "^8" + player.name + " ^7died in the knife room!" );
                level.inroom = false;
            }
    }
}

strafe() {

    orig_jumper = getEnt ("jump_strafe_org", "targetname");
    orig_acti = getEnt ("acti_strafe_org", "targetname");

    while ( 1 ) {
        level.strafe setHintString( "Press ^8&&1 ^7to choose ^8Pure Strafe!" );        
        level.strafe waittill( "trigger", player );
        level.strafe setHintString( "^8" + player.name + " ^7is batteling it out in the strafe room with ^8" + level.activ.name + "^7!" );

        level.classic delete();
        level.sniper delete();
        level.jump delete();
        level.knife delete();
        //level.strafe delete();
        level.rope delete();

        level.sniper_sign delete();
        level.jump_sign delete();
        level.knife_sign delete();
        //level.strafe_sign delete();
        level.rope_sign delete();

        player setOrigin (orig_jumper.origin);
        player setPlayerAngles (orig_jumper.angles);
        player takeAllWeapons();
        player giveWeapon("knife_mp");
        player switchToWeapon ("knife_mp");
        player iPrintLnBold("Get ready!");
        player.maxhealth = 100;

        if(isDefined(level.activ) && isAlive(level.activ))
        {
            level.activ setPlayerAngles(orig_acti.angles);
            level.activ setOrigin(orig_acti.origin);
            level.activ takeAllWeapons();
            level.activ giveWeapon("knife_mp");
            level.activ switchToWeapon("knife_mp");
            level.activ iPrintLnBold("Get ready!");
            level.activ.maxhealth = 100;

            player iPrintLnBold(player.name + " VS " + level.activ.name);
            level.activ iPrintLnBold(player.name + " VS " + level.activ.name);

            }
                    
            player freezecontrols(1);
            level.activ freezecontrols(1);

            wait 3;

            player iPrintlnBold( "^13" );
            if(isDefined(level.activ) && isAlive(level.activ))
                level.activ iPrintlnBold( "^13" );
            wait 1;
            player iPrintlnBold( "^32" );
            if(isDefined(level.activ) && isAlive(level.activ))
                level.activ iPrintlnBold( "^32" );
            wait 1;
            player iPrintlnBold( "^51" );
            if(isDefined(level.activ) && isAlive(level.activ))
                level.activ iPrintlnBold( "^51" );
            wait 1;
            player iPrintlnBold( "^2GO^7!" );
            player freezecontrols(0);
            if(isDefined(level.activ) && isAlive(level.activ))
            {
                level.activ iPrintlnBold( "^2GO^7!" );
                level.activ freezecontrols(0);
            }

        thread pureend(player, level.activ);

        while(isAlive(player) && isDefined(player))
            wait .05;

        level notify("strafeend");

        iPrintLnBold ("^3" + player.name + " got shit on");
    }
}

pureend(who, who2)
{
    level endon("strafeend");
    trig = getEnt ("strafe_end_trig", "targetname");
    origWin = getEnt ("winner", "targetname");
    origLose = getEnt ("loser", "targetname");

    while(1)
    {
        trig waittill("trigger", winner);
        winner freezeControls (1);
        winner iPrintLnBold("^7You won !");
        winner setOrigin (origWin.origin);
        winner setPlayerAngles (origWin.angles);
        winner takeAllWeapons();
        wait .1;
        winner freezeControls (0);
        winner giveWeapon("ak47_mp");
        winner giveMaxAmmo("ak47_mp");
        winner switchToWeapon("ak47_mp");


        if (winner == who)
            loser = who2;
        else
            loser = who;

        if (isDefined(loser))
        {
            loser setOrigin (origLose.origin);
            loser setPlayerAngles (origLose.angles);
            loser freezeControls (1);
            loser takeAllWeapons();
            loser iPrintLnBold("^7lmao u bad");
        }
    }
}

rope()
{
    jump_rope_org = getEnt( "jump_rope_org", "targetname");
    acti_rope_org = getEnt( "acti_rope_org", "targetname" );

    level.rope_spin = getEnt( "rope_spin", "targetname" );

    level.jump_rope_fail = getEnt( "jump_rope_fail", "targetname" );

    jump_rope_over_org = getEnt( "jump_rope_over_org", "targetname");
    acti_rope_over_org = getEnt( "acti_rope_over_org", "targetname" );

    level.jump_rope_fail enableLinkTo();
    level.jump_rope_fail linkTo(level.rope_spin);

    while(1)
    {
        level.rope setHintString( "Press ^8&&1 ^7to choose ^8Jump Rope!" );        
        level.rope waittill( "trigger", player );
        level.rope setHintString( "^8" + player.name + " ^7is batteling it out in the Jump Rope Room with ^8" + level.activ.name + "^7!" );

        if(isDefined(level.classic))
        {
            level.classic delete();
            level.sniper delete();
            level.jump delete();
            level.knife delete();
            level.strafe delete();
            //level.rope delete();

            level.sniper_sign delete();
            level.jump_sign delete();
            level.knife_sign delete();
            level.strafe_sign delete();
            //level.rope_sign delete();
        }

        player setOrigin(jump_rope_org.origin);
        player setPlayerAngles(jump_rope_org.angles);
        player TakeAllWeapons();
        player freezecontrols(1);
        player iPrintLnBold("Get ready!");

        if(isDefined(level.activ) && isAlive(level.activ))
        {
            level.activ setOrigin(acti_rope_org.origin);
            level.activ setPlayerAngles(acti_rope_org.angles);
            level.activ TakeAllWeapons();
            level.activ freezecontrols(1);

            player iPrintLnBold(player.name + " VS " + level.activ.name);
            level.activ iPrintLnBold(player.name + " VS " + level.activ.name);
        }

        wait 3;

        player iPrintlnBold( "^13" );
        if(isDefined(level.activ) && isAlive(level.activ))
            level.activ iPrintlnBold( "^13" );
        wait 1;
        player iPrintlnBold( "^32" );
        if(isDefined(level.activ) && isAlive(level.activ))
            level.activ iPrintlnBold( "^32" );
        wait 1;
        player iPrintlnBold( "^51" );
        if(isDefined(level.activ) && isAlive(level.activ))
            level.activ iPrintlnBold( "^51" );
        wait 1;
        player iPrintlnBold( "^2GO^7!" );
        player freezecontrols(0);
        if(isDefined(level.activ) && isAlive(level.activ))
        {
            level.activ iPrintlnBold( "^2GO^7!" );
            level.activ freezecontrols(0);
        }
            
        level.ropeloser = undefined;

        thread ropeLogic(player);
        ropeCheck(player);

        if(isDefined(level.ropeloser))
        {
            player setOrigin(jump_rope_over_org.origin);
            player setPlayerAngles(jump_rope_over_org.angles);

            level.activ setOrigin(acti_rope_over_org.origin);
            level.activ setPlayerAngles(acti_rope_over_org.angles);

            if(level.ropeloser == player)
            {
                if(isDefined(level.activ) && isAlive(level.activ))
                {
                    level.activ giveWeapon("ak47_mp");
                    level.activ switchToWeapon( "ak47_mp" );
                    level.activ giveMaxAmmo("ak47_mp");
                }


                player freezeControls(1);
            }
            else
            {
                player giveWeapon("ak47_mp");
                player switchToWeapon( "ak47_mp" );
                player giveMaxAmmo("ak47_mp");

                if(isDefined(level.activ) && isAlive(level.activ))
                    level.activ freezeControls(1);
            }
        }

        while( isDefined( player ) && isAlive( player ) ) 
            wait 0.05;

        iPrintLnBold("Someone died");
    }
}

ropeLogic(player)
{
    level endon("rope_touched");

    ropespeed = 3;

    while(isDefined(player) && isAlive(player))
    {
        level.rope_spin rotatePitch(360, ropespeed);
        level.rope_spin waittill("rotatedone");


        if(!(ropespeed<1))
            ropespeed /= 1.1;
    }

    level notify("rope_touched");
}

ropeCheck(player)
{
    level endon("rope_touched");

    if(!(isDefined(player) && isAlive(player)))
        return;

    level.jump_rope_fail waittill("trigger", player);
    level.ropeloser = player;
    level notify("rope_touched");
}