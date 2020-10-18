//=============================================================================
// Collection of cool features to empower your server;
// Some parts of the code are credit to TraderMut, I've heavily
// edited the code and fixed some previous issues with it
// Made by Vel-San @ https://steamcommunity.com/id/Vel-San/
//=============================================================================

class KFServerTools extends Mutator Config(KFServerTools);

// Config Vars
var() config bool bDebug, bAdminAndSelectPlayers;
var() config string sSkipTraderCmd, sVoteSkipTraderCmd, sCurrentTraderTimeCmd, sCustomTraderTimeCmd, sReviveListCmd, sReviveMeCmd, sReviveThemCmd;
var() config int iDefaultTraderTime, iReviveCost;

// Tmp Vars
var bool Debug, AdminAndSelectPlayers, VoteInProgress, IsTimerActive;
var int DefaultTraderTime, ReviveCost;
var string SkipTraderCmd, VoteSkipTraderCmd, CurrentTraderTimeCmd, CustomTraderTimeCmd, ReviveListCmd, ReviveMeCmd, ReviveThemCmd;
var KFGameType KFGT;
var array<string> aPlayerIDs;
var class<Object> STMenuType;
var KFServerTools Mut;

// Players to be marked as either VIP or Donator
struct SP
{
  var config string PName; // PlayerName, won't be checked
  var config string SteamID; // Steam ID, will always be checked
};
var() config array<SP> aSpecialPlayers; // PlayersList to be declared in the Config
var array<SP> SpecialPlayers;

// Colors from Config
struct ColorRecord
{
  var config string ColorName; // Color name, for comfort
  var config string ColorTag; // Color tag
  var config Color Color; // RGBA values
};
var() config array<ColorRecord> ColorList; // Color list

// Initialization
function PostBeginPlay()
{
	local int i;

	// Pointer To self
    Mut = self;
    default.Mut = self;
	class'KFServerTools'.default.Mut = self;

	// Tmp Vars Initialization | I don't like working directly with Config vars (>.<)
	Debug = bDebug;
	AdminAndSelectPlayers = bAdminAndSelectPlayers;
	VoteInProgress = false;
	IsTimerActive = false;
	SkipTraderCmd = sSkipTraderCmd;
	VoteSkipTraderCmd = sVoteSkipTraderCmd;
	CurrentTraderTimeCmd = sCurrentTraderTimeCmd;
	CustomTraderTimeCmd = sCustomTraderTimeCmd;
	ReviveListCmd = sReviveListCmd;
	ReviveMeCmd = sReviveMeCmd;
	ReviveThemCmd = sReviveThemCmd;
	ReviveCost = iReviveCost;
	DefaultTraderTime = iDefaultTraderTime;
	KFGT = KFGameType(Level.Game);

	// Add Server Tools tab to ESC-Menu
	InjectNewMenu(STMenuType);

	if(KFGT == none)
	{
		MutLog("-----|| KFGameType not found! ||-----");
	}

	// Fill in the Dynamic Array of Special Players
	for(i=0; i<aSpecialPlayers.Length; i=i++)
	{
    SpecialPlayers[i] = aSpecialPlayers[i];
  	}

	// Generate config in case there is no .ini file
	// SaveConfig();

	if(Debug)
	{
    	MutLog("-----|| DEBUG - DefaultTraderTime: " $DefaultTraderTime$ " ||-----");
    	MutLog("-----|| DEBUG - AdminAndSelectPlayers: " $AdminAndSelectPlayers$ " ||-----");
    	MutLog("-----|| DEBUG - SkipTraderCmd: " $SkipTraderCmd$ " ||-----");
    	MutLog("-----|| DEBUG - VoteSkipTraderCmd: " $VoteSkipTraderCmd$ " ||-----");
    	MutLog("-----|| DEBUG - CurrentTraderTimeCmd: " $CurrentTraderTimeCmd$ " ||-----");
    	MutLog("-----|| DEBUG - CustomTraderTimeCmd: " $CustomTraderTimeCmd$ " ||-----");
    	MutLog("-----|| DEBUG - ReviveListCmd: " $ReviveListCmd$ " ||-----");
    	MutLog("-----|| DEBUG - ReviveMeCmd: " $ReviveMeCmd$ " ||-----");
    	MutLog("-----|| DEBUG - ReviveThemCmd: " $ReviveThemCmd$ " ||-----");
    	MutLog("-----|| DEBUG - ReviveCost: " $ReviveCost$ " ||-----");
    	MutLog("-----|| DEBUG - # Of Special Players Players: " $SpecialPlayers.Length$ " ||-----");
	}

	if (DefaultTraderTime > 0)
	{
		TimeStampLog("-----|| Default Trader Time Modified (" $DefaultTraderTime$ ") ||-----");
		KFGT.TimeBetweenWaves = DefaultTraderTime;
	}
}

