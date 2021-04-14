class ST_Tab extends STBlankPanel DependsOn(KFServerTools);

// Left Box
var automated GUISectionBackground Left_Back_Ground;
var automated moEditBox ed_DefaultTrader;
var automated moEditBox ed_CurrentTrader;
var automated GUIButton b_ApplyButton;
var automated GUIButton b_ApplyButton2;
var automated moEditBox ed_RevPlayer;
var automated GUIButton b_ShowDeadPlayers;
var automated GUIButton b_Revive;

// Right Box
var automated GUISectionBackground Right_Back_Ground;
var automated GUIButton b_SkipTrader;
var automated GUIButton b_VoteSkipTrader;
var automated GUIButton b_RevSelf;
var automated GUIButton b_RevAllPlayers;
var automated GUIButton b_AllCommands;

var string AdminsOnlyApplyText, AdminsOnlySkipTraderText;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
  Super.Initcomponent(MyController, MyOwner);

  // Left Box
  Left_Back_Ground.ManageComponent(ed_DefaultTrader);
  Left_Back_Ground.ManageComponent(b_ApplyButton);
  Left_Back_Ground.ManageComponent(ed_CurrentTrader);
  Left_Back_Ground.ManageComponent(b_ApplyButton2);
  Left_Back_Ground.ManageComponent(ed_RevPlayer);
  Left_Back_Ground.ManageComponent(b_ShowDeadPlayers);
  Left_Back_Ground.ManageComponent(b_Revive);

  // Right Box
  Right_Back_Ground.ManageComponent(b_SkipTrader);
  Right_Back_Ground.ManageComponent(b_VoteSkipTrader);
  Right_Back_Ground.ManageComponent(b_RevSelf);
  Right_Back_Ground.ManageComponent(b_RevAllPlayers);
  Right_Back_Ground.ManageComponent(b_AllCommands);
}

