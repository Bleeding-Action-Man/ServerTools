// Thanks to ScaryGhost for his Interaction Class

class STInteraction extends Interaction;

var GUI.GUITabItem ServerToolsPanel;
var string ServerToolsPanelClass_SP;

event NotifyLevelChange() {
  Master.RemoveInteraction(self);
}

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta ) {
  local string alias;
  local MidGamePanel panel;
  local UT2K4PlayerLoginMenu escMenu;

  alias= ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key));
  if (Action == IST_Press && alias ~= "showmenu") {
  if (KFGUIController(ViewportOwner.GUIController).ActivePage == None) {
    ViewportOwner.Actor.ShowMenu();
  }
  escMenu= UT2K4PlayerLoginMenu(KFGUIController(ViewportOwner.GUIController).ActivePage);
  if (escMenu != none && escMenu.c_Main.TabIndex(ServerToolsPanel.caption) == -1) {
    if (escMenu.IsA('SRInvasionLoginMenu')) {
    ServerToolsPanel.ClassName = ServerToolsPanelClass_SP;
    }
    panel= MidGamePanel(escMenu.c_Main.AddTabItem(ServerToolsPanel));
    if (panel != none) {
    panel.ModifiedChatRestriction= escMenu.UpdateChatRestriction;
    }
  }
  }
  return false;
}

defaultproperties {
  ServerToolsPanelClass_SP="ServerTools.ST_Tab_SP"
  ServerToolsPanel=(ClassName="ServerTools.ST_Tab",Caption="Server Tools",Hint="Essential Trader Manipulation & Revival Options")
}