// TODO: Add Debugging in almost all functions

// Timer to change default trader time
function Timer()
{

	if(Debug)
    	MutLog("-----|| DEBUG - New wave started | Trader Skip Votes reset ||-----");

	// Notify Players that a new vote should be placed
	CriticalServerMessage("%wTrader Skip votes have been %greset%w. You can start a %bnew%w vote now!");

	// Reset the Votes array after trader is done
	aPlayerIDs.length = 0;
	IsTimerActive = false;
}

final function SplitStringToArray(out array<string> Parts, string Source, string Delim)
{
    Split(Source, Delim, Parts);
}

function ServerMessage(string Msg)
{
	local Controller C;
	local PlayerController PC;
	for (C = Level.ControllerList; C != none; C = C.nextController)
	{
		PC = PlayerController(C);
		if (PC != none)
		{
			SetColor(Msg);
			PC.ClientMessage(Msg);
		}
	}
}

function CriticalServerMessage(string Msg)
{
	local Controller C;
	local PlayerController PC;
	for (C = Level.ControllerList; C != none; C = C.nextController)
	{
		PC = PlayerController(C);
		if (PC != none)
		{
			SetColor(Msg);
			PC.ClientMessage(Msg, 'CriticalEvent');
		}
	}
}

function Mutate(string command, PlayerController Sender)
{
	local string PN, PID;
	local string WelcomeMSG, AdminsAndSPsMSG, DefaultTraderTimeMSG, SkipTraderMSG, VoteSkipTraderMSG, CurrentTraderTimeMSG, CustomTraderTimeMSG,
				MSG1, MSG2, MSG3,
				ReviveMeMSG, ReviveListMSG, ReviveThemMSG;
	local array<string> SplitCMD;
	local int num, i;

	PN = Sender.PlayerReplicationInfo.PlayerName;
  	PID = Sender.GetPlayerIDHash();

	if(Debug)
	{
		MutLog("-----|| DEBUG - '" $command$ "' accessed by: " $PN$ " | PID: " $PID$  " ||-----");
	}

	SplitStringToArray(SplitCMD, command, " ");

	if(command ~= "st help" || command ~= "servertools help")
	{
		WelcomeMSG = "%yYou are viewing Server-Tools Help, below are the commands you can use:";
		AdminsAndSPsMSG = "%oOnly Admins & Selected players can manipulate trader time! You can however use the %t" $VoteSkipTraderCmd$ " %ocommand";
		DefaultTraderTimeMSG = "%bCurrent default trader time: %w" $DefaultTraderTime;
		SkipTraderMSG = "%w" $SkipTraderCmd$ ": %gSkip the current trader time. %wUsage: %tmutate " $SkipTraderCmd;
		VoteSkipTraderMSG = "%w" $VoteSkipTraderCmd$ ": %gStart a vote with others to skip trader. %wUsage: %tmutate " $VoteSkipTraderCmd;
		CurrentTraderTimeMSG = "%w" $CurrentTraderTimeCmd$ ": %gChange the current trade time of this wave. %wUsage: %tmutate " $CurrentTraderTimeCmd$ " <6-255>";
		CustomTraderTimeMSG = "%w" $CustomTraderTimeCmd$ ": %gChange the default trader time. %wUsage: %tmutate " $CustomTraderTimeCmd$ " <6-255>";
		ReviveMeMSG = "%w" $ReviveMeCmd$ ": %gRevive yourself if you have at least %v" $ReviveCost$ " %gDosh. %wUsage: %tmutate " $ReviveMeCmd;
		ReviveListMSG = "%w" $ReviveListCmd$ ": %gShows a list of every dead player + their revive code. %wUsage: %tmutate " $ReviveListCmd;
		ReviveThemMSG = "%w" $ReviveThemCmd$ ": %gRevive other players. Costs %v" $ReviveCost$ " %gDosh. %wUsage: %tmutate " $ReviveThemCmd$ " all %w/ %tmutate " $ReviveThemCmd$ " <Rev Code>";
		SetColor(WelcomeMSG);
		SetColor(DefaultTraderTimeMSG);
		SetColor(SkipTraderMSG);
		SetColor(VoteSkipTraderMSG);
		SetColor(CurrentTraderTimeMSG);
		SetColor(CustomTraderTimeMSG);
		SetColor(ReviveMeMSG);
		SetColor(ReviveListMSG);
		SetColor(ReviveThemMSG);
		Sender.ClientMessage(WelcomeMSG);
		if(AdminAndSelectPlayers)
		{
			SetColor(AdminsAndSPsMSG);
			Sender.ClientMessage(AdminsAndSPsMSG);
		}
		Sender.ClientMessage(DefaultTraderTimeMSG);
		Sender.ClientMessage(SkipTraderMSG);
		Sender.ClientMessage(VoteSkipTraderMSG);
		Sender.ClientMessage(CurrentTraderTimeMSG);
		Sender.ClientMessage(CustomTraderTimeMSG);
		Sender.ClientMessage(ReviveMeMSG);
		Sender.ClientMessage(ReviveListMSG);
		Sender.ClientMessage(ReviveThemMSG);
		return;
	}

	if(command ~= VoteSkipTraderCmd)
	{
		StartSkipVote(Sender);
		return;
	}

	if(command ~= ReviveMeCmd)
	{
		if(FuckingReviveMeCmd(Sender))
		{
			ServerMessage("%t" $PN$ " %whas revived himself!");
		}
		return;
	}

	if(command ~= ReviveListCmd)
	{
		WhoTheFuckIsDead(Sender);
		return;
	}

	if(Left(command, Len(ReviveThemCmd)) ~= ReviveThemCmd)
	{
		ServerMessage("%t" $PN$ " %wis attempting to revive someone!");
		FuckingReviveThemCmd(Sender, SplitCMD[1]);
		return;
	}

	if (AdminAndSelectPlayers)
	{
		if(FindSteamID(i, PID))
		{
			if (command ~= SkipTraderCmd || Left(command, Len(CurrentTraderTimeCmd)) ~= CurrentTraderTimeCmd || Left(command, Len(CustomTraderTimeCmd)) ~= CustomTraderTimeCmd)
				ServerMessage("%t" $PN$ " %wis %gmodifying %wthe Trader!");
		}
		else
		{
			if (command ~= SkipTraderCmd || Left(command, Len(CurrentTraderTimeCmd)) ~= CurrentTraderTimeCmd || Left(command, Len(CustomTraderTimeCmd)) ~= CustomTraderTimeCmd)
				ServerMessage("%rWarning %wto: %t" $PN$ "%w! You %rcannot %wmanipulate the trader! Only Special Players have permission.");
			return;
		}
	}
	else
	{
		if(Debug)
		{
			MutLog("-----|| DEBUG - WARNING! SkipTrader Mutate is available for everybody - chance for trolls messing up your game! ||-----");
		}
	}

	// Skip the trader by setting wave countdown to 6 instantly
	if (command ~= SkipTraderCmd) {
		if(KFGT.bTradingDoorsOpen) {
			KFGT.WaveCountDown = 6;
			ServerMessage("Trader Time Skipped by: %t" $PN);
		} else {
			MSG1 = "%b" $PN$ "%w, %t" $SkipTraderCmd$ " %wis only functional during trader time.";
			SetColor(MSG1);
			Sender.ClientMessage(MSG1);
		}
	}

	// Change current trader countdown
	// Limited between 6 and 255
	if (Left(command, Len(CurrentTraderTimeCmd)) ~= CurrentTraderTimeCmd) {
		num = int(SplitCMD[1]);
		if(KFGT.bTradingDoorsOpen) {
			if(num <= 6)
				num = 6;
			if(num > 255)
				num = 120;
			KFGT.WaveCountDown = num;
			ServerMessage("%t" $PN$ " %wchanged the current trader time to %t" $string(num)$ " %wseconds.");
		} else {
			MSG2 = "%t" $PN$ "%w, %t" $CurrentTraderTimeCmd$ " %wis only functional during trader time.";
			SetColor(MSG2);
     		Sender.ClientMessage(MSG2);
		}
	}

	// Change the default time of the trader
	// Limited between 6 and 255
	if (Left(command, Len(CustomTraderTimeCmd)) ~= CustomTraderTimeCmd) {
		if(int(SplitCMD[1]) <= 6 || int(SplitCMD[1]) > 255) {
			MSG3 = "%b" $PN$ "%w, time between waves has to be between %t6 %wand %t255";
			SetColor(MSG3);
			Sender.ClientMessage(MSG3);
			return;
		}
		KFGT.TimeBetweenWaves = int(SplitCMD[1]);
		iDefaultTraderTime = int(SplitCMD[1]);
		default.iDefaultTraderTime = int(SplitCMD[1]);
		DefaultTraderTime = int(SplitCMD[1]);
		default.DefaultTraderTime = int(SplitCMD[1]);
		ServerMessage("%t" $PN$ " %wchanged the trader time between waves to %t" $string(int(SplitCMD[1]))$ " %wseconds.");

	}
	if (NextMutator != None )
		NextMutator.Mutate(command, Sender);
}

