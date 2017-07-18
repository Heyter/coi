AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );
include( "shared.lua" );

function ENT:RunBehaviour()

	while( true ) do

		if( GAMEMODE:GetState() == STATE_GAME ) then

			local ply = self:GetClosestPlayer();

			if( ply ) then

				self:StartActivity( ACT_HL2MP_RUN );
				self.loco:SetDesiredSpeed( 250 );
				self:MoveToPlayer( ply );
				if( self.SMG ) then
					self:StartActivity( ACT_HL2MP_IDLE_SMG1 );
				else
					self:StartActivity( ACT_HL2MP_IDLE_REVOLVER );
				end

				if( ply and ply:IsValid() ) then
					self:ShootAtPlayer( ply );
				end

				coroutine.wait( math.Rand( 0, 1 ) );
				coroutine.yield();

			else

				self:StartActivity( ACT_HL2MP_IDLE );
				coroutine.wait( math.Rand( 0, 1 ) );
				coroutine.yield();

			end

		else

			coroutine.yield();

		end

	end

end


function ENT:GetClosestPlayer()

	local ply = nil;
	local closest = math.huge;
	local d;
	local mp = self:GetPos();

	for _, v in pairs( player.GetAll() ) do

		if( v.Joined and self:CanTargetPlayer( v ) ) then
			
			d = v:GetPos():DistToSqr( mp ); -- faster than Distance and I don't care about exacts
			if( d < closest ) then
				closest = d;
				ply = v;
			end

		end
		
	end

	return ply;

end

function ENT:OnStuck()

	local trace = { };
	trace.start = self:GetPos() + Vector( 0, 0, 64 );
	trace.endpos = trace.start + self:GetForward() * 60;
	trace.filter = self;
	trace.mins = Vector( -16, -16, 16 );
	trace.maxs = Vector( 16, 16, 16 );
	local tr = util.TraceHull( trace );

	if( tr.Entity and tr.Entity:IsValid() and tr.Entity:GetClass() == "prop_door_rotating" ) then

		tr.Entity:Fire( "OpenAwayFrom", self:GetName() );

	end

end

function ENT:MoveToPlayer( ply )

	local path = Path( "Chase" );
	path:SetMinLookAheadDistance( 300 );
	path:SetGoalTolerance( 24 );
	path:Compute( self, ply:GetPos() );

	local targ = ply;

	if( !path:IsValid() ) then return "failed to find path" end

	while( path:IsValid() ) do

		if( !self:CanTargetPlayer( targ ) ) then return "invalid ply" end
		path:Chase( self, targ );
		
		if( self.loco:IsStuck() ) then
			self:HandleStuck();
			return "stuck";
		end

		local delay = 0.5;

		local tp = targ:GetPos();
		local mp = self:GetPos();
		local dsqr = tp:DistToSqr( mp );

		if( dsqr > self.AimDist * 6 ) then
			--delay = 1.75;
		end

		if( path:GetAge() > delay ) then

			local closest = self:GetClosestPlayer();
			if( closest != targ ) then

				targ = closest;
				tp = targ:GetPos();
				mp = self:GetPos();
				dsqr = tp:DistToSqr( mp );

				path:Compute( self, tp );

			end

			path:Compute( self, tp );

			if( self:Visible( targ ) and dsqr <= self.AimDist - 16 ) then -- buffer so we don't have edge conditions
				return "got player LOS"
			end
		end

		coroutine.yield()

	end

	return "ok"

end

function ENT:ShootAt( ply )
	
	local start = self:GetPos() + Vector( 0, 0, 60 );

	local d = 10;
	if( self.SMG ) then
		d = 5;
	end

	local bull = { };
	bull.Attacker = self;
	bull.Damage = d * ( 1 - ( math.Clamp( #player.GetJoined() / 20, 0, 1 ) * 0.8 ) );
	bull.Dir = ( ply:GetPos() + Vector( 0, 0, 44 ) - start ):GetNormal();
	bull.Spread = Vector( self.Accuracy, self.Accuracy, 0 );
	bull.Src = start;
	bull.IgnoreEntity = self;
	self:FireBullets( bull );

	if( self.SMG ) then

		self:EmitSound( Sound( "Weapon_SMG1.NPC_Single" ) );
		self:RestartGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1 );

	else

		self:EmitSound( Sound( "Weapon_Pistol.NPC_Single" ) );
		self:RestartGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL );

	end

end

function ENT:CanTargetPlayer( ply )

	if( !self:Alive() ) then return false end
	if( !ply or !ply:IsValid() ) then return false end
	if( !ply:Alive() ) then return false end
	if( ply.Safe ) then return false end
	if( ply.Unconscious ) then return false end

	return true;

end

function ENT:ShootAtPlayer( ply )

	if( !ply or !ply:IsValid() ) then return "invalid ply" end

	local targ = ply;

	while( true ) do

		if( GAMEMODE:GetState() != STATE_GAME ) then return "bad state" end

		if( !self:CanTargetPlayer( targ ) ) then return "invalid ply" end

		self.loco:FaceTowards( targ:GetPos() );

		if( !self.NextShot ) then

			self.NextShot = CurTime() + math.Rand( 0.8, 1.2 );

		end

		if( CurTime() >= self.NextShot ) then

			local t1 = SysTime();
			if( !self:Visible( targ ) ) then

				return "lost player LOS";

			end

			if( ( targ:GetPos() - self:GetPos() ):LengthSqr() > self.AimDist ) then

				return "player too far";

			end

			self.NextShot = CurTime() + math.Rand( 0.4, 0.8 );
			self:ShootAt( targ );
			
			if( self.SMG ) then
				coroutine.wait( 0.075 );
				self:ShootAt( targ );
				coroutine.wait( 0.075 );
				self:ShootAt( targ );

				if( math.random( 1, 2 ) == 1 ) then
					coroutine.wait( 0.075 );
					self:ShootAt( targ );
				end
			end

			local closest = self:GetClosestPlayer();
			if( closest != targ ) then

				targ = closest;

			end

		end

		coroutine.yield()

	end

	return "ok"

end