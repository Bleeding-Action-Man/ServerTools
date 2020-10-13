//=============================================================================
// Collection of cool features to empower your server;
// Some parts of the code are credit to TraderMut, I've heavily
// edited the code and fixed some previous issues with it
// Made by Vel-San @ https://steamcommunity.com/id/Vel-San/
//=============================================================================

class KFServerTools extends Mutator Config(KFServerTools);

// Config Vars
var() config bool bDebug, bAdminAndSelectPlayers;
var() config string sSkipTraderCmd, sCurrentTraderTimeCmd, sCustomTraderTimeCmd, sReviveMe;
var() config int iDefaultTraderTime, iReviveCost;

// Tmp Vars
var bool Debug, AdminAndSelectPlayers;
var int DefaultTraderTime, ReviveCost;
var string SkipTraderCmd, CurrentTraderTimeCmd, CustomTraderTimeCmd, ReviveMe;
var KFGameType KFGT;

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

// Timer Trigger
function PreBeginPlay()
{
	local int i;

	// Tmp Vars Initialization | I don't like working directly with Config vars (>.<)
	Debug = bDebug;
	AdminAndSelectPlayers = bAdminAndSelectPlayers;
	SkipTraderCmd = sSkipTraderCmd;
	CurrentTraderTimeCmd = sCurrentTraderTimeCmd;
	CustomTraderTimeCmd = sCustomTraderTimeCmd;
	ReviveMe = sReviveMe;
	ReviveCost = iReviveCost;
	DefaultTraderTime = iDefaultTraderTime;
	KFGT = KFGameType(level.game);

	if(KFGT == none)
	{
		MutLog("-----|| KFGameType not found! ||-----");
	}

	// Fill in the Dynamic Array of Special Players
	for(i=0; i<aSpecialPlayers.Length; i=i++)
	{
    SpecialPlayers[i] = aSpecialPlayers[i];
  	}

	if(Debug)
	{
    	MutLog("-----|| DEBUG - DefaultTraderTime: " $DefaultTraderTime$ " ||-----");
    	MutLog("-----|| DEBUG - AdminAndSelectPlayers: " $AdminAndSelectPlayers$ " ||-----");
    	MutLog("-----|| DEBUG - SkipTraderCmd: " $SkipTraderCmd$ " ||-----");
    	MutLog("-----|| DEBUG - CurrentTraderTimeCmd: " $CurrentTraderTimeCmd$ " ||-----");
    	MutLog("-----|| DEBUG - CustomTraderTimeCmd: " $CustomTraderTimeCmd$ " ||-----");
    	MutLog("-----|| DEBUG - # Of Special Players Players: " $SpecialPlayers.Length$ " ||-----");
	}
	SetTimer(1, false);
}

