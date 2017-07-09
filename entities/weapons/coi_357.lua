AddCSLuaFile();

SWEP.Base = "coi_base";
SWEP.PrintName = ".357 Magnum";
SWEP.HoldType = "357";

SWEP.ViewModel = "models/weapons/c_357.mdl";
SWEP.WorldModel = "models/weapons/w_357.mdl";
SWEP.UseHands = true;

SWEP.Primary.Ammo = "357";
SWEP.Primary.Firearm = true;
SWEP.Primary.ClipSize = 6;
SWEP.Primary.DefaultClip = 6;
SWEP.Primary.Automatic = false;
SWEP.Primary.Sound = Sound( "Weapon_357.Single" );
SWEP.Primary.Delay = 0.75;
SWEP.Primary.Spread = 0.05;
SWEP.Primary.InfiniteAmmo = true;

SWEP.ReloadSound = Sound( "Weapon_357.Reload" );