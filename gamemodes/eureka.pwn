/*
===================================================================
----------------------- Informations -----------------------
===================================================================

// Group Types
type 1: Police
type 2: Hitman
type 3: Gangs
*/

#define MAILER_URL "Gl3nutzu-demo.tk/mail.php"

#include <a_samp>
#include <a_mysql>
#include <fixes>
#include <foreach>
#include <sscanf2>
#include <streamer>
#include <regex>

#include <YSI\y_master>
#include <YSI\y_commands>
#include <YSI\y_timers>
#include <YSI\y_iterate>
#include <YSI\y_stringhash>
#include <YSI\y_bit>

#include <define>
#include <fly>
#include <sendmail>
#include <mSelection>
#include <playerprogress>

#undef MAX_PLAYERS
#define MAX_PLAYERS 50

#define function%0(%1) forward%0(%1); public%0(%1)

// Natives

native WP_Hash(buffer[], len, const str[]);

// MySQL Configuration
new handle, rows, fields;
new 
	BitArray:pLogged<MAX_PLAYERS>,
	BitArray:flyingStatus<MAX_PLAYERS>,
	
	loginTries[MAX_PLAYERS], 
	playerHashedPass[MAX_PLAYERS][129],
	enteredCode[MAX_PLAYERS],
	examCar[MAX_PLAYERS],
	CP[MAX_PLAYERS],
	Float:playerMark[MAX_PLAYERS][3]
;
new
	para,
	para2,
	para3,
	strPara[30],
	gMsg[128],
	houses = 0,
	updatequery[245]
;
new 
	Text:Logo, 
	Text:ClockTime, Text:ClockDate,
	PlayerText:SpawnChange[6], PlayerBar:LevelBar,
	PlayerText:Hud[5]
;

new 
	Iterator:Admins<MAX_PLAYERS>
;

enum playerInfo {
	pSQLID, pName[MAX_PLAYER_NAME + 1], pPassword[130], pSerialCode[41],
	pSkin,
	pLevel,
	pAdmin,
	pAge, pSex, pEmail[100],
	pCash, pBank,
	pMember, pRank,
	pCarLic, pRespect,
	pFlyLic, pBoatLic,
	pGunLic, pHouseKey,
	pHouseRent, pSpawn

};
new pInfo[MAX_PLAYERS][playerInfo];

enum groupInfo {
	gID,
	gName[50],
	gMotd[128],
	Float:geX,
	Float:geY,
	Float:geZ,
	Float:giX,
	Float:giY,
	Float:giZ,
	gRankname1[20],
	gRankname2[20],
	gRankname3[20],
	gRankname4[20],
	gRankname5[20],
	gRankname6[20],
	gRankname7[20],
	gType,
	gInterior,
	gDoor,
	gLeadskin,
	gPickup,
	Text3D:gLabel
	
};
new gInfo[MAX_GROUPS][groupInfo];

enum houseInfo {
	hID,
	hName[50],
	Float:heX,
	Float:heY,
	Float:heZ,
	Float:hiX,
	Float:hiY,
	Float:hiZ,
	hPrice,
	hRent,
	hInterior,
	hSize[10],
	hOwner[25],
	hLocked,
	hLevel,
	hDeposit,
	hPickup,
	Text3D:hLabel

};
new hInfo[200][houseInfo];

enum vehInfo {
	vID,
	vModel,
	vGroup,
	vColor1,
	vColor2,
	vCarPlate[11],
	Float:vX,
	Float:vY,
	Float:vZ,
	Float:vA
};
new vInfo[MAX_VEHICLES][vehInfo], vehID[MAX_VEHICLES];

main() {
	print("\n----------------------------------");
	print(" Beleaua RPG Gamemode by Gl3nutzu ");
	print("----------------------------------\n");
}

new Float:BigHouseInteriors[9][4] = {
	{2324.53, -1149.54, 1050.71, 12.0},
	{225.68, 1021.45, 1084.02, 7.0},
	{234.19, 1063.73, 1084.21, 6.0},
	{226.30, 1114.24, 1080.99, 5.0},
	{235.34, 1186.68, 1080.26, 3.0},
	{491.07, 1398.50, 1080.26, 2.0},
	{83.03, 1322.28, 1083.87, 9.0},
	{-42.59, 1405.47, 1084.43, 8.0},
	{2317.89, -1026.76, 1050.22, 9.0}
};

new Float:MediumHouseInteriors[12][4] = {
	{24.04, 1340.17, 1084.38, 10.0},
	{-283.44, 1470.93, 1084.38, 15.0},
	{-260.49, 1456.75, 1084.37, 4.0},
	{2495.98, -1692.08, 1014.74, 3.0},
	{2807.48, -1174.76, 1025.57, 8.0},
	{2196.85, -1204.25, 1049.02, 6.0},
	{377.15, 1417.41, 1081.33, 15.0},
	{328.05, 1477.73, 1084.44, 15.0},
	{223.20, 1287.08, 1082.14, 1.0},
	{2237.59, -1081.64, 1049.02, 2.0},
	{295.04, 1472.26, 1080.26, 15.0},
	{446.99, 1397.07, 1084.30, 2.0}
};

new Float:SmallHouseInteriors[18][4] = {
	{2270.38, -1210.35, 1047.56, 10.0},
	{387.22, 1471.70, 1080.19, 15.0},
	{22.88, 1403.33, 1084.44, 5.0},
	{2365.31, -1135.60, 1050.88, 8.0},
	{261.12, 1284.30, 1080.26, 4.0},
	{221.92, 1140.20, 1082.61, 4.0},
	{-68.81, 1351.21, 1080.21, 6.0},
	{260.85, 1237.24, 1084.26, 9.0},
	{2468.84, -1698.24, 1013.51, 2.0},
	{2283.04, -1140.28, 1050.90, 11.0},
	{446.90, 506.35, 1001.42, 12.0},
	{299.78, 309.89, 1003.30, 4.0},
	{2308.77, -1212.94, 1049.02, 6.0},
	{2233.64, -1115.26, 1050.88, 5.0},
	{2218.40, -1076.18, 1050.48, 1.0},
	{266.50, 304.90, 999.15, 2.0},
	{243.72, 304.91, 999.15, 1.0},
	{2259.38, -1135.77, 1050.64, 10.0}
};

//timers
task OneSecond[1000]() {
    new hour, minutes, seconds, day, month, year, mstr[20];
	gettime(hour, minutes, seconds), getdate(year, month, day);
	format(gMsg, 128,"%02d:%02d", hour, minutes), TextDrawSetString(ClockTime, gMsg);
	switch(month) { case 1: mstr="january"; case 2: mstr="february"; case 3: mstr="march"; case 4: mstr="april"; case 5: mstr="may"; case 6: mstr="june"; case 7: mstr="iuly"; case 8: mstr="august";  case 9: mstr="september";  case 10: mstr="octomber"; case 11: mstr="november"; case 12: mstr="december"; }
	format(gMsg, 128,"%02d %s %02d", day, mstr, year), TextDrawSetString(ClockDate, gMsg);
	
	foreach(new x: Player) {
		ResetPlayerMoney(x), GivePlayerMoney(x, pInfo[x][pCash]);
	}
}

task FiveMinutes[1000 * (60*5)]() {
	new hour, minute, second;
	gettime(hour, minute, second);
	if(minute <= 1 || minute >= 59) {
		foreach(new i: Player) {
			PayDay(i);
		}
	}
	for(new v; v < MAX_VEHICLES; v++) { if(vInfo[v][vID] > 0 ) { saveVeh(v); } }

	for(new i; i < MAX_GROUPS; i++) { saveGroup(i); }
	
	sendAdmins(COLOR_RED, "AdmData: "WHITE"All server data saved.");
}

timer kickTimer[500](playerid) {
    Kick(playerid);
}

timer securityKick[1000 * 120](playerid) {
    if(enteredCode[playerid] == 0) { Kick(playerid); }
}

timer setVehicleZAngle[700](vehicleid) {
	SetVehicleZAngle(vehicleid, vInfo[vehID[vehicleid]][vA]);
}

public OnGameModeInit() {
	handle = mysql_connect("localhost", "root", "proiect", "");
	
	if(handle && mysql_errno(handle) == 0) { print("[MYSQL] Succesfuly connected!"); }
	else print("[MYSQL] Connection not found.");
	
	mysql_tquery(handle, "SELECT * FROM `groups`", "loadGroups", "");
	mysql_tquery(handle, "SELECT * FROM `cars`", "loadCars", "");
	mysql_tquery(handle, "SELECT * FROM `houses`", "loadHouses", "");
	
	EnableStuntBonusForAll(0);
	ShowPlayerMarkers(0);
    UsePlayerPedAnims();
	DisableInteriorEnterExits();
	
	SendRconCommand("language RO/EN");
	SetGameModeText("Beleaua:RPG v1");
	
	
	Logo = TextDrawCreate(638.400085, 431.573303, "Beleaua");
    TextDrawLetterSize(Logo, 0.354799, 1.704532);
    TextDrawAlignment(Logo, 3);
    TextDrawColor(Logo, -1);
    TextDrawSetShadow(Logo, 0);
    TextDrawSetOutline(Logo, 1);
    TextDrawBackgroundColor(Logo, 51);
    TextDrawFont(Logo, 3);
    TextDrawSetProportional(Logo, 1);
	
	ClockTime = TextDrawCreate(577.599548, 21.653348, "23:45");
	TextDrawLetterSize(ClockTime, 0.449999, 1.600000);
	TextDrawAlignment(ClockTime, 2);
	TextDrawColor(ClockTime, -1);
	TextDrawSetShadow(ClockTime, 0);
	TextDrawSetOutline(ClockTime, 1);
	TextDrawBackgroundColor(ClockTime, 51);
	TextDrawFont(ClockTime, 3);
	TextDrawSetProportional(ClockTime, 1);

	ClockDate = TextDrawCreate(579.200256, 7.466676, "23 octombrie 2017");
	TextDrawLetterSize(ClockDate, 0.177200, 1.712000);
	TextDrawAlignment(ClockDate, 2);
	TextDrawColor(ClockDate, -1);
	TextDrawSetShadow(ClockDate, 0);
	TextDrawSetOutline(ClockDate, 1);
	TextDrawBackgroundColor(ClockDate, 51);
	TextDrawFont(ClockDate, 2);
	TextDrawSetProportional(ClockDate, 1);

	CreateObject(8168, 1024.52979, -1365.06189, 14.34679,   0.00000, 0.00000, 286.11096);
	CreateObject(19437, 977.10858, -1277.49548, 15.86687,   0.00000, 0.00000, 270.19211);
	CreateObject(19437, 975.50842, -1277.48267, 15.86687,   0.00000, 0.00000, 270.19211);
	CreateObject(19437, 973.91492, -1277.49487, 15.86690,   0.00000, 0.00000, 270.19211);
	CreateObject(19437, 970.70282, -1277.50415, 15.86690,   0.00000, 0.00000, 270.19211);
	CreateObject(19437, 972.30890, -1277.49365, 15.86690,   0.00000, 0.00000, 270.19211);
	CreateObject(19437, 969.59821, -1277.50525, 15.86690,   0.00000, 0.00000, 270.19211);

	CreateDynamicPickup(1581, 1, 1020.7487, -1365.0017, 13.5565, -1, -1, -1, 100.0); // DMV
	CreateDynamic3DTextLabel("DMV: Type (/exam) to start.", COLOR_WHITE, 1020.7487, -1365.0017, 13.5565, 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 100.0);
	CreateDynamicPickup(1581, 1, 1957.3932, -2183.6255, 13.5469, -1, -1, -1, 100.0); // Pilot
	CreateDynamic3DTextLabel("Pilot License: Type (/exam) to start.", COLOR_WHITE, 1957.3932, -2183.6255, 13.5469, 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 100.0);
	CreateDynamicPickup(1581, 1, 723.2545, -1493.4685, 1.9343, -1, -1, -1, 100.0); // Sailing
	CreateDynamic3DTextLabel("Sailing License: Type (/exam) to start.", COLOR_WHITE, 723.2545, -1493.4685, 1.9343, 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 100.0);
	CreateDynamicPickup(1581, 1, 1796.3507, -1146.9712, 23.8556, -1, -1, -1, 100.0); // Gun
	CreateDynamic3DTextLabel("Gun License: Type (/taketest) to start.", COLOR_WHITE, 1796.3507, -1146.9712, 23.8556, 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 100.0);


	return 1;
}

public OnGameModeExit() {
	for(new v; v < MAX_VEHICLES; v++) { if(vInfo[v][vID] > 0 ) { saveVeh(v); } }
	
	for(new i; i < MAX_GROUPS; i++) { saveGroup(i); }
	
	mysql_close(handle);
	return 1;
}

public OnPlayerRequestClass(playerid, classid) {
	return 1;
}