// Ability for a player to register a skip-trader vote
function bool StartSkipVote(PlayerController TmpPC)
{
	local string PendingMSG, EndedMSG, InProgressMSG, AlreadyVotedMSG, PlayerID, TmpPlayerName;
	local int i;
	local bool bAlreadyVoted;

	// Bool to check in case an Admin is using mutate skip to override this
	VoteInProgress = true;
	bAlreadyVoted = false;

	// Conditions to neglect votes
	if(KFGT.IsInState('PendingMatch'))
	{
		VoteInProgress = false;
		PendingMSG = "%wThe game hasn't started yet!";
		SetColor(PendingMSG);
		TmpPC.ClientMessage(PendingMSG);
		return false;
	}

	if(KFGT.IsInState('GameEnded'))
	{
		VoteInProgress = false;
		EndedMSG = "%wThe game has ended!";
		SetColor(EndedMSG);
		TmpPC.ClientMessage(EndedMSG);
		return false;
	}

	if(KFGT.bWaveInProgress)
	{
		VoteInProgress = false;
		InProgressMSG = "%wYou cannot start a vote while a wave is in progress!";
		SetColor(InProgressMSG);
		TmpPC.ClientMessage(InProgressMSG);
		return false;
	}

	// Conditions passed, start a vote
	TmpPlayerName = TmpPC.PlayerReplicationInfo.PlayerName;
	PlayerID = TmpPC.GetPlayerIDHash();
	for(i=0;i<aPlayerIDs.length;i++)
		{
			if(aPlayerIDs[i] == PlayerID)
			{
				bAlreadyVoted = true;
				AlreadyVotedMSG = "%wYou cannot vote twice, your vote has already been registered!";
				SetColor(AlreadyVotedMSG);
				TmpPC.ClientMessage(AlreadyVotedMSG);
				return false;
			}
		}
		if(bAlreadyVoted == false)
		{
			aPlayerIDs.Insert(0,1);
			aPlayerIDs[0] = PlayerID;
			ServerMessage("%t" $TmpPlayerName$ " %wis ready to skip trader / type in your console %bmutate " $VoteSkipTraderCmd$ " %wif you're also ready, or vote from the ESC-Menu!");
			// Reset aPlayerIDs to 0 if once a new wave starts
			if(IsTimerActive == false)
			{
				CriticalServerMessage("%wCollecting votes to %bSkip Trader%w - Votes collected will reset in %r30 %wseconds!");
				SetTimer( 30, false);
				IsTimerActive = true;
			}
		}
		if(aPlayerIDs.length == GetActualPlayers())
		{
			Disable('Timer');
			IsTimerActive = false;
			if(Debug)
    			MutLog("-----|| DEBUG - All votes have been collected to skip trader | Timer Disabled ||-----");
			KFGT.WaveCountDown = 6;
			aPlayerIDs.length = 0;
			return true;
		}
}

