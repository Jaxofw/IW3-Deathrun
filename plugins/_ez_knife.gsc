/*
______           __  _____  _____ 
| ___ \         /  ||  _  ||  _  |
| |_/ /_____  __`| || |/' || |_| |
|    // _ \ \/ / | ||  /| |\____ |
| |\ \  __/>  < _| |\ |_/ /.___/ /
\_| \_\___/_/\_\\___/\___/ \____/ 

*/

init(ver)
{
    thread onPlayerSpawn();
}

onPlayerSpawn()
{
    while(1)
    {
        level waittill("connected", player);
        player.canknife = false;
        player thread watchForButton();
        player thread watchForWeapon();
    }
}

watchForWeapon()
{
    self endon("disconnect");

    self.currentweaponinhand = "";

    while(1)
    {
        self.currentweaponinhand = self getCurrentWeapon();

        if (self getCurrentWeapon() != "none" && weaponClipSize(self.currentweaponinhand) == 0)
            self.canknife = true;
        else
            self.canknife = false;

        wait 0.01;
    }
}


watchForButton()
{
    self endon("disconnect");

    while(1)
    {
        if(self attackButtonPressed() && self.canknife)
        {
            self braxi\_common::clientCmd( "+melee;-melee" );
        }
        wait 0.01;
    }
}