public OnPlayerConnect(playerid) {
	loginTries[playerid] = 0;
	format(playerHashedPass[playerid], 5, "NULL");
	enteredCode[playerid] = 0;
	examCar[playerid] = -1;
	CP[playerid] = 0;
	for(new i=0; i<3; i++) playerMark[playerid][i] = 0;

	new query[128];
	mysql_format(handle, query, 128, "SELECT * FROM `players` WHERE `username` = '%e'", GetName(playerid));
	mysql_tquery(handle, query, "accountCheck", "i", playerid);
	
	//show td
	TextDrawShowForPlayer(playerid, Logo);
	TextDrawShowForPlayer(playerid, ClockTime), TextDrawShowForPlayer(playerid, ClockDate);

	RemoveBuildingForPlayer(playerid, 1438, 1015.5313, -1337.1719, 12.5547, 0.25);

	SpawnChange[0] = CreatePlayerTextDraw(playerid, 319.375000, 142.166671, "SPAWN CHANGE~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");
	PlayerTextDrawLetterSize(playerid, SpawnChange[0], 0.400000, 1.600000);
	PlayerTextDrawTextSize(playerid, SpawnChange[0], 0.000000, 536.000000);
	PlayerTextDrawAlignment(playerid, SpawnChange[0], 2);
	PlayerTextDrawColor(playerid, SpawnChange[0], -1);
	PlayerTextDrawUseBox(playerid, SpawnChange[0], 1);
	PlayerTextDrawBoxColor(playerid, SpawnChange[0], 180);
	PlayerTextDrawSetShadow(playerid, SpawnChange[0], 0);
	PlayerTextDrawSetOutline(playerid, SpawnChange[0], 0);
	PlayerTextDrawBackgroundColor(playerid, SpawnChange[0], 255);
	PlayerTextDrawFont(playerid, SpawnChange[0], 1);
	PlayerTextDrawSetProportional(playerid, SpawnChange[0], 1);
	PlayerTextDrawSetShadow(playerid, SpawnChange[0], 0);

	SpawnChange[1] = CreatePlayerTextDraw(playerid, 122.624816, 180.666763, "NORMAL PLACE");
	PlayerTextDrawLetterSize(playerid, SpawnChange[1], 0.400000, 1.600000);
	PlayerTextDrawAlignment(playerid, SpawnChange[1], 1);
	PlayerTextDrawColor(playerid, SpawnChange[1], -1);
	PlayerTextDrawSetShadow(playerid, SpawnChange[1], 0);
	PlayerTextDrawSetOutline(playerid, SpawnChange[1], 0);
	PlayerTextDrawBackgroundColor(playerid, SpawnChange[1], 255);
	PlayerTextDrawFont(playerid, SpawnChange[1], 1);
	PlayerTextDrawSetProportional(playerid, SpawnChange[1], 1);
	PlayerTextDrawSetShadow(playerid, SpawnChange[1], 0);

	SpawnChange[2] = CreatePlayerTextDraw(playerid, 451.875000, 180.666717, "HOME");
	PlayerTextDrawLetterSize(playerid, SpawnChange[2], 0.400000, 1.600000);
	PlayerTextDrawAlignment(playerid, SpawnChange[2], 1);
	PlayerTextDrawColor(playerid, SpawnChange[2], -1);
	PlayerTextDrawSetShadow(playerid, SpawnChange[2], 0);
	PlayerTextDrawSetOutline(playerid, SpawnChange[2], 0);
	PlayerTextDrawBackgroundColor(playerid, SpawnChange[2], 255);
	PlayerTextDrawFont(playerid, SpawnChange[2], 1);
	PlayerTextDrawSetProportional(playerid, SpawnChange[2], 1);
	PlayerTextDrawSetShadow(playerid, SpawnChange[2], 0);

	SpawnChange[3] = CreatePlayerTextDraw(playerid, 110.625000, 182.999969, "");
	PlayerTextDrawLetterSize(playerid, SpawnChange[3], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, SpawnChange[3], 125.000000, 120.000000);
	PlayerTextDrawAlignment(playerid, SpawnChange[3], 1);
	PlayerTextDrawColor(playerid, SpawnChange[3], -1);
	PlayerTextDrawSetShadow(playerid, SpawnChange[3], 0);
	PlayerTextDrawSetOutline(playerid, SpawnChange[3], 0);
	PlayerTextDrawBackgroundColor(playerid, SpawnChange[3], 0);
	PlayerTextDrawFont(playerid, SpawnChange[3], 5);
	PlayerTextDrawSetProportional(playerid, SpawnChange[3], 0);
	PlayerTextDrawSetShadow(playerid, SpawnChange[3], 0);
	PlayerTextDrawSetSelectable(playerid, SpawnChange[3], true);
	PlayerTextDrawSetPreviewModel(playerid, SpawnChange[3], 1240);
	PlayerTextDrawSetPreviewRot(playerid, SpawnChange[3], 0.000000, 0.000000, 0.000000, 1.000000);

	SpawnChange[4] = CreatePlayerTextDraw(playerid, 410.000000, 186.500045, "");
	PlayerTextDrawLetterSize(playerid, SpawnChange[4], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, SpawnChange[4], 117.000000, 114.000000);
	PlayerTextDrawAlignment(playerid, SpawnChange[4], 1);
	PlayerTextDrawColor(playerid, SpawnChange[4], -1);
	PlayerTextDrawSetShadow(playerid, SpawnChange[4], 0);
	PlayerTextDrawSetOutline(playerid, SpawnChange[4], 0);
	PlayerTextDrawBackgroundColor(playerid, SpawnChange[4], 0);
	PlayerTextDrawFont(playerid, SpawnChange[4], 5);
	PlayerTextDrawSetProportional(playerid, SpawnChange[4], 0);
	PlayerTextDrawSetShadow(playerid, SpawnChange[4], 0);
	PlayerTextDrawSetSelectable(playerid, SpawnChange[4], true);
	PlayerTextDrawSetPreviewModel(playerid, SpawnChange[4], 1272);
	PlayerTextDrawSetPreviewRot(playerid, SpawnChange[4], 0.000000, 0.000000, 0.000000, 1.000000);

	SpawnChange[5] = CreatePlayerTextDraw(playerid, 321.250000, 167.450057, "box");
	PlayerTextDrawLetterSize(playerid, SpawnChange[5], 0.000000, 14.125000);
	PlayerTextDrawTextSize(playerid, SpawnChange[5], 317.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, SpawnChange[5], 1);
	PlayerTextDrawColor(playerid, SpawnChange[5], -1);
	PlayerTextDrawUseBox(playerid, SpawnChange[5], 1);
	PlayerTextDrawBoxColor(playerid, SpawnChange[5], -1);
	PlayerTextDrawSetShadow(playerid, SpawnChange[5], 0);
	PlayerTextDrawSetOutline(playerid, SpawnChange[5], 0);
	PlayerTextDrawBackgroundColor(playerid, SpawnChange[5], 255);
	PlayerTextDrawFont(playerid, SpawnChange[5], 1);
	PlayerTextDrawSetProportional(playerid, SpawnChange[5], 1);
	PlayerTextDrawSetShadow(playerid, SpawnChange[5], 0);

	Hud[0] = CreatePlayerTextDraw(playerid, 241.624908, 422.850036, "34");
	PlayerTextDrawLetterSize(playerid, Hud[0], 0.400000, 1.600000);
	PlayerTextDrawAlignment(playerid, Hud[0], 2);
	PlayerTextDrawColor(playerid, Hud[0], -1);
	PlayerTextDrawSetShadow(playerid, Hud[0], 0);
	PlayerTextDrawSetOutline(playerid, Hud[0], 0);
	PlayerTextDrawBackgroundColor(playerid, Hud[0], 255);
	PlayerTextDrawFont(playerid, Hud[0], 1);
	PlayerTextDrawSetProportional(playerid, Hud[0], 1);
	PlayerTextDrawSetShadow(playerid, Hud[0], 0);

	Hud[1] = CreatePlayerTextDraw(playerid, 402.424957, 422.733215, "35");
	PlayerTextDrawLetterSize(playerid, Hud[1], 0.400000, 1.600000);
	PlayerTextDrawAlignment(playerid, Hud[1], 2);
	PlayerTextDrawColor(playerid, Hud[1], -1);
	PlayerTextDrawSetShadow(playerid, Hud[1], 0);
	PlayerTextDrawSetOutline(playerid, Hud[1], 0);
	PlayerTextDrawBackgroundColor(playerid, Hud[1], 255);
	PlayerTextDrawFont(playerid, Hud[1], 1);
	PlayerTextDrawSetProportional(playerid, Hud[1], 1);
	PlayerTextDrawSetShadow(playerid, Hud[1], 0);

	Hud[2] = CreatePlayerTextDraw(playerid, 224.099945, 415.649749, "LD_BEAT:chit");
	PlayerTextDrawLetterSize(playerid, Hud[2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Hud[2], 35.000000, 30.630136);
	PlayerTextDrawAlignment(playerid, Hud[2], 1);
	PlayerTextDrawColor(playerid, Hud[2], 255);
	PlayerTextDrawSetShadow(playerid, Hud[2], 0);
	PlayerTextDrawSetOutline(playerid, Hud[2], 0);
	PlayerTextDrawBackgroundColor(playerid, Hud[2], 255);
	PlayerTextDrawFont(playerid, Hud[2], 4);
	PlayerTextDrawSetProportional(playerid, Hud[2], 0);
	PlayerTextDrawSetShadow(playerid, Hud[2], 0);

	Hud[3] = CreatePlayerTextDraw(playerid, 385.024810, 415.433074, "LD_BEAT:chit");
	PlayerTextDrawLetterSize(playerid, Hud[3], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Hud[3], 35.000000, 30.630136);
	PlayerTextDrawAlignment(playerid, Hud[3], 1);
	PlayerTextDrawColor(playerid, Hud[3], 255);
	PlayerTextDrawSetShadow(playerid, Hud[3], 0);
	PlayerTextDrawSetOutline(playerid, Hud[3], 0);
	PlayerTextDrawBackgroundColor(playerid, Hud[3], 255);
	PlayerTextDrawFont(playerid, Hud[3], 4);
	PlayerTextDrawSetProportional(playerid, Hud[3], 0);
	PlayerTextDrawSetShadow(playerid, Hud[3], 0);

	Hud[4] = CreatePlayerTextDraw(playerid, 321.875000, 418.666870, "RP: 101 - 134 TO LEVEL UP");
	PlayerTextDrawLetterSize(playerid, Hud[4], 0.271874, 0.934998);
	PlayerTextDrawAlignment(playerid, Hud[4], 2);
	PlayerTextDrawColor(playerid, Hud[4], -1);
	PlayerTextDrawSetShadow(playerid, Hud[4], 0);
	PlayerTextDrawSetOutline(playerid, Hud[4], 1);
	PlayerTextDrawBackgroundColor(playerid, Hud[4], 255);
	PlayerTextDrawFont(playerid, Hud[4], 1);
	PlayerTextDrawSetProportional(playerid, Hud[4], 1);
	PlayerTextDrawSetShadow(playerid, Hud[4], 0);
	
	SetSpawnInfo(playerid, 0, 0, 974.0515, -1285.1781, 13.5540, 179.0847, 0,0,0,0, 0, 0 );
	InitFly(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason) {
	// iterate
	if(pInfo[playerid][pAdmin] > 0) {
		Iter_Remove(Admins, playerid);
	}
	resetData(playerid);
	if(examCar[playerid] != -1) {
		disableCP(playerid);
		DestroyVehicle(examCar[playerid]);
		examCar[playerid] = -1;
	}
	return 1;
}
// Login
function accountCheck(playerid) {
	TogglePlayerSpectating(playerid, 1);
	cache_get_data(rows, fields, handle);
	if(rows) {
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "SERVER: Login", ""WHITE"Welcome back to "CREM"Beleaua RPG!"WHITE"\n\nYour account has been found in our database, you need to log in.\nPlease enter your password below.", "Login", "Cancel");
	}
	else {
		
		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "SERVER: Register", ""WHITE"Welcome to "CREM"Beleaua RPG!"WHITE"\n\nYour account was not found in our database, make one.\nPlease enter a new password bellow.", "Register", "Cancel");
	}
	InterpolateCameraPos(playerid, 2062.878906, 988.830627, 11.947507, 2022.668579, 1397.960937, 27.489007, 20000);
	InterpolateCameraLookAt(playerid, 2063.091552, 993.787048, 12.570880, 2022.038208, 1402.912109, 27.785707, 10000);
	return 1;
}

function accountLogin(playerid) {
	cache_get_data(rows, fields, handle);
	if(rows) {
		
		pInfo[playerid][pSQLID] = cache_get_field_content_int(0, "ID");
		cache_get_field_content(0, "username",  pInfo[playerid][pName], handle, MAX_PLAYER_NAME + 1);
		cache_get_field_content(0, "SerialCode", pInfo[playerid][pSerialCode], handle, 41);
		cache_get_field_content(0, "password", pInfo[playerid][pPassword], handle, 129);
		cache_get_field_content(0, "Email", pInfo[playerid][pEmail], handle, 100);
		pInfo[playerid][pLevel] = cache_get_field_content_int(0, "Level");
		pInfo[playerid][pAdmin] = cache_get_field_content_int(0, "AdminLevel");
		pInfo[playerid][pCash] = cache_get_field_content_int(0, "Cash");
		pInfo[playerid][pAge] = cache_get_field_content_int(0, "Age");
		pInfo[playerid][pSex] = cache_get_field_content_int(0, "Sex");
		pInfo[playerid][pBank] = cache_get_field_content_int(0, "Bank");
		pInfo[playerid][pMember] = cache_get_field_content_int(0, "Member");
		pInfo[playerid][pRank] = cache_get_field_content_int(0, "Rank");
		pInfo[playerid][pSkin] = cache_get_field_content_int(0, "Skin");
		pInfo[playerid][pRespect] = cache_get_field_content_int(0, "Respect");
		pInfo[playerid][pCarLic] = cache_get_field_content_int(0, "CarLic");
		pInfo[playerid][pFlyLic] = cache_get_field_content_int(0, "FlyLic");
		pInfo[playerid][pBoatLic] = cache_get_field_content_int(0, "BoatLic");
		pInfo[playerid][pGunLic] = cache_get_field_content_int(0, "GunLic");
		pInfo[playerid][pHouseKey] = cache_get_field_content_int(0, "HouseKey");
		pInfo[playerid][pHouseRent] = cache_get_field_content_int(0, "HouseRent");
		pInfo[playerid][pSpawn] = cache_get_field_content_int(0, "Spawn");
		
		Clearchat(playerid, 20), SCM(playerid, COLOR_GREY, "(Server): "WHITE"Welcome back, have fun!");
		
		if(pInfo[playerid][pMember]) { SCMEx(playerid, COLOR_TEAL, "Group motd: "WHITE"%s", gInfo[pInfo[playerid][pMember]][gMotd]); }
		
		if(pInfo[playerid][pAdmin] > 0) { Iter_Add(Admins, playerid), SCMEx(playerid, COLOR_GREY, "(Server): "WHITE"You are connected as admin level %d!", pInfo[playerid][pAdmin]); }
		
		new serial[41], query[100];
		gpci(playerid, serial, 41);
		if(strcmp(pInfo[playerid][pSerialCode], serial, false)) {
			new str[200], randCod[10];
			format(randCod, 10, randomString(10));
			mysql_format(handle, query, 256, "INSERT INTO `accounts_blocked` (`playerID`, `time`, `securityCode`) VALUES ('%d', '%d', '%e')", pInfo[playerid][pSQLID], GetTickCount(), randCod);
			mysql_tquery(handle, query, "", "");

			format(str, 384, "Hello %s!\nYou received this email because you logged in on your account from a different location.\nUse this code to continue the game: %s", GetName(playerid), randCod);
			SendMail(pInfo[playerid][pEmail], "Beleaua@samp.com", "Beleaua RPG",  "Security code!", str);
			
			ShowPlayerDialog(playerid, DIALOG_BLOCK, DIALOG_STYLE_PASSWORD, "SERVER: Account blocked", 
			""WHITE"This account is "DRED"blocked "WHITE"because you are logged in from a different location.\n\nTo unblock your account you need to use a security cod, sended to your email.\nYou have "CREM"2 minutes "WHITE"to use it.", "Proceed", "Cancel");
			defer securityKick(playerid);
		}

		LevelBar = CreatePlayerProgressBar(playerid, 258.00, 430.00, 128.50, 3.20, 869072810, 100.0);
		UpdateBar(playerid);
		
		Bit_Set(pLogged, playerid, true);
		TogglePlayerSpectating(playerid, 0);
		SetPlayerScore(playerid, pInfo[playerid][pLevel]);
		SpawnPlayer(playerid);
	}
	else {
		if(2-loginTries[playerid] != 0) {
			loginTries[playerid] ++;
			SCMEx(playerid, COLOR_DRED, "You have %d attempts to login, otherwise you will be kicked from the server.", 3-loginTries[playerid]);
			ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""WHITE"SERVER: Login", ""WHITE"Welcome back to "CREM"Beleaua RPG"WHITE"!\n\nYour account has been found in our database, you need to log in.\nPlease enter your "DRED"correct"WHITE" password.", "Login", "Cancel");
		} else ShowPlayerDialog(playerid, DIALOG_GENERAL, DIALOG_STYLE_MSGBOX, "SERVER: Wrong password", ""WHITE"You have been kicked because you wrote wrong password 3 times.", "Okay", ""), defer kickTimer(playerid);
	}
	return 1;
}