// Timer to change default trader time
function Timer()
{
	if (DefaultTraderTime > 0)
	{
		TimeStampLog("-----|| Default Trader Time Modified ||-----");
		KFGameType(Level.Game).TimeBetweenWaves = DefaultTraderTime;
	}
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

function Mutate(string command, PlayerController Sender)
{
	local string PN, PID;
	local string WelcomeMSG, DefaultTraderTimeMSG, SkipTraderMSG, CurrentTraderTimeMSG, CustomTraderTimeMSG,
				MSG1, MSG2, MSG3,
				ReviveMSG;
	local array<string> SplitCMD;
	local int num, i;

	PN = Sender.PlayerReplicationInfo.PlayerName;
  	PID = Sender.GetPlayerIDHash();

	SplitStringToArray(SplitCMD, command, " ");

	if(command ~= "st help" || command ~= "skiptrader help")
	{
		WelcomeMSG = "%yYou are viewing Server-Tools Mut Help, below are the commands you can use!";
		DefaultTraderTimeMSG = "%bCurrent default trader time: %w" $DefaultTraderTime;
		SkipTraderMSG = "%g" $SkipTraderCmd$ ": Skip the current trader time. %wUsage: %tmutate " $SkipTraderCmd;
		CurrentTraderTimeMSG = "%g" $CurrentTraderTimeCmd$ ": Change the current trade time of this wave. %wUsage: %tmutate " $CurrentTraderTimeCmd$ " <6-255>";
		CustomTraderTimeMSG = "%g" $CustomTraderTimeCmd$ ": Change the default trader time. %wUsage: %tmutate " $CustomTraderTimeCmd$ " <6-255>";
		ReviveMSG = "%g" $ReviveMe$ ": Revive yourself if you have at least " $ReviveCost$ " Dosh. %wUsage: %tmutate " $ReviveMe;
		SetColor(WelcomeMSG);
		SetColor(DefaultTraderTimeMSG);
		SetColor(SkipTraderMSG);
		SetColor(CurrentTraderTimeMSG);
		SetColor(CustomTraderTimeMSG);
		SetColor(ReviveMSG);
		Sender.ClientMessage(WelcomeMSG);
		Sender.ClientMessage(DefaultTraderTimeMSG);
		Sender.ClientMessage(SkipTraderMSG);
		Sender.ClientMessage(CurrentTraderTimeMSG);
		Sender.ClientMessage(CustomTraderTimeMSG);
		Sender.ClientMessage(ReviveMSG);
		return;
	}

	if(command ~= ReviveMe)
	{
		if(FuckingReviveMe(Sender))
		{
			ServerMessage("%w-----|| %b" $PN$ " %whas revived himself! ||-----");
		}
		return;
	}

	if (AdminAndSelectPlayers)
	{
		if(Debug)
		{
			MutLog("-----|| DEBUG - Mutate available for Admins & Selected Players only ||-----");
		}
		if(FindSteamID(i, PID))
		{
			ServerMessage("%w-----|| %b" $PN$ " %wis %gmodifying %wthe Trader! ||-----");
		}
		else
		{
			ServerMessage("%w-----|| %rWarning %wto: %b" $PN$ "%w! You %rcannot %wmanipulate the trader! Only Special Players have permission. ||-----");
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
		if(KFGameType(Level.Game).bTradingDoorsOpen) {
			KFGameType(Level.Game).WaveCountDown = 6;
			ServerMessage("Trader Time Skipped by: %b" $PN);
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
		if(KFGameType(Level.Game).bTradingDoorsOpen) {
			if(num <= 6)
				num = 6;
			if(num > 255)
				num = 120;
			KFGameType(Level.Game).WaveCountDown = num;
			ServerMessage("%b" $PN$ " %wchanged the current trader time to %t" $string(num)$ " %wseconds.");
		} else {
			MSG2 = "%b" $PN$ "%w, %t" $CurrentTraderTimeCmd$ " %wis only functional during trader time.";
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
		KFGameType(Level.Game).TimeBetweenWaves = int(SplitCMD[1]);
		ServerMessage("%b" $PN$ " %wchanged the trader time between waves to %t" $string(int(SplitCMD[1]))$ " %wseconds.");

	}
	if (NextMutator != None )
		NextMutator.Mutate(command, Sender);
}

// Allow players to revive themselves if they have enough do$h! How cool is that?
function bool FuckingReviveMe(PlayerController TmpPC)
{
	local int dosh, hp;
	local string PendingMSG, EndedMSG, AliveMSG, DeadMSG, DoshMSG;

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

	if(TmpPC == none)
	{
		return false;
	}

	hp = TmpPC.Pawn.Health;
	dosh = TmpPC.PlayerReplicationInfo.Score;

	// If player is alive
	if (hp > 0)
	{
		AliveMSG = "%wYou're already alive!";
		SetColor(AliveMSG);
		TmpPC.ClientMessage(AliveMSG);
		return false;
	}

	// If player is dead
	if ( !TmpPC.PlayerReplicationInfo.bOnlySpectator )
	{
		// Check if they have enough dosh
		if (dosh < ReviveCost)
		{
			DeadMSG = "%wYeah... you're fucking %rdead %wAND %rbroke! %wYou need %t" $ReviveCost$ " %wDo$h for a revive";
			SetColor(DeadMSG);
			TmpPC.ClientMessage(DeadMSG);
		}
		else
		{
			TmpPC.PlayerReplicationInfo.Score = int(TmpPC.PlayerReplicationInfo.Score) - ReviveCost;
			dosh = TmpPC.PlayerReplicationInfo.Score;
			if( TmpPC != none )
            	{
            	    TmpPC.GotoState('PlayerWaiting');
            	    TmpPC.SetViewTarget(TmpPC);
            	    TmpPC.ClientSetBehindView(false);
            	    TmpPC.bBehindView = False;
            	    TmpPC.ClientSetViewTarget(TmpPC.Pawn);
            	}

            TmpPC.ServerReStartPlayer();
			DoshMSG = "%wFuck Yeah! You've been given another chance for life. Your total %g$$$ %wis now: %g" $dosh;
			SetColor(DoshMSG);
			TmpPC.ClientMessage(DoshMSG);
			return true;
		}
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
    FriendlyName = "Server Tools - v1.1"
    Description = "Collection of cool features to empower your server; Made by Vel-San;"

	// Mut Vars
	bDebug = False
	bAdminAndSelectPlayers = True
    sSkipTraderCmd = "skip"
    sCurrentTraderTimeCmd = "tt"
    sCustomTraderTimeCmd = "st"
	sReviveMe = "revme"
	iDefaultTraderTime = 60
	iReviveCost = 250

	// SpecialPlayers Array Example
	// Only SteamID is important, PName is just to easily read & track the IDs
	// aSpecialPlayers=(PName="Vel-San",steamID="76561198122568951")
}
