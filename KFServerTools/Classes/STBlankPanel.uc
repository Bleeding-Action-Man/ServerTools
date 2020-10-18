class STBlankPanel extends MidGamePanel;

var automated array<GUIButton> b_KFButtons;

var noexport bool bNetGame;
var string SkipForAdminsOnly, PlayerStyleName;
var GUIStyles PlayerStyle;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
	local GUIButton B;
	local string S;
	local int i;
	local eFontScale FS;

	Super.InitComponent(MyController, MyOwner);

	S = GetSizingCaption();
	for (i = 0; i < Controls.length; i++) {
		B = GUIButton(Controls[i]);
		if (B != None) {
			B.bAutoSize = true;
			B.SizingCaption = S;
			B.AutoSizePadding.HorzPerc = 0.04;
			B.AutoSizePadding.VertPerc = 0.5;
		}
	}

	PlayerStyle = MyController.GetStyle(PlayerStyleName, FS);
}

function bool RemoveComponent(GUIComponent Comp, optional bool SkipRemap) {
	local int i;

	for (i = 0; i < b_KFButtons.length; i++)
		if (b_KFButtons[i] == Comp)
			b_KFButtons[i] = None;

	return Super.RemoveComponent(Comp, SkipRemap);
}

function ShowPanel(bool bShow) {
    Super.ShowPanel(bShow);

	if (bShow)
    {
		InitGRI();
    }
}

function string GetSizingCaption() {
	local int i;
	local string S;

	for (i = 0; i < Controls.length; i++)
		if (GUIButton(Controls[i]) != None)
			if (S == "" || Len(GUIButton(Controls[i]).Caption) > Len(S))
				S = GUIButton(Controls[i]).Caption;

	return S;
}

function GameReplicationInfo GetGRI() {
	return PlayerOwner().GameReplicationInfo;
}

function InitGRI() {
	local PlayerController PC;
	local GameReplicationInfo GRI;

	PC = PlayerOwner();
	GRI = GetGRI();
	if (PC == None || PC.PlayerReplicationInfo == None || GRI == None)
		return;

	bInit = False;
	bNetGame = PC.Level.NetMode != NM_StandAlone;
	if (class'KFServerTools'.default.bAdminAndSelectPlayers)
			b_KFButtons[0].Caption = SkipForAdminsOnly;
	SetupGroups();
}

function float ItemHeight(Canvas C) {
	local float xl, yl, h;
	local eFontScale f;

	f = FNS_Medium;
	PlayerStyle.TextSize(C, MSAT_Blurry, "Wqz, ", xl, h, f);
	if (C.ClipX > 640 && bNetGame)
		PlayerStyle.TextSize(C, MSAT_Blurry, "Wqz, ", xl, yl, FNS_Small);

	h += yl;
	h += h * 0.2;

	return h;
}

function SetupGroups() {
	local PlayerController PC;

	PC = PlayerOwner();

	RemapComponents();
}

function SetButtonPositions() {
	local int i, j, buttonsPerRow, buttonsLeftInRow, numButtons;
	local float w, h, center, x, y, yl, buttonSpacing;

	w = b_KFButtons[0].ActualWidth();
	h = b_KFButtons[0].ActualHeight();
	center = ActualLeft() + ActualWidth() / 2;

	buttonSpacing = w / 20;
	yl = h * 1.2;
	y = b_KFButtons[0].ActualTop();

	buttonsPerRow = ActualWidth() / (w + buttonSpacing);
	buttonsLeftInRow = buttonsPerRow;

	for (i = 0; i < b_KFButtons.length; i++)
		if (b_KFButtons[i] != None && b_KFButtons[i].bVisible)
			numButtons++;

	if (numButtons < buttonsPerRow)
		x = center - (((w * float(numButtons)) + (buttonSpacing * float(numButtons - 1))) / 2);
	else if (buttonsPerRow > 1)
		x = center - (((w * float(buttonsPerRow)) + (buttonSpacing * float(buttonsPerRow - 1))) / 2);
	else
		x = center - w / 2;

	for (i = 0; i < b_KFButtons.length; i++) {
		if (b_KFButtons[i] == None || !b_KFButtons[i].bVisible)
			continue;

		b_KFButtons[i].SetPosition(x, y, w, h, true);

		if (--buttonsLeftInRow > 0)
			x += w + buttonSpacing;
		else {
			y += yl;

			for (j = i + 1; j < b_KFButtons.length && buttonsLeftInRow < buttonsPerRow; j++)
				if (b_KFButtons[i] != None && b_KFButtons[i].bVisible)
					buttonsLeftInRow++;

			if (buttonsLeftInRow > 1)
				x = center - (((w * float(buttonsLeftInRow)) + (buttonSpacing * float(buttonsLeftInRow - 1))) / 2);
			else
				x = center - w / 2;
		}
	}
}