// Load Data
function loadGroups() {
	cache_get_data(rows, fields);
	if(rows) {
		new id, pickup;
		for(new i; i < rows; i++) {
			id = cache_get_field_content_int(i, "id");
			gInfo[id][gID] = id;
			cache_get_field_content(i, "Name", gInfo[id][gName], handle, 50);
			cache_get_field_content(i, "Motd", gInfo[id][gMotd], handle, 128);
			cache_get_field_content(i, "rankName1", gInfo[id][gRankname1], handle, 20);
			cache_get_field_content(i, "rankName2", gInfo[id][gRankname2], handle, 20);
			cache_get_field_content(i, "rankName3", gInfo[id][gRankname3], handle, 20);
			cache_get_field_content(i, "rankName4", gInfo[id][gRankname4], handle, 20);
			cache_get_field_content(i, "rankName5", gInfo[id][gRankname5], handle, 20);
			cache_get_field_content(i, "rankName6", gInfo[id][gRankname6], handle, 20);
			cache_get_field_content(i, "rankName7", gInfo[id][gRankname7], handle, 20);
			
			gInfo[id][geX] = cache_get_field_content_float(i, "eX");
			gInfo[id][geY] = cache_get_field_content_float(i, "eY");
			gInfo[id][geZ] = cache_get_field_content_float(i, "eZ");
			gInfo[id][giX] = cache_get_field_content_float(i, "iX");
			gInfo[id][giY] = cache_get_field_content_float(i, "iY");
			gInfo[id][giZ] = cache_get_field_content_float(i, "iZ");

			gInfo[id][gType] = cache_get_field_content_int(i, "Type");
			gInfo[id][gInterior] = cache_get_field_content_int(i, "Interior");
			gInfo[id][gDoor] = cache_get_field_content_int(i, "Door");
			gInfo[id][gLeadskin] = cache_get_field_content_int(i, "leadSkin");

			format(gMsg, 128, "{FF6347}%s`s HQ\n{D2B48C}(%s)", gInfo[id][gName], (gInfo[id][gDoor]) ? ("closed") : ("opened"));

			if(gInfo[id][gType] == 1) { pickup = 1247; }
			else if(gInfo[id][gType] == 2) { pickup = 1254; }
			else { pickup = 1239; }
			
			gInfo[id][gPickup] = CreateDynamicPickup(pickup, 1, gInfo[id][geX], gInfo[id][geY], gInfo[id][geZ], -1, -1, -1, 20.0);
			gInfo[id][gLabel] = CreateDynamic3DTextLabel(gMsg, COLOR_YELLOW, gInfo[id][geX], gInfo[id][geY], gInfo[id][geZ], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
		}
	}
	else print("No groups.");
	return 1;
}

function loadCars() {
	cache_get_data(rows, fields, handle);
	if(rows) {
		for(new x = 0; x < rows; x++) {
			new i = cache_get_field_content_int(x, "id");
			vInfo[i][vID] = i;
			vInfo[i][vModel] = cache_get_field_content_int(x, "Model");
			vInfo[i][vGroup] = cache_get_field_content_int(x, "Group");
			vInfo[i][vX] = cache_get_field_content_float(x, "pX");
			vInfo[i][vY] = cache_get_field_content_float(x, "pY");
			vInfo[i][vZ] = cache_get_field_content_float(x, "pZ");
			vInfo[i][vA] = cache_get_field_content_float(x, "pA");
			cache_get_field_content(x, "CarPlate", vInfo[i][vCarPlate], handle, 11);
			vInfo[i][vColor1] = cache_get_field_content_int(x, "Color1");
			vInfo[i][vColor2] = cache_get_field_content_int(x, "Color2");
			
			new car = CreateVehicle(vInfo[i][vModel], vInfo[i][vX], vInfo[i][vY], vInfo[i][vZ], vInfo[i][vA], vInfo[i][vColor1], vInfo[i][vColor2], -1);
			vehID[car] = vInfo[i][vID];
			SetVehicleNumberPlate(car, vInfo[i][vCarPlate]);
			new lights, alarm, doors, bonnet, boot, objective;
			SetVehicleParamsEx(car, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);
		}
	}
	else print("No cars.");
	return 1;
}

function loadHouses() {
	cache_get_data(rows, fields, handle);
	if(rows) {
		for(new i = 0; i < rows; i++) {
			new id = cache_get_field_content_int(i, "id");
			hInfo[id][hID] = id;
			cache_get_field_content(i, "Name", hInfo[id][hName], handle, 50);
			cache_get_field_content(i, "Owner", hInfo[id][hOwner], handle, 25);
			cache_get_field_content(i, "Size", hInfo[id][hSize], handle, 10);

			hInfo[id][heX] = cache_get_field_content_float(i, "eX");
			hInfo[id][heY] = cache_get_field_content_float(i, "eY");
			hInfo[id][heZ] = cache_get_field_content_float(i, "eZ");
			hInfo[id][hiX] = cache_get_field_content_float(i, "iX");
			hInfo[id][hiY] = cache_get_field_content_float(i, "iY");
			hInfo[id][hiZ] = cache_get_field_content_float(i, "iZ");
			hInfo[id][hRent] = cache_get_field_content_int(i, "Rent");
			hInfo[id][hLocked] = cache_get_field_content_int(i, "Locked");
			hInfo[id][hInterior] = cache_get_field_content_int(i, "Interior");
			hInfo[id][hLevel] = cache_get_field_content_int(i, "Level");
			hInfo[id][hPrice] = cache_get_field_content_int(i, "Price");
			hInfo[id][hDeposit] = cache_get_field_content_int(i, "Deposit");
			UpdateProperty(id);
		}
		houses = rows;
	}
	return 1;
}

function UpdateProperty(id) {
	DestroyDynamicPickup(hInfo[id][hPickup]);
	DestroyDynamic3DTextLabel(hInfo[id][hLabel]);
	new label[250];
	if(!strcmp(hInfo[id][hOwner], "AdmBot")) {
		format(label, sizeof(label), "House "LABEL"%d"WHITE"\n"LABEL"Owner: "WHITE"AdmBot\n"LABEL"Description: "WHITE"%s\n"LABEL"Size: "WHITE"%s\n"LABEL"Level: "WHITE"%d", id, hInfo[id][hName], hInfo[id][hSize], hInfo[id][hLevel]);
		hInfo[id][hPickup] = CreateDynamicPickup(1273, 23, hInfo[id][heX], hInfo[id][heY], hInfo[id][heZ]);
	}
	else {
		format(label, sizeof(label), "House "LABEL"%d\n%s\nOwner: "WHITE"%s\n"LABEL"Rent: "WHITE"%d\n"LABEL"Size: "WHITE"%s\n"LABEL"Price: "WHITE"%s$\n"LABEL"Level: "WHITE"%d\n"LABEL"To rent a room type (/rentroom)", id, hInfo[id][hName], hInfo[id][hOwner], hInfo[id][hRent], hInfo[id][hSize], FormatNumber(hInfo[id][hPrice]), hInfo[id][hLevel]);
		hInfo[id][hPickup] = CreateDynamicPickup(19522, 23, hInfo[id][heX], hInfo[id][heY], hInfo[id][heZ]);
	}
	hInfo[id][hLabel] = CreateDynamic3DTextLabel(label, COLOR_WHITE, hInfo[id][heX], hInfo[id][heY], hInfo[id][heZ], 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 100.0);
	return 1;
}

function UpdateBar(playerid) {
	new string[34];
	format(string, sizeof(string), "RP: %d - %d TO LEVEL UP", pInfo[playerid][pRespect], pInfo[playerid][pLevel]*2);
	PlayerTextDrawSetString(playerid, Hud[4], string);
	PlayerTextDrawShow(playerid, Hud[4]);
	format(string, sizeof(string), "%d", pInfo[playerid][pLevel]);
	PlayerTextDrawSetString(playerid, Hud[0], string);
	PlayerTextDrawShow(playerid, Hud[0]);
	format(string, sizeof(string), "%d", pInfo[playerid][pLevel]+1);
	PlayerTextDrawSetString(playerid, Hud[1], string);
	PlayerTextDrawShow(playerid, Hud[1]);
	PlayerTextDrawShow(playerid, Hud[2]);
	PlayerTextDrawShow(playerid, Hud[3]);
	SetPlayerProgressBarMaxValue(playerid, LevelBar, pInfo[playerid][pLevel]*2);
	SetPlayerProgressBarValue(playerid, LevelBar, pInfo[playerid][pRespect]);
	ShowPlayerProgressBar(playerid, LevelBar);
	return 1;
}

function saveGroup(id) {
	new query[500];
	mysql_format(handle, query, 500, 
	"UPDATE `groups` SET `Name` = '%s', `Motd` = '%s', `eX` = '%f', `eY` = '%f', `eZ` = '%f', `iX` = '%f', `iY` = '%f', `iZ` = '%f', `rankName1` = '%s', `rankName2` = '%s', `rankName3` = '%s', `rankName4` = '%s', `rankName5` = '%s', `rankName6` = '%s', `rankName7` = '%s', `Type` = '%d', `Interior` = '%d', `Door` = '%d', `leadSkin` = '%d' WHERE `id` = '%d'",
	gInfo[id][gName], gInfo[id][gMotd], gInfo[id][geX], gInfo[id][geY],gInfo[id][geZ], gInfo[id][giX], gInfo[id][giY], gInfo[id][giZ], gInfo[id][gRankname1], gInfo[id][gRankname2], gInfo[id][gRankname3], gInfo[id][gRankname4], gInfo[id][gRankname5], gInfo[id][gRankname6], gInfo[id][gRankname7], gInfo[id][gType], gInfo[id][gInterior], gInfo[id][gDoor], gInfo[id][gLeadskin], id);
	mysql_tquery(handle, query, "", "");
	return 1;
}

function saveVeh(car) {
	new query[500];
	mysql_format(handle, query, 500, "UPDATE `cars` SET `Model` = '%d', `Group` = '%d', `CarPlate` = '%e', `pX` = '%f', `pY` = '%f', `pZ` = '%f', `pA` = '%f', `Color1` = '%d', `Color2` = '%d' WHERE `id` = '%d'",
	vInfo[car][vModel], vInfo[car][vGroup], vInfo[car][vCarPlate], vInfo[car][vX], vInfo[car][vY], vInfo[car][vZ], vInfo[car][vA], vInfo[car][vColor1], vInfo[car][vColor2], car);
	mysql_tquery(handle, query, "", "");
	return 1;
}

function securityCodeCheck(playerid) {
	cache_get_data(rows, fields, handle);
	if(rows) { SCM(playerid, COLOR_LIGHTRED, "You have entered the correct code, now you can play!"), enteredCode[playerid] = 1; }
	else ShowPlayerDialog(playerid, DIALOG_BLOCK, DIALOG_STYLE_PASSWORD, "SERVER: Account blocked", 
			""WHITE"You used a "DRED"incorrect code"WHITE", try again.\n\nTo unblock your account you need to use a security cod, sended to your email.\nYou have "CREM"2 minutes "WHITE"to use it.", "Proceed", "Cancel");
	return 1;
}

public OnPlayerSpawn(playerid) {
	if(Bit_Get(pLogged, playerid) == true) {
		SetPlayerHealth(playerid, 99.00);
		SetPlayerArmour(playerid, 00.00);
		SetPlayerSkin(playerid, pInfo[playerid][pSkin]);
		if(pInfo[playerid][pSpawn] == 0) {
			if(pInfo[playerid][pMember] == 0) {
				SetPlayerPos(playerid, 974.0515, -1285.1781, 13.5540), SetPlayerFacingAngle(playerid, 179.0847);
				SetPlayerInterior(playerid, 0), SetPlayerVirtualWorld(playerid, 0), SetCameraBehindPlayer(playerid);
			}
			else {
				new i = pInfo[playerid][pMember];
				SetPlayerPos(playerid, gInfo[i][giX], gInfo[i][giY], gInfo[i][giZ]);
				SetPlayerInterior(playerid, gInfo[i][gInterior]);
				SetPlayerVirtualWorld(playerid, i+1);
				SetCameraBehindPlayer(playerid);
			}
		}
		else {
			new h = pInfo[playerid][pHouseKey] + pInfo[playerid][pHouseRent];
			SetPlayerPos(playerid, hInfo[h][hiX], hInfo[h][hiY], hInfo[h][hiZ]);
			SetPlayerInterior(playerid, hInfo[h][hInterior]);
			SetPlayerVirtualWorld(playerid, h+1);
		}
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason) {
	if(examCar[playerid] != -1) {
		disableCP(playerid);
		DestroyVehicle(examCar[playerid]);
		examCar[playerid] = -1;
		SCM(playerid, COLOR_GREY, "(Server): "WHITE"You failed the exam because you died.");
		DisableRemoteVehicleCollisions(playerid, 0);
	}
	return 1;
}

public OnVehicleSpawn(vehicleid) {
	if(vInfo[vehID[vehicleid]][vID] > 0) {
		ChangeVehicleColor(vehicleid, vInfo[vehID[vehicleid]][vColor1],vInfo[vehID[vehicleid]][vColor2]);
		SetVehiclePos(vehicleid, vInfo[vehID[vehicleid]][vX], vInfo[vehID[vehicleid]][vY], vInfo[vehID[vehicleid]][vZ]);
		defer setVehicleZAngle(vehicleid);
	}
	return 1;
}

public OnVehicleDeath(vehicleid, killerid) {
	return 1;
}

public OnPlayerText(playerid, text[]) {
	format(gMsg, 128, "%s: %s", GetName(playerid), text);
	SendClientMessageToAll(-1, gMsg);
	SetPlayerChatBubble(playerid, text, COLOR_GREY, 10.0, 10000);
	return 0;
}
public OnPlayerCommandPerformed(playerid, cmdtext[], success) {
	if (success) return 1;
	if(!success) return SCMEx(playerid, COLOR_GREY, "(Server):"WHITE" This command (%s) does not exist.", cmdtext); 
	return 0;
}


YCMD:ah(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 1) return adminOnly(playerid, 1);
	SCM(playerid, COLOR_TEAL, "----------------------------- Admins Commands -----------------------------");
	SCM(playerid, -1, "Admin level 1: /a /vr /vehinfo /gotoveh /gotohq /gotopoint /fly /stopfly /mark /gotomark");
	SCM(playerid, -1, "Admin level 2: /moveveh");
	SCM(playerid, -1, "Admin level 3: /setleader /groupveh /modelveh /colorveh");
	SCM(playerid, -1, "Admin level 4: /sethqint /sethqext");
	SCM(playerid, -1, "Admin level 6: /addvehicle /setadmin ");
	SCM(playerid, COLOR_TEAL, "---------------------------------------------------------------------------");
	return 1;
}

YCMD:pset(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 3) return adminOnly(playerid, 3);
	if(sscanf(params, "us[30]i", para, strPara, para2)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/pset [playerid] [item] [value]"), SCM(playerid, -1, "Items: rank, group, money, bank (money), level");
	switch(YHash(strPara)) {
		case _H<rank>: {
			if(para2 < 0 || para2 > 7) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/pset [playerid] [rank] [0-7]");
			format(gMsg, 128, "/pset: Admin %s changed %s`s rank to %d.", GetName(playerid), GetName(para), para2), sendAdmins(COLOR_YELLOW, gMsg);
			SCMEx(para, COLOR_LORANGE, "Admin %s changed your rank to %d.", GetName(para), para2);
			pInfo[para][pRank] = para2;
		}
		case _H<group>: {
			if(gInfo[para2][gID] == 0 && para2 != 0) return SCM(playerid, COLOR_GREY, "Error: Invalid group id.");
			format(gMsg, 128, "/pset: Admin %s changed %s`s group to %s (id: %d).", GetName(playerid), GetName(para), gInfo[para2][gName], para2), sendAdmins(COLOR_YELLOW, gMsg);
			SCMEx(para, COLOR_LORANGE, "Admin %s changed your group to %s.", GetName(para), gInfo[para2][gName]);
			pInfo[para][pMember] = para2, pInfo[para][pRank] = (para2 == 0) ? (0) : (1);
		}
		case _H<money>: {
			format(gMsg, 128, "/pset: Admin %s changed %s`s money to $%s.", GetName(playerid), GetName(para), FormatNumber(para2)), sendAdmins(COLOR_YELLOW, gMsg);
			SCMEx(para, COLOR_LORANGE, "Admin %s changed your money to $%s.", GetName(para), FormatNumber(para2));
			SetMoney(playerid, para2);
		}
		case _H<bank>: {
			format(gMsg, 128, "/pset: Admin %s changed %s`s bank money to $%s.", GetName(playerid), GetName(para), FormatNumber(para2)), sendAdmins(COLOR_YELLOW, gMsg);
			SCMEx(para, COLOR_LORANGE, "Admin %s changed your bank money to $%s.", GetName(para), FormatNumber(para2));
			SetUpdate(para, playerInfo:pBank, "Bank", para2);
		}
		case _H<level>: {
			format(gMsg, 128, "/pset: Admin %s changed %s`s level to %d.", GetName(playerid), GetName(para), para2), sendAdmins(COLOR_YELLOW, gMsg);
			SCMEx(para, COLOR_LORANGE, "Admin %s changed your level to %d.", GetName(para), para2);
			SetPlayerScore(para, para2);
			SetUpdate(para, playerInfo:pLevel, "Level", para2);
			UpdateBar(playerid);
		}
		default: { SCM(playerid, COLOR_GREY, "Error: Wrong item."); }
	}
	return 1;
}

YCMD:createhouse(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 6) return adminOnly(playerid, 6);
	if(sscanf(params, "s[10]iii", strPara, para, para2, para3)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/createhouse [size] [interior] [level] [money]"), SCM(playerid, -1, "Sizes: big(0-8), medium(0-11), small(0-17)");
	new Float:x, Float:y, Float:z, i = houses+1, string[526];
	GetPlayerPos(playerid, x, y, z);
	switch(YHash(strPara)) {
		case _H<big>: {
			if(para < 0 || para > 8) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/createhouse [big] [0-8] [level] [money]");
			hInfo[i][hiX] = BigHouseInteriors[para][0];
			hInfo[i][hiY] = BigHouseInteriors[para][1];
			hInfo[i][hiZ] = BigHouseInteriors[para][2];
			hInfo[i][hInterior] = floatround(BigHouseInteriors[para][3]);
			format(hInfo[i][hSize], 10, "Big");
		}
		case _H<medium>: {
			if(para < 0 || para > 8) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/createhouse [medium] [0-11] [level] [money]");
			hInfo[i][hiX] = MediumHouseInteriors[para][0];
			hInfo[i][hiY] = MediumHouseInteriors[para][1];
			hInfo[i][hiZ] = MediumHouseInteriors[para][2];
			hInfo[i][hInterior] = floatround(MediumHouseInteriors[para][3]);
			format(hInfo[i][hSize], 10, "Medium");
		}
		case _H<small>: {
			if(para < 0 || para > 8) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/createhouse [small] [0-17] [level] [money]");
			hInfo[i][hiX] = SmallHouseInteriors[para][0];
			hInfo[i][hiY] = SmallHouseInteriors[para][1];
			hInfo[i][hiZ] = SmallHouseInteriors[para][2];
			hInfo[i][hInterior] = floatround(SmallHouseInteriors[para][3]);
			format(hInfo[i][hSize], 10, "Small");
		}
		default: return SCM(playerid, COLOR_GREY, "Error: Wrong item.");
	}
	hInfo[i][hID] = i;
	hInfo[i][heX] = x;
	hInfo[i][heY] = y;
	hInfo[i][heZ] = z;
	hInfo[i][hLevel] = para2;
	hInfo[i][hPrice] = para3;
	format(hInfo[i][hName], 50, "beleaua-rpg.ro");
	format(hInfo[i][hOwner], 25, "AdmBot");
	mysql_format(handle, string, sizeof(string), "INSERT INTO `houses` (`Size`, `eX`, `eY`, `eZ`, `iX`, `iY`, `iZ`, `Interior`, `Level`, `Price`) VALUES ('%e', '%f', '%f', '%f', '%f', '%f', '%f', '%d', '%d', '%d')",
	hInfo[i][hSize], hInfo[i][heX], hInfo[i][heY], hInfo[i][heZ], hInfo[i][hiX], hInfo[i][hiY], hInfo[i][hiZ], hInfo[i][hInterior], hInfo[i][hLevel], hInfo[i][hPrice]);
	mysql_pquery(handle, string, "", "");
	UpdateProperty(i);
	houses++;
	SCMEx(playerid, COLOR_YELLOW, "You created house %d, level: %d, price: %d.", i, hInfo[i][hLevel], hInfo[i][hPrice]);
	return 1;
}

YCMD:gotohouse(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 1) return adminOnly(playerid, 1);
	if(sscanf(params, "i", para)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/gotohouse [house id]");
	if(para > houses && para == 0) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"Wrong house id.");
	SetPlayerPos(playerid, hInfo[para][heX], hInfo[para][heY], hInfo[para][heZ]);
	SCMEx(playerid, COLOR_GREY, "(Server): "WHITE"You have been teleported to house %d.", para);
	return 1;
}

