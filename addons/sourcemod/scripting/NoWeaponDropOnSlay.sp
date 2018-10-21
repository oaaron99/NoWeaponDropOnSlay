#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

#define	CS_TEAM_T	2
#define	CS_TEAM_CT	3

int g_iHurtCounter[MAXPLAYERS+1];

public Plugin myinfo = 
{
	//TODO: Rename to NoWeaponDropOnSlay.smx
	
	name = "No Weapon Drop On Slay",
	author = "Extacy",
	description = "Deletes weapons from a CT if they suicide. Does not drop if they were in recent combat",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198183032322"
};


public void OnPluginStart ()
{
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Pre);
}

public void OnClientPutInServer(int client)
{
	RegConsoleCmd("kill", BlockKill);
	
	g_iHurtCounter[client] = 0;
}

public Action Timer_DecreaseCount(Handle timer, any client)
{		
	g_iHurtCounter[client]--;
	
	return Plugin_Stop;
}

public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int attackerClient = GetClientOfUserId(event.GetInt("attacker"));
	
	if (GetClientTeam(client) == CS_TEAM_CT && GetClientTeam(attackerClient) == CS_TEAM_T)
	{		
		g_iHurtCounter[client]++;
		CreateTimer(5.0, Timer_DecreaseCount, client);
	}
}

public Action BlockKill(int client, int args)
{
	if (g_iHurtCounter[client] == 0 && GetClientTeam(client) == CS_TEAM_CT)
		RemoveWeapon(client);
		
	return Plugin_Continue;
}

public Action RemoveWeapon(int client)
{
	int weapon;
	
	for(int i = 0; i <= 1; i++) 
	{		
		if((weapon = GetPlayerWeaponSlot(client, i)) != -1) 
		{
			SDKHooks_DropWeapon(client, weapon, NULL_VECTOR, NULL_VECTOR);
			AcceptEntityInput(weapon, "KillHierarchy");
		}
	} 
}
