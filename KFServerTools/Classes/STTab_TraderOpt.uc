class STTab_TraderOpt extends STBlankPanel;

var automated GUISectionBackground i_BGCenter;
var automated moCheckbox ch_AllowInterrupt;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
	Super.Initcomponent(MyController, MyOwner);

	i_BGCenter.ManageComponent(ch_AllowInterrupt);

}

function ShowPanel(bool bShow) {
	Super.ShowPanel(bShow);

	if (bShow) {
		ch_AllowInterrupt.SetComponentValue(True, true);
	}
}

function UpdateCheckboxVisibility() {
	if (ch_AllowInterrupt.IsChecked())
		Log("CheckBox Updated!");
}

function bool InternalOnPreDraw(Canvas C) {
	local float w, h, x, y;

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
		case ch_AllowInterrupt:
			Log("Checkbox Checked!");
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
	i_BGCenter=GUISectionBackground'STTab_TraderOpt.BGCenter'

	Begin Object Class=moCheckBox Name=AllowInterrupt
		Caption="Start Trader Skip Vote"
		Hint="Send a message to all players that you are ready to skip trader, and tells them to skip whenever they are ready"
		OnCreateComponent=AllowInterrupt.InternalOnCreateComponent
		TabOrder=0
		OnChange=STTab_TraderOpt.InternalOnChange
	End Object
	ch_AllowInterrupt=moCheckBox'STTab_TraderOpt.AllowInterrupt'
}