Class BoostMe extends Info Config(ServerTools_Config);

var() config int iSpeedBoost, iAfterWaveStartBoost, iMatchStartBoost;
var() config string sMatchStartBoostMessage, sTraderBoostMessage, sBoostEndMessage;
var() config bool bGlobalMSG;

var bool bIsBoostActive;
var KFGameType KFGT;
var GameReplicationInfo GRI;

function PostBeginPlay()
{
  KFGT = KFGameType(Level.Game);
  GRI = Level.Game.GameReplicationInfo;

  Instigator.Health = iSpeedBoost; // Value affects groundspeed
  bIsBoostActive = True; // Marker for boost is active

  // Start Speed Boost Timer
  if ( GRI != none)
  {
    if (GRI.ElapsedTime < 10)
    {
      // Match Start Boost
      if (bGlobalMSG) class'ServerTools'.default.Mut.TraderBoostCriticalServerMessage(sMatchStartBoostMessage, Instigator);
      else class'ServerTools'.default.Mut.TraderBoostServerMessage(sMatchStartBoostMessage, Instigator);
      SetTimer(iMatchStartBoost, false); // Recommended 10 seconds is for wave start countdown
    }
    else
    {
      // Trader Time Boost
      if (bGlobalMSG) class'ServerTools'.default.Mut.TraderBoostCriticalServerMessage(sTraderBoostMessage, Instigator);
      else class'ServerTools'.default.Mut.TraderBoostServerMessage(sTraderBoostMessage, Instigator);
      SetTimer(KFGT.TimeBetweenWaves + iAfterWaveStartBoost, false);
    }
  }
}

function Timer()
{
  if (bGlobalMSG) class'ServerTools'.default.Mut.TraderBoostCriticalServerMessage(sBoostEndMessage, Instigator);
  else class'ServerTools'.default.Mut.TraderBoostServerMessage(sBoostEndMessage, Instigator);
  Destroyed();
}

function Tick( float Delta )
{
  if ((KFGT.bWaveInProgress && bIsBoostActive) || KFGT.IsInState('PendingMatch') || KFGT.IsInState('GameEnded'))
  {
    if (bGlobalMSG) class'ServerTools'.default.Mut.TraderBoostCriticalServerMessage(sBoostEndMessage, Instigator);
    else class'ServerTools'.default.Mut.TraderBoostServerMessage(sBoostEndMessage, Instigator);
    Destroyed();
  }
  if (Instigator==None || Instigator.Health <= 0)
    {
      Destroyed();
    }
}

function Destroyed()
{
  if (Instigator != None) Instigator.Health = Min(Instigator.Health, 100);
  bIsBoostActive = False;
  Disable('Timer');
  Disable('Tick');
}

