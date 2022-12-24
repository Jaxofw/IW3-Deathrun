#include common_scripts\utility;
#include maps\mp\_utility;
#include braxi\_utility;

watchWeapons()
{
    self.weapon = undefined;
    self thread watchWeaponChange();
    self thread watchWeaponUsage();
}

watchWeaponChange()
{
    self endon( "death" );
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "weapon_change", newWeapon );
        self.weapon = newWeapon;

        self setClientDvars(
            "ui_weapon_current_name", formatWeaponName( self.weapon ),
            "ui_weapon_current_clip", self getWeaponAmmoClip( self.weapon ),
            "ui_weapon_current_stock", self getWeaponAmmoStock( self.weapon )
        );
    }
}

watchWeaponUsage()
{
    self endon( "death" );
    self endon( "disconnect" );

    while ( true )
    {
        self waittill_any( "weapon_fired", "reload" );
        self setClientDvars(
            "ui_weapon_current_clip", self getWeaponAmmoClip( self.weapon ),
            "ui_weapon_current_stock", self getWeaponAmmoStock( self.weapon )
        );
    }
}

formatWeaponName( weapon )
{
    if ( isKnife( weapon ) )
    {
        for ( i = 0; i < level.weapon_secondary.size; i++ )
        {
            if ( weapon == level.weapon_secondary[i]["item"] )
            {
                self setClientDvar( "ui_weapon_current_size", level.weapon_secondary[i]["name"].size );
                return level.weapon_secondary[i]["name"];
            }
        }
    }
    else
    {
        for ( i = 0; i < level.weapon_primary.size; i++ )
        {
            if ( weapon == level.weapon_primary[i]["item"] )
            {
                self setClientDvar( "ui_weapon_current_size", level.weapon_primary[i]["name"].size );
                return level.weapon_primary[i]["name"];
            }
        }

        weaponPrefix = weapon[0] + weapon[1];
        index = 0;

        switch ( weaponPrefix )
        {
            case "cs":
                index = 3;
                break;
            case "h1":
                index = 3;
                break;
            case "h2":
                index = 3;
                break;
            case "iw2":
                index = 3;
                break;
            case "iw4":
                index = 3;
                break;
            case "iw5":
                index = 3;
                break;
            case "iw6":
                index = 3;
                break;
            case "iw7":
                index = 3;
                break;
            case "iw8":
                index = 3;
                break;
            case "iw9":
                index = 3;
                break;
            case "ol":
                index = 3;
                break;
            case "s1":
                index = 3;
                break;
            case "s2":
                index = 3;
                break;
            case "s3":
                index = 3;
                break;
            case "t4":
                index = 3;
                break;
            case "t5":
                index = 3;
                break;
            case "t6":
                index = 3;
                break;
            case "t7":
                index = 3;
                break;
            case "t8":
                index = 3;
                break;
            case "t9":
                index = 3;
                break;
        }

        weaponName = getSubStr( weapon, index, weapon.size - 3 );
        formattedName = "";

        for ( i = 0; i < weaponName.size; i++ )
        {
            if ( i == 0 )
                formattedName += toUpper( weaponName[i] );
            else
            {
                if ( foundUnderscore( weaponName[i] ) )
                {
                    formattedName += " " + toUpper( weaponName[i + 1] );
                    i++;
                }
                else
                    formattedName += weaponName[i];
            }
        }

        self setClientDvar( "ui_weapon_current_size", formattedName.size );
        return formattedName;
    }
}

isKnife( weapon )
{
    weapon = getSubStr( weapon, 0, weapon.size - 3 );

    switch ( weapon )
    {
        case "hands":
            return true;
        case "knife":
            return true;
        case "tomahawk":
            return true;
        case "t5_ballistic_knife":
            return true;
        case "t7_butterfly_knife":
            return true;
        case "t7_sword":
            return true;
        case "t8_coinbag":
            return true;
        case "s2_shovel":
            return true;
        case "t9_scythe":
            return true;
        case "t9_bat":
            return true;
        case "ol_bostaff":
            return true;
        case "ol_zombieaxe":
            return true;
        case "ol_katana":
            return true;
        case "ol_slaymore":
            return true;
        case "cs_karambit":
            return true;
        default:
            return false;
    }
}