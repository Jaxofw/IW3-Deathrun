init()
{
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected", player );
        player setClientDvar( "ui_practice_state", false );
    }
}

spawnGhost()
{
    self endon( "disconnect" );
    self endon( "joined_spectators" );
    self endon( "death" );

    self braxi\_mod::spawnPlayer();

    self hide();
    self.ghost = true;
    self.statusicon = "hud_status_dead";
    self setClientDvar( "ui_practice_state", true );

    while ( self.ghost )
    {
        if ( self SecondaryOffhandButtonPressed() )
            self suicide();

        if ( self meleeButtonPressed() )
        {
            if ( self isOnGround() )
            {
                self.o = self.origin;
                self.a = self.angles;
                self iPrintLn( "Position ^1Saved" );
            }

            wait 0.3;
        }
        else if ( self fragButtonPressed() )
        {
            if ( isDefined( self.o ) || isDefined( self.a ) )
            {
                self setOrigin( self.o );
                self setPlayerAngles( self.a );
                self iPrintLn( "Position ^2Loaded" );
            }

            wait 0.3;
        }

        wait 0.05;
    }
}