YCMD:findhouse(playerid, params[], help) {
	if(sscanf(params, "i", para)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/findhouse [house id]");
	if(para > houses && para == 0) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"Wrong house id.");
	SetPlayerCheckpointEx(playerid, hInfo[para][heX], hInfo[para][heY], hInfo[para][heZ], 2.0, 1337);
	return 1;
}

YCMD:interiors(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 1) return adminOnly(playerid, 1);
	ShowPlayerDialog(playerid, DIALOG_INTERIORS, DIALOG_STYLE_LIST, "House interiors:", "Big interiors\nMedium interiors\nSmall interiors", "Ok", "Cancel");
	return 1;
}

YCMD:movehouse(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 4) return adminOnly(playerid, 4);
	if(sscanf(params, "is[9]", para, strPara)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/movehouse [house id] [item]"), SCM(playerid, -1, "item: interior, exterior");
	if(para > houses && para == 0) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"Wrong house id.");
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	switch(YHash(strPara)) {
		case _H<interior>: {
			hUpdateFloat(para, "iX", x);
			hInfo[para][hiX] = x;
			hUpdateFloat(para, "iY", y);
			hInfo[para][hiY] = y;
			hUpdateFloat(para, "iZ", z);
			hInfo[para][hiZ] = z;
			hUpdate(para, houseInfo:hInterior, "Interior", GetPlayerInterior(playerid));
			UpdateProperty(para);
			SCM(playerid, COLOR_GREY, "(Server): "WHITE"You have changed house interior.");
		}
		case _H<exterior>: {
			hUpdateFloat(para, "eX", x);
			hInfo[para][heX] = x;
			hUpdateFloat(para, "eY", y);
			hInfo[para][heY] = y;
			hUpdateFloat(para, "eZ", z);
			hInfo[para][heZ] = z;
			UpdateProperty(para);
			SCM(playerid, COLOR_GREY, "(Server): "WHITE"You have changed house exterior.");
		}
		default: return SCM(playerid, COLOR_GREY, "Error: Wrong item.");
	}
	return 1;
}

YCMD:edithouse(playerid, params[], help) {
	new strg[50];
	if(pInfo[playerid][pAdmin] < 4) return adminOnly(playerid, 4);
	if(sscanf(params, "is[12]s[50]", para, strPara, strg)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/edithouse [house id] [item] [value]"), SCM(playerid, -1, "item: level, price, rent, lock, name");
	if(para > houses && para == 0) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"Wrong house id.");
	switch(YHash(strPara)) {
		case _H<level>: {
			hUpdate(para, houseInfo:hLevel, "Level", strval(strg));
		}
		case _H<price>: {
			hUpdate(para, houseInfo:hPrice, "Price", strval(strg));
		}
		case _H<rent>: {
			hUpdate(para, houseInfo:hRent, "Rent", strval(strg));
		}
		case _H<lock>: {
			if(strval(strg) < 0 || strval(strg) > 1) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"Wrong value, 0/1.");
			hUpdate(para, houseInfo:hLocked, "Locked", strval(strg));
		}
		case _H<name>: {
			hUpdateStr(para, houseInfo:hName, "Name", strg);
		}
	}
	UpdateProperty(para);
	SCMEx(playerid, COLOR_GREY, "(Server): "WHITE"You have changed succesfully edit house [id: %d].", para);
	return 1;
}

YCMD:buyhouse(playerid, params[], help) {
	new id;
	if(pInfo[playerid][pHouseRent] != 0) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You need to (/unrentroom) to buy a house.");
	if(pInfo[playerid][pHouseKey] != 0) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You can have only one house.");
	for(new i = 1; i < 50; i++) {
		if(IsPlayerInRangeOfPoint(playerid, 2.0, hInfo[i][heX], hInfo[i][heY], hInfo[i][heZ])) {
			if(hInfo[i][hPrice] == 0 || !strcmp(hInfo[i][hOwner], "AdmBot")) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"This house is not for sale.");
			if(GetPlayerMoney(playerid) < hInfo[i][hPrice]) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You have not enough money to buy this house.");
			if(pInfo[playerid][pLevel] < hInfo[i][hLevel]) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"Your level is to low to buy this house.");
			format(updatequery, 254, "SELECT * FROM `players` WHERE `HouseKey` = '%d' LIMIT 1", i);
			new Cache: houseresult = mysql_query(handle, updatequery);
			if(cache_get_row_count() > 0) {
				id = cache_get_field_content_int(0, "ID");
			}
			cache_delete(houseresult);
			foreach (new x : Player) {
				if(pInfo[x][pSQLID] == id){
					SCMEx(x, COLOR_GREY, "(Server): "WHITE"Someone just buy your house [ID:%d] for %s$.", i, FormatNumber(hInfo[i][hPrice]));
					SetUpdate(x, playerInfo:pHouseKey, "HouseKey", 0);
				}
			}
			mysql_format(handle, updatequery, 254, "UPDATE `players` SET `HouseKey` = '0' WHERE `ID` = '%d'", id);
			mysql_pquery(handle, updatequery, "", "");
			SetUpdate(playerid, playerInfo:pHouseKey, "HouseKey", i);
			hUpdateStr(i, houseInfo:hOwner, "Owner", GetName(playerid));
			UpdateProperty(i);
			SCMEx(playerid, COLOR_GREY, "(Server): "WHITE"Congratulations! You buy house %d for $%s.", i, FormatNumber(hInfo[i][hPrice]));
			UpdateMoney(playerid, -hInfo[i][hPrice]);
		}
	}
	return 1;
}

YCMD:sellhousetostate(playerid, params[], help) {
	if(pInfo[playerid][pHouseKey] == 0) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You have not a house.");
	format(updatequery, sizeof(updatequery), "Do you want to sell your house (ID: %d) to state for $%d ?", pInfo[playerid][pHouseKey], houseValue(pInfo[playerid][pHouseKey]));
	ShowPlayerDialog(playerid, DIALOG_SELLHOUSETOSTATE, DIALOG_STYLE_MSGBOX, "Sell house to state:", updatequery, "Yes", "No");
	return 1;
}

YCMD:rentroom(playerid, params[], help) {
	if(pInfo[playerid][pHouseKey] != 0) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You have a house.");
	for(new i = 1; i < 50; i++) {
		if(IsPlayerInRangeOfPoint(playerid, 2.0, hInfo[i][heX], hInfo[i][heY], hInfo[i][heZ])) {
			if(pInfo[playerid][pHouseRent] != 0) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You need first to (/unrentroom) to rent a room in this house.");
			SetUpdate(playerid, playerInfo:pHouseRent, "HouseRent", i);
			SCM(playerid, COLOR_GREY, "(Server): "WHITE"Congratulations! You rent a room.");
		}
	}	
	return 1;
}

YCMD:unrentroom(playerid, params[], help) {
	if(pInfo[playerid][pHouseRent] == 0) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You don't have rent a room.");
	SetUpdate(playerid, playerInfo:pHouseRent, "HouseRent", 0);
	SCM(playerid, COLOR_GREY, "(Server): "WHITE"You unrent your room.");
	return 1;
}

YCMD:spawnchange(playerid, params[], help) {
	if(pInfo[playerid][pHouseKey] + pInfo[playerid][pHouseRent] == 0) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You can't change your spawn because you have not a house");
	for(new i = 0; i <= 5; i++) { PlayerTextDrawShow(playerid, SpawnChange[i]); }
	SelectTextDraw(playerid, 0xA3B4C5FF);
	return 1;
}

YCMD:housemenu(playerid, params[], help) {
	if(pInfo[playerid][pHouseKey] == 0) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You don't have a house.");
	ShowPlayerDialog(playerid, DIALOG_HOUSEMENU, DIALOG_STYLE_LIST, "House menu:", "House details\nChange house name\nChange house rent\nChange house price\nLock/Unlock house\nShow online renters", "Select", "Cancel");
	return 1;
}

YCMD:vr(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 1) return adminOnly(playerid, 1);
	if(IsPlayerInAnyVehicle(playerid)) {
		SetVehicleToRespawn(GetPlayerVehicleID(playerid));
		SCMEx(playerid, -1, ""NON"You succesfull respawned vehicle #%d.", GetPlayerVehicleID(playerid));
	}
	else {
		if(sscanf(params, "i", para)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/vr [vehicle id]");
		SetVehicleToRespawn(para);
		SCMEx(playerid, -1, ""NON"You succesfull respawned vehicle #%d.", para);
	}
	return 1;
}

YCMD:addvehicle(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 6) return adminOnly(playerid, 6);
	new str[284], Cache:cache_i;
	if(GetPVarInt(playerid, "AddVehicle") > 0) {
		new Float:x, Float:y, Float:z, Float:a;
		GetVehiclePos(GetPVarInt(playerid, "AddVehicle"), x, y, z), GetVehicleZAngle(GetPVarInt(playerid, "AddVehicle"), a);
		mysql_format(handle, str, 284, "INSERT INTO `cars` (`Model`, `Group`, `CarPlate`, `pX`, `pY`, `pZ`, `pA`, `Color1`, `Color2`) VALUES ('%d', '0', 'Null', '%f', '%f', '%f', '%f', '-1', '-1')", GetVehicleModel(GetPVarInt(playerid, "AddVehicle")), x, y, z, a);
		cache_i = mysql_query(handle, str);
		
		new id = cache_insert_id();
		GetVehiclePos(GetPVarInt(playerid, "AddVehicle"), x, y, z), GetVehicleZAngle(GetPVarInt(playerid, "AddVehicle"), a);
		vInfo[id][vID] = id;
		vInfo[id][vModel] = GetVehicleModel(GetPVarInt(playerid, "AddVehicle"));
		vInfo[id][vX] = x, vInfo[id][vY] = y, vInfo[id][vZ] = z, vInfo[id][vA] = a;
		vInfo[id][vGroup] = 0;
		vInfo[id][vColor1] = vInfo[id][vColor2] = -1;
		format(vInfo[id][vCarPlate], 11, "Null");
		vehID[GetPVarInt(playerid, "AddVehicle")] = id;
		SetVehicleToRespawn(GetPVarInt(playerid, "AddVehicle")), DeletePVar(playerid, "AddVehicle");
		cache_delete(cache_i);
		format(str, 100, ""ORANGE"/addvehicle: Admin %s added a new vehicle on server.", GetName(playerid));
		sendAdmins(COLOR_WHITE, str);
	}
	else {
		if(IsPlayerInAnyVehicle(playerid)) return SCM(playerid, COLOR_GREY, "You can use this command because you are in a vehicle.");
		if(sscanf(params, "i", para)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/addvehicle [model]"); 
		if(para < 400 || para > 612) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/addvehicle [400-612]"); 
		
		new Float:x, Float:y, Float:z, Float:a;
		GetPlayerPos(playerid, x, y, z), GetPlayerFacingAngle(playerid, a);
		new vehicle = CreateVehicle(para,x, y, z, a, -1, -1, -1);
		PutPlayerInVehicle(playerid, vehicle, 0);
		SetPVarInt(playerid, "AddVehicle", vehicle);
	}
	return 1;
}

YCMD:colorveh(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 3) return adminOnly(playerid, 3);
	if(sscanf(params, "ii", para, para2)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/colorveh [color 1] [color 2]"); 
	new i = GetPlayerVehicleID(playerid);
	if(i) { 
		if((para < 0 || para > 256) || (para2 < 0 || para2 > 256)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/colorveh [color 1] [color 2]"); 
		vInfo[vehID[i]][vColor1] = para, vInfo[vehID[i]][vColor2] = para2;
		ChangeVehicleColor(i, para, para2);
		SCMEx(playerid, -1, ""NON"You succesfull changed vehicle colors to %d and %d (for vehicle #%d).", para, para2, i);
	}
	else SCM(playerid, -1, "You are not in a vehicle.");
	return 1;
}

YCMD:modelveh(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 3) return adminOnly(playerid, 3);
	if(sscanf(params, "i", para)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/modelveh [model]"); 
	new i = GetPlayerVehicleID(playerid);
	if(i) { 
		if(para < 400 || para > 612) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/modelveh [400-612]"); 
		vInfo[vehID[i]][vModel] = para;
		DestroyVehicle(i);
		i = CreateVehicle(vInfo[vehID[i]][vModel], vInfo[vehID[i]][vX], vInfo[vehID[i]][vY], vInfo[vehID[i]][vZ], vInfo[vehID[i]][vA], vInfo[vehID[i]][vColor1], vInfo[vehID[i]][vColor2], -1);
		PutPlayerInVehicle(playerid, i, 0);
		SCMEx(playerid, -1, ""NON"You succesfull changed vehicle model (for vehicle #%d).", i);
	}
	else SCM(playerid, -1, "You are not in a vehicle.");
	return 1;
}

YCMD:groupveh(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 3) return adminOnly(playerid, 3);
	new veh = GetPlayerVehicleID(playerid);
	if(veh) { 
		if(sscanf(params, "i", para)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/groupveh [group id]"); 
		if(gInfo[para][gID] == 0) return SCM(playerid, COLOR_GREY, "Error: Invalid group id.");
		vInfo[vehID[veh]][vGroup] = para;
		SetVehicleToRespawn(veh);
		SCMEx(playerid, COLOR_NON, "Now, this %s (id: %d) its %s`s vehicle.", vehName[GetVehicleModel(veh) - 400], veh, gInfo[para][gName]);
	}
	else SCM(playerid, -1, "You are not in a vehicle.");
	return 1;
}

YCMD:moveveh(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 2) return adminOnly(playerid, 2);
	new veh = GetPlayerVehicleID(playerid);
	if(veh) { 
		GetVehiclePos(veh, vInfo[vehID[veh]][vX], vInfo[vehID[veh]][vY], vInfo[vehID[veh]][vZ]);
		GetVehicleZAngle(veh, vInfo[vehID[veh]][vA]);
		SetVehicleToRespawn(veh);
		SCMEx(playerid, COLOR_NON, "You succesfull moved this %s (id: %d)!", vehName[GetVehicleModel(veh) - 400], veh);
	}
	else SCM(playerid, -1, "You are not in a vehicle.");
	return 1;
}