// Allow players to revive themselves if they have enough do$h!
function bool FuckingReviveMeCmd(PlayerController TmpPC)
{
	local int dosh;
	local bool bIsAlive; // False = Alive, True = Dead;
	local string PendingMSG, EndedMSG, InProgressMSG, AliveMSG, DeadMSG, DoshMSG;

	if(KFGT.IsInState('PendingMatch'))
	{
		PendingMSG = "%wThe game hasn't started yet!";
		SetColor(PendingMSG);
		TmpPC.ClientMessage(PendingMSG);
		return false;
	}

	if(KFGT.IsInState('GameEnded'))
	{
		EndedMSG = "%wThe game has ended, you cannot revive!";
		SetColor(EndedMSG);
		TmpPC.ClientMessage(EndedMSG);
		return false;
	}

	if(!KFGT.bWaveInProgress)
	{
		InProgressMSG = "%wAll players are already alive in Trader Time";
		SetColor(InProgressMSG);
		TmpPC.ClientMessage(InProgressMSG);
		return false;
	}

	bIsAlive = TmpPC.PlayerReplicationInfo.bOutOfLives;
	dosh = TmpPC.PlayerReplicationInfo.Score;

	// If player is alive
	if (bIsAlive == false)
	{
		AliveMSG = "%wYou're already alive!";
		SetColor(AliveMSG);
		TmpPC.ClientMessage(AliveMSG);
		return false;
	}

	// If player is dead
	// Check if they have enough dosh
	if (dosh < ReviveCost)
	{
		DeadMSG = "%wYeah... you're fucking %rdead %wAND %rbroke! %wYou need %t" $ReviveCost$ " %wDo$h for a revive";
		SetColor(DeadMSG);
		TmpPC.ClientMessage(DeadMSG);
		return false;
	}
	else
	{
		SelfRespawnProcess(TmpPC);
		dosh = TmpPC.PlayerReplicationInfo.Score;
		DoshMSG = "%wFuck Yeah! You've been given another chance for life. Your total %g$$$ %wis now: %g" $dosh;
		SetColor(DoshMSG);
		TmpPC.ClientMessage(DoshMSG);
		return true;
	}
}

