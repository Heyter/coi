AddCSLuaFile();

SWEP.Base = "weapon_coi_grenade";
SWEP.PrintName = "Trick Bag";
SWEP.HoldType = "grenade";

SWEP.ViewModel = "models/weapons/c_grenade.mdl";
SWEP.WorldModel = "";
SWEP.UseHands = false;
SWEP.NoDraw = true;

SWEP.Primary.Ammo = "trickbag";
SWEP.Primary.ClipSize = 1;
SWEP.Primary.DefaultClip = 1;
SWEP.Primary.Automatic = false;

function SWEP:PrimaryAttack()

	self:SetNextPrimaryFire( math.huge );
	self:SetNextSecondaryFire( math.huge );

	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	
	self.RemoveTime = CurTime() + 0.1;

end

function SWEP:Throw()

	local fwd = self.Owner:GetForward();
	fwd.z = fwd.z + 0.1;

	local p = self.Owner:EyePos() + fwd * 18 + self.Owner:GetRight() * 8;
	local gpos = self:GrenadeCheckThrow( p );

	local ent = ents.Create( "coi_trickbag" );
	ent:SetPos( gpos );
	ent:SetAngles( Angle() );
	ent:SetPlayer( self.Owner );
	ent:Spawn();
	ent:Activate();

	self.Owner:EmitSound( Sound( "coi/coin.wav" ), 100, math.random( 80, 120 ) );

end