YCMD:vehinfo(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 1) return adminOnly(playerid, 1);
	if(sscanf(params, "i", para)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/vehinfo [veh id]");
	SCMEx(playerid, COLOR_GREY, "Model: "WHITE"%d | "GREY"Carplate: "WHITE"%s | "GREY"Group: "WHITE"%d | "GREY"Colors: "WHITE"%d, %d",
	vInfo[vehID[para]][vModel], vInfo[vehID[para]][vCarPlate], vInfo[vehID[para]][vGroup], vInfo[vehID[para]][vColor1], vInfo[vehID[para]][vColor2]);
	return 1;
}

YCMD:fly(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 1) return adminOnly(playerid, 1);
	StartFly(playerid), SetPlayerHealth(playerid, 999999.00);
	Bit_Set(flyingStatus, playerid, true);
	return 1;
}

YCMD:stopfly(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 1) return adminOnly(playerid, 1);
	StopFly(playerid), SetPlayerHealth(playerid, 99.00);
	Bit_Set(flyingStatus, playerid, false);
	return 1;
}

YCMD:mark(playerid, params[], help) {
	new Float:x, Float:y, Float:z;
	if(pInfo[playerid][pAdmin] < 1) return adminOnly(playerid, 1);
	GetPlayerPos(playerid, Float:x, Float:y, Float:z);
	playerMark[playerid][0] = x;
	playerMark[playerid][1] = y;
	playerMark[playerid][2] = z;
	SendClientMessage(playerid, COLOR_GREY, "(Server): "WHITE"Your point has been set.");
	return 1;
}

YCMD:gotomark(playerid, params[], help) {
	if(playerMark[playerid][0] == 0 && playerMark[playerid][1] == 0 && playerMark[playerid][2] == 0) return SendClientMessage(playerid, COLOR_GREY, "You don't have a mark.");
	SetPlayerPos(playerid, playerMark[playerid][0], playerMark[playerid][1], playerMark[playerid][2]);
	SendClientMessage(playerid, COLOR_GREY, "(Server): "WHITE"You have been teleported to mark.");
	return 1;
}

YCMD:gotoveh(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 1) return adminOnly(playerid, 1);
	if(sscanf(params, "i", para)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/gotoveh [vehicle id]");
	new Float:x, Float:y, Float:z;
	GetVehiclePos(para, Float:x, Float:y, Float:z), SetPlayerPos(playerid, x, y, z+5), SetPlayerVirtualWorld(playerid, GetVehicleVirtualWorld(para));
	return 1;
}

YCMD:gotopoint(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 1) return adminOnly(playerid, 1);
	new Float:x, Float:y, Float:z;
	if(sscanf(params, "fffi", x, y, z, para)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/gotopoint [x] [y] [z] [interior]");
	SetPlayerPos(playerid, x, y, z), SetPlayerInterior(playerid, para), SetCameraBehindPlayer(playerid);
	return 1;
}

YCMD:gotohq(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 1) return adminOnly(playerid, 1);
	if(sscanf(params, "i", para)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/gotohq [id]");
	SetPlayerPos(playerid, gInfo[para][geX], gInfo[para][geY], gInfo[para][geZ]);
	SetPlayerInterior(playerid, 0);
	SetCameraBehindPlayer(playerid);
	SCMEx(playerid, -1, "You have teleported to %s`s headquarter.", gInfo[para][gName]);
	return 1;
}

YCMD:setadmin(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 6) return adminOnly(playerid, 6);
	if(sscanf(params, "ui", para, para2)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/setadmin [playerid] [level]");
	if(para == INVALID_PLAYER_ID) return SCM(playerid, COLOR_GREY, "Error: Invalid player id.");
	if(pInfo[para][pAdmin] < para2) { SCMEx(para, -1, ""NON"Congratulations! You have been promoted to admin level %d, by %s", para2, GetName(playerid)); } 
	else if(pInfo[para][pAdmin] > para2 && para2 != 0) { SCMEx(para, -1, ""NON"You have been demoted to admin level %d, by %s", para2, GetName(playerid)); }
	else { SCMEx(para, -1, ""NON"You have been removed from Staff Team (administrators), by %s", GetName(para)); }
	
	// iterators
	if(pInfo[para][pAdmin] == 0 && para2 > 0) { Iter_Add(Admins, para); }
	else if(pInfo[para][pAdmin] > 0 && para2 == 0) { Iter_Remove(Admins, para); }
	
	pInfo[para][pAdmin] = para2;
	SCMEx(playerid, -1, "You have changed %s`s admin level to %d.", GetName(para), para2);
	return 1;
}

YCMD:respawn(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 1) return adminOnly(playerid, 1);
	if(sscanf(params, "u", para)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/respawn [playerid]");
	if(para == INVALID_PLAYER_ID) return SCM(playerid, COLOR_GREY, "Error: Invalid player id.");
	SpawnPlayer(para);
	SCMEx(playerid, COLOR_WHITE, "You respawned %s", GetName(para));
	SCMEx(para, COLOR_WHITE, "You have been respawned by %s", GetName(playerid));
	return 1;
}