// Allow players to revive other players, and the dosh will be deducted from their own
function bool FuckingReviveThemCmd(PlayerController TmpPC, string PlayerToReviveCodeMATCH)
{
	local int dosh, isPlayerFound;
	local string PendingMSG, EndedMSG, InProgressMSG, AliveMSG, NotFoundMSG, PoorMSG, DoshMSG, PlayerToReviveNAME, PlayerToReviveCode;
	local Controller c;
	local bool bIsAlive; // false = Alive, true = Dead

	// Dosh of the player attempting to revive another player
	dosh = TmpPC.PlayerReplicationInfo.Score;

	if(KFGT.IsInState('PendingMatch'))
	{
		PendingMSG = "%wThe game hasn't started yet!";
		SetColor(PendingMSG);
		TmpPC.ClientMessage(PendingMSG);
		return false;
	}

	if(KFGT.IsInState('GameEnded'))
	{
		EndedMSG = "%wThe game has ended, you cannot revive!";
		SetColor(EndedMSG);
		TmpPC.ClientMessage(EndedMSG);
		return false;
	}

	if(!KFGT.bWaveInProgress)
	{
		InProgressMSG = "%wAll players are already alive in Trader Time";
		SetColor(InProgressMSG);
		TmpPC.ClientMessage(InProgressMSG);
		return false;
	}

	for( C = Level.ControllerList; C != None; C = C.nextController )
	{
		if( C.IsA('PlayerController') && PlayerController(C).PlayerReplicationInfo.PlayerID != 0)
		{
			bIsAlive = C.PlayerReplicationInfo.bOutOfLives;
			PlayerToReviveNAME = C.PlayerReplicationInfo.PlayerName;
			PlayerToReviveCode = PlayerController(C).GetPlayerIDHash();

			if (PlayerToReviveCodeMATCH ~= "all")
			{
					// Skip if player is alive
					if (bIsAlive == false)
					{
						continue;
					}

					// Check if they have enough dosh
					if (dosh < ReviveCost)
					{
						PoorMSG = "%wYou do not have enough dosh! You need %t" $ReviveCost$ " %wDo$h for a revive";
						SetColor(PoorMSG);
						TmpPC.ClientMessage(PoorMSG);
						return false;
					}

					// If all above conditions are passed, revive current player
					// And take dosh from the charitable reviver :D
					TmpPC.PlayerReplicationInfo.Score = int(TmpPC.PlayerReplicationInfo.Score) - ReviveCost;
					dosh = TmpPC.PlayerReplicationInfo.Score;
					DoshMSG = "%wFuck Yeah! You've given %t" $PlayerToReviveNAME$ " %wanother chance for life. Your total %g$$$ %wis now: %g" $dosh;
					SetColor(DoshMSG);
					TmpPC.ClientMessage(DoshMSG);
					OthersRespawnProcess(PlayerController(C));
			}
			else
			{
				isPlayerFound = InStr( Caps(PlayerToReviveCode), Caps(PlayerToReviveCodeMATCH));
				if (isPlayerFound >=0)
				{
					// If player being revived is already alive
					if (bIsAlive == false)
					{
						AliveMSG = "%t" $PlayerToReviveNAME$ " %wis already alive!";
						SetColor(AliveMSG);
						TmpPC.ClientMessage(AliveMSG);
						return false;
					}

					// Check if they have enough dosh
					if (dosh < ReviveCost)
					{
						PoorMSG = "%wYou do not have enough dosh! You need %t" $ReviveCost$ " %wDo$h for a revive";
						SetColor(PoorMSG);
						TmpPC.ClientMessage(PoorMSG);
						return false;
					}

					// If all above conditions are passed, revive this player!
					// And take dosh from the charitable reviver :D
					TmpPC.PlayerReplicationInfo.Score = int(TmpPC.PlayerReplicationInfo.Score) - ReviveCost;
					dosh = TmpPC.PlayerReplicationInfo.Score;
					DoshMSG = "%wFuck Yeah! You've given %t" $PlayerToReviveNAME$ " %wanother chance for life. Your total %g$$$ %wis now: %g" $dosh;
					SetColor(DoshMSG);
					TmpPC.ClientMessage(DoshMSG);
					OthersRespawnProcess(PlayerController(C));
					return true;
				}
				else
				{
					NotFoundMSG = "%t" $PlayerToReviveCodeMATCH$ " %wis not related to any of the players! Try again with a more accurate name.";
					SetColor(NotFoundMSG);
					TmpPC.ClientMessage(NotFoundMSG);
					return false;
				}
			}
		}
	}
}

