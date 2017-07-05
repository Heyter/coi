local meta = FindMetaTable( "Player" );

function GM:PlayerLoadout( ply )

	

end

local function nJoin( len, ply )

	if( !ply.Joined ) then

		ply.Joined = true;

		ply:SetTeamAuto();
		ply:SetColorToTeam();

		net.Start( "nJoin" );
			net.WriteEntity( ply );
		net.Broadcast();

		ply:SpawnAtTruck();

		if( #player.GetJoined() == 1 ) then
			GAMEMODE:ResetState();
		end

	end

end
net.Receive( "nJoin", nJoin );
util.AddNetworkString( "nJoin" );

function GM:PlayerInitialSpawn( ply )

	self.BaseClass:PlayerInitialSpawn( ply );

	ply.Joined = false;

	ply:SendPlayers();
	ply:SendState();
	ply:SetCustomCollisionCheck( true );

	ply:SetTeam( TEAM_UNJOINED );

end

function GM:PlayerSpawn( ply )

	player_manager.SetPlayerClass( ply, "coi" );

	ply:UnSpectate();

	ply:SetupHands();

	player_manager.OnPlayerSpawn( ply );
	player_manager.RunClass( ply, "Spawn" );
	hook.Call( "PlayerSetModel", GAMEMODE, ply );

	if( ply:IsBot() ) then

		ply.Joined = true;

		ply:SetTeamAuto();
		ply:SetColorToTeam();

		net.Start( "nJoin" );
			net.WriteEntity( ply );
		net.Broadcast();

		ply:SpawnAtTruck();

	end

	ply:SetColorToTeam();
	ply:SpawnAtTruck();

end

function meta:SendPlayers()

	net.Start( "nPlayers" );
		net.WriteUInt( #player.GetAll(), 7 );
		for _, v in pairs( player.GetAll() ) do

			net.WriteEntity( v );
			net.WriteBool( v.Joined );
			net.WriteBool( v.HasMoney );

		end
	net.Send( self );

end
util.AddNetworkString( "nPlayers" );

function meta:SetTeamAuto( noMsg )

	local trucks = GAMEMODE.Trucks;

	local amt = math.huge;
	local t = -1;

	for k, v in pairs( trucks ) do

		if( team.NumPlayers( k ) < amt ) then
			t = k;
			amt = team.NumPlayers( k );
		end

	end

	if( t > -1 ) then

		self:SetTeam( t );

		if( !noMsg ) then

			net.Start( "nSetTeamAuto" );
				net.WriteUInt( t, 16 );
			net.Send( self );

		end

	end

end
util.AddNetworkString( "nSetTeamAuto" );

function meta:SetColorToTeam()

	local col = team.GetColor( self:Team() );
	self:SetPlayerColor( Vector( col.r / 255, col.g / 255, col.b / 255 ) );

end

function meta:SpawnAtTruck()

	if( !GAMEMODE.Trucks ) then return end
	if( !GAMEMODE.Trucks[self:Team()] ) then return end

	local t = GAMEMODE.Trucks[self:Team()];
	self:SetPos( t:GetPos() + t:GetForward() * -180 );

end

function GM:RebalanceTeams()

	for _, v in pairs( player.GetAll() ) do

		v:SetTeam( TEAM_UNJOINED );

	end

	for _, v in pairs( player.GetAll() ) do

		v:SetTeamAuto( true );
		v:SetColorToTeam();

		net.Start( "nSetTeamAutoRebalance" );
			net.WriteUInt( v:Team(), 16 );
		net.Send( v );

	end

end
util.AddNetworkString( "nSetTeamAutoRebalance" );

local function nJoinTeam( len, ply )

	local t = net.ReadUInt( 16 );

	if( !GAMEMODE:CanChangeTeam( ply:Team(), t ) ) then return end

	ply:SetTeam( t );
	ply:SetColorToTeam();

end
net.Receive( "nJoinTeam", nJoinTeam );
util.AddNetworkString( "nJoinTeam" );

function GM:PlayerTakeMoney( ply, ent )

	if( !ply.HasMoney ) then
		
		ply.HasMoney = true;
		net.Start( "nSetMoney" );
			net.WriteEntity( ply );
			net.WriteBool( true );
		net.Broadcast();

	end

end
util.AddNetworkString( "nSetMoney" );

function GM:KeyPress( ply, key )

	if( ply.HasMoney and key == IN_ATTACK2 ) then

		ply:DropMoney( true );

	end

end

function meta:DropMoney( thrown )

	self.HasMoney = false;
	net.Start( "nSetMoney" );
		net.WriteEntity( self );
		net.WriteBool( false );
	net.Broadcast();
	
	self:EmitSound( Sound( "coi/coin.wav" ), 100, math.random( 80, 120 ) );

	local bag = ents.Create( "coi_money" );
	bag:SetPos( self:GetShootPos() + self:GetAimVector() * 32 );
	bag:SetAngles( Angle( math.Rand( -180, 180 ), math.Rand( -180, 180 ), math.Rand( -180, 180 ) ) );
	bag.Owner = self;
	bag:SetDropped( true );
	bag:SetThrown( thrown );
	bag:Spawn();
	bag:Activate();

end