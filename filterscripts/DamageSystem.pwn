// System Mode
#define FILTERSCRIPT

// Includes
#include	<a_samp>
#include	<izcmd>
#include	<sscanf2>


// Bodypart Constants
#define	BODY_PART_TORSO	3
#define	BODY_PART_GROIN	4
#define	BODY_PART_RIGHT_ARM	5
#define	BODY_PART_LEFT_ARM	6
#define	BODY_PART_RIGHT_LEG	7
#define	BODY_PART_LEFT_LEG	8
#define	BODY_PART_HEAD	9


// Colors Constants
#define	COLOR_TOMATO	0xFF6347FF
#define	COLOR_LIGHT_BEIGE	0xB8BAC6FF


// Limits Constants
#define	MAX_DAMAGES	1000 // Max Info for Damage Array
#define	MAX_RANGE_CMD	5.0 // Max Range for Damage Command

// Dialogs Constants
#define	DIALOG_DAMAGE	1927 // Dialog ID for Damage Info


// Enumerators
enum DAMAGE_INFO {
	dmgDamage,
	dmgWeapon,
	dmgBodypart,
	dmgArmourhit,
	dmgSeconds
};


// Variables
new DamageInfo[MAX_PLAYERS][MAX_DAMAGES][DAMAGE_INFO];
new const ResetDamageInfo[MAX_DAMAGES][DAMAGE_INFO];
new NextDamageSlot[MAX_PLAYERS];


// Callbacks
public OnFilterScriptInit() {
	print("\n ======================================");
	print(" |          Damage System               |");
	print(" | By Hreesang with help from infin1tyy |");
	print(" |    Problems fixed by DeviceBlack     |");
	print(" ========================================\n");
	return 1;
}

public OnPlayerDisconnect(playerid, reason) {
	DamageInfo[playerid] = ResetDamageInfo;
	NextDamageSlot[playerid] = 0;
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason) {
	DamageInfo[playerid] = ResetDamageInfo;
	NextDamageSlot[playerid] = 0;
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart) {
	new Float:pHP, Float:pArm;
	GetPlayerHealth(playerid, pHP);
	GetPlayerArmour(playerid, pArm);

	new slot = NextDamageSlot[playerid]++ % MAX_DAMAGES;
	if(pArm) DamageInfo[playerid][slot][dmgArmourhit] = 1;
	DamageInfo[playerid][slot][dmgDamage] = floatround(amount);
	DamageInfo[playerid][slot][dmgWeapon] = weaponid;
	DamageInfo[playerid][slot][dmgBodypart] = bodypart;
	DamageInfo[playerid][slot][dmgSeconds] = gettime();
	return 1;
}


// Commands
CMD:damages(playerid, const args[]) {
	new id:
	if(sscanf(args, "r", id)) 
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/damages [playerid or username]");

	new Float:x, Float:y, Float:z;
	
	// false on player not connected.
	if(!GetPlayerPos(id, x, y, z)) 
		return SendClientMessage(playerid, COLOR_TOMATO, "Playerid is not an active player.");

	if(!IsPlayerInRangeOfPoint(playerid, MAX_RANGE_CMD, x, y, z))
		return SendClientMessage(playerid, COLOR_LIGHT_BEIGE, "You're too far away.");

	ShowPlayerDamages(playerid, id);
	return 1;
}

// It is always called first in filterscripts so returning 1 there blocks other filterscripts from seeing it.
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	if(dialogid == DIALOG_DAMAGE) return 1;
	return 0;
}


// Functions
GetBodypartName(bodypart) {
	new bodyname[11];
	format(bodyname, sizeof(bodyname), "UNKNOWN");

	switch(bodypart) {
 	   case BODY_PART_TORSO: format(bodyname, sizeof(bodyname), "TORSO");
 	   case BODY_PART_GROIN: format(bodyname, sizeof(bodyname), "GROIN");
 	   case BODY_PART_RIGHT_ARM: format(bodyname, sizeof(bodyname), "RIGHT ARM");
 	   case BODY_PART_LEFT_ARM: format(bodyname, sizeof(bodyname), "LEFT ARM");
 	   case BODY_PART_RIGHT_LEG: format(bodyname, sizeof(bodyname), "RIGHT LEG");
 	   case BODY_PART_LEFT_LEG: format(bodyname, sizeof(bodyname), "LEFT LEG");
 	   case BODY_PART_HEAD: format(bodyname, sizeof(bodyname), "HEAD");
	}

	return bodypart;
}

ShowPlayerDamages(playerid, targetid) {
	new name[MAX_PLAYER_NAME];
	GetPlayerName(targetid, name, MAX_PLAYER_NAME);

	new count;
	for(new i; i < MAX_DAMAGES; i++)
		if(DamageInfo[targetid][i][dmgDamage]) count++;

	if(!count)
		return ShowPlayerDialog(playerid, DIALOG_DAMAGE, DIALOG_STYLE_LIST, name, "There is no damage to display...", "Close", "");
	
	new retstr[1000], weaponname[16], tmpstr[500];
	for(new id; id < MAX_DAMAGES; id++) {
		if(DamageInfo[targetid][id][dmgDamage]) {
			GetWeaponName(weaponid, weaponname, 16);

			format(
				str1, 500, "%d dmg from %s to %s (Armourhit: %d) %d s ago\n", 
				DamageInfo[playerid][id][dmgDamage], weaponname, GetBodypartName(DamageInfo[playerid][id][dmgBodypart]),
				DamageInfo[playerid][id][dmgArmourhit], gettime() - DamageInfo[playerid][id][dmgSeconds]
			);	

			strcat(str, str1);
		}
	}

	ShowPlayerDialog(playerid, DIALOG_DAMAGE, DIALOG_STYLE_LIST, name, str, "Close", "");
}