// Process of a player respawning themselves
// Combination of AdminMut, Admin.uc & KFGameType code contributions
function SelfRespawnProcess(PlayerController TmpPC)
{
	if (TmpPC.PlayerReplicationInfo != None && !TmpPC.PlayerReplicationInfo.bOnlySpectator && TmpPC.PlayerReplicationInfo.bOutOfLives)
	{
		Level.Game.Disable('Timer');
		TmpPC.PlayerReplicationInfo.bOutOfLives = false;
		TmpPC.PlayerReplicationInfo.NumLives = 0;
		TmpPC.PlayerReplicationInfo.Score =  int(TmpPC.PlayerReplicationInfo.Score) - ReviveCost;
		TmpPC.GotoState('PlayerWaiting');
		TmpPC.SetViewTarget(TmpPC);
		TmpPC.ClientSetBehindView(false);
		TmpPC.bBehindView = False;
		TmpPC.ClientSetViewTarget(TmpPC.Pawn);
		KFGT.bWaveInProgress = false;
		TmpPC.ServerReStartPlayer();
		KFGT.bWaveInProgress = true;
		Level.Game.Enable('Timer');
	}
}

// Process of a player other players
// Combination of AdminMut, Admin.uc & KFGameType code contributions
function OthersRespawnProcess(PlayerController TmpPC)
{
	if (TmpPC.PlayerReplicationInfo != None && !TmpPC.PlayerReplicationInfo.bOnlySpectator && TmpPC.PlayerReplicationInfo.bOutOfLives)
	{
		Level.Game.Disable('Timer');
		TmpPC.PlayerReplicationInfo.bOutOfLives = false;
		TmpPC.PlayerReplicationInfo.NumLives = 0;
		TmpPC.PlayerReplicationInfo.Score =   Max(KFGT.MinRespawnCash, int(TmpPC.PlayerReplicationInfo.Score));
		TmpPC.GotoState('PlayerWaiting');
		TmpPC.SetViewTarget(TmpPC);
		TmpPC.ClientSetBehindView(false);
		TmpPC.bBehindView = False;
		TmpPC.ClientSetViewTarget(TmpPC.Pawn);
		KFGT.bWaveInProgress = false;
		TmpPC.ServerReStartPlayer();
		KFGT.bWaveInProgress = true;
		Level.Game.Enable('Timer');
		ServerMessage("%t" $TmpPC.PlayerReplicationInfo.PlayerName$ " %whas revived!");
	}
}

