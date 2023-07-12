#include <sourcemod>
#include <left4dhooks>
// #include "../# shared notes tf2-l4d2/PrintToChatAllLog.sp"

#define TRUE_MAXPLAYERS MAXPLAYERS + 1

static bool AllowingLedgehang[TRUE_MAXPLAYERS] = { true, ... };
static ConVar LevelTransferStorage;

public Plugin myinfo =
{
  name   = "Toggle Ledgehanging",
  author = "ijre",
  version = "1.0.0.0"
}

public void OnPluginStart()
{
  LevelTransferStorage = CreateConVar("sm_ledgehang_storage", "", "Storage for use between level loads. Not to be edited manually.", FCVAR_DONTRECORD);

  RegConsoleCmd("sm_ledgehang", OnToggled, "Toggle on/off ledgehang-ability for yourself.");

  HookEvent("player_transitioned", OnTransition);
}

public Action L4D_OnLedgeGrabbed(int client)
{
  return AllowingLedgehang[client] ? Plugin_Continue : Plugin_Handled;
}

Action OnTransition(Event event, const char[] name, bool dontBroadcast)
{
  int client = GetClientOfUserId(event.GetInt("userid"));

  if (IsFakeClient(client))
  {
    return Plugin_Continue;
  }

  char CVarStorage[1000];
  LevelTransferStorage.GetString(CVarStorage, sizeof(CVarStorage));

  char steamid[30];
  Format(steamid, sizeof(steamid), " %d ", GetSteamAccountID(client));

  if (StrContains(CVarStorage, steamid) != -1)
  {
    AllowingLedgehang[client] = false;
  }

  return Plugin_Continue;
}

Action OnToggled(int client, int args)
{
  UpdateStorage(client);
  char reply[128];

  if (!AllowingLedgehang[client])
  {
    reply = "Ledgehanging has now been disabled for you, keep your eyes peeled for those 90° descents.";
  }
  else
  {
    reply = "Ledgehanging has now been re-enabled for you, this mf %N got cleats on.";
  }

  PrintToChat(client, reply, client);

  return Plugin_Handled;
}

void UpdateStorage(int client)
{
  bool wasDisallowed = AllowingLedgehang[client] == false;

  char CVarStorage[1000];
  LevelTransferStorage.GetString(CVarStorage, sizeof(CVarStorage));

  char steamid[30];
  Format(steamid, sizeof(steamid), " %d ", GetSteamAccountID(client));

  AllowingLedgehang[client] = !AllowingLedgehang[client];
  if (wasDisallowed)
  {
    if (ReplaceString(CVarStorage, sizeof(CVarStorage), steamid, "") == 0)
    {
      LogError("Client %d (%N) was disallowed but had no logged id in cvar! (id: %s, storage: %s)", client, client, steamid, CVarStorage);
      AllowingLedgehang[client] = !AllowingLedgehang[client]; // if this happens they likely expect to be where they technically were
    }
  }
  else
  {
    StrCat(CVarStorage, sizeof(CVarStorage), steamid);
  }

  LevelTransferStorage.SetString(CVarStorage);
}