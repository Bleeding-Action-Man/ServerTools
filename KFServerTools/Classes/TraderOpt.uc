class TraderOpt extends STBlankPanel DependsOn(KFServerTools);

var automated GUISectionBackground i_BGCenter;
var automated moEditBox ed_DefaultTrader;
var automated moEditBox ed_CurrentTrader;
var automated GUIButton b_ApplyButton;
var automated GUIButton b_ApplyButton2;
var automated moEditBox ed_RevPlayer;
var automated GUIButton b_ShowDeadPlayers;
var automated GUIButton b_Revive;
var string AdminsOnlyText;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
  Super.Initcomponent(MyController, MyOwner);

  i_BGCenter.ManageComponent(ed_DefaultTrader);
  i_BGCenter.ManageComponent(b_ApplyButton);
  i_BGCenter.ManageComponent(ed_CurrentTrader);
  i_BGCenter.ManageComponent(b_ApplyButton2);
  i_BGCenter.ManageComponent(ed_RevPlayer);
  i_BGCenter.ManageComponent(b_ShowDeadPlayers);
  i_BGCenter.ManageComponent(b_Revive);
}

function ShowPanel(bool bShow)
{
  Super.ShowPanel(bShow);

  MutRef = class'KFServerTools'.default.Mut;
  if (bShow)
  {
    // Default Trader EditBox
    ed_DefaultTrader.SetComponentValue(MutRef.DefaultTraderTime, true);
    if (MutRef.AdminAndSelectPlayers) b_ApplyButton.Caption = AdminsOnlyText;

    // Current Trader EditBox
    ed_CurrentTrader.SetComponentValue(120, true);
    if (MutRef.AdminAndSelectPlayers) b_ApplyButton2.Caption = AdminsOnlyText;

    // Revive related Info
    // Player Code EditBox
    ed_RevPlayer.SetComponentValue("", true);
  }
}

function UpdateDefaultTraderTime(PlayerController TmpPC)
{
  local string Cmd;

  cmd = class'KFServerTools'.default.Mut.CustomTraderTimeCmd$ " " $ed_DefaultTrader.GetComponentValue();
  TmpPC.ServerMutate(cmd);
}

function UpdateCurrentTraderTime(PlayerController TmpPC)
{
  local string Cmd;

  cmd = class'KFServerTools'.default.Mut.CurrentTraderTimeCmd$ " " $ed_CurrentTrader.GetComponentValue();
  TmpPC.ServerMutate(cmd);
}

function PrintDeadPlayers(PlayerController TmpPC)
{
  local string Cmd;

  cmd = class'KFServerTools'.default.Mut.ReviveListCmd;
  TmpPC.ServerMutate(cmd);
}

function RevivePlayerByCode(PlayerController TmpPC)
{
  local string Cmd;

  cmd = class'KFServerTools'.default.Mut.ReviveThemCmd$ " " $ed_RevPlayer.GetComponentValue();
  TmpPC.ServerMutate(cmd);
}

function bool InternalOnPreDraw(Canvas C)
{
  local float w, h, x, y;

  w = ActualWidth() / 1.5;
  h = ActualHeight() / 1.5;
  y = ActualTop() + ActualHeight() * 0.15;
  x = ActualLeft() + (ActualWidth() - w) / 2;
  i_BGCenter.SetPosition(x, y, w, h, true);

  return Super.InternalOnPreDraw(C);
}

function InternalOnChange(GUIComponent Sender)
{

}

function bool ClickOfAButton(GUIComponent Sender)
{
  local PlayerController PC;

  PC = PlayerOwner();
  if (Sender == b_ApplyButton) UpdateDefaultTraderTime(PC);

  if (Sender == b_ApplyButton2) UpdateCurrentTraderTime(PC);

  if (Sender == b_ShowDeadPlayers) PrintDeadPlayers(PC);

  if (Sender == b_Revive) RevivePlayerByCode(PC);

  return true;
}

defaultproperties
{
  Begin Object Class=GUISectionBackground Name=BGCenter
    bFillClient=True
    Caption="Server Tools"
    OnPreDraw=BGCenter.InternalPreDraw
  End Object
  i_BGCenter=GUISectionBackground'TraderOpt.BGCenter'

  Begin Object Class=moEditBox Name=DefaultTraderTime
    Caption="Default Trader Time: "
    Hint="Changes the default time for trader for the whole match; Must be between <6-255>"
    bBoundToParent=True
    bScaleToParent=True
    TabOrder=0
  End Object
  ed_DefaultTrader=DefaultTraderTime

  Begin Object Class=GUIButton Name=Apply
    Caption="Apply"
    Hint="Apply new default trader time; You might not have permission for this!"
    TabOrder=1
    bBoundToParent=True
    bScaleToParent=True
    OnClick=TraderOpt.ClickOfAButton
    OnKeyEvent=Apply.InternalOnKeyEvent
  End Object
  b_ApplyButton=GUIButton'TraderOpt.Apply'

  Begin Object Class=moEditBox Name=CurrentTraderTime
    Caption="Current Trader Time: "
    Hint="Changes the current time for trader; Must be between <6-255>"
    bBoundToParent=True
    bScaleToParent=True
    TabOrder=2
  End Object
  ed_CurrentTrader=CurrentTraderTime

  Begin Object Class=GUIButton Name=Apply2
    Caption="Apply"
    Hint="Instantly change current trader time; You might not have permission for this!"
    TabOrder=3
    bBoundToParent=True
    bScaleToParent=True
    OnClick=TraderOpt.ClickOfAButton
    OnKeyEvent=Apply2.InternalOnKeyEvent
  End Object
  b_ApplyButton2=GUIButton'TraderOpt.Apply2'

  Begin Object Class=moEditBox Name=RevivePlayer
    Caption="Revive player by code: "
    Hint="Enter a player code to revive them, if you have enough Do$h"
    bBoundToParent=True
    bScaleToParent=True
    TabOrder=4
  End Object
  ed_RevPlayer=RevivePlayer

  Begin Object Class=GUIButton Name=PrintRevList
    Caption="Show Player Codes"
    Hint="Prints all dead player codes to revive them"
    TabOrder=6
    bBoundToParent=True
    bScaleToParent=True
    OnClick=TraderOpt.ClickOfAButton
    OnKeyEvent=PrintRevList.InternalOnKeyEvent
  End Object
  b_ShowDeadPlayers=GUIButton'TraderOpt.PrintRevList'

  Begin Object Class=GUIButton Name=ReviveDeadPlayer
    Caption="Revive"
    Hint="If you have dosh, the player with the respective code will be revived"
    TabOrder=7
    bBoundToParent=True
    bScaleToParent=True
    OnClick=TraderOpt.ClickOfAButton
    OnKeyEvent=ReviveDeadPlayer.InternalOnKeyEvent
  End Object
  b_Revive=GUIButton'TraderOpt.ReviveDeadPlayer'

  AdminsOnlyText = "Apply | Admins Only"
}