// Matches SteamIDs for each player
final function bool FindSteamID(out int i, string ID)
{
    for(i=0; i<SpecialPlayers.Length; i++){
        if (ID == SpecialPlayers[i].SteamID){
            return true;
        }
    }
    return false;
}

// Edit ESC-Menu to inject new Trader Opt. Menu
final function InjectNewMenu(class<Object> MenuName)
{
	local PlayerController TmpPC;

	KFGT.LoginMenuClass = string(MenuName);

	ForEach DynamicActors(class'PlayerController', TmpPC)
		TmpPC.MidGameMenuClass = "STInvasionLoginMenu";
}

// Print all 'dead' player names + IDs for revival message
final function WhoTheFuckIsDead(PlayerController TmpPC)
{
	local bool bIsAlive, bNoOneDead;
	local Controller C;
	local string PendingMSG, EndedMSG, InProgressMSG, DeadPlayerMSG, NoOneDeadMSG, DeadPlayerName, DeadPlayerID, DeadPlayerRevCode;

	bNoOneDead = true;

	if(KFGT.IsInState('PendingMatch'))
	{
		PendingMSG = "%wThe game hasn't started yet!";
		SetColor(PendingMSG);
		TmpPC.ClientMessage(PendingMSG);
		return;
	}

	if(KFGT.IsInState('GameEnded'))
	{
		EndedMSG = "%wThe game has ended, you cannot revive!";
		SetColor(EndedMSG);
		TmpPC.ClientMessage(EndedMSG);
		return;
	}

	if(!KFGT.bWaveInProgress)
	{
		InProgressMSG = "%wAll players are already alive in Trader Time";
		SetColor(InProgressMSG);
		TmpPC.ClientMessage(InProgressMSG);
		return;
	}

	for( C = Level.ControllerList; C != None; C = C.nextController )
	{
		if( C.IsA('PlayerController') && PlayerController(C).PlayerReplicationInfo.PlayerID != 0)
		{
			bIsAlive = C.PlayerReplicationInfo.bOutOfLives;
			DeadPlayerName = C.PlayerReplicationInfo.PlayerName;
			DeadPlayerID = PlayerController(C).GetPlayerIDHash();
			DeadPlayerRevCode = Right(DeadPlayerID, 5);

			// Skip if player is alive
			if (bIsAlive == false)
			{
				continue;
			}

			bNoOneDead = false;
			DeadPlayerMSG = "%t" $DeadPlayerName$ " %w / rev code: %t" $DeadPlayerRevCode$ " %w/ full code: %t" $DeadPlayerID;
			SetColor(DeadPlayerMSG);
			TmpPC.ClientMessage(DeadPlayerMSG);
		}
	}

	if(bNoOneDead)
	{
		NoOneDeadMSG = "%wAll players are alive!";
		SetColor(NoOneDeadMSG);
		TmpPC.ClientMessage(NoOneDeadMSG);
		return;
	}
}

