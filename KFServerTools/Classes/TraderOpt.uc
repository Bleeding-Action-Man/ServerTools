class TraderOpt extends STBlankPanel;

// TODO: All chechkboxes and settings in this section should be visible only to the admins
// to do this, I need to create a new aAdmins array in the base class that holds admins only

var automated GUISectionBackground i_BGCenter;
var automated moCheckbox ch_AdminsOnly;
var automated moEditBox ed_DefaultTrader;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
	Super.Initcomponent(MyController, MyOwner);

	i_BGCenter.ManageComponent(ch_AdminsOnly);
	i_BGCenter.ManageComponent(ed_DefaultTrader);
}

function ShowPanel(bool bShow) {
	Super.ShowPanel(bShow);

	if (bShow) {
			ch_AdminsOnly.SetComponentValue(class'KFServerTools'.default.bAdminAndSelectPlayers, true);
			ed_DefaultTrader.SetComponentValue(class'KFServerTools'.default.iDefaultTraderTime, true);
		}
}

function UpdateCheckboxVisibility() {
	// if (ch_AdminsOnly.IsChecked())

	if(class'KFServerTools'.default.bAdminAndSelectPlayers)
		{
			ch_AdminsOnly.DisableMe();
			ed_DefaultTrader.DisableMe();
		}
}

function bool InternalOnPreDraw(Canvas C) {
	local float w, h, x, y;

	// TODO: Change width and height
	w = ActualWidth() / 2;
	h = ActualHeight() / 2;
	y = ActualTop() + ActualHeight() * 0.15;
	x = ActualLeft() + (ActualWidth() - w) / 2;
	i_BGCenter.SetPosition(x, y, w, h, true);

	UpdateCheckboxVisibility();

	return Super.InternalOnPreDraw(C);
}

function InternalOnChange(GUIComponent Sender) {
	switch (Sender) {
		case ch_AdminsOnly:
			UpdateCheckboxVisibility();
			break;
	}
}

defaultproperties {
	Begin Object Class=GUISectionBackground Name=BGCenter
		bFillClient=True
		Caption="Server Tools"
		OnPreDraw=BGCenter.InternalPreDraw
	End Object
	i_BGCenter=GUISectionBackground'TraderOpt.BGCenter'

	Begin Object Class=moCheckBox Name=AdminsOnly
		Caption="Admins & Special Players Only"
		Hint="If enabled, only admins & special players can manipulate trader !"
		OnCreateComponent=AdminsOnly.InternalOnCreateComponent
		TabOrder=0
		OnChange=TraderOpt.InternalOnChange
	End Object
	ch_AdminsOnly=moCheckBox'TraderOpt.AdminsOnly'

	Begin Object Class=moEditBox Name=DefaultTraderTime
		Caption="Default Trader Time: "
		Hint="Enter new value for trader time. Must be between <6-255>"
	End Object
	ed_DefaultTrader=DefaultTraderTime
}