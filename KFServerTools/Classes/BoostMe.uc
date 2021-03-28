Class BoostMe extends Info Config(KFServerTools);

var() config int iSpeedBoost, iAfterWaveStartBoost, iMatchStartBoost;
var() config string sMatchStartBoostMessage, sTraderBoostMessage;
var() config bool bGlobalMSG;

function PostBeginPlay()
{
  local KFGameType KFGT;
  local GameReplicationInfo GRI;

  KFGT = KFGameType(Level.Game);
  GRI = Level.Game.GameReplicationInfo;

  Instigator.Health = iSpeedBoost; // Value affects groundspeed

  // Start Speed Boost Timer
  if ( GRI != none)
  {
    if (GRI.ElapsedTime < 10)
    {
      // Match Start Boost
      if (bGlobalMSG) class'KFServerTools'.default.Mut.CriticalServerMessage(sMatchStartBoostMessage);
      else class'KFServerTools'.default.Mut.ServerMessage(sMatchStartBoostMessage);
      SetTimer(iMatchStartBoost, false); // Recommended 10 seconds is for wave start countdown
    }
    else
    {
      // Trader Time Boost
      if (bGlobalMSG) class'KFServerTools'.default.Mut.CriticalServerMessage(sTraderBoostMessage);
      else class'KFServerTools'.default.Mut.ServerMessage(sTraderBoostMessage);
      SetTimer(KFGT.TimeBetweenWaves + iAfterWaveStartBoost + 10, false); // +10 is for wave start 10 seconds
    }
  }
}

function Timer()
{
  Destroy();
}

function Tick( float Delta )
{
  if (Instigator==None || Instigator.Health <= 0) Destroy();
}

function Destroyed()
{
  if (Instigator != None) Instigator.Health = Min(Instigator.Health, 100);
}