// Gets actual players regardless of bots/faked players or spectaters
// Credits for AdminMut
function int GetActualPlayers()
{
  	local Controller C;
  	local PlayerReplicationInfo PRI;
  	local int i;

  	i = 0;
  	for( C=Level.ControllerList; C!=None; C=C.NextController )
  	{
  	  PRI = C.PlayerReplicationInfo;
  	  if( (PRI != None) && !PRI.bBot && MessagingSpectator(C) == None && !PRI.bOnlySpectator && !PRI.bIsSpectator)
  	  {
  	    i++;
  	  }
  	}
	if(Debug)
	{
		MutLog("-----|| DEBUG - Actual Players Count: " $i$ " ||-----");
	}
  	return i;
}

function TimeStampLog(coerce string s)
{
  log("["$Level.TimeSeconds$"s]" @ s, 'SkipTrader');
}

function MutLog(string s)
{
  log(s, 'SkipTrader');
}

/////////////////////////////////////////////////////////////////////////
// BELOW SECTION IS CREDITED FOR NikC //

// Apply Color Tags To Message
function SetColor(out string Msg)
{
  local int i;
  for(i=0; i<ColorList.Length; i++)
  {
    if(ColorList[i].ColorTag!="" && InStr(Msg, ColorList[i].ColorTag)!=-1)
    {
      ReplaceText(Msg, ColorList[i].ColorTag, FormatTagToColorCode(ColorList[i].ColorTag, ColorList[i].Color));
    }
  }
}

// Format Color Tag to ColorCode
function string FormatTagToColorCode(string Tag, Color Clr)
{
  Tag=Class'GameInfo'.Static.MakeColorCode(Clr);
  Return Tag;
}

function string RemoveColor(string S)
{
  local int P;
  P=InStr(S,Chr(27));
  While(P>=0)
  {
    S=Left(S,P)$Mid(S,P+4);
    P=InStr(S,Chr(27));
  }
  Return S;
}
//////////////////////////////////////////////////////////////////////

defaultproperties
{
	// Mandatory Vars
	GroupName = "KF-ServerTools"
    FriendlyName = "Server Tools - v1.8b"
    Description = "Collection of cool features to empower your server; Made by Vel-San"
	bAddToServerPackages=true
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true

	// Inject new ESC-Menu Tab
	STMenuType=class'STInvasionLoginMenu'

	// Mut Vars
	bDebug = False
	bAdminAndSelectPlayers = True
    sSkipTraderCmd = "skip"
	sVoteSkipTraderCmd = "voteskip"
    sCurrentTraderTimeCmd = "tt"
    sCustomTraderTimeCmd = "ct"
	sReviveListCmd = "dpl"
	sReviveMeCmd = "revme"
	sReviveThemCmd = "rev"
	iDefaultTraderTime = 60
	iReviveCost = 250

	// SpecialPlayers Array Example
	// Only SteamID is important, PName is just to easily read & track the IDs
	// aSpecialPlayers=(PName="Vel-San",steamID="76561198122568951")

	// Colors list | Do not edit the tags AT ALL COSTS | Better leave this untouched at all times
	ColorList(0)=(ColorName="Red",ColorTag="%r",Color=(B=0,G=0,R=200,A=0))
	ColorList(1)=(ColorName="Orange",ColorTag="%o",Color=(B=0,G=127,R=255,A=0))
	ColorList(2)=(ColorName="Yellow",ColorTag="%y",Color=(B=0,G=255,R=255,A=0))
	ColorList(3)=(ColorName="Green",ColorTag="%g",Color=(B=0,G=200,R=0,A=0))
	ColorList(4)=(ColorName="Blue",ColorTag="%b",Color=(B=200,G=100,R=0,A=0))
	ColorList(5)=(ColorName="Teal",ColorTag="%t",Color=(B=113,G=179,R=60,A=0))
	ColorList(6)=(ColorName="Violet",ColorTag="%v",Color=(B=139,G=0,R=255,A=0))
	ColorList(7)=(ColorName="White",ColorTag="%w",Color=(B=200,G=200,R=200,A=0))
}