function bool ButtonClicked(GUIComponent Sender) {
	local PlayerController PC;
	local string Cmd;

	PC = PlayerOwner();
	if (PC == None)
        return false;


	if (Sender == b_KFButtons[0])
    {
        PC.ServerMutate(class'KFServerTools'.default.sSkipTraderCmd);
    }

    if (Sender == b_KFButtons[1])
    {
        PC.ServerMutate(class'KFServerTools'.default.sVoteSkipTraderCmd);
    }

	if (Sender == b_KFButtons[2])
    {
		cmd = class'KFServerTools'.default.sReviveThemCmd$ " all";
        PC.ServerMutate(cmd);
    }

	if (Sender == b_KFButtons[3])
    {
		cmd = "st help";
        PC.ServerMutate(cmd);
    }

	return true;
}

function bool InternalOnPreDraw(Canvas C) {
	local GameReplicationInfo GRI;

	GRI = GetGRI();
	if (GRI != None) {
		if (bInit)
			InitGRI();

		SetButtonPositions();
	}

	return false;
}

defaultproperties
{

    Begin Object Class=GUIButton Name=SkipTrader
		Caption="Skip Trader"
		Hint="Instantly skip trader; You might not have permission to use this !"
		WinTop=0.878657
		WinLeft=0.194420
		WinWidth=0.8
		WinHeight=0.048769
		TabOrder=20
		bBoundToParent=True
		bScaleToParent=True
		OnClick=STBlankPanel.ButtonClicked
		OnKeyEvent=SkipTrader.InternalOnKeyEvent
	End Object
	b_KFButtons(0)=GUIButton'STBlankPanel.SkipTrader'

	Begin Object Class=GUIButton Name=VoteSkipTrader
		Caption="Start Vote to Skip Trader"
		Hint="Start a vote when you're ready to skip trader, everyone has access to this. Once clicked, a vote message will show for all players."
		TabOrder=21
		bBoundToParent=True
		bScaleToParent=True
		OnClick=STBlankPanel.ButtonClicked
		OnKeyEvent=VoteSkipTrader.InternalOnKeyEvent
	End Object
	b_KFButtons(1)=GUIButton'STBlankPanel.VoteSkipTrader'

	Begin Object Class=GUIButton Name=RevAllPlayers
		Caption="Revive All Dead Players"
		Hint="Once clicked, you will revive all dead players for the cost of Dosh; dosh will be taken from you."
		TabOrder=22
		bBoundToParent=True
		bScaleToParent=True
		OnClick=STBlankPanel.ButtonClicked
		OnKeyEvent=RevAllPlayers.InternalOnKeyEvent
	End Object
	b_KFButtons(2)=GUIButton'STBlankPanel.RevAllPlayers'

	Begin Object Class=GUIButton Name=AllCommands
		Caption="Help"
		Hint="Print a list of all mutate commands | Commands are used in console, not in chat!"
		TabOrder=23
		bBoundToParent=True
		bScaleToParent=True
		OnClick=STBlankPanel.ButtonClicked
		OnKeyEvent=AllCommands.InternalOnKeyEvent
	End Object
	b_KFButtons(3)=GUIButton'STBlankPanel.AllCommands'

	PlayerStyleName="TextLabel"
	SkipForAdminsOnly="Skip Trader | Admins Only"
	PropagateVisibility=False
	WinTop=0.125000
	WinLeft=0.250000
	WinWidth=0.500000
	WinHeight=0.750000

	OnPreDraw=STBlankPanel.InternalOnPreDraw
}