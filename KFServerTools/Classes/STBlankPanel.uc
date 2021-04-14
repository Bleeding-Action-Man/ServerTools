class STBlankPanel extends MidGamePanel DependsOn(ServerTools);

var noexport bool bNetGame;
var string PlayerStyleName;
var GUIStyles PlayerStyle;

var ServerTools MutRef;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
  local GUIButton B;
  local string S;
  local int i;
  local eFontScale FS;

  Super.InitComponent(MyController, MyOwner);

  S = GetSizingCaption();
  for (i = 0; i < Controls.length; i++)
  {
    B = GUIButton(Controls[i]);
    if (B != None)
    {
      B.bAutoSize = true;
      B.SizingCaption = S;
      B.AutoSizePadding.HorzPerc = 0.04;
      B.AutoSizePadding.VertPerc = 0.5;
    }
  }

  PlayerStyle = MyController.GetStyle(PlayerStyleName, FS);
}

function ShowPanel(bool bShow)
{
  Super.ShowPanel(bShow);

  if (bShow)
  {
    InitGRI();
  }
}

function string GetSizingCaption()
{
  local int i;
  local string S;

  for (i = 0; i < Controls.length; i++)
    if (GUIButton(Controls[i]) != None)
      if (S == "" || Len(GUIButton(Controls[i]).Caption) > Len(S))
        S = GUIButton(Controls[i]).Caption;

  return S;
}

function GameReplicationInfo GetGRI()
{
  return PlayerOwner().GameReplicationInfo;
}

function InitGRI()
{
  local PlayerController PC;
  local GameReplicationInfo GRI;

  PC = PlayerOwner();
  GRI = GetGRI();
  if (PC == None || PC.PlayerReplicationInfo == None || GRI == None) return;

  bInit = False;
  bNetGame = PC.Level.NetMode != NM_StandAlone;
  SetupGroups();
}

function float ItemHeight(Canvas C)
{
  local float xl, yl, h;
  local eFontScale f;

  f = FNS_Medium;
  PlayerStyle.TextSize(C, MSAT_Blurry, "Wqz, ", xl, h, f);
  if (C.ClipX > 640 && bNetGame) PlayerStyle.TextSize(C, MSAT_Blurry, "Wqz, ", xl, yl, FNS_Small);

  h += yl;
  h += h * 0.2;

  return h;
}

function SetupGroups()
{
  local PlayerController PC;

  PC = PlayerOwner();

  RemapComponents();
}

function bool InternalOnPreDraw(Canvas C)
{
  local GameReplicationInfo GRI;

  GRI = GetGRI();
  if (GRI != None)
  {
    if (bInit) InitGRI();
  }

  return false;
}

defaultproperties
{
  PlayerStyleName="TextLabel"
  PropagateVisibility=False
  WinTop=0.125000
  WinLeft=0.250000
  WinWidth=0.500000
  WinHeight=0.750000

  OnPreDraw=STBlankPanel.InternalOnPreDraw
}