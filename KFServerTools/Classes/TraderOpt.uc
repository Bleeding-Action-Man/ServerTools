class TraderOpt extends STBlankPanel;

// TODO: All chechkboxes and settings in this section should be visible only to the admins
// to do this, I need to create a new aAdmins array in the base class that holds admins only

var automated GUISectionBackground i_BGCenter;
var automated moEditBox ed_DefaultTrader;
var automated GUIButton b_ApplyButton;
var string AdminsOnlyText;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
	Super.Initcomponent(MyController, MyOwner);

	i_BGCenter.ManageComponent(ed_DefaultTrader);
	i_BGCenter.ManageComponent(b_ApplyButton);

}

function ShowPanel(bool bShow) {
	Super.ShowPanel(bShow);

	if (bShow) {
			ed_DefaultTrader.SetComponentValue(class'KFServerTools'.default.iDefaultTraderTime, true);
			if (class'KFServerTools'.default.bAdminAndSelectPlayers)
				b_ApplyButton.Caption = AdminsOnlyText;
		}
}

function UpdateTraderTime(PlayerController TmpPC) {

	local string Cmd;

	cmd = class'KFServerTools'.default.sCustomTraderTimeCmd$ " " $ed_DefaultTrader.GetComponentValue();
	TmpPC.ServerMutate(cmd);

}

function bool InternalOnPreDraw(Canvas C) {
	local float w, h, x, y;

	// TODO: Change width and height
	w = ActualWidth() / 2;
	h = ActualHeight() / 2;
	y = ActualTop() + ActualHeight() * 0.15;
	x = ActualLeft() + (ActualWidth() - w) / 2;
	i_BGCenter.SetPosition(x, y, w, h, true);

	return Super.InternalOnPreDraw(C);
}

function InternalOnChange(GUIComponent Sender) {

}

function bool ClickOfAButton(GUIComponent Sender) {
	local PlayerController PC;

	PC = PlayerOwner();
	if (Sender == b_ApplyButton){
		UpdateTraderTime(PC);
	}
	return true;
}

defaultproperties {
	Begin Object Class=GUISectionBackground Name=BGCenter
		bFillClient=True
		Caption="Server Tools"
		OnPreDraw=BGCenter.InternalPreDraw
	End Object
	i_BGCenter=GUISectionBackground'TraderOpt.BGCenter'

	Begin Object Class=moEditBox Name=DefaultTraderTime
		Caption="Default Trader Time: "
		Hint="Changes the default time for trader for the whole game; Must be between <6-255>"
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

	AdminsOnlyText = "Apply | Admins Only"
}