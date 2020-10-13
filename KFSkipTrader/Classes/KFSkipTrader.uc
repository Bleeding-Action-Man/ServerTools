//=============================================================================
// Enhanced version of TraderMut;
// Modified by Vel-San @ https://steamcommunity.com/id/Vel-San/
//=============================================================================

class KFSkipTrader extends Mutator Config(KFSkipTrader);

// Config Vars
var() config bool bDebug, bAdminAndSelectPlayers;
var() config string sSkipTraderCmd, sCurrentTraderTimeCmd, sCustomTraderTimeCmd;
var() config int iDefaultTraderTime;

// Tmp Vars
var bool Debug, AdminAndSelectPlayers;
var int DefaultTraderTime;
var string SkipTraderCmd, CurrentTraderTimeCmd, CustomTraderTimeCmd;

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
	DefaultTraderTime = iDefaultTraderTime;

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
	local string WelcomeMSG, DefaultTraderTimeMSG, SkipTraderMSG, CurrentTraderTimeMSG, CustomTraderTimeMSG;
	local array<string> SplitCMD;
	local int num, i;

	PN = Sender.PlayerReplicationInfo.PlayerName;
  	PID = Sender.GetPlayerIDHash();

	SplitStringToArray(SplitCMD, command, " ");

	if(command ~= "st help" || command ~= "skiptrader help")
	{
		WelcomeMSG = "%yYou are viewing the SkipTrader Mut Help, below are the commands you can use!";
		DefaultTraderTimeMSG = "%bCurrent default trader time: %w" $DefaultTraderTime;
		SkipTraderMSG = "%g" $SkipTraderCmd$ ": Skip the current trader time. %wUsage: %tmutate " $SkipTraderCmd;
		CurrentTraderTimeMSG = "%g" $CurrentTraderTimeCmd$ ": Change the current trade time of this wave. %wUsage: %tmutate " $CurrentTraderTimeCmd$ " <6-255>";
		CustomTraderTimeMSG = "%g" $CustomTraderTimeCmd$ ": Change the default trader time. %wUsage: %tmutate " $CustomTraderTimeCmd$ " <6-255>";
		SetColor(WelcomeMSG);
		SetColor(DefaultTraderTimeMSG);
		SetColor(SkipTraderMSG);
		SetColor(CurrentTraderTimeMSG);
		SetColor(CustomTraderTimeMSG);
		Sender.ClientMessage(WelcomeMSG);
		Sender.ClientMessage(DefaultTraderTimeMSG);
		Sender.ClientMessage(SkipTraderMSG);
		Sender.ClientMessage(CurrentTraderTimeMSG);
		Sender.ClientMessage(CustomTraderTimeMSG);
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
			ServerMessage("-----|| " $PN$ " is %gmodifying %wthe Trader! ||-----");
		}
		else
		{
			ServerMessage("-----|| %rWarning %wto:" $PN$ "! You %rcannot %wmanipulate the trader! ||-----");
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
			ServerMessage("Trader Time Skipped by: " $PN);
		} else {
			Sender.ClientMessage(PN$ ", " $SkipTraderCmd$ " is only functional during trader time.");
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
			ServerMessage(PN$ " changed the current trader time to " $string(num)$ " seconds.");
		} else {
     		Sender.ClientMessage(PN$ ", " $CurrentTraderTimeCmd$ " is only functional during trader time.");
		}
	}

	// Change the default time of the trader
	// Limited between 6 and 255
	if (Left(command, Len(CustomTraderTimeCmd)) ~= CustomTraderTimeCmd) {
		if(int(SplitCMD[1]) <= 6 || int(SplitCMD[1]) > 255) {
			Sender.ClientMessage(PN$ ", time between waves has to be between 6 and 255");
			return;
		}
		KFGameType(Level.Game).TimeBetweenWaves = int(SplitCMD[1]);
		ServerMessage(PN$ " changed the trader time between waves to " $string(int(SplitCMD[1]))$ " seconds.");

	}
	if (NextMutator != None )
		NextMutator.Mutate(command, Sender);
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
	GroupName = "KF-SkipTrader"
    FriendlyName = "Skip Trader - v1.0"
    Description = "Enhanced version of Trader Mutator, with better features; Modified by Vel-San;"

	// Mut Vars
	bDebug = False
	bAdminAndSelectPlayers = True
    sSkipTraderCmd = "skip"
    sCurrentTraderTimeCmd = "tt"
    sCustomTraderTimeCmd = "st"
	iDefaultTraderTime = 60

	// SpecialPlayers Array Example
	// Only SteamID is important, PName is just to easily read & track the IDs
	// aSpecialPlayers=(PName="Vel-San",steamID="76561198122568951")
}
