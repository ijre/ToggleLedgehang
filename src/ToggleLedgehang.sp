#include <sourcemod>
#include <sdktools>

static bool HasDisabledHang[18];

public Plugin myinfo =
{
  name   = "Toggle Ledgehanging",
  author = "ijre"
}

public void OnPluginStart()
{
  AddCommandListener(OnToggled, "ledgehang");
  AddCommandListener(OnToggled, "sm_ledgehang");
}

Action OnToggled(int client, const char[] cmd, int args)
{
  HasDisabledHang[client] = !HasDisabledHang[client];
  char reply[128 * 2];

  if (HasDisabledHang[client])
  {
    AcceptEntityInput(client, "DisableLedgeHang");
    reply = "Ledgehanging has now been disabled for you. Don't let those bananas get you when you least expect it (like a diaper).";
  }
  else
  {
    AcceptEntityInput(client, "EnableLedgeHang");
    reply = "Ledgehanging has now been re-enabled for you. What're those shoes that soccer players wear again? You have those on, whatever they're called.";
  }

  PrintToChat(client, reply);

  return Plugin_Handled;
}