function ShowPanel(bool bShow)
{
  Super.ShowPanel(bShow);

  MutRef = class'KFServerTools'.default.Mut;
  if (bShow)
  {
    // Default Trader EditBox
    ed_DefaultTrader.SetComponentValue(MutRef.DefaultTraderTime, true);
    if (MutRef.AdminAndSelectPlayers) b_ApplyButton.Caption = AdminsOnlyApplyText;

    // Current Trader EditBox
    ed_CurrentTrader.SetComponentValue(120, true);
    if (MutRef.AdminAndSelectPlayers) b_ApplyButton2.Caption = AdminsOnlyApplyText;

    // SkipTrader
    if (MutRef.AdminAndSelectPlayers) b_SkipTrader.Caption = AdminsOnlySkipTraderText;

    // Revive related Info
    // Player Code EditBox
    ed_RevPlayer.SetComponentValue("", true);

    // Disable Components if bOnlyVoteTraderGUI=True;
    if (MutRef.OnlyVoteTraderGUI)
    {
      if(!MutRef.AdminAndSelectPlayers) DisableComponent(b_SkipTrader);
      DisableComponent(b_RevSelf);
      DisableComponent(b_RevAllPlayers);
      DisableComponent(b_AllCommands);
      DisableComponent(ed_RevPlayer);
      DisableComponent(b_ShowDeadPlayers);
      DisableComponent(b_Revive);
    }
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

function SkipTraderMutate(PlayerController TmpPC)
{
  local string Cmd;

  cmd = class'KFServerTools'.default.Mut.SkipTraderCmd;
  TmpPC.ServerMutate(cmd);
}

function VoteSkipTraderMutate(PlayerController TmpPC)
{
  local string Cmd;

  cmd = class'KFServerTools'.default.Mut.VoteSkipTraderCmd;
  TmpPC.ServerMutate(cmd);
}

function RevSelfMutate(PlayerController TmpPC)
{
  local string Cmd;

  cmd = class'KFServerTools'.default.Mut.ReviveMeCmd;
  TmpPC.ServerMutate(cmd);
}

function RevAllMutate(PlayerController TmpPC)
{
  local string Cmd;

  cmd = class'KFServerTools'.default.Mut.ReviveThemCmd$ " all";
  TmpPC.ServerMutate(cmd);
}

function HelpMutate(PlayerController TmpPC)
{
  local string Cmd;

  cmd = "st help";
  TmpPC.ServerMutate(cmd);
}

function bool InternalOnPreDraw(Canvas C)
{
  local float w, h, x, y;
  local float w_rightBG, h_rightBG, x_rightBG, y_rightBG;

  w = ActualWidth() / 2; // Increase Division to Decrease Width
  h = ActualHeight() / 1.6; // Increase division to decrease height
  y = ActualTop() + ActualHeight() * 0.02; // Increase Multiplication to move higher
  x = ActualLeft() + ActualWidth() / 0.25; // Increase Division to move more to the left
  Left_Back_Ground.SetPosition(x, y, w, h, true);

  w_rightBG = ActualWidth() / 2.5; // Increase Division to Decrease Width
  h_rightBG = ActualHeight() / 2.2; // Increase division to decrease height
  y_rightBG = ActualTop() + ActualHeight() * 0.02; // Increase Multiplication to move higher
  x_rightBG = ActualWidth() / 1.4; // Increase Division to move more to the left
  Right_Back_Ground.SetPosition(x_rightBG, y_rightBG, w_rightBG, h_rightBG, true);

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

  if (Sender == b_SkipTrader) SkipTraderMutate(PC);

  if (Sender == b_VoteSkipTrader) VoteSkipTraderMutate(PC);

  if (Sender == b_RevSelf) RevSelfMutate(PC);

  if (Sender == b_RevAllPlayers) RevAllMutate(PC);

  if (Sender == b_AllCommands) HelpMutate(PC);


  return true;
}

defaultproperties
{
  Begin Object Class=GUISectionBackground Name=Left_BG
    bFillClient=True
    Caption="Trader manipulation & revive"
    OnPreDraw=Left_BG.InternalPreDraw
  End Object
  Left_Back_Ground=GUISectionBackground'ST_Tab.Left_BG'

  Begin Object Class=GUISectionBackground Name=Right_BG
    bFillClient=True
    Caption="Voting, global revive & Help"
    OnPreDraw=Right_BG.InternalPreDraw
  End Object
  Right_Back_Ground=GUISectionBackground'ST_Tab.Right_BG'

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
    OnClick=ST_Tab.ClickOfAButton
    OnKeyEvent=Apply.InternalOnKeyEvent
  End Object
  b_ApplyButton=GUIButton'ST_Tab.Apply'

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
    OnClick=ST_Tab.ClickOfAButton
    OnKeyEvent=Apply2.InternalOnKeyEvent
  End Object
  b_ApplyButton2=GUIButton'ST_Tab.Apply2'

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
    TabOrder=5
    bBoundToParent=True
    bScaleToParent=True
    OnClick=ST_Tab.ClickOfAButton
    OnKeyEvent=PrintRevList.InternalOnKeyEvent
  End Object
  b_ShowDeadPlayers=GUIButton'ST_Tab.PrintRevList'

  Begin Object Class=GUIButton Name=ReviveDeadPlayer
    Caption="Revive"
    Hint="If you have dosh, the player with the respective code will be revived"
    TabOrder=6
    bBoundToParent=True
    bScaleToParent=True
    OnClick=ST_Tab.ClickOfAButton
    OnKeyEvent=ReviveDeadPlayer.InternalOnKeyEvent
  End Object
  b_Revive=GUIButton'ST_Tab.ReviveDeadPlayer'

  Begin Object Class=GUIButton Name=SkipTrader
    Caption="Skip Trader"
    Hint="Instantly skip trader; You might not have permission to use this !"
    TabOrder=7
    bBoundToParent=True
    bScaleToParent=True
    OnClick=ST_Tab.ClickOfAButton
    OnKeyEvent=SkipTrader.InternalOnKeyEvent
  End Object
  b_SkipTrader=GUIButton'ST_Tab.SkipTrader'

  Begin Object Class=GUIButton Name=VoteSkipTrader
    Caption="Start Vote to Skip Trader"
    Hint="Start a vote when you're ready to skip trader, everyone has access to this. Once clicked, a vote message will show for all players."
    TabOrder=8
    bBoundToParent=True
    bScaleToParent=True
    OnClick=ST_Tab.ClickOfAButton
    OnKeyEvent=VoteSkipTrader.InternalOnKeyEvent
  End Object
  b_VoteSkipTrader=GUIButton'ST_Tab.VoteSkipTrader'

  Begin Object Class=GUIButton Name=RevSelf
    Caption="Revive Yourself"
    Hint="Once clicked, you will revive for the cost of Dosh; dosh will be taken from you."
    TabOrder=9
    bBoundToParent=True
    bScaleToParent=True
    OnClick=ST_Tab.ClickOfAButton
    OnKeyEvent=RevSelf.InternalOnKeyEvent
  End Object
  b_RevSelf=GUIButton'ST_Tab.RevSelf'

  Begin Object Class=GUIButton Name=RevAllPlayers
    Caption="Revive All Dead Players"
    Hint="Once clicked, you will revive all dead players for the cost of Dosh; dosh will be taken from you."
    TabOrder=10
    bBoundToParent=True
    bScaleToParent=True
    OnClick=ST_Tab.ClickOfAButton
    OnKeyEvent=RevAllPlayers.InternalOnKeyEvent
  End Object
  b_RevAllPlayers=GUIButton'ST_Tab.RevAllPlayers'

  Begin Object Class=GUIButton Name=AllCommands
    Caption="Help"
    Hint="Print a list of all mutate commands | Commands are used in console, not in chat!"
    TabOrder=11
    bBoundToParent=True
    bScaleToParent=True
    OnClick=ST_Tab.ClickOfAButton
    OnKeyEvent=AllCommands.InternalOnKeyEvent
  End Object
  b_AllCommands=GUIButton'ST_Tab.AllCommands'

  AdminsOnlyApplyText = "Apply | Admins Only"
  AdminsOnlySkipTraderText = "Skip Trader | Admin Only"
}