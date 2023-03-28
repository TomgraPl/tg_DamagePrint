#include <sourcemod>
#include <multicolors>

int g_iDamage[MAXPLAYERS+1][MAXPLAYERS+1];
int g_iHits[MAXPLAYERS+1][MAXPLAYERS+1];
#define TAG "{green}[Obrażenia]"

public Plugin myinfo =
{
	name = "tg_DamagePrint",
	author = "Tomgra",
	description = "Pod koniec każdej rundy plugin drukuje na chacie obrażanie, jakie otrzymaliśmy i zadaliśmy przeciwnikom, podobnie do Faceita",
	version = "1.1.0",
	url = "https://steamcommunity.com/id/tomgra/",
};

public void OnPluginStart()
{
	HookEvent("player_hurt", Event_PlayerHurt);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_Pre);
	HookEvent("round_start", Event_RoundStart, EventHookMode_Pre);
}

public void OnClientPutInServer(int client)
{
	for(int i=1; i<=MAXPLAYERS; i++)
	{
		g_iDamage[client][i]=0;
		g_iHits[client][i]=0;
	}
}

public Action Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	for(int i=1; i<MAXPLAYERS+1; i++)
	{
		for(int j=1; j<MAXPLAYERS+1; j++)
		{
			g_iDamage[i][j] = 0;
			g_iHits[i][j] = 0;
		}
	}
}

public Action Event_PlayerHurt(Event event, char[] name, bool dontBroadcast)
{
	int attacker=GetClientOfUserId(event.GetInt("attacker"));
	int victim=GetClientOfUserId(event.GetInt("userid"));
	if(!IsValidClient(attacker)||!IsValidClient(victim)) return Plugin_Continue;
		
	g_iDamage[attacker][victim]+=event.GetInt("dmg_health");
	g_iHits[attacker][victim]++;
	return Plugin_Continue;
}

public Action Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	for(int i=1; i<=MaxClients; i++)
	{
		if(!IsValidClient(i)) continue;
		if(GetClientTeam(i)<2) continue;
		for(int j=1; j<=MaxClients; j++)
		{
			if(!IsValidClient(j)) continue;
			if(GetClientTeam(j)<2) continue;
			if(GetClientTeam(i)==GetClientTeam(j)) continue;
			CPrintToChat(i, "%s Zadane: [%d / %d hits] Otrzymane: [%d / %d hits] - %N [%d hp]", TAG, g_iDamage[i][j], g_iHits[i][j], g_iDamage[j][i], g_iHits[j][i], j, IsPlayerAlive(j)?GetClientHealth(j):0);
		}
	}
}



bool IsValidClient(int client)
{
	if(client<=0) return false;
	if(client>MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	if(IsFakeClient(client)) return false;
	if(IsClientSourceTV(client)) return false;
	return IsClientInGame(client);
}