//=============================================================================
// Enhanced version of TraderTime;
// Modified by Vel-San
// for more information, feedback, questions or requests please contact
// https://steamcommunity.com/id/Vel-San/
//=============================================================================

class KFSkipTrader extends Mutator Config(KFSkipTrader);

// Config Vars
var() config int iTraderTime;
var() config bool bDebug;
var() config string sSkipCmd, sCurrentCmd, sWaveCmd;

// Tmp Vars
var bool Debug;

// Players to be marked as either VIP or Donator
struct SP
{
  var config string PName; // PlayerName, won't be checked
  var config string SteamID; // Steam ID, will always be checked
};
var() config array<SP> aSpecialPlayers; // PlayersList to be declared in the Config
var array<SP> SpecialPlayers; // PlayersList to be declared in the Config

// Colors from Config
struct ColorRecord
{
  var config string ColorName; // Color name, for comfort
  var config string ColorTag; // Color tag
  var config Color Color; // RGBA values
};
var() config array<ColorRecord> ColorList; // Color list

function PostBeginPlay()
{
  	Super.PreBeginPlay();
	SetTimer(5,false);
}

function Timer()
{
	if (iTraderTime > 0)
		KFGameType(Level.Game).TimeBetweenWaves=iTraderTime;
	SetTimer(0,false);
}

final function SplitStringToArray(out array<string> Parts, string Source, string Delim) {
    Split(Source, Delim, Parts);
}

function ServerMessage(string Msg) {
	local Controller p;
	local PlayerController player;
	for (p = Level.ControllerList; p != none; p = p.nextController) {
		player = PlayerController(p);
		if (player != none) {
			player.ClientMessage(Msg);
		}
	}
}

function Mutate(string command, PlayerController user) {
	local array<string> split;
	local int num;
	SplitStringToArray(split, command, " ");
	if (command == iSkipCmd) {
		if(KFGameType(Level.Game).bTradingDoorsOpen) {
			KFGameType(Level.Game).WaveCountDown = 6;
			ServerMessage("Trader Time Skipped.");
		} else {
			user.ClientMessage("Only functional during trader time.");
		}
	}
	if (Left(command, Len(iCurrentCmd)) == iCurrentCmd) {
		num = int(split[1]);
		if(KFGameType(Level.Game).bTradingDoorsOpen) {
			if(num <= 6)
				num = 6;
			KFGameType(Level.Game).WaveCountDown = num;
			ServerMessage("Current trader time set to " $ string(num));
		} else {
     		user.ClientMessage("Only functional in trader time.");
		}
	}
	if (Left(command, Len(iWaveCmd)) == iWaveCmd) {
		if(int(split[1]) <= 6) {
			user.ClientMessage("Has to be 6 seconds or more.");
			return;
		}
		KFGameType(Level.Game).TimeBetweenWaves = int(split[1]);
		ServerMessage("Trader time between waves set to " $ string(int(split[1])));

	}
	if (NextMutator != None )
		NextMutator.Mutate(command, user);
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
    iTraderTime=60
    iSkipCmd="skip"
    iCurrentCmd="settrade"
    iWaveCmd="settime"
    GroupName="KF-SkipTrader"
    FriendlyName="Skip Trader - v1.0"
    Description="Enhanced version of Trader Mutator, with better features; Modified by Vel-San;"
}