YCMD:sethqext(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 4) return adminOnly(playerid, 4);
	if(sscanf(params, "i", para)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/sethqext [group id]");
	if(gInfo[para][gID] == 0) return SCM(playerid, COLOR_GREY, "Error: Invalid group ID.");
			
	GetPlayerPos(playerid, gInfo[para][geX], gInfo[para][geY], gInfo[para][geZ]);
	DestroyDynamicPickup(gInfo[para][gPickup]);
	DestroyDynamic3DTextLabel(gInfo[para][gLabel]);
	format(gMsg, 128, "{FF6347}%s`s HQ\n{D2B48C}(%s)", gInfo[para][gName], (gInfo[para][gDoor]) ? ("closed") : ("opened"));
	new pickup;
	if(gInfo[para][gType] == 1) { pickup = 1247; }
	else if(gInfo[para][gType] == 2) { pickup = 1254; }
	else { pickup = 1239; }
			
	gInfo[para][gPickup] = CreateDynamicPickup(pickup, 1, gInfo[para][geX], gInfo[para][geY], gInfo[para][geZ], -1, -1, -1, 20.0);
	gInfo[para][gLabel] = CreateDynamic3DTextLabel(gMsg, COLOR_YELLOW, gInfo[para][geX], gInfo[para][geY], gInfo[para][geZ], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
			
	SCMEx(playerid, COLOR_GREY, "(Server): "WHITE"The exterior of %s (#%d) was changed successfully.", gInfo[para][gName], para);
	saveGroup(para);
	return 1;
}

YCMD:sethqint(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 4) return adminOnly(playerid, 4);
	if(sscanf(params, "i", para)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/sethqint [group id]");
	if(gInfo[para][gID] == 0) return SCM(playerid, COLOR_GREY, "Error: Invalid group ID.");
			
	GetPlayerPos(playerid, gInfo[para][giX], gInfo[para][giY], gInfo[para][giZ]), gInfo[para][gInterior] = GetPlayerInterior(playerid);
	SCMEx(playerid, COLOR_GREY, "(Server): "WHITE"The interior of %s (#%d) was changed successfully.", gInfo[para][gName], para);
	saveGroup(para);
	return 1;
}
YCMD:auninvite(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 2) return adminOnly(playerid, 2);
	if(sscanf(params, "us[30]", para, strPara)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/auninvite [playerid] [reason: max 30 characters]");
	if(para == INVALID_PLAYER_ID) return SCM(playerid, COLOR_GREY, "Error: Invalid player id.");
	if(pInfo[para][pMember] == 0) return SCM(playerid, COLOR_GREY, "You can not use this command on civilians.");
	
	format(gMsg, 128, "%s was uninvited by Admin %s from %s, reason: %s", GetName(para), GetName(playerid), gInfo[pInfo[para][pMember]][gName], strPara);
	sendGroup(COLOR_LIGHTBLUE, pInfo[para][pMember], gMsg);
	format(gMsg, 128, "Admin uninvite: %s was uninvited by Admin %s from %s, reason: %s", GetName(para), GetName(playerid), gInfo[pInfo[playerid][pMember]][gName], strPara);
	sendAdmins(COLOR_DRED, gMsg);
	format(gMsg, 128, "You got uninvited by Admin %s from %s, reason: %s", GetName(playerid), gInfo[pInfo[playerid][pMember]][gName], strPara);
	ShowPlayerDialog(para, DIALOG_GENERAL, DIALOG_STYLE_MSGBOX, "SERVER: Uninvite", gMsg, "Close", "");
	SetPlayerSkin(para, SPAWN_SKIN);
	SetUpdate(para, playerInfo:pMember, "Member", 0);
	SetUpdate(para, playerInfo:pRank, "Rank", 0);
	SetUpdate(para, playerInfo:pSkin, "Skin", SPAWN_SKIN);
	return 1;
}
YCMD:setleader(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 3) return adminOnly(playerid, 3);
	new p;
	if(sscanf(params, "ui", p, para)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/setleader [playerid] [group id]");
	if(p == INVALID_PLAYER_ID) return SCM(playerid, COLOR_GREY, "Error: Invalid player id.");
	if(pInfo[p][pMember] > 0) return SCM(playerid, COLOR_GREY, "This player is already in a faction, you need to use /auninvite first.");
	if(gInfo[para][gID] == 0 && para != 0) return SCM(playerid, COLOR_GREY, "Error: Invalid group id.");
	SCMEx(playerid, -1, "You have set %s`s leader to %s.", GetName(p), gInfo[para][gName]), SCMEx(p, -1, ""NON"You have been promoted to %s`s leader by %s. Good job!", gInfo[para][gName], GetName(playerid));
	SetPlayerSkin(p, gInfo[para][gLeadskin]);
	SetUpdate(p, playerInfo:pMember, "Member", para);
	SetUpdate(p, playerInfo:pRank, "Rank", 7);
	SetUpdate(p, playerInfo:pSkin, "Skin", gInfo[para][gLeadskin]);
	return 1;
}

YCMD:a(playerid, params[], help) {
	if(pInfo[playerid][pAdmin] < 1) return adminOnly(playerid, 1);
	if(isnull(params)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/a [message]");
	format(gMsg, 128, "(/a) %s: %s", GetName(playerid), params);
	sendAdmins(COLOR_ACHAT, gMsg);
	return 1;
}

YCMD:invite(playerid, params[], help) {
	if(pInfo[playerid][pRank] < 6 || pInfo[playerid][pMember] == 0) return SCM(playerid, COLOR_GREY, "You are not allowed to use this command.");
	if(sscanf(params, "u", para)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/invite [playerid]");
	if(para == INVALID_PLAYER_ID) return SCM(playerid, COLOR_GREY, "Error: Invalid player id.");
	if(para == playerid) return SCM(playerid, COLOR_GREY, "You can not invite yourself.");
	if(pInfo[para][pMember] > 0) return SCM(playerid, COLOR_GREY, "You can invite in your group only civilians.");
	if(GetPVarInt(para, "inviteGroup") == pInfo[playerid][pMember]) return SCM(playerid, COLOR_GREY, "This player is already invited to your group.");
	SetPVarInt(para, "inviteGroup", pInfo[playerid][pMember]), SetPVarString(para, "inviteName", pInfo[playerid][pName]);
	SCMEx(playerid, COLOR_NON, "%s was invited, please wait...", GetName(para));
	SCMEx(para, COLOR_NON, "You have been invited by %s to join in %s. Type /accept invite to accept.", GetName(playerid), gInfo[pInfo[playerid][pMember]][gName]);
	return 1;
}

YCMD:admins(playerid, params[], help) {
	SCM(playerid, COLOR_TEAL, "---------------------------------------------------------");
	foreach(new i : Admins)
	{
		SCMEx(playerid, -1, "(%d) %s - admin level %d", i, GetName(i), pInfo[i][pAdmin]);
	}
	SCMEx(playerid, -1, "There are %d %s online. If you have a problem, use report.", Iter_Count(Admins), (Iter_Count(Admins) == 1) ? ("admin") : ("admins"));
	SCM(playerid, COLOR_TEAL, "---------------------------------------------------------");
	return 1;
}

YCMD:accept(playerid, params[], help) {
	if(sscanf(params, "s[30]", strPara)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/accept [item]"), SCM(playerid, -1, "Items: invite");
	switch(YHash(strPara)) {
		case _H<invite>: {
			if(GetPVarInt(playerid, "inviteGroup") == 0) return SCM(playerid, COLOR_GREY, "You haven`t been invited in any group.");
			new name[MAX_PLAYER_NAME];
			SetPlayerSkin(playerid, gInfo[pInfo[playerid][pMember]][gLeadskin]);
			SetUpdate(playerid, playerInfo:pSkin, "Skin", gInfo[pInfo[playerid][pMember]][gLeadskin]);
			SetUpdate(playerid, playerInfo:pMember, "Member", GetPVarInt(playerid, "inviteGroup"));
			SetUpdate(playerid, playerInfo:pRank, "Rank", 1);
			format(gMsg, 128, "%s is now your teammate, invited by %s.", GetName(playerid), GetPVarString(playerid, "inviteName", name, MAX_PLAYER_NAME));
			sendGroup(COLOR_LIGHTBLUE, pInfo[playerid][pMember], gMsg);
			format(gMsg, 128, "Congratulations! Now you are %s`s member.", gInfo[pInfo[playerid][pMember]][gName]);
			ShowPlayerDialog(playerid, DIALOG_GENERAL, DIALOG_STYLE_MSGBOX, "SERVER: Invitation", gMsg, "Close", "");
			DeletePVar(playerid, "inviteName"), DeletePVar(playerid, "inviteGroup");
		}
		default: {
			SCM(playerid, COLOR_GREY, "Error: Wrong item.");
		}
	}
	return 1;
}

YCMD:f(playerid, params[], help) {
	if(pInfo[playerid][pMember] && (gInfo[pInfo[playerid][pMember]][gType] == 3 || gInfo[pInfo[playerid][pMember]][gType] == 2)) {
		if(isnull(params)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/f(action) [message]");
		switch(pInfo[playerid][pRank]) { 
			case 1: format(gMsg, 128, "* %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname1], GetName(playerid), params); case 2: format(gMsg, 128, "* %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname2], GetName(playerid), params); case 3: format(gMsg, 128, "* %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname3], GetName(playerid), params); 
			case 4: format(gMsg, 128, "* %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname4], GetName(playerid), params); case 5: format(gMsg, 128, "* %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname5], GetName(playerid), params); case 6: format(gMsg, 128, "{1BA6C2}* %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname6], GetName(playerid), params); 
			case 7: format(gMsg, 128, "{1BA6C2}* %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname7], GetName(playerid), params); 
		}
		sendGroup(COLOR_FCHAT, pInfo[playerid][pMember], gMsg);
	}
	else SendClientMessage(playerid, COLOR_GREY, "Invalid group chat!");
	return 1;
}

YCMD:r(playerid, params[], help) {
	if(pInfo[playerid][pMember] && gInfo[pInfo[playerid][pMember]][gType] == 1) {
		if(isnull(params)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/r(adio) [message]");
		switch(pInfo[playerid][pRank]) { 
			case 1: format(gMsg, 128, "* %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname1], GetName(playerid), params); case 2: format(gMsg, 128, "* %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname2], GetName(playerid), params); case 3: format(gMsg, 128, "* %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname3], GetName(playerid), params); 
			case 4: format(gMsg, 128, "* %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname4], GetName(playerid), params); case 5: format(gMsg, 128, "* %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname5], GetName(playerid), params); case 6: format(gMsg, 128, "* %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname6], GetName(playerid), params); 
			case 7: format(gMsg, 128, "* %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname7], GetName(playerid), params); 
		}
		sendGroup(COLOR_RCHAT, pInfo[playerid][pMember], gMsg);
	}
	else SendClientMessage(playerid, COLOR_GREY, "Invalid group chat!");
	return 1;
}

YCMD:d(playerid, params[], help) {
	if(pInfo[playerid][pMember] && gInfo[pInfo[playerid][pMember]][gType] == 1) {
		if(isnull(params)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"/d(epartments) [message]");
		switch(pInfo[playerid][pRank]) { 
			case 1: format(gMsg, 128, "** %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname1], GetName(playerid), params); case 2: format(gMsg, 128, "** %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname2], GetName(playerid), params); case 3: format(gMsg, 128, "** %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname3], GetName(playerid), params); 
			case 4: format(gMsg, 128, "** %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname4], GetName(playerid), params); case 5: format(gMsg, 128, "** %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname5], GetName(playerid), params); case 6: format(gMsg, 128, "** %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname6], GetName(playerid), params); 
			case 7: format(gMsg, 128, "** %s %s: %s", gInfo[pInfo[playerid][pMember]][gRankname7], GetName(playerid), params); 
		}
		sendgType(COLOR_DCHAT, gInfo[pInfo[playerid][pMember]][gType], gMsg);
	}
	else SendClientMessage(playerid, COLOR_GREY, "Invalid group chat!");
	return 1;
}

YCMD:stats(playerid, params[], help) {
	showStats(playerid, playerid);
	return 1;
}


YCMD:exam(playerid, params[], help) {
	if(IsPlayerInAnyVehicle(playerid)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You can't use this command when you are in a car.");
	new lights, alarm, doors, bonnet, boot, objective;
	if(IsPlayerInRangeOfPoint(playerid, 5.0, 1020.3734, -1363.3644, 13.5558)) {
		if(pInfo[playerid][pCarLic] > 0) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You have already driving license.");
		examCar[playerid] = AddStaticVehicle(560, 1008.6274, -1358.0985, 13.4326, 359.8185, random(100), random(100));
		disableCP(playerid);
		CP[playerid] = 1;
		SetPlayerRaceCheckpoint(playerid, 0, 1008.7606, -1321.0334, 13.4751, 941.2776, -1320.2727, 13.4829, 4.0);
	}
	else if(IsPlayerInRangeOfPoint(playerid, 5.0, 1957.3932, -2183.6255, 13.5469)) {
		if(pInfo[playerid][pFlyLic] > 0) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You have already fly license.");
		examCar[playerid] = AddStaticVehicle(487, 2067.6941, -2542.9915, 13.7235, 86.0253, random(100), random(100));
		disableCP(playerid);
		CP[playerid] = 100;
		SetPlayerRaceCheckpoint(playerid, 3, 1886.1248, -2539.5283, 94.7035, 1495.4569, -2315.8523, 89.6612, 4.0);
	}
	else if(IsPlayerInRangeOfPoint(playerid, 5.0, 723.2545, -1493.4685, 1.9343)) {
		if(pInfo[playerid][pBoatLic] > 0) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You have already boat license.");
		examCar[playerid] = AddStaticVehicle(473, 723.7279, -1502.4417, -0.2659, 181.6384, random(100), random(100));
		disableCP(playerid);
		CP[playerid] = 200;
		SetPlayerRaceCheckpoint(playerid, 3, 725.6168, -1654.2576, -0.2844, 723.3669, -1884.9502, -0.3983, 4.0);
	}
	else return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You are not at one of license center.");
	PutPlayerInVehicle(playerid, examCar[playerid], 0);
	DisableRemoteVehicleCollisions(playerid, 1);
	SetVehicleParamsEx(examCar[playerid], VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);
	SCM(playerid, COLOR_GREY, "(Server): "WHITE"The exam has begun, go to the checkpoint. Type /engine or press key 2 to start the engine.");
	return 1;
}

YCMD:taketest(playerid, params[], help) {
	if(IsPlayerInAnyVehicle(playerid)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You can't use this command when you are in a car.");
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, 1796.3507, -1146.9712, 23.8556)) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You are not at gun license center.");
	if(pInfo[playerid][pGunLic] > 0) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You have already gun license.");
	ShowPlayerDialog(playerid, DIALOG_GUNLIC, DIALOG_STYLE_MSGBOX, "Gun License tutorial:", ""WHITE"Hi, I'm your instructor and I will give you some informations.\n\nRule 1:\nYou can deathmatch only on cops and in gang wars.\n\nRule 2:\n You can't deathmatch in safezones.\n\nRule 3:\n If you don't follow the rules you will be ajailed by an admin.", "Test", "Cancel");
	SetPlayerVirtualWorld(playerid, playerid+1);
	return 1;
}

YCMD:engine(playerid, params[], help) {
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;
	new car = GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective, string[125];
	if(IsABike(car)) return 1;
	GetVehicleParamsEx(car, engine, lights, alarm, doors, bonnet, boot, objective);
	if(engine == 0) {SetVehicleParamsEx(car, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective); format(string, 125, "%s has turn on engine of his %s.", GetName(playerid), vehName[GetVehicleModel(car) - 400]); ProxDetector(10.0, playerid, string, COLOR_PURPLE);}
	if(engine == 1) {SetVehicleParamsEx(car, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective); format(string, 125, "%s has turn of engine of his %s.", GetName(playerid), vehName[GetVehicleModel(car) - 400]); ProxDetector(10.0, playerid, string, COLOR_PURPLE);}
	return 1;
}

YCMD:licenses(playerid, params[], help) {
	new string[75], fullstring[562];
	format(string, sizeof(string), ""WHITE"Driving license: %s - %d hours\n", (pInfo[playerid][pCarLic] == 0) ? (""RED"Expired") : (""GREEN"Passed"), pInfo[playerid][pCarLic]);
	strcat(fullstring, string);
	format(string, sizeof(string), ""WHITE"Fly license: %s - %d hours\n", (pInfo[playerid][pFlyLic] == 0) ? (""RED"Expired") : (""GREEN"Passed"), pInfo[playerid][pFlyLic]);
	strcat(fullstring, string);
	format(string, sizeof(string), ""WHITE"Boat license: %s - %d hours\n", (pInfo[playerid][pBoatLic] == 0) ? (""RED"Expired") : (""GREEN"Passed"), pInfo[playerid][pBoatLic]);
	strcat(fullstring, string);
	format(string, sizeof(string), ""WHITE"Gun license: %s - %d hours", (pInfo[playerid][pGunLic] == 0) ? (""RED"Expired") : (""GREEN"Passed"), pInfo[playerid][pGunLic]);
	strcat(fullstring, string);
	ShowPlayerDialog(playerid, DIALOG_NULL, DIALOG_STYLE_MSGBOX, "Your licenses:", fullstring, "OK", "");
	return 1;
}

YCMD:buylevel(playerid, params[], help) {
	if(pInfo[playerid][pRespect] < pInfo[playerid][pLevel]*2) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You don't have enough respect to level up.");
	SetUpdate(playerid, playerInfo:pLevel, "Level", pInfo[playerid][pLevel]+1);
	SetUpdate(playerid, playerInfo:pRespect, "Respect", pInfo[playerid][pRespect]-pInfo[playerid][pLevel]*2);
	SCMEx(playerid, COLOR_GREY, "(Server): "WHITE"Congratulations, you have level %d now!", pInfo[playerid][pLevel]);
	SetPlayerScore(playerid, pInfo[playerid][pLevel]);
	UpdateBar(playerid);
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
	if((vInfo[vehID[vehicleid]][vGroup] > 0 && pInfo[playerid][pMember] != vInfo[vehID[vehicleid]][vGroup])  && pInfo[playerid][pAdmin] == 0) {
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z), SetPlayerPos(playerid, x, y, z+2);
		SCMEx(playerid, COLOR_GREY, "This %s can be used only be %s`s members!", vehName[GetVehicleModel(vehicleid) - 400], gInfo[vInfo[vehID[vehicleid]][vGroup]][gName]);
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
	if(vehicleid == examCar[playerid]) {
		disableCP(playerid);
		DestroyVehicle(examCar[playerid]);
		examCar[playerid] = -1;
		SCM(playerid, COLOR_GREY, "(Server): "WHITE"You failed the exam because you left the car.");
		DisableRemoteVehicleCollisions(playerid, 0);
	}
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate) {
	new veh = GetPlayerVehicleID(playerid);
	new Float:x, Float:y, Float:z;
	if(newstate == PLAYER_STATE_DRIVER) {
		new vehicleName[30], rand = random(3);
		if(IsAPlane(veh) && pInfo[playerid][pFlyLic] == 0 && examCar[playerid] == -1) {
			GetPlayerPos(playerid, x, y, z), SetPlayerPos(playerid, x, y, z+2);
			SCMEx(playerid, COLOR_GREY, "(Server): "WHITE"You don't have fly licence, go to fly license center.");
		}
		else if(IsABoat(veh) && pInfo[playerid][pBoatLic] == 0 && examCar[playerid] == -1) {
			GetPlayerPos(playerid, x, y, z), SetPlayerPos(playerid, x, y, z+2);
			SCMEx(playerid, COLOR_GREY, "(Server): "WHITE"You don't have boat licence, go to boat license center.");
		}
		else if(pInfo[playerid][pCarLic] == 0 && examCar[playerid] == -1) {
			GetPlayerPos(playerid, x, y, z), SetPlayerPos(playerid, x, y, z+2);
			SCMEx(playerid, COLOR_GREY, "(Server): "WHITE"You don't have car licence, go to DMV.");
		}
		switch(rand) {
			case 0: { format(vehicleName, 30, "~g~%s", vehName[GetVehicleModel(veh) - 400]); }
			case 1: { format(vehicleName, 30, "~y~%s", vehName[GetVehicleModel(veh) - 400]); }
			case 2: { format(vehicleName, 30, "~r~~h~%s", vehName[GetVehicleModel(veh) - 400]); }
		}
		GameTextForPlayer(playerid, vehicleName, 3000, 1);

		
		if((vInfo[vehID[veh]][vGroup] > 0 && pInfo[playerid][pMember] != vInfo[vehID[veh]][vGroup])  && pInfo[playerid][pAdmin] == 0) {
			GetPlayerPos(playerid, x, y, z), SetPlayerPos(playerid, x, y, z+2);
			SCMEx(playerid, COLOR_GREY, "This %s can be used only be %s`s members!", vehName[GetVehicleModel(veh) - 400], gInfo[vInfo[vehID[veh]][vGroup]][gName]);
		}
	}
	if(newstate != PLAYER_STATE_DRIVER && GetPVarInt(playerid, "AddVehicle") > 0 && veh != GetPVarInt(playerid, "AddVehicle")) {
		DestroyVehicle(GetPVarInt(playerid, "AddVehicle"));
		SCMEx(playerid, COLOR_LIGHTRED, "Vehicle #%d was destroyed because you left it.", GetPVarInt(playerid, "AddVehicle")), DeletePVar(playerid, "AddVehicle");
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
	switch(CP[playerid]) {
		case 1337: disableCP(playerid), SCM(playerid, COLOR_GREY, "(Server):"WHITE"You have reached your destination.");
	}
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid) {
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid) {
	switch(CP[playerid]) {
		case 1: {disableCP(playerid); SetPlayerRaceCheckpoint(playerid, 0, 941.2776, -1320.2727, 13.4829, 799.7684, -1305.4069, 13.4752, 4.0); CP[playerid] = 2;}
		case 2: {disableCP(playerid); SetPlayerRaceCheckpoint(playerid, 0, 799.7684, -1305.4069, 13.4752, 810.6096, -1149.0100, 23.9497, 4.0); CP[playerid] = 3;}
		case 3: {disableCP(playerid); SetPlayerRaceCheckpoint(playerid, 0, 810.6096, -1149.0100, 23.9497, 1056.4441,-1162.1558, 23.8530, 4.0); CP[playerid] = 4;}
		case 4: {disableCP(playerid); SetPlayerRaceCheckpoint(playerid, 0, 1056.4441,-1162.1558, 23.8530, 1038.2849,-1320.2205, 13.4880, 4.0); CP[playerid] = 5;}
		case 5: {disableCP(playerid); SetPlayerRaceCheckpoint(playerid, 0, 1038.2849,-1320.2205, 13.4880, 998.2159, -1349.9519, 13.4418, 4.0); CP[playerid] = 6;}
		case 6: {disableCP(playerid); SetPlayerRaceCheckpoint(playerid, 1, 998.2159, -1349.9519, 13.4418, 0.0, 0.0, 0.0, 4.0); CP[playerid] = 7;}
		case 7: {
			disableCP(playerid);
			DestroyVehicle(examCar[playerid]);
			examCar[playerid] = -1;
			SetUpdate(playerid, playerInfo:pCarLic, "CarLic", 50);
			SCM(playerid, COLOR_GREY, "(Server): "WHITE"Congratulations! You recived car license for 50 hours.");
		}
		case 100: {disableCP(playerid); SetPlayerRaceCheckpoint(playerid, 3, 1495.4569, -2315.8523, 89.6612, 1625.7645, -2125.8088, 123.9545, 8.0); CP[playerid] = 101;}
		case 101: {disableCP(playerid); SetPlayerRaceCheckpoint(playerid, 3, 1625.7645, -2125.8088, 123.9545, 1876.4480, -2243.9009, 24.8870, 8.0); CP[playerid] = 102;}
		case 102: {disableCP(playerid); SetPlayerRaceCheckpoint(playerid, 1, 1876.4480, -2243.9009, 24.8870, 0.0, 0.0, 0.0, 8.0); CP[playerid] = 103;}
		case 103: {
			disableCP(playerid);
			DestroyVehicle(examCar[playerid]);
			examCar[playerid] = -1;
			SetPlayerPos(playerid, 1957.3932, -2183.6255, 13.5469);
			SetUpdate(playerid, playerInfo:pFlyLic, "FlyLic", 50);
			SCM(playerid, COLOR_GREY, "(Server): "WHITE"Congratulations! You recived fly license for 50 hours.");
		}
		case 200: {disableCP(playerid); SetPlayerRaceCheckpoint(playerid, 3, 723.3669, -1884.9502, -0.3983, 671.3928, -1966.8657, -0.2379, 6.0); CP[playerid] = 201;}
		case 201: {disableCP(playerid); SetPlayerRaceCheckpoint(playerid, 3, 671.3928, -1966.8657, -0.2379, 719.8076, -2003.1292, -0.1344, 6.0); CP[playerid] = 202;}
		case 202: {disableCP(playerid); SetPlayerRaceCheckpoint(playerid, 3, 719.8076, -2003.1292, -0.1344, 721.5114, -1912.5170, -0.1285, 6.0); CP[playerid] = 203;}
		case 203: {disableCP(playerid); SetPlayerRaceCheckpoint(playerid, 3, 721.5114, -1912.5170, -0.1285, 723.7269, -1766.3621, -0.2245, 6.0); CP[playerid] = 204;}
		case 204: {disableCP(playerid); SetPlayerRaceCheckpoint(playerid, 3, 723.7269, -1766.3621, -0.2245, 733.9890, -1512.9550, -0.0694, 6.0); CP[playerid] = 205;}
		case 205: {disableCP(playerid); SetPlayerRaceCheckpoint(playerid, 4, 733.9890, -1512.9550, -0.0694, 0.0, 0.0, 0.0, 8.0); CP[playerid] = 206;}
		case 206: {
			disableCP(playerid);
			DestroyVehicle(examCar[playerid]);
			examCar[playerid] = -1;
			SetPlayerPos(playerid, 723.2545, -1493.4685, 1.9343);
			SetUpdate(playerid, playerInfo:pBoatLic, "BoatLic", 50);
			SCM(playerid, COLOR_GREY, "(Server): "WHITE"Congratulations! You recived boat license for 50 hours.");
		}
	}
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid) {
	return 1;
}

public OnRconCommand(cmd[]) {
	return 1;
}

public OnPlayerRequestSpawn(playerid) {
	return 1;
}

public OnObjectMoved(objectid) {
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid) {
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid) {
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid) {
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid) {
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2) {
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row) {
	return 1;
}

public OnPlayerExitedMenu(playerid) {
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid) {
	return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(newkeys & KEY_SECONDARY_ATTACK) {
    	if(Bit_Get(flyingStatus, playerid) == true) {
			StopFly(playerid), SetPlayerHealth(playerid, 99.00);
			Bit_Set(flyingStatus, playerid, false);
			GameTextForPlayer(playerid, "~~Flying mode off", 4500, 3);
		}
		if(IsPlayerConnected(playerid)) {
			new Float: X, Float: Y, Float: Z;
			GetPlayerPos(playerid, X, Y, Z);
			for(new i = 0; i < MAX_GROUPS; i++) {
				if(IsPlayerInRangeOfPoint(playerid, 2.0, gInfo[i][geX], gInfo[i][geY], gInfo[i][geZ])) {
					if(gInfo[i][gDoor] == 0 || (pInfo[playerid][pMember] == i && gInfo[i][gDoor] == 1)) {
						SetPlayerPos(playerid, gInfo[i][giX], gInfo[i][giY], gInfo[i][giZ]);
						SetPlayerInterior(playerid, gInfo[i][gInterior]);
						SetPlayerVirtualWorld(playerid, i+1);
						SetCameraBehindPlayer(playerid);
					} 
					else SCMEx(playerid, -1, "You are not %s`s member.", gInfo[i][gName]);
				}
				else if(IsPlayerInRangeOfPoint(playerid, 2.0, gInfo[i][giX], gInfo[i][giY], gInfo[i][giZ])) {
					SetPlayerPos(playerid, gInfo[i][geX], gInfo[i][geY], gInfo[i][geZ]);
					SetPlayerInterior(playerid, 0);
					SetPlayerVirtualWorld(playerid, 0);
					SetCameraBehindPlayer(playerid);
				}
			}
			for(new i = 1; i < 50; i++) {
				if(IsPlayerInRangeOfPoint(playerid, 2.0, hInfo[i][heX], hInfo[i][heY], hInfo[i][heZ])) {
					if(hInfo[i][hLocked] == 0 || (pInfo[playerid][pHouseKey] == i || pInfo[playerid][pHouseRent] == i)) {
						SetPlayerPos(playerid, hInfo[i][hiX], hInfo[i][hiY], hInfo[i][hiZ]);
						SetPlayerInterior(playerid, hInfo[i][hInterior]);
						SetPlayerVirtualWorld(playerid, i+1);
						SetCameraBehindPlayer(playerid);
					}
					else GameTextForPlayer(playerid, "~r~LOCKED", 2000, 1);
				}
				else if(IsPlayerInRangeOfPoint(playerid, 2.0, hInfo[i][hiX], hInfo[i][hiY], hInfo[i][hiZ])) {
					SetPlayerPos(playerid, hInfo[i][heX], hInfo[i][heY], hInfo[i][heZ]);
					SetPlayerInterior(playerid, 0);
					SetPlayerVirtualWorld(playerid, 0);
					SetCameraBehindPlayer(playerid);
				}
			}
		}
	}
	if(newkeys == KEY_LOOK_BEHIND) {
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;
		new car = GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective, string[125];
		if(IsABike(car)) return 1;
		GetVehicleParamsEx(car, engine, lights, alarm, doors, bonnet, boot, objective);
		if(engine == 0) {SetVehicleParamsEx(car, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective); format(string, 125, "%s has turn on engine of his %s.", GetName(playerid), vehName[GetVehicleModel(car) - 400]); ProxDetector(10.0, playerid, string, COLOR_PURPLE);}
		if(engine == 1) {SetVehicleParamsEx(car, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective); format(string, 125, "%s has turn of engine of his %s.", GetName(playerid), vehName[GetVehicleModel(car) - 400]); ProxDetector(10.0, playerid, string, COLOR_PURPLE);}
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success) {
	return 1;
}

public OnPlayerUpdate(playerid) {
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid) {
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid) {
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid) {
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid) {
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	new query[354];
	switch(dialogid) {
		case DIALOG_REGISTER: {
			if(response) {
				new serialCode[41];
				WP_Hash(playerHashedPass[playerid], 129, inputtext);
				gpci(playerid, serialCode, 41);
				mysql_format(handle, query, 354, "INSERT INTO `players` (`username`, `password`, `SerialCode`, `Skin`) VALUES ('%e', '%e', '%e', '%d')", GetName(playerid), playerHashedPass[playerid], serialCode, SPAWN_SKIN);
				mysql_tquery(handle, query, "", "" );
				Clearchat(playerid, 20);
				SCM(playerid, COLOR_GREY, "(Server): "WHITE"Your account was been created! You need to finish all registration steps, otherwise it will be deleted.");
				ShowPlayerDialog(playerid, DIALOG_SEX, DIALOG_STYLE_MSGBOX, "SERVER: Select your character", ""WHITE"Please select your "CREM"character"WHITE"!", "Male", "Female");
			} 
			else Kick(playerid);
		}
		case DIALOG_LOGIN: {
			if(response) {
				new hashed[129];
				WP_Hash(hashed, 129, inputtext);
				mysql_format(handle, query, 256, "SELECT * FROM `players` WHERE `username` = '%e' AND `password` = '%e'", GetName(playerid), hashed);
				mysql_tquery(handle, query, "accountLogin", "i", playerid);
			}
			else Kick(playerid);
		}
		case DIALOG_SEX: {
			if(response) {
				SetUpdate(playerid, playerInfo:pSex, "Sex", 1);
				SCM(playerid, COLOR_GREY, "(Server): "WHITE"Thanks, now we know that you are a boy. How old are you?");
			}
			else {
				SetUpdate(playerid, playerInfo:pSex, "Sex", 2);
				SCM(playerid, COLOR_GREY, "(Server): "WHITE"Thanks, now we know that you are a girl. How old are you?");
			}
			ShowPlayerDialog(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, "SERVER: Age", ""WHITE"It`s important for us to know how "CREM"old"WHITE" are you!", "Proceed", "Cancel");
		}
		case DIALOG_AGE: {
			if(response) {
				new age = strval(inputtext);
				if(age > 0 && age < 50) {
					new y, m, d;
					getdate(y, m, d);
					SetUpdate(playerid, playerInfo:pAge, "Age", age);
					SCMEx(playerid, COLOR_GREY, "(Server): "WHITE"Ok, you was born in %d. Now, sets the corectly email address.", y-age);
					ShowPlayerDialog(playerid, DIALOG_EMAIL, DIALOG_STYLE_INPUT, "SERVER: Email", ""WHITE"If you lose your account you can use your "CREM"email address "WHITE"to recover your account.", "Set", "Cancel");
				}
				else ShowPlayerDialog(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, "SERVER: Age", ""WHITE"It`s important for us to know how "CREM"old"WHITE" are you!", "Male", "Female");
			}
			else Kick(playerid);
		}
		case DIALOG_EMAIL: {
			if(response) {
				if(IsMail(inputtext)) {
					SetUpdateStr(playerid, playerInfo:pEmail, "Email", inputtext);
					mysql_format(handle, query, 284, "UPDATE `players` SET `Sex` = '%d', `Age` = '%d', `Email` = '%e' WHERE `username` = '%e'", pInfo[playerid][pSex], pInfo[playerid][pAge], pInfo[playerid][pEmail], GetName(playerid));
					mysql_tquery(handle, query, "", "");
					
					mysql_format(handle, query, 256, "SELECT * FROM `players` WHERE `username` = '%e' AND `password` = '%e'", GetName(playerid), playerHashedPass[playerid]);
					mysql_tquery(handle, query, "accountLogin", "i", playerid);
					
					new Cache:count, sCode[41], pIP[16];
					gpci(playerid, sCode, 41), GetPlayerIp(playerid, pIP, 16);
					
					mysql_format(handle, query, 200, "SELECT * FROM `players` WHERE `serialCode` = '%e'", sCode);
					count = mysql_query(handle, query), cache_get_data(rows, fields, handle);
					format(gMsg, 128, "New account - %s (%d) // %d accounts, ip: %s.", GetName(playerid), playerid, rows, pIP), sendAdmins(COLOR_DRED, gMsg);
					cache_delete(count);
					
				}
				else ShowPlayerDialog(playerid, DIALOG_EMAIL, DIALOG_STYLE_INPUT, "SERVER: Email", ""DRED"Error: Invalid email format.\n\n"WHITE"If you lose your account you can use your "CREM"email address "WHITE"to recover your account.", "Set", "Cancel");
			}
			else Kick(playerid);
		}
		case DIALOG_BLOCK: {
			if(response) {
				mysql_format(handle, query, 284, "SELECT * FROM `accounts_blocked` WHERE `playerID` = '%d' AND `securityCode` = '%e' ORDER BY `id` DESC LIMIT 1", pInfo[playerid][pSQLID], inputtext);
				mysql_tquery(handle, query, "securityCodeCheck", "i", playerid);
			}
			else Kick(playerid);
		}
		case DIALOG_GUNLIC: {
			if(!response) return SetPlayerVirtualWorld(playerid, 0);
			else ShowPlayerDialog(playerid, DIALOG_GUNLIC+1, DIALOG_STYLE_MSGBOX, "Question 1:", ""WHITE"You can deathmatch cops?", "Yes", "No");
		}
		case DIALOG_GUNLIC+1: {
			if(!response) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You failed the exam because you wrong."), SetPlayerVirtualWorld(playerid, 0);
			else ShowPlayerDialog(playerid, DIALOG_GUNLIC+2, DIALOG_STYLE_MSGBOX, "Question 2:", ""WHITE"You can deathmatch only in safezones.", "Yes", "No");
		}
		case DIALOG_GUNLIC+2: {
			if(!response) ShowPlayerDialog(playerid, DIALOG_GUNLIC+3, DIALOG_STYLE_MSGBOX, "Question 3:", ""WHITE"If you deathmatch you will be ajailed?", "Yes", "No");
			else return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You failed the exam because you wrong."), SetPlayerVirtualWorld(playerid, 0);
		}
		case DIALOG_GUNLIC+3: {
			if(!response) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"You failed the exam because you wrong."), SetPlayerVirtualWorld(playerid, 0);
			else {
				SetPlayerVirtualWorld(playerid, 0);
				SetUpdate(playerid, playerInfo:pGunLic, "GunLic", 50);
				SCM(playerid, COLOR_GREY, "(Server): "WHITE"Congratulations! You recived gun license for 50 hours.");
			}
		}
		case DIALOG_INTERIORS: {
			new string[30], fullstring[225];
			if(!response) return 1;
			else {
				switch(listitem) {
					case 0: {
						for(new i=0; i < sizeof(BigHouseInteriors); i++) {
							format(string, 30, "Interior %d\n", i);
							strcat(fullstring, string);
						}
						ShowPlayerDialog(playerid, DIALOG_INTERIORS+1, DIALOG_STYLE_LIST, "Big interiors:", fullstring, "OK", "Cancel");
					}
					case 1: {
						for(new i=0; i < sizeof(MediumHouseInteriors); i++) {
							format(string, 30, "Interior %d\n", i);
							strcat(fullstring, string);
						}
						ShowPlayerDialog(playerid, DIALOG_INTERIORS+2, DIALOG_STYLE_LIST, "Medium interiors:", fullstring, "OK", "Cancel");
					}
					case 2: {
						for(new i=0; i < sizeof(SmallHouseInteriors); i++) {
							format(string, 30, "Interior %d\n", i);
							strcat(fullstring, string);
						}
						ShowPlayerDialog(playerid, DIALOG_INTERIORS+3, DIALOG_STYLE_LIST, "Small interiors:", fullstring, "OK", "Cancel");
					}
				}
			}
		}
		case DIALOG_INTERIORS+1: {
			if(!response) return 1;
			else {
				SetPlayerPos(playerid, BigHouseInteriors[listitem][0], BigHouseInteriors[listitem][1], BigHouseInteriors[listitem][2]);
				SetPlayerInterior(playerid, floatround(BigHouseInteriors[listitem][3]));
			}
		}
		case DIALOG_INTERIORS+2: {
			if(!response) return 1;
			else {
				SetPlayerPos(playerid, MediumHouseInteriors[listitem][0], MediumHouseInteriors[listitem][1], MediumHouseInteriors[listitem][2]);
				SetPlayerInterior(playerid, floatround(MediumHouseInteriors[listitem][3]));
			}
		}
		case DIALOG_INTERIORS+3: {
			if(!response) return 1;
			else {
				SetPlayerPos(playerid, SmallHouseInteriors[listitem][0], SmallHouseInteriors[listitem][1], SmallHouseInteriors[listitem][2]);
				SetPlayerInterior(playerid, floatround(SmallHouseInteriors[listitem][3]));
			}
		}
		case DIALOG_SELLHOUSETOSTATE: {
			if(!response) return 1;
			else {
				new house = pInfo[playerid][pHouseKey];
				SetUpdate(playerid, playerInfo:pHouseKey, "HouseKey", 0);
				format(hInfo[house][hOwner], 25, "AdmBot");
				format(hInfo[house][hName], 50, "beleaua-rpg.ro");
				mysql_format(handle, updatequery, 254, "UPDATE `houses` SET `Owner` = '%e', `Name` = '%e' WHERE `ID` = '%d'", hInfo[house][hOwner], hInfo[house][hName], house);
				mysql_pquery(handle, updatequery, "", "");
				UpdateProperty(house);
				UpdateMoney(playerid, houseValue(house));
				SCMEx(playerid, COLOR_GREY, "(Server): "WHITE"You sold your house (ID: %d) to state for %d$", house, houseValue(house));
			}
		}
		case DIALOG_CHECKPOINT: {
			if(!response) return 1;
			else {
				disableCP(playerid);
			}
		}
		case DIALOG_HOUSEMENU: {
			new h = pInfo[playerid][pHouseKey], string[425], string2[30], maxrenters = 20;
			if(!response) return 1;
			else {
				switch(listitem) {
					case 0: {
						format(string, sizeof(string), ""WHITE"House ID: %d\nHouse size: %s\nHouse name: %s\nRent price: %d (%s)\nOnline renters: %d\nHouse deposit: %s$\nDoor status: %s\nHouse price: %s$\nHouse level: %d"
							, h, hInfo[h][hSize], hInfo[h][hName], hInfo[h][hRent], (hInfo[h][hRent]) ? ("rentable") : ("non-rentable"), onlineRenters(h), FormatNumber(hInfo[h][hDeposit]), (hInfo[h][hLocked] == 1) ? ("Closed") : ("Open"), FormatNumber(hInfo[h][hPrice]), hInfo[h][hLevel]);
						ShowPlayerDialog(playerid, DIALOG_HOUSEMENU+1, DIALOG_STYLE_MSGBOX, "House info:", string, "Ok", "");
					}
					case 1: {
						ShowPlayerDialog(playerid, DIALOG_HOUSEMENU+2, DIALOG_STYLE_INPUT, "Change house name:", "Write below your new house name,\nselect an appropriate name or you risk ban, max 50 chars:", "Change", "Cancel");
					}
					case 2: {
						ShowPlayerDialog(playerid, DIALOG_HOUSEMENU+3, DIALOG_STYLE_INPUT, "Change house rent:", "Insert below your new house rent price\n\n0$ - non rentable\n5.000$ - max rent", "Change", "Cancel");
					}
					case 3: {
						ShowPlayerDialog(playerid, DIALOG_HOUSEMENU+4, DIALOG_STYLE_INPUT, "Change house price:", "Insert below your new house price\n\n0$ - non saleable\n500.000.000$ - max price", "Change", "Cancel");
					}
					case 4: {
						if(hInfo[h][hLocked] == 0) hUpdate(h, houseInfo:hLocked, "Locked", 1);
						else hUpdate(h, houseInfo:hLocked, "Locked", 0);
						SCMEx(playerid, COLOR_GREY, "(Server): "WHITE"You have %s the door.", (hInfo[h][hLocked] == 0) ? ("opened") : ("closed"));
					}
					case 5: {
						format(string, 425, " On renters:\n\n");
						foreach(new i : Player) {
							if(maxrenters != 0 && pInfo[i][pHouseRent] == h) format(string2, 30, "%s - [ID: %d]\n", GetName(i), i), strcat(string, string2), maxrenters--;
						}
						if(maxrenters == 20) format(string2, 30, "No renters online."), strcat(string, string2);
						ShowPlayerDialog(playerid, DIALOG_HOUSEMENU+5, DIALOG_STYLE_MSGBOX, "Renters:", string, "Ok", "");
					}
				}
			}
		}
		case DIALOG_HOUSEMENU+2: {
			new h = pInfo[playerid][pHouseKey];
			if(!response) return 1;
			else {
				if(strlen(inputtext) > 50) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"Too many chars, max 50.");
				hUpdateStr(h, houseInfo:hName, "Name", inputtext);
				UpdateProperty(h);
				SCMEx(playerid, COLOR_GREY, "(Server): "WHITE"You changed your house name in %s.", inputtext);
			}
		}
		case DIALOG_HOUSEMENU+3: {
			new h = pInfo[playerid][pHouseKey];
			if(!response) return 1;
			else {
				if(strval(inputtext) > 5000) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"Invalid house rent price, max 5.000$.");
				hUpdate(h, houseInfo:hRent, "Rent", strval(inputtext));
				UpdateProperty(h);
				SCMEx(playerid, COLOR_GREY, "(Server): "WHITE"You changed your house rent to %d.", strval(inputtext));
			}
		}
		case DIALOG_HOUSEMENU+4: {
			new h = pInfo[playerid][pHouseKey];
			if(!response) return 1;
			else {
				if(strval(inputtext) > 500000000) return SCM(playerid, COLOR_GREY, "(Server): "WHITE"Invalid house  price, max 500.000.000$.");
				hUpdate(h, houseInfo:hPrice, "Price", strval(inputtext));
				UpdateProperty(h);
				SCMEx(playerid, COLOR_GREY, "(Server): "WHITE"You changed your house price to %d.", strval(inputtext));
			}
		}
	}
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid) {
	if(clickedid == Text:INVALID_TEXT_DRAW) {
		for(new i = 0; i <= 5; i++) { PlayerTextDrawHide(playerid, SpawnChange[i]); }
	}
	return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {
	if(playertextid == SpawnChange[3]) {
		SetUpdate(playerid, playerInfo:pSpawn, "Spawn", 0);
		SCM(playerid, COLOR_GREY, "(Server): "WHITE"You will spawn at your normal place.");
		for(new i = 0; i <= 5; i++) { PlayerTextDrawHide(playerid, SpawnChange[i]); }
		CancelSelectTextDraw(playerid);
	}
	else if(playertextid == SpawnChange[4]) {
		SetUpdate(playerid, playerInfo:pSpawn, "Spawn", 1);
		SCM(playerid, COLOR_GREY, "(Server): "WHITE"You will spawn at your house.");
		for(new i = 0; i <= 5; i++) { PlayerTextDrawHide(playerid, SpawnChange[i]); }
		CancelSelectTextDraw(playerid);
	}
	return 1;
}


public OnPlayerClickPlayer(playerid, clickedplayerid, source) {
	return 1;
}

function PayDay(playerid) {
	new account = pInfo[playerid][pBank]/100;
	SetUpdate(playerid, playerInfo:pBank, "Bank", pInfo[playerid][pBank]+pInfo[playerid][pBank]/100);
	SetUpdate(playerid, playerInfo:pRespect, "Respect", pInfo[playerid][pRespect]+1);
	SCM(playerid, COLOR_TEAL, "----------------------------------------------------------------------------");
	SCM(playerid, COLOR_WHITE, "Your paycheck has arrived; please visit the bank to withdraw your money.");
	SCMEx(playerid, COLOR_WHITE, "Paycheck: %d | Bank Balance: %d | Respect: +1", account, pInfo[playerid][pBank]);
	SCM(playerid, COLOR_TEAL, "----------------------------------------------------------------------------");
	if(pInfo[playerid][pRespect] >= pInfo[playerid][pLevel]*2) SCM(playerid, COLOR_GREY, "(Server): "WHITE"You can use now buy level.");
	if(pInfo[playerid][pCarLic] != 0) SetUpdate(playerid, playerInfo:pCarLic, "CarLic", pInfo[playerid][pCarLic]-1);
	else SCM(playerid, COLOR_GREY, "(Server): "WHITE"Your driving license has expired, go to DMV.");
	if(pInfo[playerid][pFlyLic] != 0) SetUpdate(playerid, playerInfo:pFlyLic, "FlyLic", pInfo[playerid][pFlyLic]-1);
	else SCM(playerid, COLOR_GREY, "(Server): "WHITE"Your pilot license has expired, go to pilot license center.");
	if(pInfo[playerid][pBoatLic] != 0) SetUpdate(playerid, playerInfo:pBoatLic, "BoatLic", pInfo[playerid][pBoatLic]-1);
	else SCM(playerid, COLOR_GREY, "(Server): "WHITE"Your sailing license has expired, go to sailing license center.");
	if(pInfo[playerid][pGunLic] != 0) SetUpdate(playerid, playerInfo:pGunLic, "GunLic", pInfo[playerid][pGunLic]-1);
	else SCM(playerid, COLOR_GREY, "(Server): "WHITE"Your driving license has expired, go to gun license center.");
	if(pInfo[playerid][pHouseRent] != 0 && pInfo[playerid][pCash] < hInfo[pInfo[playerid][pHouseKey]][hRent]) SetUpdate(playerid, playerInfo:pHouseRent, "HouseRent", 0), SCM(playerid, COLOR_GREY, "You have been evicted from house because you don't have enough money to pay the rent.");
	if(pInfo[playerid][pHouseRent] != 0) UpdateMoney(playerid, -hInfo[pInfo[playerid][pHouseKey]][hRent]), hUpdate(pInfo[playerid][pHouseKey], houseInfo:hDeposit, "Deposit", hInfo[pInfo[playerid][pHouseKey]][hDeposit] + hInfo[pInfo[playerid][pHouseKey]][hRent]);
	UpdateBar(playerid);
	GameTextForPlayer(playerid, "~g~Payday!", 5000, 1);
	return 1;
}

function IsABike(carid) {
	if(GetVehicleModel(carid) == 481 || GetVehicleModel(carid) == 509 || GetVehicleModel(carid) == 510) return 1;
	return 0;
}

function IsABoat(carid) {
	if(GetVehicleModel(carid) == 430 || GetVehicleModel(carid) == 446 || GetVehicleModel(carid) == 452 || GetVehicleModel(carid) == 453 || GetVehicleModel(carid) == 454 || GetVehicleModel(carid) == 472 || GetVehicleModel(carid) == 473 || GetVehicleModel(carid) == 484 || GetVehicleModel(carid) == 493 || GetVehicleModel(carid) == 595) return 1;
	return 0;
}

function IsAPlane(carid) {
	if(GetVehicleModel(carid) == 417 || GetVehicleModel(carid) == 425 || GetVehicleModel(carid) == 447 || GetVehicleModel(carid) == 460 || GetVehicleModel(carid) == 464 || GetVehicleModel(carid) == 465 || GetVehicleModel(carid) == 469 || GetVehicleModel(carid) == 476 || GetVehicleModel(carid) == 487 || GetVehicleModel(carid) == 488 ||
	 GetVehicleModel(carid) == 497 || GetVehicleModel(carid) == 501 || GetVehicleModel(carid) == 511 || GetVehicleModel(carid) == 512 || GetVehicleModel(carid) == 513 || GetVehicleModel(carid) == 519 || GetVehicleModel(carid) == 520 || GetVehicleModel(carid) == 548 || GetVehicleModel(carid) == 553 || GetVehicleModel(carid) == 563 || GetVehicleModel(carid) == 577 || GetVehicleModel(carid) == 592 || GetVehicleModel(carid) == 593) return 1;
	return 0;
}

// stocks
stock resetData(playerid) { 
	loginTries[playerid] = 0;
	SetPVarInt(playerid, "AddVehicle", 0);
	Bit_Set(pLogged, playerid, false);
	return 1;
}
stock showStats(playerid, tid) {
	new groupName[50];
	SCM(playerid, COLOR_TEAL, "-----------------------------------------------------------------");
	SCMEx(playerid, -1, "(%d) %s | Level: %d | Respect: %d/%d | Money in pocket: %s | Bank money: %s", tid, GetName(tid), pInfo[tid][pLevel], pInfo[tid][pRespect], pInfo[tid][pLevel]*2, FormatNumber(pInfo[tid][pCash]), FormatNumber(pInfo[tid][pBank]));
	SCMEx(playerid, -1, "Age: %d | Gender: %s | Email address: %s ", pInfo[tid][pAge], (pInfo[tid][pSex] == 1) ? ("Male") : ("Female"), pInfo[tid][pEmail]);
	format(groupName, 50, "%s, rank %d",gInfo[pInfo[tid][pMember]][gName], pInfo[tid][pRank]);
	SCMEx(playerid, -1, "Group: %s", (pInfo[tid][pMember]) ? (groupName) : ("No-one"));
	SCM(playerid, COLOR_TEAL, "-----------------------------------------------------------------");
	return 1;
}
stock FormatNumber(iNum, const szChar[] = ",") { 
    new szStr[16];
    format(szStr, sizeof(szStr), "%d", iNum);
	for(new iLen = strlen(szStr) - 3; iLen > 0; iLen -= 3) { strins(szStr, szChar, iLen); }
    return szStr;
}
stock IsMail(const string[]) {
	static RegEx:mail;
	if(!mail) {		
		mail = regex_build("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");
	}
	return regex_match_exid(string, mail);
}
stock houseValue(id) {
	if(!strcmp(hInfo[id][hSize], "Big")) return 15000000;
	if(!strcmp(hInfo[id][hSize], "Medium")) return 10000000;
	if(!strcmp(hInfo[id][hSize], "Small")) return 5000000;
	return 1;
}
stock hUpdate(house, houseInfo:hVar, dbField[32], value) {
	hInfo[house][hVar] = value;
	mysql_format(handle, updatequery, sizeof(updatequery),"UPDATE `houses` SET `%s`='%d' WHERE `id`='%e' LIMIT 1",dbField, hInfo[house][hVar], house);
	mysql_pquery(handle, updatequery, "", "");
}
stock hUpdateFloat(house, dbField[32], Float:value) {
	mysql_format(handle, updatequery, sizeof(updatequery),"UPDATE `houses` SET `%s`='%f' WHERE `id`='%e' LIMIT 1",dbField, value, house);
	mysql_pquery(handle, updatequery, "", "");
}
stock hUpdateStr(house, houseInfo:hVar, dbField[32], value[]) {
	format(hInfo[house][hVar], 200, "%s", value);
	mysql_format(handle, updatequery, sizeof(updatequery),"UPDATE `houses` SET `%s`='%e' WHERE `id`='%e' LIMIT 1",dbField, hInfo[house][hVar], house);
	mysql_pquery(handle, updatequery, "", "");
}
stock SetUpdate(playerid, playerInfo:pVar, dbField[32], value) {
	pInfo[playerid][pVar] = value;
	mysql_format(handle, updatequery, sizeof(updatequery),"UPDATE `players` SET `%s`='%d' WHERE `username`='%e' LIMIT 1",dbField, pInfo[playerid][pVar], GetName(playerid));
	mysql_pquery(handle, updatequery, "", "");
}
stock SetUpdateStr(playerid, playerInfo:pVar, dbField[32], value[]) {
	format(pInfo[playerid][pVar], 200, "%s", value);
	mysql_format(handle, updatequery, sizeof(updatequery),"UPDATE `players` SET `%s`='%e' WHERE `username`='%e' LIMIT 1",dbField, pInfo[playerid][pVar], GetName(playerid));
	mysql_pquery(handle, updatequery, "", "");
}
stock UpdateMoney(playerid, money) {
	if(money < 0) pInfo[playerid][pCash] -= money;
	else pInfo[playerid][pCash] += money;
	mysql_format(handle, updatequery, sizeof(updatequery),"UPDATE `players` SET `Cash`='%d' WHERE `username`='%e' LIMIT 1", pInfo[playerid][pCash], GetName(playerid));
	mysql_pquery(handle, updatequery, "", "");
}
stock SetMoney(playerid, money) {
	pInfo[playerid][pCash] = money;
	mysql_format(handle, updatequery, sizeof(updatequery),"UPDATE `players` SET `Cash`='%d' WHERE `username`='%e' LIMIT 1", pInfo[playerid][pCash], GetName(playerid));
	mysql_pquery(handle, updatequery, "", "");
}
stock randomString(lenght) {
	new randomChar[][] = {
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
		"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"
	};
	new string[20], rand;
	for(new i; i < lenght; i++) 
	{
		rand = random(sizeof(randomChar));
		strcat(string, randomChar[rand]);
	}
	return string;
}
stock disableCP(playerid) {
	DisablePlayerRaceCheckpoint(playerid);
	DisablePlayerCheckpoint(playerid);
	CP[playerid] = 0;
	return 1;
}
stock SetPlayerCheckpointEx(playerid, Float:x, Float:y, Float:z, Float:size, cp) {
	if(CP[playerid] != 0) ShowPlayerDialog(playerid, DIALOG_CHECKPOINT, DIALOG_STYLE_MSGBOX, "Disable checkpoint:", "Do you want to disable your curent checkpoint?", "Yes", "No");
	else disableCP(playerid), SetPlayerCheckpoint(playerid, x, y, z, size), CP[playerid] = cp, SCM(playerid, COLOR_GREY, "(Server): "WHITE"Server set you a checkpoint on map.");
	return 1;
}
stock sendAdmins(color, msg[]) {
	foreach(new i : Player) {
		if(pInfo[i][pAdmin] >= 1) { SCMEx(i, color, msg); }
	}
	return 1;
}
stock sendGroup(color, group, msg[]) {
	for(new i, j = GetPlayerPoolSize(); i <= j; i++) {
		if(pInfo[i][pMember] == group) {
			SCMEx(i, color, msg);
		}
	}
	return 1;
}
stock sendgType(color, type, msg[]) {
	foreach(new i : Player) {
		if(pInfo[i][pMember] && gInfo[pInfo[i][pMember]][gType] == type) {
			SCMEx(i, color, msg);
		}
	}
	return 1;
}
stock adminOnly(playerid, admin) {
	SCMEx(playerid, COLOR_GREY, ""GREY"You need to have admin level "ORANGE"%d+"GREY" to use this command.", admin);
	return 1;
}
stock ProxDetector(Float:radi, playerid, string[], color) {
    new Float:x,Float:y,Float:z;
    GetPlayerPos(playerid,x,y,z);
    foreach(Player,i) {
        if(IsPlayerInRangeOfPoint(i,radi,x,y,z)) {
            SendClientMessage(i,color,string);
        }
    }
}
stock SCMEx(playerid, color, fstring[], {Float, _}:...) { // source: sa-mp.com forum
    #if defined DEBUG
	    printf("[debug] SCM(%d,%d,%s,...)",playerid,color,fstring);
	#endif
    new n = numargs() * 4;
	if (n == 3 * 4) {
		return SendClientMessage(playerid, color, fstring);
	}
	else {
		new message[255];
		new arg_start;
        new arg_end;
        new i = 0;

        #emit CONST.pri  fstring
        #emit ADD.C    0x4
        #emit STOR.S.pri arg_start

        #emit LOAD.S.pri n
        #emit ADD.C    0x8
        #emit STOR.S.pri arg_end

        for (i = arg_end; i >= arg_start; i -= 4)
        {
            #emit LCTRL    5
            #emit LOAD.S.alt i
            #emit ADD
            #emit LOAD.I
            #emit PUSH.pri
        }
        #emit PUSH.S  fstring
        #emit PUSH.C  128
        #emit PUSH.ADR message
        #emit PUSH.S  n
        #emit SYSREQ.C format

        i = n / 4 + 1;
        while (--i >= 0) {
            #emit STACK 0x4
        }
        return SendClientMessage(playerid, color, message);
	}
}

stock GetName(playerid) {
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	return name;
}

stock onlineRenters(house) {
	new renters = 0;
	foreach(new i : Player) {
		if(pInfo[i][pHouseRent] == house) renters++;
	}
	return renters;
}

stock Clearchat(player, lines) {
	for(new l; l <= lines; l++) { SCM(player, -1, " "); }
	return 1;
}