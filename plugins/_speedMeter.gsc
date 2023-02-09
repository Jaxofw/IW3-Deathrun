#include braxi\_common;

init()
{
    for (;;)
    {
        level waittill( "connected", player );
        player setClientDvar( "ui_player_speed", 0 );
        player thread drawSpeedMeter();
    }
}

drawSpeedMeter()
{
    self endon( "disconnect" );

    while ( true )
    {
        if ( self isPlaying() && self getStat( 993 ) == 1 )
        {
            speed = self getPlayerSpeed();
            self setClientDvar( "ui_player_speed", speed );
        }

        wait .05;
    }
}

getPlayerSpeed()
{
    velocity = self getVelocity();
    return int( sqrt( ( velocity[0] * velocity[0] ) + ( velocity[1] * velocity[1] ) ) );
}