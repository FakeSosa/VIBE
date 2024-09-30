/* ------------------------- [ INFORMACIJE ] -------------------------------- //

- Ime : Vibe Roleplay
- Vlasnik : Sosa
- Skripter : Sosa
- Zasluge servera : Y-Less, Blue-G, samp-incognito etc.

// -------------------------------------------------------------------------- */

// - > Main Includes
#define		YSI_YES_HEAP_MALLOC
#define 	CGEN_MEMORY  	60000

// - > Includes
#include 		< a_samp >
#include        < a_mysql >
#include 		< SKY >
#include 		< weapon-config >

#if defined _ALS_OnPlayerGiveDamage
	#undef OnPlayerGiveDamage
#else
	#define _ALS_OnPlayerGiveDamage
#endif
#define OnPlayerGiveDamage NULL_OnPlayerGiveDamage
#if defined NULL_OnPlayerGiveDamage
	forward NULL_OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart);
#endif


#if defined _ALS_OnPlayerTakeDamage
	#undef OnPlayerTakeDamage
#else
	#define _ALS_OnPlayerTakeDamage
#endif
#define OnPlayerTakeDamage NULL_OnPlayerTakeDamage
#if defined NULL_OnPlayerTakeDamage
	forward NULL_OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart);
#endif

#include        < YSI_Data\y_iterate >
#include        < YSI_Coding\y_va >
#include        < YSI_Coding\y_timers >
#include        < streamer >
#include        < sscanf2 >
#include        < izcmd >
#include        < easyDialog >

// - > MySQL
const MYSQL_CONNECT = (0);

#if MYSQL_CONNECT == 0

	static const MYSQL_HOST[10] =  "localhost";
	static const MYSQL_USER[5] = "root";
	static const MYSQL_PASS[1] = "";
	static const MYSQL_DB[8] = "vibe_db";

#elseif MYSQL_CONNECT == 1

    static const MYSQL_HOST[1] =  "";
	static const MYSQL_USER[1] = "";
	static const MYSQL_PASS[1] = "";
	static const MYSQL_DB[1] =  "";

#endif

static MySQL:SQL;

// - > Limits
#undef MAX_PLAYERS
#define MAX_PLAYERS 					  100

#undef MAX_VEHICLES
#define MAX_VEHICLES                      2000

#define MAX_VOZILA  					  1000
#define MAX_ATM                           40
#define MAX_KUCA 						  350
#define MAX_STANOVA 					  350

// - > Statics
static Ulogovan[MAX_PLAYERS],
    IncorrectPassword[MAX_PLAYERS],
	bool:CorrectPassword[MAX_PLAYERS],
	bool:InputPassword[MAX_PLAYERS],
	InputMail[MAX_PLAYERS],
	InputAge[MAX_PLAYERS],
	ChooseCountry[MAX_PLAYERS],
	InputSex[MAX_PLAYERS],
	accountRealPass[MAX_PLAYERS][64],
	DobioPay[MAX_PLAYERS],
	chat = 1,
	AdminDuty[MAX_PLAYERS],
	JetpackUsed[MAX_PLAYERS],
	LoginTimer[MAX_PLAYERS],
	PlayerTimer[MAX_PLAYERS],
	AdminVozilo[MAX_PLAYERS],
	vozilo1,
	KomeSalje[MAX_PLAYERS],
	Fuel[MAX_VOZILA],
	SpecaID[MAX_PLAYERS],
	SpecTip[MAX_PLAYERS],
 	brojbankomate = 0,
 	brojkuce = 0,
 	brojstanova = 0,
 	bool:PuniGorivo[MAX_PLAYERS];
	
static ZabranjeneReci[][] =
{
	"CroHerze",
	"Balkan Underground",
	"Balkan-Underground",
	"YUB",
	"Yunited Balkan",
	"YunitedBalkan",
	"Yunited-Balkan",
	"Y-U-B",
	"Y.U.B",
	"Dream World",
	"Dream-World",
	"DreamWorld",
	"City Of Angels",
	"City-Of-Angels",
	"CityOfAngels",
	"Faction Game",
	"Faction-Game",
	"FactionGame",
	"NooBot",
	"Balkan Extazy",
	"Balkan-Extazy",
	"Balkan.Extazy",
	"BalkanExtazy",
	"Skill Arena",
	"Skill-Arena",
	"Skill.Arena",
	"SkillArena",
	"Balkan School",
	"Balkan-School",
	"Balkan.School",
	"BalkanSchool",
	"Arcane",
	"Meanwhile",
	"Black School",
	"Black-School",
	"Black.School",
	"BlackSchool",
	"Old School",
	"Old-School",
	"Old.School",
	"OldSchool",
	"Black Jack",
	"Black-Jack",
	"Black.Jack",
	"BlackJack",
	"Venezuela"
};
	
// - > TextDraws
new Text:InGameTD[6];
new PlayerText:BankaTD[MAX_PLAYERS];
new PlayerText:ZlatoTD[MAX_PLAYERS];
new PlayerText:LoginTD[MAX_PLAYERS][5];
new PlayerText:BrzinaTD[MAX_PLAYERS][21];

// - > Clear Chat
#define ClearChat(%0,%1)  				for(new c = 0; c < %1; c ++) SendClientMessage(%0, -1, " ")

// - > Enums
enum E_PLAYERS_DATA
{
	SQLID,
	Password[128],
	Email[50],
	Skin,
	Admin,
	Level,
	Respekti,
	SatiIgre,
	Novac,
	Pol,
	Drzava,
	Godine,
	NovacBanka,
	Zlato,
	Banovan,
	BRazlog[40],
	Kartica,
	KarticaPin,
	Warn,
	ADozvola,
	KamionDozvola,
	MotorDozvola,
	AvionDozvola,
	BrodDozvola,
	Kuca,
	Rent,
	Spawn,
	Droga,
	Mats,
	Hrana,
	Stan,
	IznosKredita,
	IznosRate,
	PreostaloZaOtplatu,
	Vip,
	Mutiran
}
static PI[MAX_PLAYERS][E_PLAYERS_DATA];

enum
{
	SPAWN_NORMAL = 1,
	SPAWN_KUCA,
	SPAWN_RENTKUCA,
	SPAWN_STAN
};

#define ATM_OBJEKAT  2942
enum E_ATM_DATA
{
	SQLID,
    aPostavljen,
    Float:aX,
    Float:aY,
    Float:aZ,
    Float:aAngle,
    aObjekat,
    aInt,
    aVW,
    Text3D:aAtmLabel
}
new AtmInfo[MAX_ATM][E_ATM_DATA];
new eData[MAX_PLAYERS];

enum
{
	MALA_KUCA = 1,
    SREDNJA_KUCA,
    VELIKA_KUCA,
    VILLA
};

enum E_HOUSES_DATA
{
	SQLID,
	kProveraVlasnika,
	kVlasnik[MAX_PLAYER_NAME],
	kVrsta,
	Float:kUlazX,
	Float:kUlazY,
	Float:kUlazZ,
	Float:kIzlazX,
	Float:kIzlazY,
	Float:kIzlazZ,
	kLevel,
	kCena,
    kNovac,
	kInt,
	kZatvoreno,
	kVW,
	kOruzije,
	kMunicija,
	kRent,
	kCenaRenta,
	kZvono,
	kFrizder,
	kMats,
	kDroga,
	kOdjeca,
	kVrstaIntKuce,
	kHrana
};
new KucaInfo[MAX_KUCA][E_HOUSES_DATA];
new KucaPickup[sizeof(KucaInfo)];
new Text3D:KucaLabel[sizeof(KucaInfo)];

enum E_APARTMENTS_ENUM
{
    SQLID,
	sProveraVlasnika,
	sVlasnik[MAX_PLAYER_NAME],
	Float:sUlazX,
	Float:sUlazY,
	Float:sUlazZ,
	Float:sIzlazX,
	Float:sIzlazY,
	Float:sIzlazZ,
	sLevel,
	sCena,
    sNovac,
	sInt,
	sZatvoreno,
	sVW,
	sOruzije,
	sMunicija
};
new StanInfo[MAX_STANOVA][E_APARTMENTS_ENUM];
new StanPickup[sizeof(StanInfo)];
new Text3D:StanLabel[sizeof(StanInfo)];

enum SAZONE_MAIN
{
	SAZONE_NAME[38],
	Float:SAZONE_AREA[6]
};

#define MAX_ZONE_NAME 38
static const gSAZones[][SAZONE_MAIN] =
{
	{"The Big Ear",	                {-410.00,1403.30,-3.00,-137.90,1681.20,200.00}},
	{"Aldea Malvada",               {-1372.10,2498.50,0.00,-1277.50,2615.30,200.00}},
	{"Angel Pine",                  {-2324.90,-2584.20,-6.10,-1964.20,-2212.10,200.00}},
	{"Arco del Oeste",              {-901.10,2221.80,0.00,-592.00,2571.90,200.00}},
	{"Avispa Country Club",         {-2646.40,-355.40,0.00,-2270.00,-222.50,200.00}},
	{"Avispa Country Club",         {-2831.80,-430.20,-6.10,-2646.40,-222.50,200.00}},
	{"Avispa Country Club",         {-2361.50,-417.10,0.00,-2270.00,-355.40,200.00}},
	{"Avispa Country Club",         {-2667.80,-302.10,-28.80,-2646.40,-262.30,71.10}},
	{"Avispa Country Club",         {-2470.00,-355.40,0.00,-2270.00,-318.40,46.10}},
	{"Avispa Country Club",         {-2550.00,-355.40,0.00,-2470.00,-318.40,39.70}},
	{"Back o Beyond",               {-1166.90,-2641.10,0.00,-321.70,-1856.00,200.00}},
	{"Battery Point",               {-2741.00,1268.40,-4.50,-2533.00,1490.40,200.00}},
	{"Bayside",                     {-2741.00,2175.10,0.00,-2353.10,2722.70,200.00}},
	{"Bayside Marina",              {-2353.10,2275.70,0.00,-2153.10,2475.70,200.00}},
	{"Beacon Hill",                 {-399.60,-1075.50,-1.40,-319.00,-977.50,198.50}},
	{"Blackfield",                  {964.30,1203.20,-89.00,1197.30,1403.20,110.90}},
	{"Blackfield",                  {964.30,1403.20,-89.00,1197.30,1726.20,110.90}},
	{"Blackfield Chapel",           {1375.60,596.30,-89.00,1558.00,823.20,110.90}},
	{"Blackfield Chapel",           {1325.60,596.30,-89.00,1375.60,795.00,110.90}},
	{"Blackfield Section",          {1197.30,1044.60,-89.00,1277.00,1163.30,110.90}},
	{"Blackfield Section",          {1166.50,795.00,-89.00,1375.60,1044.60,110.90}},
	{"Blackfield Section",          {1277.00,1044.60,-89.00,1315.30,1087.60,110.90}},
	{"Blackfield Section",          {1375.60,823.20,-89.00,1457.30,919.40,110.90}},
	{"Blueberry",                   {104.50,-220.10,2.30,349.60,152.20,200.00}},
	{"Blueberry",                   {19.60,-404.10,3.80,349.60,-220.10,200.00}},
	{"Blueberry Acres",             {-319.60,-220.10,0.00,104.50,293.30,200.00}},
	{"Caligula's Palace",           {2087.30,1543.20,-89.00,2437.30,1703.20,110.90}},
	{"Caligula's Palace",           {2137.40,1703.20,-89.00,2437.30,1783.20,110.90}},
	{"Calton Heights",              {-2274.10,744.10,-6.10,-1982.30,1358.90,200.00}},
	{"Chinatown",                   {-2274.10,578.30,-7.60,-2078.60,744.10,200.00}},
	{"City Hall",                   {-2867.80,277.40,-9.10,-2593.40,458.40,200.00}},
	{"Come-A-Lot",                  {2087.30,943.20,-89.00,2623.10,1203.20,110.90}},
	{"Commerce",                    {1323.90,-1842.20,-89.00,1701.90,-1722.20,110.90}},
	{"Commerce",                    {1323.90,-1722.20,-89.00,1440.90,-1577.50,110.90}},
	{"Commerce",                    {1370.80,-1577.50,-89.00,1463.90,-1384.90,110.90}},
	{"Commerce",                    {1463.90,-1577.50,-89.00,1667.90,-1430.80,110.90}},
	{"Commerce",                    {1583.50,-1722.20,-89.00,1758.90,-1577.50,110.90}},
	{"Commerce",                    {1667.90,-1577.50,-89.00,1812.60,-1430.80,110.90}},
	{"Conference Center",           {1046.10,-1804.20,-89.00,1323.90,-1722.20,110.90}},
	{"Conference Center",           {1073.20,-1842.20,-89.00,1323.90,-1804.20,110.90}},
	{"Cranberry Station",           {-2007.80,56.30,0.00,-1922.00,224.70,100.00}},
	{"Creek",                       {2749.90,1937.20,-89.00,2921.60,2669.70,110.90}},
	{"Dillimore",                   {580.70,-674.80,-9.50,861.00,-404.70,200.00}},
	{"Doherty",                     {-2270.00,-324.10,-0.00,-1794.90,-222.50,200.00}},
	{"Doherty",                     {-2173.00,-222.50,-0.00,-1794.90,265.20,200.00}},
	{"Downtown",                    {-1982.30,744.10,-6.10,-1871.70,1274.20,200.00}},
	{"Downtown",                    {-1871.70,1176.40,-4.50,-1620.30,1274.20,200.00}},
	{"Downtown",                    {-1700.00,744.20,-6.10,-1580.00,1176.50,200.00}},
	{"Downtown",                    {-1580.00,744.20,-6.10,-1499.80,1025.90,200.00}},
	{"Downtown",                    {-2078.60,578.30,-7.60,-1499.80,744.20,200.00}},
	{"Downtown",                    {-1993.20,265.20,-9.10,-1794.90,578.30,200.00}},
	{"Downtown Los Santos",         {1463.90,-1430.80,-89.00,1724.70,-1290.80,110.90}},
	{"Downtown Los Santos",         {1724.70,-1430.80,-89.00,1812.60,-1250.90,110.90}},
	{"Downtown Los Santos",         {1463.90,-1290.80,-89.00,1724.70,-1150.80,110.90}},
	{"Downtown Los Santos",         {1370.80,-1384.90,-89.00,1463.90,-1170.80,110.90}},
	{"Downtown Los Santos",         {1724.70,-1250.90,-89.00,1812.60,-1150.80,110.90}},
	{"Downtown Los Santos",         {1370.80,-1170.80,-89.00,1463.90,-1130.80,110.90}},
	{"Downtown Los Santos",         {1378.30,-1130.80,-89.00,1463.90,-1026.30,110.90}},
	{"Downtown Los Santos",         {1391.00,-1026.30,-89.00,1463.90,-926.90,110.90}},
	{"Downtown Los Santos",         {1507.50,-1385.20,110.90,1582.50,-1325.30,335.90}},
	{"East Beach",                  {2632.80,-1852.80,-89.00,2959.30,-1668.10,110.90}},
	{"East Beach",                  {2632.80,-1668.10,-89.00,2747.70,-1393.40,110.90}},
	{"East Beach",                  {2747.70,-1668.10,-89.00,2959.30,-1498.60,110.90}},
	{"East Beach",                  {2747.70,-1498.60,-89.00,2959.30,-1120.00,110.90}},
	{"East Los Santos",             {2421.00,-1628.50,-89.00,2632.80,-1454.30,110.90}},
	{"East Los Santos",             {2222.50,-1628.50,-89.00,2421.00,-1494.00,110.90}},
	{"East Los Santos",             {2266.20,-1494.00,-89.00,2381.60,-1372.00,110.90}},
	{"East Los Santos",             {2381.60,-1494.00,-89.00,2421.00,-1454.30,110.90}},
	{"East Los Santos",             {2281.40,-1372.00,-89.00,2381.60,-1135.00,110.90}},
	{"East Los Santos",             {2381.60,-1454.30,-89.00,2462.10,-1135.00,110.90}},
	{"East Los Santos",             {2462.10,-1454.30,-89.00,2581.70,-1135.00,110.90}},
	{"Easter Basin",                {-1794.90,249.90,-9.10,-1242.90,578.30,200.00}},
	{"Easter Basin",                {-1794.90,-50.00,-0.00,-1499.80,249.90,200.00}},
	{"Easter Bay Airport",          {-1499.80,-50.00,-0.00,-1242.90,249.90,200.00}},
	{"Easter Bay Airport",          {-1794.90,-730.10,-3.00,-1213.90,-50.00,200.00}},
	{"Easter Bay Airport",          {-1213.90,-730.10,0.00,-1132.80,-50.00,200.00}},
	{"Easter Bay Airport",          {-1242.90,-50.00,0.00,-1213.90,578.30,200.00}},
	{"Easter Bay Airport",          {-1213.90,-50.00,-4.50,-947.90,578.30,200.00}},
	{"Easter Bay Airport",          {-1315.40,-405.30,15.40,-1264.40,-209.50,25.40}},
	{"Easter Bay Airport",          {-1354.30,-287.30,15.40,-1315.40,-209.50,25.40}},
	{"Easter Bay Airport",          {-1490.30,-209.50,15.40,-1264.40,-148.30,25.40}},
	{"Easter Bay Chemical",         {-1132.80,-768.00,0.00,-956.40,-578.10,200.00}},
	{"Easter Bay Chemical",         {-1132.80,-787.30,0.00,-956.40,-768.00,200.00}},
	{"Castillo del Diablo",         {-464.50,2217.60,0.00,-208.50,2580.30,200.00}},
	{"Castillo del Diablo",         {-208.50,2123.00,-7.60,114.00,2337.10,200.00}},
	{"Castillo del Diablo",         {-208.50,2337.10,0.00,8.40,2487.10,200.00}},
	{"El Corona",                   {1812.60,-2179.20,-89.00,1970.60,-1852.80,110.90}},
	{"El Corona",                   {1692.60,-2179.20,-89.00,1812.60,-1842.20,110.90}},
	{"El Quebrados",                {-1645.20,2498.50,0.00,-1372.10,2777.80,200.00}},
	{"Esplanade East",              {-1620.30,1176.50,-4.50,-1580.00,1274.20,200.00}},
	{"Esplanade East",              {-1580.00,1025.90,-6.10,-1499.80,1274.20,200.00}},
	{"Esplanade East",              {-1499.80,578.30,-79.60,-1339.80,1274.20,20.30}},
	{"Esplanade North",             {-2533.00,1358.90,-4.50,-1996.60,1501.20,200.00}},
	{"Esplanade North",             {-1996.60,1358.90,-4.50,-1524.20,1592.50,200.00}},
	{"Esplanade North",             {-1982.30,1274.20,-4.50,-1524.20,1358.90,200.00}},
	{"Fallen Tree",                 {-792.20,-698.50,-5.30,-452.40,-380.00,200.00}},
	{"Fallow Bridge",               {434.30,366.50,0.00,603.00,555.60,200.00}},
	{"Fern Ridge",                  {508.10,-139.20,0.00,1306.60,119.50,200.00}},
	{"Financial",                   {-1871.70,744.10,-6.10,-1701.30,1176.40,300.00}},
	{"Fisher's Lagoon",             {1916.90,-233.30,-100.00,2131.70,13.80,200.00}},
	{"Flint Intersection",          {-187.70,-1596.70,-89.00,17.00,-1276.60,110.90}},
	{"Flint Range",                 {-594.10,-1648.50,0.00,-187.70,-1276.60,200.00}},
	{"Fort Carson",                 {-376.20,826.30,-3.00,123.70,1220.40,200.00}},
	{"Foster Valley",               {-2270.00,-430.20,-0.00,-2178.60,-324.10,200.00}},
	{"Foster Valley",               {-2178.60,-599.80,-0.00,-1794.90,-324.10,200.00}},
	{"Foster Valley",               {-2178.60,-1115.50,0.00,-1794.90,-599.80,200.00}},
	{"Foster Valley",               {-2178.60,-1250.90,0.00,-1794.90,-1115.50,200.00}},
	{"Frederick Bridge",            {2759.20,296.50,0.00,2774.20,594.70,200.00}},
	{"Gant Bridge",                 {-2741.40,1659.60,-6.10,-2616.40,2175.10,200.00}},
	{"Gant Bridge",                 {-2741.00,1490.40,-6.10,-2616.40,1659.60,200.00}},
	{"Ganton",                      {2222.50,-1852.80,-89.00,2632.80,-1722.30,110.90}},
	{"Ganton",                      {2222.50,-1722.30,-89.00,2632.80,-1628.50,110.90}},
	{"Garcia",                      {-2411.20,-222.50,-0.00,-2173.00,265.20,200.00}},
	{"Garcia",                      {-2395.10,-222.50,-5.30,-2354.00,-204.70,200.00}},
	{"Garver Bridge",               {-1339.80,828.10,-89.00,-1213.90,1057.00,110.90}},
	{"Garver Bridge",               {-1213.90,950.00,-89.00,-1087.90,1178.90,110.90}},
	{"Garver Bridge",               {-1499.80,696.40,-179.60,-1339.80,925.30,20.30}},
	{"Glen Park",                   {1812.60,-1449.60,-89.00,1996.90,-1350.70,110.90}},
	{"Glen Park",                   {1812.60,-1100.80,-89.00,1994.30,-973.30,110.90}},
	{"Glen Park",                   {1812.60,-1350.70,-89.00,2056.80,-1100.80,110.90}},
	{"Green Palms",                 {176.50,1305.40,-3.00,338.60,1520.70,200.00}},
	{"Greenglass College",          {964.30,1044.60,-89.00,1197.30,1203.20,110.90}},
	{"Greenglass College",          {964.30,930.80,-89.00,1166.50,1044.60,110.90}},
	{"Hampton Barns",               {603.00,264.30,0.00,761.90,366.50,200.00}},
	{"Hankypanky Point",            {2576.90,62.10,0.00,2759.20,385.50,200.00}},
	{"Harry Gold Parkway",          {1777.30,863.20,-89.00,1817.30,2342.80,110.90}},
	{"Hashbury",                    {-2593.40,-222.50,-0.00,-2411.20,54.70,200.00}},
	{"Hilltop Farm",                {967.30,-450.30,-3.00,1176.70,-217.90,200.00}},
	{"Hunter Quarry",               {337.20,710.80,-115.20,860.50,1031.70,203.70}},
	{"Idlewood",                    {1812.60,-1852.80,-89.00,1971.60,-1742.30,110.90}},
	{"Idlewood",                    {1812.60,-1742.30,-89.00,1951.60,-1602.30,110.90}},
	{"Idlewood",                    {1951.60,-1742.30,-89.00,2124.60,-1602.30,110.90}},
	{"Idlewood",                    {1812.60,-1602.30,-89.00,2124.60,-1449.60,110.90}},
	{"Idlewood",                    {2124.60,-1742.30,-89.00,2222.50,-1494.00,110.90}},
	{"Idlewood",                    {1971.60,-1852.80,-89.00,2222.50,-1742.30,110.90}},
	{"Jefferson",                   {1996.90,-1449.60,-89.00,2056.80,-1350.70,110.90}},
	{"Jefferson",                   {2124.60,-1494.00,-89.00,2266.20,-1449.60,110.90}},
	{"Jefferson",                   {2056.80,-1372.00,-89.00,2281.40,-1210.70,110.90}},
	{"Jefferson",                   {2056.80,-1210.70,-89.00,2185.30,-1126.30,110.90}},
	{"Jefferson",                   {2185.30,-1210.70,-89.00,2281.40,-1154.50,110.90}},
	{"Jefferson",                   {2056.80,-1449.60,-89.00,2266.20,-1372.00,110.90}},
	{"Julius Thruway East",         {2623.10,943.20,-89.00,2749.90,1055.90,110.90}},
	{"Julius Thruway East",         {2685.10,1055.90,-89.00,2749.90,2626.50,110.90}},
	{"Julius Thruway East",         {2536.40,2442.50,-89.00,2685.10,2542.50,110.90}},
	{"Julius Thruway East",         {2625.10,2202.70,-89.00,2685.10,2442.50,110.90}},
	{"Julius Thruway North",        {2498.20,2542.50,-89.00,2685.10,2626.50,110.90}},
	{"Julius Thruway North",        {2237.40,2542.50,-89.00,2498.20,2663.10,110.90}},
	{"Julius Thruway North",        {2121.40,2508.20,-89.00,2237.40,2663.10,110.90}},
	{"Julius Thruway North",        {1938.80,2508.20,-89.00,2121.40,2624.20,110.90}},
	{"Julius Thruway North",        {1534.50,2433.20,-89.00,1848.40,2583.20,110.90}},
	{"Julius Thruway North",        {1848.40,2478.40,-89.00,1938.80,2553.40,110.90}},
	{"Julius Thruway North",        {1704.50,2342.80,-89.00,1848.40,2433.20,110.90}},
	{"Julius Thruway North",        {1377.30,2433.20,-89.00,1534.50,2507.20,110.90}},
	{"Julius Thruway South",        {1457.30,823.20,-89.00,2377.30,863.20,110.90}},
	{"Julius Thruway South",        {2377.30,788.80,-89.00,2537.30,897.90,110.90}},
	{"Julius Thruway West",         {1197.30,1163.30,-89.00,1236.60,2243.20,110.90}},
	{"Julius Thruway West",         {1236.60,2142.80,-89.00,1297.40,2243.20,110.90}},
	{"Juniper Hill",                {-2533.00,578.30,-7.60,-2274.10,968.30,200.00}},
	{"Juniper Hollow",              {-2533.00,968.30,-6.10,-2274.10,1358.90,200.00}},
	{"KACC Military Fuels",         {2498.20,2626.50,-89.00,2749.90,2861.50,110.90}},
	{"Kincaid Bridge",              {-1339.80,599.20,-89.00,-1213.90,828.10,110.90}},
	{"Kincaid Bridge",              {-1213.90,721.10,-89.00,-1087.90,950.00,110.90}},
	{"Kincaid Bridge",              {-1087.90,855.30,-89.00,-961.90,986.20,110.90}},
	{"King's",                      {-2329.30,458.40,-7.60,-1993.20,578.30,200.00}},
	{"King's",                      {-2411.20,265.20,-9.10,-1993.20,373.50,200.00}},
	{"King's",                      {-2253.50,373.50,-9.10,-1993.20,458.40,200.00}},
	{"LVA Freight Depot",           {1457.30,863.20,-89.00,1777.40,1143.20,110.90}},
	{"LVA Freight Depot",           {1375.60,919.40,-89.00,1457.30,1203.20,110.90}},
	{"LVA Freight Depot",           {1277.00,1087.60,-89.00,1375.60,1203.20,110.90}},
	{"LVA Freight Depot",           {1315.30,1044.60,-89.00,1375.60,1087.60,110.90}},
	{"LVA Freight Depot",           {1236.60,1163.40,-89.00,1277.00,1203.20,110.90}},
	{"Las Barrancas",               {-926.10,1398.70,-3.00,-719.20,1634.60,200.00}},
	{"Las Brujas",                  {-365.10,2123.00,-3.00,-208.50,2217.60,200.00}},
	{"Las Colinas",                 {1994.30,-1100.80,-89.00,2056.80,-920.80,110.90}},
	{"Las Colinas",                 {2056.80,-1126.30,-89.00,2126.80,-920.80,110.90}},
	{"Las Colinas",                 {2185.30,-1154.50,-89.00,2281.40,-934.40,110.90}},
	{"Las Colinas",                 {2126.80,-1126.30,-89.00,2185.30,-934.40,110.90}},
	{"Las Colinas",                 {2747.70,-1120.00,-89.00,2959.30,-945.00,110.90}},
	{"Las Colinas",                 {2632.70,-1135.00,-89.00,2747.70,-945.00,110.90}},
	{"Las Colinas",                 {2281.40,-1135.00,-89.00,2632.70,-945.00,110.90}},
	{"Las Payasadas",               {-354.30,2580.30,2.00,-133.60,2816.80,200.00}},
	{"Las Venturas Airport",        {1236.60,1203.20,-89.00,1457.30,1883.10,110.90}},
	{"Las Venturas Airport",        {1457.30,1203.20,-89.00,1777.30,1883.10,110.90}},
	{"Las Venturas Airport",        {1457.30,1143.20,-89.00,1777.40,1203.20,110.90}},
	{"Las Venturas Airport",        {1515.80,1586.40,-12.50,1729.90,1714.50,87.50}},
	{"Last Dime Motel",             {1823.00,596.30,-89.00,1997.20,823.20,110.90}},
	{"Leafy Hollow",                {-1166.90,-1856.00,0.00,-815.60,-1602.00,200.00}},
	{"Liberty City",                {-1000.00,400.00,1300.00,-700.00,600.00,1400.00}},
	{"Lil' Probe Inn",              {-90.20,1286.80,-3.00,153.80,1554.10,200.00}},
	{"Linden Side",                 {2749.90,943.20,-89.00,2923.30,1198.90,110.90}},
	{"Linden Station",              {2749.90,1198.90,-89.00,2923.30,1548.90,110.90}},
	{"Linden Station",              {2811.20,1229.50,-39.50,2861.20,1407.50,60.40}},
	{"Little Mexico",               {1701.90,-1842.20,-89.00,1812.60,-1722.20,110.90}},
	{"Little Mexico",               {1758.90,-1722.20,-89.00,1812.60,-1577.50,110.90}},
	{"Los Flores",                  {2581.70,-1454.30,-89.00,2632.80,-1393.40,110.90}},
	{"Los Flores",                  {2581.70,-1393.40,-89.00,2747.70,-1135.00,110.90}},
	{"LS International",            {1249.60,-2394.30,-89.00,1852.00,-2179.20,110.90}},
	{"LS International",            {1852.00,-2394.30,-89.00,2089.00,-2179.20,110.90}},
	{"LS International",            {1382.70,-2730.80,-89.00,2201.80,-2394.30,110.90}},
	{"LS International",            {1974.60,-2394.30,-39.00,2089.00,-2256.50,60.90}},
	{"LS International",            {1400.90,-2669.20,-39.00,2189.80,-2597.20,60.90}},
	{"LS International",            {2051.60,-2597.20,-39.00,2152.40,-2394.30,60.90}},
	{"Marina",                      {647.70,-1804.20,-89.00,851.40,-1577.50,110.90}},
	{"Marina",                      {647.70,-1577.50,-89.00,807.90,-1416.20,110.90}},
	{"Marina",                      {807.90,-1577.50,-89.00,926.90,-1416.20,110.90}},
	{"Market",                      {787.40,-1416.20,-89.00,1072.60,-1310.20,110.90}},
	{"Market",                      {952.60,-1310.20,-89.00,1072.60,-1130.80,110.90}},
	{"Market",                      {1072.60,-1416.20,-89.00,1370.80,-1130.80,110.90}},
	{"Market",                      {926.90,-1577.50,-89.00,1370.80,-1416.20,110.90}},
	{"Market Station",              {787.40,-1410.90,-34.10,866.00,-1310.20,65.80}},
	{"Martin Bridge",               {-222.10,293.30,0.00,-122.10,476.40,200.00}},
	{"Missionary Hill",             {-2994.40,-811.20,0.00,-2178.60,-430.20,200.00}},
	{"Montgomery",                  {1119.50,119.50,-3.00,1451.40,493.30,200.00}},
	{"Montgomery",                  {1451.40,347.40,-6.10,1582.40,420.80,200.00}},
	{"Montgomery Section",     {1546.60,208.10,0.00,1745.80,347.40,200.00}},
	{"Montgomery Section",     {1582.40,347.40,0.00,1664.60,401.70,200.00}},
	{"Mulholland",                  {1414.00,-768.00,-89.00,1667.60,-452.40,110.90}},
	{"Mulholland",                  {1281.10,-452.40,-89.00,1641.10,-290.90,110.90}},
	{"Mulholland",                  {1269.10,-768.00,-89.00,1414.00,-452.40,110.90}},
	{"Mulholland",                  {1357.00,-926.90,-89.00,1463.90,-768.00,110.90}},
	{"Mulholland",                  {1318.10,-910.10,-89.00,1357.00,-768.00,110.90}},
	{"Mulholland",                  {1169.10,-910.10,-89.00,1318.10,-768.00,110.90}},
	{"Mulholland",                  {768.60,-954.60,-89.00,952.60,-860.60,110.90}},
	{"Mulholland",                  {687.80,-860.60,-89.00,911.80,-768.00,110.90}},
	{"Mulholland",                  {737.50,-768.00,-89.00,1142.20,-674.80,110.90}},
	{"Mulholland",                  {1096.40,-910.10,-89.00,1169.10,-768.00,110.90}},
	{"Mulholland",                  {952.60,-937.10,-89.00,1096.40,-860.60,110.90}},
	{"Mulholland",                  {911.80,-860.60,-89.00,1096.40,-768.00,110.90}},
	{"Mulholland",                  {861.00,-674.80,-89.00,1156.50,-600.80,110.90}},
	{"Mulholland Section",     {1463.90,-1150.80,-89.00,1812.60,-768.00,110.90}},
	{"North Rock",                  {2285.30,-768.00,0.00,2770.50,-269.70,200.00}},
	{"Ocean Docks",                 {2373.70,-2697.00,-89.00,2809.20,-2330.40,110.90}},
	{"Ocean Docks",                 {2201.80,-2418.30,-89.00,2324.00,-2095.00,110.90}},
	{"Ocean Docks",                 {2324.00,-2302.30,-89.00,2703.50,-2145.10,110.90}},
	{"Ocean Docks",                 {2089.00,-2394.30,-89.00,2201.80,-2235.80,110.90}},
	{"Ocean Docks",                 {2201.80,-2730.80,-89.00,2324.00,-2418.30,110.90}},
	{"Ocean Docks",                 {2703.50,-2302.30,-89.00,2959.30,-2126.90,110.90}},
	{"Ocean Docks",                 {2324.00,-2145.10,-89.00,2703.50,-2059.20,110.90}},
	{"Ocean Flats",                 {-2994.40,277.40,-9.10,-2867.80,458.40,200.00}},
	{"Ocean Flats",                 {-2994.40,-222.50,-0.00,-2593.40,277.40,200.00}},
	{"Ocean Flats",                 {-2994.40,-430.20,-0.00,-2831.80,-222.50,200.00}},
	{"Octane Springs",              {338.60,1228.50,0.00,664.30,1655.00,200.00}},
	{"Old Venturas Strip",          {2162.30,2012.10,-89.00,2685.10,2202.70,110.90}},
	{"Palisades",                   {-2994.40,458.40,-6.10,-2741.00,1339.60,200.00}},
	{"Palomino Creek",              {2160.20,-149.00,0.00,2576.90,228.30,200.00}},
	{"Paradiso",                    {-2741.00,793.40,-6.10,-2533.00,1268.40,200.00}},
	{"Pershing Square",             {1440.90,-1722.20,-89.00,1583.50,-1577.50,110.90}},
	{"Pilgrim",                     {2437.30,1383.20,-89.00,2624.40,1783.20,110.90}},
	{"Pilgrim",                     {2624.40,1383.20,-89.00,2685.10,1783.20,110.90}},
	{"Pilson Intersection",         {1098.30,2243.20,-89.00,1377.30,2507.20,110.90}},
	{"Pirates in Men's Pants",      {1817.30,1469.20,-89.00,2027.40,1703.20,110.90}},
	{"Playa del Seville",           {2703.50,-2126.90,-89.00,2959.30,-1852.80,110.90}},
	{"Prickle Pine",                {1534.50,2583.20,-89.00,1848.40,2863.20,110.90}},
	{"Prickle Pine",                {1117.40,2507.20,-89.00,1534.50,2723.20,110.90}},
	{"Prickle Pine",                {1848.40,2553.40,-89.00,1938.80,2863.20,110.90}},
	{"Prickle Pine",                {1938.80,2624.20,-89.00,2121.40,2861.50,110.90}},
	{"Queens",                      {-2533.00,458.40,0.00,-2329.30,578.30,200.00}},
	{"Queens",                      {-2593.40,54.70,0.00,-2411.20,458.40,200.00}},
	{"Queens",                      {-2411.20,373.50,0.00,-2253.50,458.40,200.00}},
	{"Randolph Ind. Estate",        {1558.00,596.30,-89.00,1823.00,823.20,110.90}},
	{"Redsands East",               {1817.30,2011.80,-89.00,2106.70,2202.70,110.90}},
	{"Redsands East",               {1817.30,2202.70,-89.00,2011.90,2342.80,110.90}},
	{"Redsands East",               {1848.40,2342.80,-89.00,2011.90,2478.40,110.90}},
	{"Redsands West",               {1236.60,1883.10,-89.00,1777.30,2142.80,110.90}},
	{"Redsands West",               {1297.40,2142.80,-89.00,1777.30,2243.20,110.90}},
	{"Redsands West",               {1377.30,2243.20,-89.00,1704.50,2433.20,110.90}},
	{"Redsands West",               {1704.50,2243.20,-89.00,1777.30,2342.80,110.90}},
	{"Regular Tom",                 {-405.70,1712.80,-3.00,-276.70,1892.70,200.00}},
	{"Richman",                     {647.50,-1118.20,-89.00,787.40,-954.60,110.90}},
	{"Richman",                     {647.50,-954.60,-89.00,768.60,-860.60,110.90}},
	{"Richman",                     {225.10,-1369.60,-89.00,334.50,-1292.00,110.90}},
	{"Richman",                     {225.10,-1292.00,-89.00,466.20,-1235.00,110.90}},
	{"Richman",                     {72.60,-1404.90,-89.00,225.10,-1235.00,110.90}},
	{"Richman",                     {72.60,-1235.00,-89.00,321.30,-1008.10,110.90}},
	{"Richman",                     {321.30,-1235.00,-89.00,647.50,-1044.00,110.90}},
	{"Richman",                     {321.30,-1044.00,-89.00,647.50,-860.60,110.90}},
	{"Richman",                     {321.30,-860.60,-89.00,687.80,-768.00,110.90}},
	{"Richman",                     {321.30,-768.00,-89.00,700.70,-674.80,110.90}},
	{"Robada Section",              {-1119.00,1178.90,-89.00,-862.00,1351.40,110.90}},
	{"Roca Escalante",              {2237.40,2202.70,-89.00,2536.40,2542.50,110.90}},
	{"Roca Escalante",              {2536.40,2202.70,-89.00,2625.10,2442.50,110.90}},
	{"Rockshore East",              {2537.30,676.50,-89.00,2902.30,943.20,110.90}},
	{"Rockshore West",              {1997.20,596.30,-89.00,2377.30,823.20,110.90}},
	{"Rockshore West",              {2377.30,596.30,-89.00,2537.30,788.80,110.90}},
	{"Rodeo",                       {72.60,-1684.60,-89.00,225.10,-1544.10,110.90}},
	{"Rodeo",                       {72.60,-1544.10,-89.00,225.10,-1404.90,110.90}},
	{"Rodeo",                       {225.10,-1684.60,-89.00,312.80,-1501.90,110.90}},
	{"Rodeo",                       {225.10,-1501.90,-89.00,334.50,-1369.60,110.90}},
	{"Rodeo",                       {334.50,-1501.90,-89.00,422.60,-1406.00,110.90}},
	{"Rodeo",                       {312.80,-1684.60,-89.00,422.60,-1501.90,110.90}},
	{"Rodeo",                       {422.60,-1684.60,-89.00,558.00,-1570.20,110.90}},
	{"Rodeo",                       {558.00,-1684.60,-89.00,647.50,-1384.90,110.90}},
	{"Rodeo",                       {466.20,-1570.20,-89.00,558.00,-1385.00,110.90}},
	{"Rodeo",                       {422.60,-1570.20,-89.00,466.20,-1406.00,110.90}},
	{"Rodeo",                       {466.20,-1385.00,-89.00,647.50,-1235.00,110.90}},
	{"Rodeo",                       {334.50,-1406.00,-89.00,466.20,-1292.00,110.90}},
	{"Royal Casino",                {2087.30,1383.20,-89.00,2437.30,1543.20,110.90}},
	{"San Andreas Sound",           {2450.30,385.50,-100.00,2759.20,562.30,200.00}},
	{"Santa Flora",                 {-2741.00,458.40,-7.60,-2533.00,793.40,200.00}},
	{"Santa Maria Beach",           {342.60,-2173.20,-89.00,647.70,-1684.60,110.90}},
	{"Santa Maria Beach",           {72.60,-2173.20,-89.00,342.60,-1684.60,110.90}},
	{"Shady Cabin",                 {-1632.80,-2263.40,-3.00,-1601.30,-2231.70,200.00}},
	{"Shady Creeks",                {-1820.60,-2643.60,-8.00,-1226.70,-1771.60,200.00}},
	{"Shady Creeks",                {-2030.10,-2174.80,-6.10,-1820.60,-1771.60,200.00}},
	{"Sobell Rail Yards",           {2749.90,1548.90,-89.00,2923.30,1937.20,110.90}},
	{"Spinybed",                    {2121.40,2663.10,-89.00,2498.20,2861.50,110.90}},
	{"Starfish Casino",             {2437.30,1783.20,-89.00,2685.10,2012.10,110.90}},
	{"Starfish Casino",             {2437.30,1858.10,-39.00,2495.00,1970.80,60.90}},
	{"Starfish Casino",             {2162.30,1883.20,-89.00,2437.30,2012.10,110.90}},
	{"Temple",                      {1252.30,-1130.80,-89.00,1378.30,-1026.30,110.90}},
	{"Temple",                      {1252.30,-1026.30,-89.00,1391.00,-926.90,110.90}},
	{"Temple",                      {1252.30,-926.90,-89.00,1357.00,-910.10,110.90}},
	{"Temple",                      {952.60,-1130.80,-89.00,1096.40,-937.10,110.90}},
	{"Temple",                      {1096.40,-1130.80,-89.00,1252.30,-1026.30,110.90}},
	{"Temple",                      {1096.40,-1026.30,-89.00,1252.30,-910.10,110.90}},
	{"The Camel's Toe",             {2087.30,1203.20,-89.00,2640.40,1383.20,110.90}},
	{"The Clown's Pocket",          {2162.30,1783.20,-89.00,2437.30,1883.20,110.90}},
	{"The Emerald Isle",            {2011.90,2202.70,-89.00,2237.40,2508.20,110.90}},
	{"The Farm",                    {-1209.60,-1317.10,114.90,-908.10,-787.30,251.90}},
	{"Four Dragons Casino",         {1817.30,863.20,-89.00,2027.30,1083.20,110.90}},
	{"The High Roller",             {1817.30,1283.20,-89.00,2027.30,1469.20,110.90}},
	{"The Mako Span",               {1664.60,401.70,0.00,1785.10,567.20,200.00}},
	{"The Panopticon",              {-947.90,-304.30,-1.10,-319.60,327.00,200.00}},
	{"The Pink Swan",               {1817.30,1083.20,-89.00,2027.30,1283.20,110.90}},
	{"The Sherman Dam",             {-968.70,1929.40,-3.00,-481.10,2155.20,200.00}},
	{"The Strip",                   {2027.40,863.20,-89.00,2087.30,1703.20,110.90}},
	{"The Strip",                   {2106.70,1863.20,-89.00,2162.30,2202.70,110.90}},
	{"The Strip",                   {2027.40,1783.20,-89.00,2162.30,1863.20,110.90}},
	{"The Strip",                   {2027.40,1703.20,-89.00,2137.40,1783.20,110.90}},
	{"The Visage",                  {1817.30,1863.20,-89.00,2106.70,2011.80,110.90}},
	{"The Visage",                  {1817.30,1703.20,-89.00,2027.40,1863.20,110.90}},
	{"Unity Station",               {1692.60,-1971.80,-20.40,1812.60,-1932.80,79.50}},
	{"Valle Ocultado",              {-936.60,2611.40,2.00,-715.90,2847.90,200.00}},
	{"Verdant Bluffs",              {930.20,-2488.40,-89.00,1249.60,-2006.70,110.90}},
	{"Verdant Bluffs",              {1073.20,-2006.70,-89.00,1249.60,-1842.20,110.90}},
	{"Verdant Bluffs",              {1249.60,-2179.20,-89.00,1692.60,-1842.20,110.90}},
	{"Verdant Meadows",             {37.00,2337.10,-3.00,435.90,2677.90,200.00}},
	{"Verona Beach",                {647.70,-2173.20,-89.00,930.20,-1804.20,110.90}},
	{"Verona Beach",                {930.20,-2006.70,-89.00,1073.20,-1804.20,110.90}},
	{"Verona Beach",                {851.40,-1804.20,-89.00,1046.10,-1577.50,110.90}},
	{"Verona Beach",                {1161.50,-1722.20,-89.00,1323.90,-1577.50,110.90}},
	{"Verona Beach",                {1046.10,-1722.20,-89.00,1161.50,-1577.50,110.90}},
	{"Vinewood",                    {787.40,-1310.20,-89.00,952.60,-1130.80,110.90}},
	{"Vinewood",                    {787.40,-1130.80,-89.00,952.60,-954.60,110.90}},
	{"Vinewood",                    {647.50,-1227.20,-89.00,787.40,-1118.20,110.90}},
	{"Vinewood",                    {647.70,-1416.20,-89.00,787.40,-1227.20,110.90}},
	{"Whitewood Estates",           {883.30,1726.20,-89.00,1098.30,2507.20,110.90}},
	{"Whitewood Estates",           {1098.30,1726.20,-89.00,1197.30,2243.20,110.90}},
	{"Willowfield",                 {1970.60,-2179.20,-89.00,2089.00,-1852.80,110.90}},
	{"Willowfield",                 {2089.00,-2235.80,-89.00,2201.80,-1989.90,110.90}},
	{"Willowfield",                 {2089.00,-1989.90,-89.00,2324.00,-1852.80,110.90}},
	{"Willowfield",                 {2201.80,-2095.00,-89.00,2324.00,-1989.90,110.90}},
	{"Willowfield",                 {2541.70,-1941.40,-89.00,2703.50,-1852.80,110.90}},
	{"Willowfield",                 {2324.00,-2059.20,-89.00,2541.70,-1852.80,110.90}},
	{"Willowfield",                 {2541.70,-2059.20,-89.00,2703.50,-1941.40,110.90}},
	{"Yellow Bell Station",         {1377.40,2600.40,-21.90,1492.40,2687.30,78.00}},
	// Main Zones
	{"Los Santos",                  {44.60,-2892.90,-242.90,2997.00,-768.00,900.00}},
	{"Las Venturas",                {869.40,596.30,-242.90,2997.00,2993.80,900.00}},
	{"Bone County",                 {-480.50,596.30,-242.90,869.40,2993.80,900.00}},
	{"Tierra Robada",               {-2997.40,1659.60,-242.90,-480.50,2993.80,900.00}},
	{"Tierra Robada",               {-1213.90,596.30,-242.90,-480.50,1659.60,900.00}},
	{"San Fierro",                  {-2997.40,-1115.50,-242.90,-1213.90,1659.60,900.00}},
	{"Red County",                  {-1213.90,-768.00,-242.90,2997.00,596.30,900.00}},
	{"Flint County",                {-1213.90,-2892.90,-242.90,44.60,-768.00,900.00}},
	{"Whetstone",                   {-2997.40,-2892.90,-242.90,-1213.90,-1115.50,900.00}}
};

// - > Floats
static Float:RandomSpawn2[3][4] =
{
	{824.9390,		-1368.1731,		-0.5015,	319.2446},
	{828.5801,		-1371.9122,		-0.5015,	315.1644},
	{833.1729,		-1372.6681,		-0.5015,	44.8589}
};

main() { }

public OnGameModeInit()
{
	// - > Server Varijable
	SetGameModeText("VIBE v0.1");
	SendRconCommand("language #NA_RA_VNO");
	SendRconCommand("mapname San Andreas");
	SendRconCommand("weburl www.vibe-ogc.samp.info");
	DisableInteriorEnterExits();
	ManualVehicleEngineAndLights();
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	SetNameTagDrawDistance(20.0);
	LimitGlobalChatRadius(20.0);
	AllowInteriorWeapons(true);
	EnableVehicleFriendlyFire();
	EnableStuntBonusForAll(false);
	AntiDeAMX();
	Load3DLabels();
	LoadPickups();
	
	// - > MySQL Connect
	SQL = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DB);
	if(SQL == MYSQL_INVALID_HANDLE || mysql_errno(SQL) != 0)
	{
	    SendRconCommand("exit");
		print("[MySQL]: Konekcija na databazu je neuspesna proverite postavke.");
		return 1;
	}
	else print("[MySQL]: Konekcija na databazu je uspesna nastavljam ucitavanje.");
	
	// - > Ucitavanje Mapa
	static tmpobjid;
 	#include "maps\Main_Locations_Create"
 	#include "maps\Interiors_Create"

	// - > TextDrawovi
	InGameTD[0] = TextDrawCreate(255.3334, 426.4446, "www.vibe-ogc.samp.info"); 
	TextDrawLetterSize(InGameTD[0], 0.3242, 1.3759);
	TextDrawAlignment(InGameTD[0], 1);
	TextDrawColor(InGameTD[0], 997448959);
	TextDrawBackgroundColor(InGameTD[0], 255);
	TextDrawFont(InGameTD[0], 3);
	TextDrawSetProportional(InGameTD[0], 1);
	TextDrawSetShadow(InGameTD[0], 0);

	InGameTD[1] = TextDrawCreate(321.0000, 438.0592, "00:00:00_-_00.00.0000");
	TextDrawLetterSize(InGameTD[1], 0.1476, 0.8657);
	TextDrawAlignment(InGameTD[1], 1);
	TextDrawColor(InGameTD[1], -1);
	TextDrawBackgroundColor(InGameTD[1], 255);
	TextDrawFont(InGameTD[1], 2);
	TextDrawSetProportional(InGameTD[1], 1);
	TextDrawSetShadow(InGameTD[1], 0);

	InGameTD[2] = TextDrawCreate(255.9999, 417.7334, "Forum:");
	TextDrawLetterSize(InGameTD[2], 0.2423, 1.0399);
	TextDrawAlignment(InGameTD[2], 1);
	TextDrawColor(InGameTD[2], -1);
	TextDrawBackgroundColor(InGameTD[2], 255);
	TextDrawFont(InGameTD[2], 3);
	TextDrawSetProportional(InGameTD[2], 1);
	TextDrawSetShadow(InGameTD[2], 0);

	InGameTD[3] = TextDrawCreate(561.3332, 7.0666, "V");
	TextDrawLetterSize(InGameTD[3], 0.6526, 3.1514);
	TextDrawAlignment(InGameTD[3], 1);
	TextDrawColor(InGameTD[3], 997448959);
	TextDrawBackgroundColor(InGameTD[3], 255);
	TextDrawFont(InGameTD[3], 2);
	TextDrawSetProportional(InGameTD[3], 1);
	TextDrawSetShadow(InGameTD[3], 0);

	InGameTD[4] = TextDrawCreate(572.0000, 0.0148, "-");
	TextDrawLetterSize(InGameTD[4], 2.3713, 3.3546);
	TextDrawAlignment(InGameTD[4], 1);
	TextDrawColor(InGameTD[4], 997448959);
	TextDrawBackgroundColor(InGameTD[4], 255);
	TextDrawFont(InGameTD[4], 2);
	TextDrawSetProportional(InGameTD[4], 1);
	TextDrawSetShadow(InGameTD[4], 0);

	InGameTD[5] = TextDrawCreate(575.0001, 17.0222, "IBE"); 
	TextDrawLetterSize(InGameTD[5], 0.4000, 1.6000);
	TextDrawAlignment(InGameTD[5], 1);
	TextDrawColor(InGameTD[5], -1);
	TextDrawBackgroundColor(InGameTD[5], 255);
	TextDrawFont(InGameTD[5], 2);
	TextDrawSetProportional(InGameTD[5], 1);
	TextDrawSetShadow(InGameTD[5], 0);
	
	// - > MYSQL UCITAVANJA
	new Cache:bankomat_cache;
    bankomat_cache = mysql_query(SQL, "SELECT * FROM `atms`");
    if(bankomat_cache)
    {
    	new rows;
        cache_get_row_count(rows);
        if(rows)
        {
          	for(new i = 0; i < rows; i ++)
	        {
	       		new ba;
		        cache_get_value_name_int(i, "SQLID", ba);
		        if(ba > 0)
		        {
		            AtmInfo[ba][SQLID] = ba;
	                cache_get_value_name_int(i,"Postavljen_Bankomat", AtmInfo[ba][aPostavljen]);
		            cache_get_value_name_float(i,"Poz_X", AtmInfo[ba][aX]);
	                cache_get_value_name_float(i,"Poz_Y", AtmInfo[ba][aY]);
	                cache_get_value_name_float(i,"Poz_Z", AtmInfo[ba][aZ]);
	                cache_get_value_name_float(i,"Poz_Angle", AtmInfo[ba][aAngle]);
	                cache_get_value_name_int(i,"Interijer", AtmInfo[ba][aInt]);
	                cache_get_value_name_int(i,"VW", AtmInfo[ba][aVW]);
	                KreirajAtm(ba);
	                brojbankomate ++;
		        }
	        }
	    }
	    printf("[MySQL]: Ucitano bankomata - [%d].", brojbankomate);
	    cache_delete(bankomat_cache);
	}
	
	new Cache:kuce_cache;
    kuce_cache = mysql_query(SQL, "SELECT * FROM `houses`");
    if(kuce_cache)
    {
    	new rows;
        cache_get_row_count(rows);
        if(rows)
        {
          	for(new i = 0; i < rows; i ++)
	        {
	       		new k, string[500];
		        cache_get_value_name_int(i, "SQLID", k);
		        if(k > 0)
		        {
		            KucaInfo[k][SQLID] = k;
	                cache_get_value_name_int(i,"ProveraVlasnika",KucaInfo[k][kProveraVlasnika]);
					cache_get_value_name(i,"Vlasnik",KucaInfo[k][kVlasnik],MAX_PLAYER_NAME);
				    cache_get_value_name_int(i,"Vrsta",KucaInfo[k][kVrsta]);
				    cache_get_value_name_float(i,"UlazX",KucaInfo[k][kUlazX]);
				    cache_get_value_name_float(i,"UlazY",KucaInfo[k][kUlazY]);
				    cache_get_value_name_float(i,"UlazZ",KucaInfo[k][kUlazZ]);
				    cache_get_value_name_float(i,"IzlazX",KucaInfo[k][kIzlazX]);
				    cache_get_value_name_float(i,"IzlazY",KucaInfo[k][kIzlazY]);
				    cache_get_value_name_float(i,"IzlazZ",KucaInfo[k][kIzlazZ]);
				    cache_get_value_name_int(i,"Level",KucaInfo[k][kLevel]);
				    cache_get_value_name_int(i,"Cena",KucaInfo[k][kCena]);
				    cache_get_value_name_int(i,"Novac",KucaInfo[k][kNovac]);
				    cache_get_value_name_int(i,"Interior",KucaInfo[k][kInt]);
				    cache_get_value_name_int(i,"Zatvoreno",KucaInfo[k][kZatvoreno]);
				    cache_get_value_name_int(i,"VW",KucaInfo[k][kVW]);
				    cache_get_value_name_int(i,"Oruzije",KucaInfo[k][kOruzije]);
				    cache_get_value_name_int(i,"Municija",KucaInfo[k][kMunicija]);
				    cache_get_value_name_int(i,"Rent",KucaInfo[k][kRent]);
				    cache_get_value_name_int(i,"CenaRenta",KucaInfo[k][kCenaRenta]);
				    cache_get_value_name_int(i,"Zvono",KucaInfo[k][kZvono]);
				    cache_get_value_name_int(i,"Heal",KucaInfo[k][kFrizder]);
				    cache_get_value_name_int(i,"Mats",KucaInfo[k][kMats]);
				    cache_get_value_name_int(i,"Droga",KucaInfo[k][kDroga]);
				    cache_get_value_name_int(i,"Odjeca",KucaInfo[k][kOdjeca]);
				    cache_get_value_name_int(i,"VrstaIntKuce",KucaInfo[k][kVrstaIntKuce]);
				    cache_get_value_name_int(i,"Hrana",KucaInfo[k][kHrana]);
	                
	                if(KucaInfo[k][kProveraVlasnika] == 0)
			        {
		        	    format(string,sizeof(string),"{04CC29}[ KUCA NA PRODAJU ]\nVrsta: {FFFFFF}%s\n{04CC29}Cena: {FFFFFF}%d$\n{04CC29}Level: {FFFFFF}%d\n{04CC29}Adresa: {FFFFFF}%s\n{04CC29}Za kupovinu kuce /kupikucu",Vrsta_Kuce(KucaInfo[k][kVrsta]),KucaInfo[k][kCena],KucaInfo[k][kLevel],UlicaKuce(k));
		        	    KucaLabel[k] = CreateDynamic3DTextLabel(string, -1, KucaInfo[k][kUlazX], KucaInfo[k][kUlazY], KucaInfo[k][kUlazZ], 30);
		        	    KucaPickup[k] = CreateDynamicPickup(19522, 1, KucaInfo[k][kUlazX], KucaInfo[k][kUlazY], KucaInfo[k][kUlazZ]);
		        	}
		        	else if(KucaInfo[k][kProveraVlasnika] == 1)
		        	{
		                if(KucaInfo[k][kRent] == 0)
						{
							format(string,sizeof(string),"{04CC29}[ KUCA ]\nVlasnik: {FFFFFF}%s\n{04CC29}Vrsta: {FFFFFF}%s\n{04CC29}Level: {FFFFFF}%d\n{04CC29}Cena: {FFFFFF}%d$\n{04CC29}Adresa: {FFFFFF}%s",KucaInfo[k][kVlasnik],Vrsta_Kuce(KucaInfo[k][kVrsta]),KucaInfo[k][kLevel],KucaInfo[k][kCena],UlicaKuce(k));
						}
						else if(KucaInfo[k][kRent] == 1)
						{
							format(string,sizeof(string),"{04CC29}[ KUCA ]\nVlasnik: {FFFFFF}%s\n{04CC29}Vrsta: {FFFFFF}%s\n{04CC29}Level: {FFFFFF}%d\n{04CC29}Cena: {FFFFFF}%d$\n{04CC29}Cena Renta: {FFFFFF}%d$\n{04CC29}Adresa: {FFFFFF}%s\n{04CC29}Za rent kuce /rentajkucu",KucaInfo[k][kVlasnik],Vrsta_Kuce(KucaInfo[k][kVrsta]),KucaInfo[k][kLevel],KucaInfo[k][kCena],UlicaKuce(k));
						}
						KucaLabel[k] = CreateDynamic3DTextLabel(string, -1, KucaInfo[k][kUlazX],KucaInfo[k][kUlazY],KucaInfo[k][kUlazZ], 30);
		        	    KucaPickup[k] = CreateDynamicPickup(19524, 1, KucaInfo[k][kUlazX], KucaInfo[k][kUlazY], KucaInfo[k][kUlazZ]);
		        	}
		        	brojkuce ++;
		        }
	        }
	    }
	    printf("[MySQL]: Ucitano kuca - [%d].", brojkuce);
	    cache_delete(kuce_cache);
	}
	
	new Cache:stanovi_cache;
    stanovi_cache = mysql_query(SQL, "SELECT * FROM `apartments`");
    if(stanovi_cache)
    {
    	new rows;
        cache_get_row_count(rows);
        if(rows)
        {
          	for(new i = 0; i < rows; i ++)
	        {
	       		new s, string[300];
		        cache_get_value_name_int(i, "SQLID", s);
		        if(s > 0)
		        {
		            StanInfo[s][SQLID] = s;
		            cache_get_value_name_int(i,"ProveraVlasnika",StanInfo[s][sProveraVlasnika]);
					cache_get_value_name(i,"Vlasnik",StanInfo[s][sVlasnik],MAX_PLAYER_NAME);
				    cache_get_value_name_float(i,"UlazX",StanInfo[s][sUlazX]);
				    cache_get_value_name_float(i,"UlazY",StanInfo[s][sUlazY]);
				    cache_get_value_name_float(i,"UlazZ",StanInfo[s][sUlazZ]);
				    cache_get_value_name_float(i,"IzlazX",StanInfo[s][sIzlazX]);
				    cache_get_value_name_float(i,"IzlazY",StanInfo[s][sIzlazY]);
				    cache_get_value_name_float(i,"IzlazZ",StanInfo[s][sIzlazZ]);
				    cache_get_value_name_int(i,"Level",StanInfo[s][sLevel]);
				    cache_get_value_name_int(i,"Cena",StanInfo[s][sCena]);
				    cache_get_value_name_int(i,"Novac",StanInfo[s][sNovac]);
				    cache_get_value_name_int(i,"Interijer",StanInfo[s][sInt]);
				    cache_get_value_name_int(i,"Zatvoreno",StanInfo[s][sZatvoreno]);
				    cache_get_value_name_int(i,"VW",StanInfo[s][sVW]);
				    cache_get_value_name_int(i,"Oruzije",StanInfo[s][sOruzije]);
				    cache_get_value_name_int(i,"Municija",StanInfo[s][sMunicija]);
				    
				    if(StanInfo[s][sProveraVlasnika] == 0)
					{
						format(string,sizeof(string),"{56dc7d}[ STAN NA PRODAJU ]\nCena: {FFFFFF}%d$\n{56dc7d}Level: {FFFFFF}%d\nZa kupovinu {56dc7d}/kupistan",StanInfo[s][sCena], StanInfo[s][sLevel]);
						StanLabel[s] = CreateDynamic3DTextLabel(string, -1, StanInfo[s][sUlazX], StanInfo[s][sUlazY], StanInfo[s][sUlazZ], 30);
						StanPickup[s] = CreateDynamicPickup(19605, 1, StanInfo[s][sUlazX], StanInfo[s][sUlazY], StanInfo[s][sUlazZ]);
					}
					else if(StanInfo[s][sProveraVlasnika] == 1)
					{
						format(string,sizeof(string),"{56dc7d}[ STAN ]\nVlasnik: {FFFFFF}%s\n{56dc7d}Cena: {FFFFFF}%d$\n{56dc7d}Level: {FFFFFF}%d",StanInfo[s][sVlasnik],StanInfo[s][sCena],StanInfo[s][sLevel]);
						StanLabel[s] = CreateDynamic3DTextLabel(string, -1, StanInfo[s][sUlazX], StanInfo[s][sUlazY], StanInfo[s][sUlazZ], 30);
						StanPickup[s] = CreateDynamicPickup(19606, 1, StanInfo[s][sUlazX], StanInfo[s][sUlazY], StanInfo[s][sUlazZ]);
					}
				    
		        	brojstanova ++;
		        }
	        }
	    }
	    printf("[MySQL]: Ucitano stanova - [%d].", brojstanova);
	    cache_delete(stanovi_cache);
	}
	
	// - > VOZILO SYSTEM
	for(new o; o < MAX_VOZILA; o++)
	{
	    if(VoziloJeAvion(GetVehicleModel(o)) || VoziloJeBrod(GetVehicleModel(o)) || VoziloJeKamion(GetVehicleModel(o))) Fuel[o] = 80;
	    else if(VoziloJeMotor(GetVehicleModel(o))) Fuel[o] = 45;
	    else if(VoziloJeBicikla(GetVehicleModel(o)) || GetVehicleModel(o) == 538) Fuel[o] = 1000000;
	    else Fuel[o] = 45;
		if(!VoziloJeBicikla(GetVehicleModel(o)))
		{
			new engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(o, engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(o, 0, 0, alarm, doors, bonnet, boot, objective);
		}
	}
	return 1;
}

public OnGameModeExit()
{
	foreach(new i: Player)
	{
	    KillTimer(LoginTimer[i]);
	    KillTimer(PlayerTimer[i]);
	    SavePlayer(i);
	}
	mysql_close(SQL);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(Ulogovan[playerid] == 1)
	{
	   SpawnIgraca(playerid); SpawnPlayer(playerid);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
    CorrectPassword[playerid] = false;
    IncorrectPassword[playerid] = 0;
    strmid(accountRealPass[playerid], "", 0, strlen(""), 64);
    Ulogovan[playerid] = 0;
    InputPassword[playerid] = false;
    InputMail[playerid] = 0;
    ChooseCountry[playerid] = 0;
    InputAge[playerid] = 0;
    InputSex[playerid] = 0;
	DobioPay[playerid] = 0;
	AdminDuty[playerid] = 0;
	JetpackUsed[playerid] = 0;
	KillTimer(LoginTimer[playerid]);
	AdminVozilo[playerid] = -1;
	KomeSalje[playerid] = -1;
 	eData[playerid] = -1;
 	PuniGorivo[playerid] = false;
	
	// - > Ucitavanje Revove Objekata
	#include "maps\Main_Locations_Remove"
	
	// - > Player Textdrawovi
	BankaTD[playerid] = CreatePlayerTextDraw(playerid, 606.532958, 99.146400, "~b~0$");
	PlayerTextDrawLetterSize(playerid, BankaTD[playerid], 0.177662, 0.932147);
	PlayerTextDrawAlignment(playerid, BankaTD[playerid], 3);
	PlayerTextDrawColor(playerid, BankaTD[playerid], -1);
	PlayerTextDrawSetShadow(playerid, BankaTD[playerid], 0);
	PlayerTextDrawSetOutline(playerid, BankaTD[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, BankaTD[playerid], 255);
	PlayerTextDrawFont(playerid, BankaTD[playerid], 2);
	PlayerTextDrawSetProportional(playerid, BankaTD[playerid], 1);
	PlayerTextDrawSetShadow(playerid, BankaTD[playerid], 0);

	ZlatoTD[playerid] = CreatePlayerTextDraw(playerid, 606.283020, 107.946937, "~y~zlato:_0G");
	PlayerTextDrawLetterSize(playerid, ZlatoTD[playerid], 0.177662, 0.932147);
	PlayerTextDrawAlignment(playerid, ZlatoTD[playerid], 3);
	PlayerTextDrawColor(playerid, ZlatoTD[playerid], -1);
	PlayerTextDrawSetShadow(playerid, ZlatoTD[playerid], 0);
	PlayerTextDrawSetOutline(playerid, ZlatoTD[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, ZlatoTD[playerid], 255);
	PlayerTextDrawFont(playerid, ZlatoTD[playerid], 2);
	PlayerTextDrawSetProportional(playerid, ZlatoTD[playerid], 1);
	PlayerTextDrawSetShadow(playerid, ZlatoTD[playerid], 0);
	
	// - > Login Textdrawovi
	LoginTD[playerid][0] = CreatePlayerTextDraw(playerid, 330.6667, 295.2074, ""); 
	PlayerTextDrawTextSize(playerid, LoginTD[playerid][0], 93.0000, 98.0000);
	PlayerTextDrawAlignment(playerid, LoginTD[playerid][0], 1);
	PlayerTextDrawColor(playerid, LoginTD[playerid][0], 255);
	PlayerTextDrawFont(playerid, LoginTD[playerid][0], 5);
	PlayerTextDrawSetProportional(playerid, LoginTD[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, LoginTD[playerid][0], 0x00000000000);
	PlayerTextDrawSetShadow(playerid, LoginTD[playerid][0], 0);
	PlayerTextDrawSetPreviewModel(playerid, LoginTD[playerid][0], 623);
	PlayerTextDrawSetPreviewRot(playerid, LoginTD[playerid][0], 0.0000, -15.0000, -30.0000, 1.0000);
	
	LoginTD[playerid][1] = CreatePlayerTextDraw(playerid, 273.3332, 332.6964, "V"); 
	PlayerTextDrawLetterSize(playerid, LoginTD[playerid][1], 1.1553, 4.4995);
	PlayerTextDrawAlignment(playerid, LoginTD[playerid][1], 1);
	PlayerTextDrawColor(playerid, LoginTD[playerid][1], 997448959);
	PlayerTextDrawBackgroundColor(playerid, LoginTD[playerid][1], 255);
	PlayerTextDrawFont(playerid, LoginTD[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, LoginTD[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, LoginTD[playerid][1], 0);

	LoginTD[playerid][2] = CreatePlayerTextDraw(playerid, 290.3332, 327.7185, "-"); 
	PlayerTextDrawLetterSize(playerid, LoginTD[playerid][2], 3.1983, 2.8320);
	PlayerTextDrawAlignment(playerid, LoginTD[playerid][2], 1);
	PlayerTextDrawColor(playerid, LoginTD[playerid][2], 997448959);
	PlayerTextDrawBackgroundColor(playerid, LoginTD[playerid][2], 255);
	PlayerTextDrawFont(playerid, LoginTD[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, LoginTD[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, LoginTD[playerid][2], 0);

	LoginTD[playerid][3] = CreatePlayerTextDraw(playerid, 296.6666, 343.8963, "IBE"); 
	PlayerTextDrawLetterSize(playerid, LoginTD[playerid][3], 0.6693, 2.6287);
	PlayerTextDrawAlignment(playerid, LoginTD[playerid][3], 1);
	PlayerTextDrawColor(playerid, LoginTD[playerid][3], -1);
	PlayerTextDrawBackgroundColor(playerid, LoginTD[playerid][3], 255);
	PlayerTextDrawFont(playerid, LoginTD[playerid][3], 2);
	PlayerTextDrawSetProportional(playerid, LoginTD[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, LoginTD[playerid][3], 0);

	LoginTD[playerid][4] = CreatePlayerTextDraw(playerid, 211.6667, 272.3925, ""); 
	PlayerTextDrawTextSize(playerid, LoginTD[playerid][4], 90.0000, 90.0000);
	PlayerTextDrawAlignment(playerid, LoginTD[playerid][4], 1);
	PlayerTextDrawColor(playerid, LoginTD[playerid][4], 255);
	PlayerTextDrawFont(playerid, LoginTD[playerid][4], 5);
	PlayerTextDrawSetProportional(playerid, LoginTD[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, LoginTD[playerid][4], 0x00000000000);
	PlayerTextDrawSetShadow(playerid, LoginTD[playerid][4], 0);
	PlayerTextDrawSetPreviewModel(playerid, LoginTD[playerid][4], 519);
	PlayerTextDrawSetPreviewRot(playerid, LoginTD[playerid][4], -30.0000, -15.0000, -60.0000, 1.0000);
	PlayerTextDrawSetPreviewVehCol(playerid, LoginTD[playerid][4], 1, 1);
	
	// - > Brzinomer
	BrzinaTD[playerid][0] = CreatePlayerTextDraw(playerid, 625.000000, 395.988891, "usebox");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][0], 0.000000, 3.370575);
	PlayerTextDrawTextSize(playerid, BrzinaTD[playerid][0], 487.666687, 0.000000);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][0], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][0], 0);
	PlayerTextDrawUseBox(playerid, BrzinaTD[playerid][0], true);
	PlayerTextDrawBoxColor(playerid, BrzinaTD[playerid][0], 102);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][0], 0);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][0], 0);

	BrzinaTD[playerid][1] = CreatePlayerTextDraw(playerid, 489.666687, 394.903686, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][1], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, BrzinaTD[playerid][1], 133.333312, 2.488891);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][1], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][1], 255);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][1], 0);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][1], 4);

	BrzinaTD[playerid][2] = CreatePlayerTextDraw(playerid, 489.666625, 425.355621, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, BrzinaTD[playerid][2], 133.333312, 2.488891);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][2], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][2], 255);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][2], 0);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][2], 4);

	BrzinaTD[playerid][3] = CreatePlayerTextDraw(playerid, 489.666687, 395.318542, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][3], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, BrzinaTD[playerid][3], 2.000000, 31.940704);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][3], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][3], 255);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][3], 0);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][3], 4);

	BrzinaTD[playerid][4] = CreatePlayerTextDraw(playerid, 621.333190, 395.074127, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][4], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, BrzinaTD[playerid][4], 2.000000, 31.940704);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][4], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][4], 255);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][4], 0);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][4], 4);

	BrzinaTD[playerid][5] = CreatePlayerTextDraw(playerid, 528.000000, 399.466674, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][5], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, BrzinaTD[playerid][5], 1.666666, 24.474058);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][5], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][5], -1);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][5], 0);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][5], 4);

	BrzinaTD[playerid][6] = CreatePlayerTextDraw(playerid, 569.666809, 399.222167, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][6], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, BrzinaTD[playerid][6], 1.666666, 24.474058);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][6], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][6], -1);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][6], 0);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][6], 4);

	BrzinaTD[playerid][7] = CreatePlayerTextDraw(playerid, 585.000000, 383.544433, "usebox");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][7], 0.000000, 1.019959);
	PlayerTextDrawTextSize(playerid, BrzinaTD[playerid][7], 523.333312, 0.000000);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][7], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][7], 0);
	PlayerTextDrawUseBox(playerid, BrzinaTD[playerid][7], true);
	PlayerTextDrawBoxColor(playerid, BrzinaTD[playerid][7], 102);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][7], 0);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][7], 0);

	BrzinaTD[playerid][8] = CreatePlayerTextDraw(playerid, 525.000000, 380.800018, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][8], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, BrzinaTD[playerid][8], 59.000000, 1.659240);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][8], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][8], 255);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][8], 0);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][8], 4);

	BrzinaTD[playerid][9] = CreatePlayerTextDraw(playerid, 525.000000, 381.629608, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][9], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, BrzinaTD[playerid][9], 1.333374, 12.444458);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][9], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][9], 255);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][9], 0);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][9], 4);

	BrzinaTD[playerid][10] = CreatePlayerTextDraw(playerid, 583.000000, 381.799987, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][10], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, BrzinaTD[playerid][10], 1.333374, 12.444458);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][10], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][10], 255);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][10], 0);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][10], 4);

	BrzinaTD[playerid][11] = CreatePlayerTextDraw(playerid, 533.333190, 384.118591, "BRZINOMER");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][11], 0.174999, 0.799407);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][11], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][11], -1);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][11], 1);
	PlayerTextDrawBackgroundColor(playerid, BrzinaTD[playerid][11], 255);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][11], 2);
	PlayerTextDrawSetProportional(playerid, BrzinaTD[playerid][11], 1);

	BrzinaTD[playerid][12] = CreatePlayerTextDraw(playerid, 550.666625, 403.200103, "000");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][12], 0.221999, 1.069037);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][12], 2);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][12], -1);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][12], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][12], 1);
	PlayerTextDrawBackgroundColor(playerid, BrzinaTD[playerid][12], 255);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][12], 2);
	PlayerTextDrawSetProportional(playerid, BrzinaTD[playerid][12], 1);

	BrzinaTD[playerid][13] = CreatePlayerTextDraw(playerid, 541.666259, 413.155670, "KM/H");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][13], 0.164333, 0.791111);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][13], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][13], 997448959);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][13], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][13], 1);
	PlayerTextDrawBackgroundColor(playerid, BrzinaTD[playerid][13], 255);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][13], 2);
	PlayerTextDrawSetProportional(playerid, BrzinaTD[playerid][13], 1);

	BrzinaTD[playerid][14] = CreatePlayerTextDraw(playerid, 577.000000, 402.370361, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][14], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, BrzinaTD[playerid][14], 10.000000, 17.422241);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][14], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][14], 997448959);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][14], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][14], 0);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][14], 4);

	BrzinaTD[playerid][15] = CreatePlayerTextDraw(playerid, 574.333374, 418.962951, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][15], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, BrzinaTD[playerid][15], 16.666625, 2.074096);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][15], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][15], 997448959);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][15], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][15], 0);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][15], 4);

	BrzinaTD[playerid][16] = CreatePlayerTextDraw(playerid, 578.333312, 404.859252, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][16], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, BrzinaTD[playerid][16], 7.000000, 7.466674);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][16], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][16], 255);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][16], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][16], 0);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][16], 4);

	BrzinaTD[playerid][17] = CreatePlayerTextDraw(playerid, 585.666625, 401.540832, "]");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][17], 0.376666, 1.276444);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][17], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][17], 997448959);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][17], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][17], 1);
	PlayerTextDrawBackgroundColor(playerid, BrzinaTD[playerid][17], 51);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][17], 1);
	PlayerTextDrawSetProportional(playerid, BrzinaTD[playerid][17], 1);

	BrzinaTD[playerid][18] = CreatePlayerTextDraw(playerid, 606.999816, 404.200012, "45");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][18], 0.221999, 1.069037);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][18], 2);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][18], -1);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][18], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][18], 1);
	PlayerTextDrawBackgroundColor(playerid, BrzinaTD[playerid][18], 255);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][18], 2);
	PlayerTextDrawSetProportional(playerid, BrzinaTD[playerid][18], 1);

	BrzinaTD[playerid][19] = CreatePlayerTextDraw(playerid, 596.332946, 414.155609, "litara");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][19], 0.150999, 0.728888);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][19], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][19], 997448959);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][19], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][19], 1);
	PlayerTextDrawBackgroundColor(playerid, BrzinaTD[playerid][19], 255);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][19], 2);
	PlayerTextDrawSetProportional(playerid, BrzinaTD[playerid][19], 1);

	BrzinaTD[playerid][20] = CreatePlayerTextDraw(playerid, 487.333312, 389.925903, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, BrzinaTD[playerid][20], 0.000000, 0.100000);
	PlayerTextDrawTextSize(playerid, BrzinaTD[playerid][20], 49.000003, 45.214813);
	PlayerTextDrawAlignment(playerid, BrzinaTD[playerid][20], 1);
	PlayerTextDrawColor(playerid, BrzinaTD[playerid][20], -1);
	PlayerTextDrawUseBox(playerid, BrzinaTD[playerid][20], true);
	PlayerTextDrawBoxColor(playerid, BrzinaTD[playerid][20], 0);
	PlayerTextDrawBackgroundColor(playerid, BrzinaTD[playerid][20], 0x000000000000);
	PlayerTextDrawSetShadow(playerid, BrzinaTD[playerid][20], 0);
	PlayerTextDrawSetOutline(playerid, BrzinaTD[playerid][20], 0);
	PlayerTextDrawFont(playerid, BrzinaTD[playerid][20], 5);
	PlayerTextDrawSetPreviewModel(playerid, BrzinaTD[playerid][20], 560);
	PlayerTextDrawSetPreviewRot(playerid, BrzinaTD[playerid][20], 0.000000, 0.000000, -20.000000, 1.000000);

    // - > MySQL Check
    new q[144];
	mysql_format(SQL, q, sizeof(q), "SELECT * FROM `users` WHERE `Ime` = '%e'", ReturnPlayerName(playerid));
	mysql_tquery(SQL, q, "SQL_PlayerCheck", "i", playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(Ulogovan[playerid] == 1)
	{
    	Ulogovan[playerid] = 0;
    	SavePlayer(playerid);
	}
	TextDrawDestroy(InGameTD[0]);
    TextDrawDestroy(InGameTD[1]);
    TextDrawDestroy(InGameTD[2]);
    TextDrawDestroy(InGameTD[3]);
    TextDrawDestroy(InGameTD[4]);
    TextDrawDestroy(InGameTD[5]);
	PlayerTextDrawDestroy(playerid, BankaTD[playerid]);
	PlayerTextDrawDestroy(playerid, ZlatoTD[playerid]);
	PlayerTextDrawDestroy(playerid, LoginTD[playerid][0]);
	PlayerTextDrawDestroy(playerid, LoginTD[playerid][1]);
	PlayerTextDrawDestroy(playerid, LoginTD[playerid][2]);
	PlayerTextDrawDestroy(playerid, LoginTD[playerid][3]);
	PlayerTextDrawDestroy(playerid, LoginTD[playerid][4]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][0]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][1]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][2]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][3]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][4]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][5]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][6]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][7]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][8]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][9]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][10]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][11]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][12]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][13]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][14]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][15]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][16]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][17]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][18]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][19]);
	PlayerTextDrawDestroy(playerid, BrzinaTD[playerid][20]);
	KillTimer(LoginTimer[playerid]);
	if(AdminVozilo[playerid] != -1) DestroyVehicle(AdminVozilo[playerid]), AdminVozilo[playerid] = -1;
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerSkin(playerid, PI[playerid][Skin]);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SpawnIgraca(playerid);
	if(AdminVozilo[playerid] != -1) DestroyVehicle(AdminVozilo[playerid]), AdminVozilo[playerid] = -1;
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
    for(new words; words < sizeof(ZabranjeneReci); words++)
	{
		if(strfind(text, ZabranjeneReci[words], true) != -1)
		{
			va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ta rec je zabranjena ne mozete je pisati!");
			return 0;
		}
	}
	if(Ulogovan[playerid] != 1)
 	{
		va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi mogli pisati!");
		return 0;
	}
    if(chat)
	{
	    if(!strcmp(text," ") || isnull(text)) return 0;
		new string[256];
		if(IsPlayerInAnyVehicle(playerid))
		{
			format(string, sizeof(string), "{FFFFFF}(Iz vozila): {1b71bc}%s kaze: {FFFFFF}%s", ReturnPlayerName(playerid), text);
		}
		else
		{
			format(string, sizeof(string), "{FFFFFF}[%d] {1b71bc}%s kaze: {FFFFFF}%s", playerid, ReturnPlayerName(playerid), text);
		}
		ProxMessage(playerid, string, 20.0);
		new cb_string[156];
		format(cb_string, sizeof(cb_string), "{FFFFFF}%s", text);
		SetPlayerChatBubble(playerid, cb_string, 0xFFFFFFAA, 20.0, 5000);
		return 0;
	}
	return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
	if(!success)
	{
		va_SendClientMessage(playerid, 0xFF0000FF, "#Komande: {FFFFFF}Komanda ne postoji, da vidite listu komandi kucajte {FF0000}/komande.");
		PlayerPlaySound(playerid, 1052, 0.0, 0.0, 10.0);
	}
    return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    if(!ispassenger)
	{
	    foreach(new i : Player)
		{
		    if(GetPlayerVehicleID(i) == vehicleid && GetPlayerState(i) == PLAYER_STATE_DRIVER)
		    {
	     		new Float:Poz[3];
	     		new Float:smanjihp;
		        GetPlayerPos(playerid, Poz[0], Poz[1], Poz[2]);
		        SetPlayerPos(playerid, Poz[0], Poz[1], Poz[2]);
		        TogglePlayerControllable(playerid, 0);
		        GetPlayerHealth(playerid, smanjihp);
		        SetPlayerHealth(playerid, smanjihp-20);
		        PlayerTimer[playerid] = SetTimerEx("ZalediOdledi", 3000, false, "i", playerid);
		        GameTextForPlayer(playerid, "~r~NINJAJACKING ~n~~w~NIJE DOZVOLJEN", 5000, 3);
		    }
		}
	    new str[128];
		format(str, sizeof(str), "{C2A2DA}* %s ulazi u vozilo.", ReturnPlayerName(playerid));
		ProxMessage(playerid, str, 20.0);
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
    new str[128];
	format(str, sizeof(str), "{C2A2DA}* %s izlazi iz vozila.", ReturnPlayerName(playerid));
	ProxMessage(playerid, str, 20.0);
	return 1;
}

// - > Aliasi
CMD:help(const playerid) return cmd_komande(playerid);
CMD:postaviadmina(playerid, const params[]) return cmd_makeadmin(playerid, params);
CMD:adminduty(const playerid) return cmd_aduty(playerid);
CMD:aduznost(const playerid) return cmd_aduty(playerid);
CMD:aon(const playerid) return cmd_aduty(playerid);
CMD:ubij(playerid, const params[]) return cmd_kill(playerid, params);
CMD:jetpack(const playerid) return cmd_jp(playerid);
CMD:jpack(const playerid) return cmd_jp(playerid);
CMD:upozorenje(playerid, const params[]) return cmd_warn(playerid, params);
CMD:changepass(playerid, const params[]) return cmd_promenilozinku(playerid, params);
CMD:specijalnoime(playerid, const params[]) return cmd_changename(playerid, params);
CMD:zvizdi(const playerid) return cmd_z(playerid);
CMD:tiho(playerid, const params[]) return cmd_c(playerid, params);
CMD:glasno(playerid, const params[]) return cmd_s(playerid, params);
CMD:sapni(playerid, const params[]) return cmd_w(playerid, params);
CMD:idido(playerid, const params[]) return cmd_goto(playerid, params);
CMD:check(playerid, const params[]) return cmd_proveri(playerid, params);
CMD:kreirajatm(const playerid) return cmd_kreirajbankomat(playerid);
CMD:editatm(const playerid) return cmd_ebankomat(playerid);

// - > Komande
CMD:komande(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
	Dialog_Show(playerid, dialog_none, DIALOG_STYLE_MSGBOX, "{1b71bc}Komande", "{1b71bc}Komande: {FFFFFF}/b /me /do /stats /z /c /promenilozinku /s /w /eject /bankomat /gorivo /zvoni\n\
                                                                               {1b71bc}Komande: {FFFFFF}/rentajkucu /unrentajkucu /stopmusic /replay\n\
 																		       {1b71bc}Imovina: {FFFFFF}/kupikucu /kuca /kupistan /stan\n\
	                                                                           {1b71bc}Vozila: {FFFFFF}Koristite tipku 2 da upalite ili ugasite motor.", "OK", "");
	return 1;
}

CMD:stats(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
    new sat, minut, sekund, godina, mesec, dan;
	gettime(sat, minut, sekund);
	getdate(godina, mesec, dan);
    Dialog_Show(playerid, dialog_none, DIALOG_STYLE_MSGBOX, "{1b71bc}VIBE - Stats", "{1b71bc}Opste podatke:\n\
                                                                                     {1b71bc}Ime i Prezime: {FFFFFF}[%s] - {1b71bc}%02d:%02d:%02d - %02d.%02d.%02d\n\
                                                                                     {1b71bc}Pol: {FFFFFF}[%s] | {1b71bc}Godine: {FFFFFF}[%d] | {1b71bc}Drzava: {FFFFFF}[%s]\n\
                                                                                     {1b71bc}Level: {FFFFFF}[%d] | {1b71bc}Respekti: {FFFFFF}[%d/%d] | {1b71bc}Sati Igre: {FFFFFF}[%d]\n\
                                                                                     {1b71bc}Mutiran: {FFFFFF}[%s] | {1b71bc}Upozorenja: {FFFFFF}[%d/5]\n\n\
                                                                                     {1b71bc}Bogatstvo:\n\
                                                                                     {1b71bc}Novac Dzep: {FFFFFF}[%d$] | {1b71bc}Novac Banka: {FFFFFF}[%d$] | {1b71bc}Zlato: {FFFFFF}[%dg]\n\n\
                                                                                     {1b71bc}Imovina:\n\
                                                                                     {1b71bc}Kuca: {FFFFFF}[%d] | {1b71bc}Rent Kuca: {FFFFFF}[%d] | {1b71bc}Stan: {FFFFFF}[%d]", "OK", "",
																					 ReturnPlayerName(playerid), sat, minut, sekund, dan, mesec, godina, PI[playerid][Pol] == 1 ? "Musko" : "Zensko",
																					 PI[playerid][Godine], CheckCountry(PI[playerid][Drzava]), PI[playerid][Level], PI[playerid][Respekti], (PI[playerid][Level] * 2) + 2, PI[playerid][SatiIgre],
                                                                                     PI[playerid][Mutiran] == 1 ? "Da" : "Ne", PI[playerid][Warn], PI[playerid][Novac], PI[playerid][NovacBanka], PI[playerid][Zlato], PI[playerid][Kuca],
																					 PI[playerid][Rent], PI[playerid][Stan]);
	return 1;
}
CMD:b(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
    if(PI[playerid][Mutiran] != 0)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vi ste mutirani ne mozete koristiti komande!");
		
    static result[100],
		string[156];

	if(sscanf(params, "s[100]", result))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/b(occ) [tekst]");

	if(strlen(result) < 1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Tekst mora imati minimum 4, a maksimum 100 znamenki!");

	if(strlen(result) > 99)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Tekst mora imati minimum 4, a maksimum 100 znamenki!");

	format(string, sizeof(string), "{1b71bc}(( OOC | {FFFFFF}%s kaze: %s {1b71bc}))", ReturnPlayerName(playerid), result);
	ProxMessage(playerid, string, 20.0);
	return 1;
}

CMD:me(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
    if(PI[playerid][Mutiran] != 0)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vi ste mutirani ne mozete koristiti komande!");
		
    static result[100],
		string[156];

	if(sscanf(params, "s[100]", result))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/me [tekst]");

	if(strlen(result) < 1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Tekst mora imati minimum 4, a maksimum 100 znamenki!");

	if(strlen(result) > 99)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Tekst mora imati minimum 4, a maksimum 100 znamenki!");

	format(string, sizeof(string), "{C2A2DA}[/me] %s %s.", ReturnPlayerName(playerid), result);
	ProxMessage(playerid, string, 20.0);
	return 1;
}

CMD:do(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Mutiran] != 0)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vi ste mutirani ne mozete koristiti komande!");
		
    static result[100],
		string[156];

	if(sscanf(params, "s[100]", result))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/do [tekst]");

	if(strlen(result) < 1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Tekst mora imati minimum 4, a maksimum 100 znamenki!");

	if(strlen(result) > 99)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Tekst mora imati minimum 4, a maksimum 100 znamenki!");

	format(string, sizeof(string), "{C2A2DA}[/do] %s %s.", ReturnPlayerName(playerid), result);
	ProxMessage(playerid, string, 20.0);
	return 1;
}

CMD:z(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
    if(PI[playerid][Mutiran] != 0)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vi ste mutirani ne mozete koristiti komande!");
		
    static string[70];
    
 	format(string, sizeof(string), "{FFFFFF}%s zvizdi: Zzz!", ReturnPlayerName(playerid));
    ProxMessage(playerid, string, 20.0);
	return 1;
}

CMD:c(playerid, const params[])
{
    static result[100],
		string[156];
		
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Mutiran] != 0)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vi ste mutirani ne mozete koristiti komande!");

	if(sscanf(params, "s[100]", result))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/c [tekst za tiho]");
    
	if(strlen(result) < 1) 
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Tekst mora imati minimum 4, a maksimum 100 znamenki!");

	if(strlen(result) > 99)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Tekst mora imati minimum 4, a maksimum 100 znamenki!");

	if(IsPlayerInAnyVehicle(playerid))
	{
		format(string, sizeof(string), "{1b71bc}(Iz vozila): {FFFFFF}%s tiho kaze: %s", ReturnPlayerName(playerid), result);
	}
	else
	{
	    format(string, sizeof(string), "{FFFFFF}%s tiho kaze: %s", ReturnPlayerName(playerid), result);
	}
	ProxMessage(playerid, string, 5.0);
	return 1;
}

CMD:s(playerid, const params[])
{
    static result[100],
		string[156];
		
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Mutiran] != 0)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vi ste mutirani ne mozete koristiti komande!");

	if(sscanf(params, "s[100]", result))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/s [tekst za deranje/vikanje]");

	if(strlen(result) < 1)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Tekst mora imati minimum 4, a maksimum 100 znamenki!");

	if(strlen(result) > 99)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Tekst mora imati minimum 4, a maksimum 100 znamenki!");

	if(IsPlayerInAnyVehicle(playerid))
	{
		format(string, sizeof(string), "{1b71bc}(Iz vozila): {FFFFFF}%s se dere: %s", ReturnPlayerName(playerid), result);
	}
	else
	{
	    ApplyAnimation(playerid, "ON_LOOKERS", "shout_01", 3.0, 1, 0, 0, 0, 2650, 1);
	    format(string, sizeof(string), "{FFFFFF}%s se dere: %s", ReturnPlayerName(playerid), result);
	}
	ProxMessage(playerid, string, 20.0);
	return 1;
}

CMD:w(playerid, const params[])
{
    static result[100],
		string[156],
		id,
		Float:Poz[3];
		
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Mutiran] != 0)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vi ste mutirani ne mozete koristiti komande!");

	if(sscanf(params, "us[100]", id, result))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/w [ID/Ime] [Tekst za saptanje]");

	if(strlen(result) < 1)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Tekst mora imati minimum 4, a maksimum 100 znamenki!");

	if(strlen(result) > 99)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Tekst mora imati minimum 4, a maksimum 100 znamenki!");
		
	if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");

	if(id == playerid)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ne mozete sami sebi saptati!");
		
	GetPlayerPos(id, Poz[0], Poz[1], Poz[2]);

	if(!IsPlayerInRangeOfPoint(playerid, 5.0, Poz[0], Poz[1], Poz[2]))
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Taj igrac nije blizu Vas!");

	va_SendClientMessage(id, -1, "{C0C0C0}* %s Vam sapuce: %s", ReturnPlayerName(playerid), result);
	va_SendClientMessage(playerid, -1, "{C0C0C0}* Sapnuli ste %s: %s", ReturnPlayerName(id), result);

	format(string, sizeof(string), "{C2A2DA}* %s sapuce nesto osobi %s.", ReturnPlayerName(playerid), ReturnPlayerName(id));
	ProxMessage(playerid, string, 15.0);
	return 1;
}

CMD:plata(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
	if(PI[playerid][Admin] < 6)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
	    
	if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	foreach(new i : Player)
    {
    	PayDay(i);
    }
    return 1;
}

CMD:proveri(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Admin] < 2)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	static id;

	if(sscanf(params, "u", id))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/proveri [ID]");

	if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");
	    
    new sat, minut, sekund, godina, mesec, dan;
	gettime(sat, minut, sekund);
	getdate(godina, mesec, dan);
    Dialog_Show(playerid, dialog_none, DIALOG_STYLE_MSGBOX, "{1b71bc}VIBE - Stats", "{1b71bc}Opste podatke:\n\
                                                                                     {1b71bc}Ime i Prezime: {FFFFFF}[%s] - {1b71bc}%02d:%02d:%02d - %02d.%02d.%02d\n\
                                                                                     {1b71bc}Pol: {FFFFFF}[%s] | {1b71bc}Godine: {FFFFFF}[%d] | {1b71bc}Drzava: {FFFFFF}[%s]\n\
                                                                                     {1b71bc}Level: {FFFFFF}[%d] | {1b71bc}Respekti: {FFFFFF}[%d/%d] | {1b71bc}Sati Igre: {FFFFFF}[%d]\n\
                                                                                     {1b71bc}Mutiran: {FFFFFF}[%s] | {1b71bc}Upozorenja: {FFFFFF}[%d/5]\n\n\
                                                                                     {1b71bc}Bogatstvo:\n\
                                                                                     {1b71bc}Novac Dzep: {FFFFFF}[%d$] | {1b71bc}Novac Banka: {FFFFFF}[%d$] | {1b71bc}Zlato: {FFFFFF}[%dg]\n\n\
                                                                                     {1b71bc}Imovina:\n\
                                                                                     {1b71bc}Kuca: {FFFFFF}[%d] | {1b71bc}Rent Kuca: {FFFFFF}[%d] | {1b71bc}Stan: {FFFFFF}[%d]", "OK", "",
																					 ReturnPlayerName(id), sat, minut, sekund, dan, mesec, godina, PI[id][Pol] == 1 ? "Musko" : "Zensko",
																					 PI[id][Godine], CheckCountry(PI[id][Drzava]), PI[id][Level], PI[id][Respekti], (PI[id][Level] * 2) + 2, PI[id][SatiIgre],
                                                                                     PI[id][Mutiran] == 1 ? "Da" : "Ne", PI[id][Warn], PI[id][Novac], PI[id][NovacBanka], PI[id][Zlato], PI[id][Kuca],
																					 PI[id][Rent], PI[id][Stan]);
	return 1;
}

CMD:makeadmin(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Admin] < 6)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	static id,
		level;

	if(sscanf(params, "ud", id, level))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/makeadmin [ID] [Level]");

	if(id == INVALID_PLAYER_ID)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");

	if(level < 0 || level > 6)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Admin Level ne moze biti manji od 0 i veci od 6!");
		
	if(level == 0)
	{
	    va_SendClientMessage(id, 0xFF0000FF, "[ADMIN]: {FFFFFF}Admin %s vam je skinuo admina.", ReturnPlayerName(playerid));
		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Igracu %s ste skinuli admina.", ReturnPlayerName(id));
		
		PI[id][Admin] = level;
		if(PI[playerid][Pol] == 1) { PI[id][Skin] = 240; SetPlayerSkin(id, PI[playerid][Skin]); }
		else if(PI[playerid][Pol] == 2) { PI[id][Skin] = 91; SetPlayerSkin(id, PI[playerid][Skin]); }
	}
	else
	{
	    PI[id][Admin] = level;
	    if(PI[playerid][Pol] == 1) { PI[id][Skin] = 294; SetPlayerSkin(id, PI[playerid][Skin]); }
		else if(PI[playerid][Pol] == 2) { PI[id][Skin] = 211; SetPlayerSkin(id, PI[playerid][Skin]); }
		va_SendClientMessage(id, 0xFF0000FF, "[ADMIN]: {FFFFFF}Admin %s vam je dao Admin Level %d.", ReturnPlayerName(playerid), level);
		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Igracu %s ste postavili Admin Level %d.", ReturnPlayerName(id), level);
	}
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Admin` = '%d', `Skin` = '%d' WHERE `SQLID` = '%d'", PI[id][Admin], PI[id][Skin], PI[id][SQLID]);
	return 1;
}

CMD:makevip(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Admin] < 6)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	static id,
		level;

	if(sscanf(params, "ud", id, level))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/makevip [ID] [Level]");

	if(id == INVALID_PLAYER_ID)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");

	if(level < 0 || level > 4)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vip Level ne moze biti manji od 0 i veci od 4!");

	if(level == 0)
	{
	    va_SendClientMessage(id, 0xFF0000FF, "[ADMIN]: {FFFFFF}Admin %s vam je skinuo vipa.", ReturnPlayerName(playerid));
		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Igracu %s ste skinuli vipa.", ReturnPlayerName(id));

		PI[id][Vip] = level;
	}
	else
	{
	    PI[id][Vip] = level;
		va_SendClientMessage(id, 0xFF0000FF, "[ADMIN]: {FFFFFF}Admin %s vam je dao Vip Level %d.", ReturnPlayerName(playerid), level);
		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Igracu %s ste postavili Vip Level %d.", ReturnPlayerName(id), level);
	}
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Vip` = '%d' WHERE `SQLID` = '%d'", PI[id][Vip], PI[id][SQLID]);
	return 1;
}

CMD:cc(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
	if(PI[playerid][Admin] < 1)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
	    
    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	foreach(new i : Player) { ClearChat(i, 100); }
 	va_SendClientMessageToAll(0x1b71bcFF, "VIBE: {FFFFFF}Chat cleared!");
	va_SendClientMessageToAll(-1, "| www{1b71bc}.vibeogc.samp.{FFFFFF}info |");
	
	static str[128];
	format(str, sizeof(str), "[ADMIN]: %s je ocistio chat.", ReturnPlayerName(playerid));
	AdminMessage(0xFF0000FF, str);
	return 1;
}

CMD:aduty(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
	if(PI[playerid][Admin] < 1)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
	    
	if(AdminDuty[playerid] == 0)
	{
		va_SendClientMessageToAll(0xFF0000FF, "(( {FFFFFF}%s {FF0000}%s {FFFFFF}je sada na duznosti za pomoc kucajte {FF0000}/report. ))", GetStaffRankName(PI[playerid][Admin]), ReturnPlayerName(playerid));
		AdminDuty[playerid] = 1;
		SetPlayerArmour(playerid, 100);
		SetPlayerHealth(playerid, 100);
	}
	else
	{
        AdminDuty[playerid] = 0;
		SetPlayerArmour(playerid, 0);
		SetPlayerHealth(playerid, 100);
		va_SendClientMessageToAll(0xFF0000FF, "(( {FFFFFF}%s {FF0000}%s {FFFFFF}vise nije na duznosti molimo strpljenje. {FF0000}))", GetStaffRankName(PI[playerid][Admin]), ReturnPlayerName(playerid));
	}
	return 1;
}

CMD:kill(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
	static id;
	
	if(PI[playerid][Admin] < 1)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
	    
    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	if(sscanf(params, "i", id))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/kill [ID]");

	if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");
	    
	SetPlayerHealth(id, 0);
	va_SendClientMessage(id, 0xFF0000FF, "[ADMIN]: {FFFFFF}Admin %s vas je ubio.", ReturnPlayerName(playerid));
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Ubili ste igraca %s.", ReturnPlayerName(id));
	return 1;
}

CMD:eject(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
	if(!IsPlayerInAnyVehicle(playerid))
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti u vozilu!");

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na mestu vozaca!");

	static id;

	if(sscanf(params, "u", id))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/eject [ID/Ime]");

	if(!IsPlayerConnected(id))
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Igrac je offline!");

	if(GetPlayerVehicleID(id) != GetPlayerVehicleID(playerid))
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Igrac se ne nalazi u vasem vozilu!");

	RemovePlayerFromVehicle(id);

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Izbacili ste %s iz vozila.", ReturnPlayerName(id));
	va_SendClientMessage(id, 0x1b71bcFF, "#Info: {FFFFFF}%s vas je izbacio iz vozila.", ReturnPlayerName(playerid));
	return 1;
}

CMD:freeze(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	static id;

	if(PI[playerid][Admin] < 1)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	if(sscanf(params, "i", id))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/freeze [ID]");

	if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");

	TogglePlayerControllable(id, false);
	va_SendClientMessage(id, 0xFF0000FF, "[ADMIN]: {FFFFFF}Admin %s vas je frezovao.", ReturnPlayerName(playerid));
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Frezovali ste igraca %s.", ReturnPlayerName(id));
	return 1;
}

CMD:unfreeze(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	static id;

	if(PI[playerid][Admin] < 1)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	if(sscanf(params, "i", id))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/unfreeze [ID]");

	if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");

	TogglePlayerControllable(id, true);
	va_SendClientMessage(id, 0xFF0000FF, "[ADMIN]: {FFFFFF}Admin %s vas je unfrezovao.", ReturnPlayerName(playerid));
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Unfrezovali ste igraca %s.", ReturnPlayerName(id));
	return 1;
}

CMD:rtc(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Admin] < 1)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	if(!IsPlayerInAnyVehicle(playerid))
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti u vozilu!");

	SetVehicleToRespawn(GetPlayerVehicleID(playerid));
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Respawnovali ste vozilo!");
	return 1;
}

CMD:kick(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	static id,
		razlog[64],
		str[128];

	if(PI[playerid][Admin] < 1)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	if(sscanf(params, "us[64]", id, razlog))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/kick [ID] [Razlog]");

	if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");
	    
    if(PI[playerid][Admin] == 1 && PI[id][Admin] >= 2)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ne mozete kikovati veceg Admina od sebe!");

	if(PI[playerid][Admin] == 2 && PI[id][Admin] >= 3)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ne mozete kikovati veceg Admina od sebe!");

	if(PI[playerid][Admin] == 3 && PI[id][Admin] >= 4)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ne mozete kikovati veceg Admina od sebe!");

	if(PI[playerid][Admin] == 5 && PI[id][Admin] >= 6)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ne mozete kikovati veceg Admina od sebe!");

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Kickovali ste igraca %s | Razlog: %s.", ReturnPlayerName(id), razlog);
	format(str, sizeof(str), "{ddd74e}[AdminInfo]: {FFFFFF}Admin %s je kickovao igraca %s | Razlog: %s!", ReturnPlayerName(playerid), ReturnPlayerName(id), razlog);
	AdminMessage(-1, str);
	
	va_SendClientMessage(id, 0xFF0000FF, "[ADMIN]: {FFFFFF}Kickovani ste od strane Admina %s, Razlog: %s.", ReturnPlayerName(playerid), razlog);
	PlayerTimer[id] = SetTimerEx("KonektKick", 1000, 0, "d", id);
	return 1;
}

CMD:ban(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
    if(PI[playerid][Admin] < 3)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
	
	static id,
		razlog[80];

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	if(sscanf(params, "us[40]", id, razlog))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/ban [ID/Ime] [Razlog]");

	if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");

	if(id == playerid)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ne mozete banovati sami sebe!");

	if(Ulogovan[id] != 1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Taj igrac nije ulogovan!");

	if(PI[id][Banovan] == 1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Taj Igrac je vec banovan!");

	if(strlen(razlog) < 3 || strlen(razlog) > 40)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Razlog ne moze imati manje od 3 i vise od 40 znakova!");

	if(PI[playerid][Admin] == 5 && PI[id][Admin] >= 6)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ne mozes banovati Vlasnika!");

	if(PI[playerid][Admin] == 4 && PI[id][Admin] >= 5)
		va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ne mozes banovati Direktora");

 	va_SendClientMessageToAll(0xFF0000FF, "#BAN: {FFFFFF}Admin %s je banovao igraca %s | Razlog: %s.", ReturnPlayerName(playerid), ReturnPlayerName(id), razlog);
 	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Banovali ste igraca %s | Razlog: %s", ReturnPlayerName(id), razlog);
	 
	PI[id][Banovan] = 1;
	format(PI[id][BRazlog], 40, razlog);
 	mysql_tqueryEx(SQL, "UPDATE `users` SET `Banovan` = '%d', `BRazlog` = '%e' WHERE `SQLID` = '%d'", PI[id][Banovan], razlog, PI[id][SQLID]);
	
	PlayerTimer[id] = SetTimerEx("KonektBan", 1000, 0, "d", id);
    return 1;
}

CMD:unban(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
    if(PI[playerid][Admin] < 3)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	new imeigraca[MAX_PLAYER_NAME];

	if(sscanf(params, "s[24]", imeigraca))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/unban [Ime_Prezime]");

	new query[128];
	mysql_format(SQL, query, sizeof(query), "SELECT `SQLID` FROM `users` WHERE `Ime` = '%e' LIMIT 1", imeigraca);
	mysql_tquery(SQL, query, "CheckPlayerUnBan", "is", playerid, imeigraca);
	return 1;
}

CMD:obrisiacc(playerid, const params[])
{
    static acc[32];

    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Admin] < 6)
    	return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
    	
    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	if(sscanf(params, "s[32]", acc))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/obrisiacc [Ime_Prezime]");

	new query[128];
	mysql_format(SQL, query, sizeof(query), "DELETE FROM `users` WHERE `Ime` = '%e'", acc);
	mysql_tquery(SQL, query, "CheckPlayerDelete", "is", playerid, acc);
    return 1;
}

CMD:jp(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Admin] < 1)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");
	    
    static Float: Poz[3];
	if(JetpackUsed[playerid] == 0)
	{
 		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
   		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uzeli ste JetPack da ga unistite koristite /jetpack.");
   		JetpackUsed[playerid] = 1;
	}
	else
	{
		GetPlayerPos(playerid, Poz[0], Poz[1], Poz[2]);
		SetPlayerPos(playerid, Poz[0], Poz[1], Poz[2]);
		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}JetPack koji ste stvorili je unisten.");
		JetpackUsed[playerid] = 0;
	}
	return 1;
}

CMD:kreirajbankomat(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Admin] < 6)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");
	    
    static idatm,
		Float:Pos[4];

	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	GetPlayerFacingAngle(playerid, Pos[3]);

	for(new id = 1; id < MAX_ATM; id++)
	{
	    if(AtmInfo[id][SQLID] < 1)
		{
            idatm = id; break;
        }
	}
	if(idatm == 0) return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Maksimum bankomata je dostignut!");
	
	AtmInfo[idatm][SQLID] = idatm;
	AtmInfo[idatm][aPostavljen] = 1; 
    AtmInfo[idatm][aX] = Pos[0];
	AtmInfo[idatm][aY] = Pos[1];
	AtmInfo[idatm][aZ] = Pos[2];
	AtmInfo[idatm][aAngle] = Pos[3];
    AtmInfo[idatm][aInt] = GetPlayerInterior(playerid);
	AtmInfo[idatm][aVW] = GetPlayerVirtualWorld(playerid);

	KreirajAtm(idatm);
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Kreirali ste bankomat ID: %d (/ebankomat)!", idatm);
	
	mysql_tqueryEx(SQL, "INSERT INTO `atms` (SQLID, Postavljen_Bankomat, Poz_X, Poz_Y, Poz_Z, Poz_Angle, Interijer, VW) \
  		VALUES( '%d', '%d', '%f', '%f', '%f', '%f', '%d', '%d')", idatm, 1, Pos[0], Pos[1], Pos[2], Pos[3], AtmInfo[idatm][aInt], AtmInfo[idatm][aVW]);
    return 1;
}

CMD:ebankomat(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Admin] < 6)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	new idatm;
	idatm = GetNearestAtm(playerid);
	if(idatm == -1) return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nema bankomata u blizini!");

	DestroyDynamic3DTextLabel(AtmInfo[idatm][aAtmLabel]);
	eData[playerid] = idatm;
	EditDynamicObject(playerid,AtmInfo[idatm][aObjekat]);
	
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Editujete poziciju bankomata ID: %d!", idatm);
	return 1;
}

CMD:obrisibankomat(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Admin] < 6)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");
	    
    new atmid;
	atmid = GetNearestAtm(playerid);
	if(atmid == -1) return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nema bankomata u blizini!");

	DestroyDynamic3DTextLabel(AtmInfo[atmid][aAtmLabel]);
	DestroyDynamicObject(AtmInfo[atmid][aObjekat]);
	AtmInfo[atmid][SQLID] = 0;
	AtmInfo[atmid][aX] = 0, AtmInfo[atmid][aY] = 0, AtmInfo[atmid][aZ] = 0;

	mysql_tqueryEx(SQL, "DELETE FROM `atms` WHERE `SQLID` = '%d'", atmid);
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Obrisali ste bankomat ID: %d!", atmid);
	return 1;
}

CMD:bankomat(const playerid)
{
    for(new i = 1; i < MAX_ATM; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 1.5, AtmInfo[i][aX], AtmInfo[i][aY], AtmInfo[i][aZ]) && !IsPlayerInAnyVehicle(playerid))
		{
		    if(PI[playerid][Kartica] == 0)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate bankovni racun.");
            
            Dialog_Show(playerid, dialog_bankomat, DIALOG_STYLE_LIST, "{1b71bc}Bankomat Meni", "{1b71bc}(1). {FFFFFF}Stanje na racunu\n{1b71bc}(2). {FFFFFF}Podigni Novac", "Odaberi", "Izlaz");
			break;
		}
	}
    return 1;
}

CMD:kreirajkucu(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Admin] < 6)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");
	    
	static idkuce = 0,
		vrsta,
		level,
		cena,
		string[500];

	new Float:Pos[3];

	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);

	if(sscanf(params, "iii", vrsta, level, cena))
	{
	    va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/kreirajkucu [Vrsta] [Level] [Cena]");
	    va_SendClientMessage(playerid, -1, "Vrste Kuca | 0: Mala | 1: Srednja | 2: Velika | 3: Villa");
	    return 1;
	}
    
    for(new id = 1; id < MAX_KUCA; id++)
	{
	    if(KucaInfo[id][SQLID] < 1)
        {
            idkuce = id; break;
        }
	}
    if(idkuce == 0) return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Maksimum kuca je dostignut!");
	if(vrsta == 0) // MALA KUCA
	{
        KucaInfo[idkuce][kIzlazX] = 223.0732;
    	KucaInfo[idkuce][kIzlazY] = 1288.3668;
    	KucaInfo[idkuce][kIzlazZ] = 1082.1406;
    	KucaInfo[idkuce][kInt] = 1;
    	KucaInfo[idkuce][kVrsta] = MALA_KUCA;
    	KucaInfo[idkuce][kVrstaIntKuce] = 1;
	}
	else if(vrsta == 1) // SREDNJA KUCA
	{
        KucaInfo[idkuce][kIzlazX] = 2365.2822;
    	KucaInfo[idkuce][kIzlazY] = -1134.5186;
    	KucaInfo[idkuce][kIzlazZ] = 1050.8750;
    	KucaInfo[idkuce][kInt] = 8;
    	KucaInfo[idkuce][kVrsta] = SREDNJA_KUCA;
    	KucaInfo[idkuce][kVrstaIntKuce] = 2;
	}
	else if(vrsta == 2) // VELIKA KUCA
	{
        KucaInfo[idkuce][kIzlazX] = 2317.8977;
    	KucaInfo[idkuce][kIzlazY] = -1025.7722;
    	KucaInfo[idkuce][kIzlazZ] = 1050.2109;
    	KucaInfo[idkuce][kInt] = 9;
    	KucaInfo[idkuce][kVrsta] = VELIKA_KUCA;
    	KucaInfo[idkuce][kVrstaIntKuce] = 3;
	}
	else if(vrsta == 3) // VILLA KUCA
	{
        KucaInfo[idkuce][kIzlazX] = 140.2605;
    	KucaInfo[idkuce][kIzlazY] = 1367.4221;
    	KucaInfo[idkuce][kIzlazZ] = 1083.8615;
    	KucaInfo[idkuce][kInt] = 5;
    	KucaInfo[idkuce][kVrsta] = VILLA;
    	KucaInfo[idkuce][kVrstaIntKuce] = 4;
	}
	KucaInfo[idkuce][SQLID] = idkuce;
	KucaInfo[idkuce][kCena] = cena;
	KucaInfo[idkuce][kLevel] = level;
	KucaInfo[idkuce][kUlazX] = Pos[0];
    KucaInfo[idkuce][kUlazY] = Pos[1];
	KucaInfo[idkuce][kUlazZ] = Pos[2];
	KucaInfo[idkuce][kProveraVlasnika] = 0;
	KucaInfo[idkuce][kZatvoreno] = 1;
	KucaInfo[idkuce][kVW] = idkuce;
 	strmid(KucaInfo[idkuce][kVlasnik],"Niko",0,strlen("Niko"),255);

	format(string,sizeof(string),"{04CC29}[ KUCA NA PRODAJU ]\nVrsta: {FFFFFF}%s\n{04CC29}Cena: {FFFFFF}%d$\n{04CC29}Level: {FFFFFF}%d\n{04CC29}Adresa: {FFFFFF}%s\n{04CC29}Za kupovinu kuce /kupikucu", Vrsta_Kuce(KucaInfo[idkuce][kVrsta]), KucaInfo[idkuce][kCena], KucaInfo[idkuce][kLevel], UlicaKuce(idkuce));
    KucaLabel[idkuce] = CreateDynamic3DTextLabel(string, 0x33CCFFAA, Pos[0], Pos[1], Pos[2], 25);
    KucaPickup[idkuce] = CreateDynamicPickup(19522, 1, KucaInfo[idkuce][kUlazX], KucaInfo[idkuce][kUlazY], KucaInfo[idkuce][kUlazZ]);

	mysql_tqueryEx(SQL, "INSERT INTO `houses` (SQLID, ProveraVlasnika, Vlasnik, Vrsta, UlazX, UlazY, UlazZ, IzlazX, IzlazY, IzlazZ, Level, Cena, Interior, Zatvoreno, VW, VrstaIntKuce) \
  		VALUES( '%d', '%d', 'Niko', '%d', '%f', '%f', '%f', '%f', '%f', '%f', '%d', '%d', '%d', '%d', '%d', '%d')", idkuce, KucaInfo[idkuce][kProveraVlasnika], KucaInfo[idkuce][kVrsta],
		  																									Pos[0], Pos[1], Pos[2],
		  																								    KucaInfo[idkuce][kIzlazX], KucaInfo[idkuce][kIzlazY], KucaInfo[idkuce][kIzlazZ],
  																											level, cena, KucaInfo[idkuce][kInt], KucaInfo[idkuce][kZatvoreno], idkuce, KucaInfo[idkuce][kVrstaIntKuce]);

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Kuca je uspesno kreirana (ID Kuce: %d)!", idkuce);
	return 1;
}

CMD:kreirajstan(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Admin] < 6)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");
	    
	static idstan,
		level,
		cena,
		string[500];

	new Float:Pos[3];

	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);

	if(sscanf(params, "ii", level, cena)) return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/kreirajstan [Level] [Cena]");
	for(new id = 1; id < MAX_STANOVA; id++)
	{
	    if(StanInfo[id][SQLID] < 1)
        {
            idstan = id; break;
        }
	}
    if(idstan == 0) return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Maksimum stanova je dostignut!");

    StanInfo[idstan][SQLID] = idstan;
	StanInfo[idstan][sIzlazX] = 244.1522;
	StanInfo[idstan][sIzlazY] = 305.0730;
	StanInfo[idstan][sIzlazZ] = 999.1484;
	StanInfo[idstan][sInt] = 1;
	StanInfo[idstan][sCena] = cena;
	StanInfo[idstan][sLevel] = level;
	StanInfo[idstan][sUlazX] = Pos[0];
    StanInfo[idstan][sUlazY] = Pos[1];
	StanInfo[idstan][sUlazZ] = Pos[2];
	StanInfo[idstan][sProveraVlasnika] = 0;
	StanInfo[idstan][sZatvoreno] = 1;
	StanInfo[idstan][sVW] = idstan;
    strmid(StanInfo[idstan][sVlasnik],"Niko",0,strlen("Niko"),255);

	format(string,sizeof(string),"{56dc7d}[ STAN NA PRODAJU ]\nCena: {FFFFFF}%d$\n{56dc7d}Level: {FFFFFF}%d\nZa kupovinu {56dc7d}/kupistan", StanInfo[idstan][sCena], StanInfo[idstan][sLevel]);
	StanLabel[idstan] = CreateDynamic3DTextLabel(string, -1, StanInfo[idstan][sUlazX], StanInfo[idstan][sUlazY], StanInfo[idstan][sUlazZ], 25);
	StanPickup[idstan] = CreateDynamicPickup(19605, 1, StanInfo[idstan][sUlazX], StanInfo[idstan][sUlazY], StanInfo[idstan][sUlazZ]);
	
	mysql_tqueryEx(SQL, "INSERT INTO `apartments` (SQLID, ProveraVlasnika, Vlasnik, UlazX, UlazY, UlazZ, IzlazX, IzlazY, IzlazZ, Level, Cena, Interijer, Zatvoreno, VW) \
  		VALUES('%d', '%d', 'Niko', '%f', '%f', '%f', '%f', '%f', '%f', '%d', '%d', '%d', '%d', '%d')", idstan, StanInfo[idstan][sProveraVlasnika], Pos[0], Pos[1], Pos[2],
		  																								    StanInfo[idstan][sIzlazX], StanInfo[idstan][sIzlazY], StanInfo[idstan][sIzlazZ],
  																											level, cena, StanInfo[idstan][sInt], StanInfo[idstan][sZatvoreno], idstan);

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Stan je uspesno kreiran (ID Stana: %d)!", idstan);
	return 1;
}

CMD:aprodajstan(playerid, params[])
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Admin] < 6)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");
	    
	static id;

	if(sscanf(params, "i", id))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/aprodajstan [ID]");
	
	if(StanInfo[id][SQLID] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresan ID kuce!");

	if(StanInfo[id][sProveraVlasnika] == 0)
		 return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Taj stan nema vlasnika pa ne mozete ga prodati!");

	StanInfo[id][sProveraVlasnika] = 0;
	StanInfo[id][sOruzije] = -1;
	StanInfo[id][sNovac] = 0;
	StanInfo[id][sZatvoreno] = 1;
	StanInfo[id][sMunicija] = 0;
	StanLP(id);
	strmid(StanInfo[id][sVlasnik], "Niko", 0, strlen("Niko"), 255);

    mysql_tqueryEx(SQL, "UPDATE `apartments` SET `ProveraVlasnika` = '%d', `Vlasnik` = 'Niko', `Novac` = '%d', `Zatvoreno` = '%d', `Oruzije` = '%d', `Municija` = '%d' WHERE `SQLID` = '%d'", StanInfo[id][sProveraVlasnika], StanInfo[id][sNovac], StanInfo[id][sZatvoreno],
		StanInfo[id][sOruzije], StanInfo[id][sMunicija], StanInfo[id][SQLID]);
		
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Prodali ste stan ID: %d!", id);
	return 1;
}

CMD:estan(playerid, const params[])
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Admin] < 6)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");
	    
	static sta[20],
		ide;

	if(sscanf(params, "s[20]i",sta,ide))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/estan [level,cena,novac] [kol]");

	for(new i; i < MAX_STANOVA; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 3.0, StanInfo[i][sUlazX], StanInfo[i][sUlazY], StanInfo[i][sUlazZ]))
		{
			if(!strcmp(sta, "level", true))
			{
		        StanInfo[i][sLevel] = ide;
				StanLP(i);

				mysql_tqueryEx(SQL, "UPDATE `apartments` SET `Level` = '%d' WHERE `SQLID` = '%d'", ide, StanInfo[i][SQLID]);

				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Izmenili ste level u stanu (ID: %d) u %d!", i, ide);
			}
			else if(!strcmp(sta, "cena", true))
			{
		        StanInfo[i][sCena] = ide;
				StanLP(i);

				mysql_tqueryEx(SQL, "UPDATE `apartments` SET `Cena` = '%d' WHERE `SQLID` = '%d'", ide, StanInfo[i][SQLID]);

				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Izmenili ste cenu u stanu (ID: %d) u %d!", i, ide);
			}
			else if(!strcmp(sta, "novac", true))
			{
		        StanInfo[i][sNovac] = ide;
				StanLP(i);

				mysql_tqueryEx(SQL, "UPDATE `apartments` SET `Novac` = '%d' WHERE `SQLID` = '%d'", ide, StanInfo[i][SQLID]);
				
				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Izmenili ste novac u stanu (ID: %d) u %d!", i, ide);
			}
		}
	}
	return 1;
}

CMD:kupistan(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
    for(new i; i < sizeof(StanInfo); i++)
	{
    	if(IsPlayerInRangeOfPoint(playerid, 3.0, StanInfo[i][sUlazX], StanInfo[i][sUlazY], StanInfo[i][sUlazZ]))
    	{
    		if(!strcmp(StanInfo[i][sVlasnik], "Niko", true) && StanInfo[i][sProveraVlasnika] == 0)
    		{
		        if(PI[playerid][Stan] != -1)
					return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec imas stan!");

				if(GetPlayerScore(playerid) < StanInfo[i][sLevel])
					return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dovoljan level za kupovinu stana!");

				if(PI[playerid][Novac] < StanInfo[i][sCena])
					return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dovoljno novca za kupovinu stana!");

				strmid(StanInfo[i][sVlasnik], ReturnPlayerName(playerid), 0, strlen(ReturnPlayerName(playerid)), 255);

				StanInfo[i][sProveraVlasnika] = 1;
				PI[playerid][Stan] = i;
		        StanInfo[i][sZatvoreno] = 1;
                PI[playerid][Novac] -= StanInfo[i][sCena];
				GivePlayerMoney(playerid, -StanInfo[i][sCena]);
				StanLP(i); 

                mysql_tqueryEx(SQL, "UPDATE `apartments` SET `ProveraVlasnika` = '1', `Vlasnik` = '%s' WHERE `SQLID` = '%d'", StanInfo[i][sVlasnik], StanInfo[i][SQLID]);
				mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `Stan` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], i, PI[playerid][SQLID]);
				
		        va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Cestitamo kupili ste stan, Za komande stana kucajte /stan!");
		        return 1;
			}
			else return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Taj stan se ne prodaje!");
		}
	}
    return 1;
}

CMD:kupikucu(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
    for(new i; i < sizeof(KucaInfo); i++)
	{
    	if(IsPlayerInRangeOfPoint(playerid, 3.0, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]))
    	{
    		if(!strcmp(KucaInfo[i][kVlasnik], "Niko", true) && KucaInfo[i][kProveraVlasnika] == 0)
    		{
		        if(PI[playerid][Kuca] != -1)
					return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec imas kucu!");

				if(GetPlayerScore(playerid) < KucaInfo[i][kLevel])
					return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dovoljan level za kupovinu kuce!");

				if(PI[playerid][Novac] < KucaInfo[i][kCena])
					return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dovoljno novca za kupovinu kuce!");

				if(PI[playerid][Rent] != -1)
					return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Rentate kucu prvo unrentajte kucu da bi kupili ovu!");

				strmid(KucaInfo[i][kVlasnik], ReturnPlayerName(playerid), 0, strlen(ReturnPlayerName(playerid)), 255);
		        KucaInfo[i][kProveraVlasnika] = 1;
				SetPlayerInterior(playerid, KucaInfo[i][kInt]);
				PI[playerid][Kuca] = i;
		        SetPlayerVirtualWorld(playerid, KucaInfo[i][kVW]);
				SetPlayerPos(playerid, KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ]);
		        KucaInfo[i][kZatvoreno] = 1;
		        PI[playerid][Novac] -= KucaInfo[i][kCena];
				GivePlayerMoney(playerid, -KucaInfo[i][kCena]);
				KuceLP(i);
				
				mysql_tqueryEx(SQL, "UPDATE `houses` SET `ProveraVlasnika` = '1', `Vlasnik` = '%s' WHERE `SQLID` = '%d'", KucaInfo[i][kVlasnik], KucaInfo[i][SQLID]);
				mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `Kuca` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], i, PI[playerid][SQLID]);

				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Cestitamo kupili ste kucu, Za komande kuce kucajte /kuca!");
		        return 1;
			}
			else return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ta kuca se ne prodaje!");
		}
	}
    return 1;
}

CMD:promenispawn(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	Dialog_Show(playerid, dialog_pspawn, DIALOG_STYLE_LIST, "Promena spawna", "Market Stanica\nKuca\nRent Kuca\nStan", "Potvrdi", "Izadji");
	return 1;
}

CMD:kuca(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Kuca] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate kucu!");

	if(strcmp(KucaInfo[PI[playerid][Kuca]][kVlasnik], ReturnPlayerName(playerid), true))
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste vlasnik te kuce!");

    Dialog_Show(playerid, dialog_kuca, DIALOG_STYLE_LIST, "{1b71bc}Kuca", "{1b71bc}(1). {FFFFFF}Informacije\n\
																           {1b71bc}(2). {FFFFFF}Otkljucaj\n\
																		   {1b71bc}(3). {FFFFFF}Zakljucaj\n\
																		   {1b71bc}(4). {FFFFFF}Ostavi u kuci\n\
																		   {1b71bc}(5). {FFFFFF}Uzmi iz kuce\n\
																		   {1b71bc}(6). {FFFFFF}Prodaj kucu\n\
																		   {1b71bc}(7). {FFFFFF}Dozvoli/Zabrani Rent\n\
																		   {1b71bc}(8). {FFFFFF}Cena Renta\n\
																		   {1b71bc}(9). {FFFFFF}Nadogradi  -  Preuredi\n\
																		   {1b71bc}(10). {FFFFFF}Namernice iz frizdera", "Odaberi", "Izlaz");
	return 1;
}

CMD:stan(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Stan] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate stan!");

	if(strcmp(KucaInfo[PI[playerid][Kuca]][kVlasnik], ReturnPlayerName(playerid), true))
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste vlasnik tog stana!");

    Dialog_Show(playerid, dialog_stan, DIALOG_STYLE_LIST, "{1b71bc}Stan", "{1b71bc}(1). {FFFFFF}Informacije\n\
																           {1b71bc}(2). {FFFFFF}Otkljucaj\n\
																		   {1b71bc}(3). {FFFFFF}Zakljucaj\n\
																		   {1b71bc}(4). {FFFFFF}Ostavi u stanu\n\
																		   {1b71bc}(5). {FFFFFF}Uzmi iz stana\n\
																		   {1b71bc}(6). {FFFFFF}Prodaj stan\n\
																		   {1b71bc}(7). {FFFFFF}Preuredi", "Odaberi", "Izlaz");
	return 1;
}

CMD:rentajkucu(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
   	for(new i = 0; i < MAX_KUCA; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 3.0, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]))
		{
	        if(PI[playerid][Kuca] != -1)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec imas kucu pa ne mozes rentati!");

			if(KucaInfo[i][kRent] == 0)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}U toj kuci rent nije dozvoljen!");

			if(PI[playerid][Novac] < KucaInfo[i][kCenaRenta])
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas dovoljno novca za rent!");

			PI[playerid][Novac] -= KucaInfo[i][kCenaRenta];
			GivePlayerMoney(playerid, -KucaInfo[i][kCenaRenta]);
			KucaInfo[i][kNovac] += KucaInfo[i][kCenaRenta];

			PI[playerid][Rent] = i;
			SetPlayerInterior(playerid, KucaInfo[i][kInt]);
			SetPlayerVirtualWorld(playerid, KucaInfo[i][kVW]);
			
			mysql_tqueryEx(SQL, "UPDATE `houses` SET `Novac` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kCenaRenta], KucaInfo[i][SQLID]);
			mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `RentKuca` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][Rent], PI[playerid][SQLID]);
			
			SetPlayerPos(playerid, KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ]);
			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste rentali kucu za %d$!", KucaInfo[i][kCenaRenta]);
			return 1;
		}
	}
    return 1;
}

CMD:zvoni(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
	for(new i = 0; i < sizeof(KucaInfo); i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 5.0, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]))
		{
	        if(KucaInfo[i][kZvono] == 0)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ta kuca nema zvono!");

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Zvonite na vrata...");

			foreach(new k: Player)
			{
				if(IsPlayerInRangeOfPoint(k,25.0,KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ]))
				{
	            	va_SendClientMessage(k, 0x1b71bcFF, "#Info: {FFFFFF}Neko zvoni na vratima.");
				}
			}
		}
	}
	return 1;
}

CMD:unrentajkucu(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
	if(PI[playerid][Kuca] != -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Imas kucu ne mozes to!");

	if(PI[playerid][Rent] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ne rentas kucu!");

	PI[playerid][Rent] = -1;
    mysql_tqueryEx(SQL, "UPDATE `users` SET `RentKuca` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Rent], PI[playerid][SQLID]);
    
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Unrent ste kucu!");
	return 1;
}

CMD:aprodajkucu(playerid, const params[])
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Admin] < 6)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");
	    
	static id;

	if(sscanf(params, "i", id))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/aprodajkucu [ID]");

    if(KucaInfo[id][SQLID] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresan ID kuce!");

	if(KucaInfo[id][kProveraVlasnika] == 0)
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}Ta kuca nema vlasnika pa je ne mozete prodati!");

	KucaInfo[id][kProveraVlasnika] = 0;
	KucaInfo[id][kFrizder] = 0;
	KucaInfo[id][kOruzije] = -1;
	KucaInfo[id][kOdjeca] = 0;
    KucaInfo[id][kNovac] = 0;
	KucaInfo[id][kZatvoreno] = 1;
	KucaInfo[id][kZvono] = 0;
	KucaInfo[id][kDroga] = 0;
    KucaInfo[id][kMunicija] = 0;
	KucaInfo[id][kRent] = 0;
	KucaInfo[id][kMats] = 0;
	KucaInfo[id][kHrana] = 0;
    strmid(KucaInfo[id][kVlasnik],"Niko",0,strlen("Niko"),255);
    
    mysql_tqueryEx(SQL, "UPDATE `houses` SET `ProveraVlasnika` = '%d', `Vlasnik` = 'Niko', `Zatvoreno` = '%d', `Oruzije` = '%d', `Municija` = '%d', `Rent` = '%d', `Zvono` = '%d', `Heal` = '%d', `Mats` = '%d', `Droga` = '%d',\
		`Odjeca` = '%d', `Hrana` = '%d' WHERE `SQLID` = '%d'", KucaInfo[id][kProveraVlasnika], KucaInfo[id][kZatvoreno], KucaInfo[id][kOruzije], KucaInfo[id][kMunicija], KucaInfo[id][kRent], KucaInfo[id][kZvono],
		KucaInfo[id][kFrizder], KucaInfo[id][kMats], KucaInfo[id][kDroga], KucaInfo[id][kOdjeca], KucaInfo[id][kHrana], KucaInfo[id][SQLID]);

    KuceLP(id);
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Prodali ste kucu ID: %d!", id);
	return 1;
}

CMD:obrisikucu(playerid, const params[])
{
    static id;
    
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Admin] < 6)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	if(sscanf(params, "i", id))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/obrisikucu [ID]");

	mysql_tqueryEx(SQL, "DELETE FROM `houses` WHERE `SQLID` = '%d'", id);
	
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Obrisali ste kucu ID: %d!", id);
    return 1;
}

CMD:obrisistan(playerid, const params[])
{
    static id;

    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Admin] < 6)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	if(sscanf(params, "i", id))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/obrisistan [ID]");

	mysql_tqueryEx(SQL, "DELETE FROM `apartments` WHERE `SQLID` = '%d'", id);

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Obrisali ste stan ID: %d!", id);
    return 1;
}

CMD:ekucu(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Admin] < 6)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");
	    
	static sta[20],
		ide;

	if(sscanf(params, "s[20]i",sta,ide))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/ekucu [level,cena,novac] [kol]");

	for(new i; i < MAX_KUCA; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 3.0, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]))
		{
			if(!strcmp(sta, "level", true))
			{
			    KucaInfo[i][kLevel] = ide;
				KuceLP(i);
				mysql_tqueryEx(SQL, "UPDATE `houses` SET `Level` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kLevel], KucaInfo[i][SQLID]);
				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Izmenili ste level kuce ID: %d u %d!", i, ide);
			}
			else if(!strcmp(sta, "cena", true))
			{
			    KucaInfo[i][kCena] = ide;
		        KuceLP(i);
				mysql_tqueryEx(SQL, "UPDATE `houses` SET `Cena` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kCena], KucaInfo[i][SQLID]);
				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Izmenili ste cenu kuce ID: %d u %d!", i, ide);
			}
			else if(!strcmp(sta, "novac", true))
			{
                KucaInfo[i][kNovac] = ide;
		        KuceLP(i);
				mysql_tqueryEx(SQL, "UPDATE `houses` SET `Novac` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kNovac], KucaInfo[i][SQLID]);
				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Izmenili ste novac u kuci ID: %d u %d!", i, ide);
			}
		}
	}
	return 1;
}

CMD:sviheal(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Admin] < 5)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	foreach(new i : Player) { SetPlayerHealth(i, 100); }
	va_SendClientMessageToAll(0xFF0000FF, "#Health: {FFFFFF}Admin %s je napunio helte svim igracima.", ReturnPlayerName(playerid));
	return 1;
}

CMD:svipancir(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Admin] < 5)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	foreach(new i : Player) { SetPlayerArmour(i, 100); }
	va_SendClientMessageToAll(0x1b71bcFF, "#Armour: {FFFFFF}Admin %s je napunio pancir svim igracima.", ReturnPlayerName(playerid));
	return 1;
}

CMD:ao(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Moras se ulogovati da bi koristio ovu komandu!");

	if(PI[playerid][Admin] < 1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	static text[128];

	if(sscanf(params, "s[128]", text))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/ao [tekst]");

	va_SendClientMessageToAll(0xFF0000FF, "(( {FFFFFF}%s {FF0000}%s: {FFFFFF}%s {FF0000}))", GetStaffRankName(PI[playerid][Admin]), ReturnPlayerName(playerid), text);
	return 1;
}

CMD:sacuvajracune(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Moras se ulogovati da bi koristio ovu komandu!");
		
	if(PI[playerid][Admin] < 5)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	foreach(new i: Player)
	{
		if(Ulogovan[i] == 1)
		{
			SavePlayer(i);
		}
	}
	va_SendClientMessageToAll(0x1b71bcFF, "#Info: {FFFFFF}Svi korisnicki racuni su uspesno sacuvani!");
	return 1;
}

CMD:admini(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
	new string[150];
	foreach(new i: Player)
	{
		if(PI[i][Admin] >= 1 || PI[i][Admin] >= 6)
		{
		    format(string, 150, "{FFFFFF}%s | AL: %d | %s", ReturnPlayerName(i), PI[i][Admin], (AdminDuty[i] == 1) ? ("{2ddd65}Na duznosti") : ("{F81414}Van duznosti"));
			strcat(string, "\n");
		}
	}
	if(strlen(string) == 0) return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nijedan admin nije trenutno online!");
	Dialog_Show(playerid, dialog_none, DIALOG_STYLE_MSGBOX, "{FFFFFF}Admini Online", string, "OK", "");
	return 1;
}

CMD:mute(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Admin] < 2)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
        
    if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na admin duznosti!");

	static id,
		razlog[40];

	if(sscanf(params, "us[40]", id, razlog))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/mute [id] [razlog]");

	if(PI[id][Mutiran] == 1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Taj igrac je vec mutiran!");

	if(id == INVALID_PLAYER_ID)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");

	PI[id][Mutiran] = 1;
	
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Mutiran` = '%d' WHERE `SQLID` = '%d'", PI[id][Mutiran], PI[id][SQLID]);

	va_SendClientMessage(id, 0xFF0000FF, "#Mute: {FFFFFF}Mutirani ste od strane admina %s | Razlog: %s!", ReturnPlayerName(playerid), razlog);
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Mutirali ste igraca %s | Razlog: %s!", ReturnPlayerName(id), razlog);
	return 1;
}

CMD:unmute(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Admin] < 2)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na admin duznosti!");

	static id;

	if(sscanf(params, "u", id))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/unmute [id]");

	if(PI[id][Mutiran] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Taj igrac nije mutiran!");

	if(id == INVALID_PLAYER_ID)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");

	PI[id][Mutiran] = 0;

	mysql_tqueryEx(SQL, "UPDATE `users` SET `Mutiran` = '%d' WHERE `SQLID` = '%d'", PI[id][Mutiran], PI[id][SQLID]);

	va_SendClientMessage(id, 0xFF0000FF, "#Unmute: {FFFFFF}Unmutirani ste od strane admina %s, Sada mozete opet pisati!", ReturnPlayerName(playerid));
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Unmutirali ste igraca %s!", ReturnPlayerName(id));
	return 1;
}

CMD:mlista(const playerid)
{
   	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Admin] < 2)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na admin duznosti!");

    new string[150];
	foreach(new i: Player)
	{
		if(PI[i][Mutiran] != 0)
		{
		    format(string, 150, "{FFFFFF}[ID: %d] | %s", i, ReturnPlayerName(i));
			strcat(string, "\n");
		}
	}
	if(strlen(string) == 0) return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nema mutiranih igraca!");
	Dialog_Show(playerid, dialog_none, DIALOG_STYLE_MSGBOX, "{FFFFFF}Mutirani Igraci", string, "OK", "");
	return 1;
}

CMD:ah(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
        
	new info[800];
	if(PI[playerid][Admin] >= 1)
	{
		strcat(info, "{FF0000}Admin Level 1\n", sizeof(info));
		strcat(info, "{FFFFFF}/aduty /cc /kill /freeze /unfreeze /rtc /kick /jp /ao /fv /spec /specoff /avozilo /a /goto\n", sizeof(info));
		strcat(info, "{FFFFFF}/gethere /nitro /port\n\n", sizeof(info));
	}
	if(PI[playerid][Admin] >= 2)
	{
		strcat(info, "{FF0000}Admin Level 2\n", sizeof(info));
		strcat(info, "{FFFFFF}/proveri /warn /skiniwarn /podesivreme /podesisat /mute /unmute /mlista\n\n", sizeof(info));
	}
	if(PI[playerid][Admin] >= 3)
	{
 		strcat(info, "{FF0000}Admin Level 3\n", sizeof(info));
		strcat(info, "{FFFFFF}/ban /unban /muzika /bojavozila\n\n", sizeof(info));
	}
	if(PI[playerid][Admin] >= 4)
	{
 		strcat(info, "{FF0000}Admin Level 4 (Head Admin)\n", sizeof(info));
		strcat(info, "{FFFFFF}/setskin /agorivo /fban /setdozvole\n\n", sizeof(info));
	}
	if(PI[playerid][Admin] >= 5)
	{
 		strcat(info, "{FF0000}Admin Level 5 (Direktor)\n", sizeof(info));
		strcat(info, "{FFFFFF}/sviheal /svipancir /sacuvajracune /aoruzje\n\n", sizeof(info));
	}
	if(PI[playerid][Admin] >= 6)
	{
 		strcat(info, "{FF0000}Admin Level 6 (Vlasnik)\n", sizeof(info));
		strcat(info, "{FFFFFF}/makeadmin /plata /ubisve /dajnovac /podesinovac /changename /obrisiacc /kreirajbankomat /ebankomat\n", sizeof(info));
		strcat(info, "{FFFFFF}/obrisibankomat /kreirajkucu /ekucu /aprodajkucu /obrisikucu /kreirajstan /estan /aprodajstan\n", sizeof(info));
		strcat(info, "{FFFFFF}/obrisistan /makevip", sizeof(info));
	}
	Dialog_Show(playerid, dialog_none, DIALOG_STYLE_MSGBOX, "{FF0000}Admin Help", info, "OK", "");
	return 1;
}

CMD:viph(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Vip] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	new info[450];
	if(PI[playerid][Vip] >= 1)
	{
		strcat(info, "{1fde79}Vip Level 1\n", sizeof(info));
		strcat(info, "{FFFFFF}/g /goto /dodaci /vipskin /boombox /tunecar /dodacioff\n\n", sizeof(info));
	}
	if(PI[playerid][Vip] >= 2)
	{
		strcat(info, "{1fde79}Vip Level 2\n", sizeof(info));
		strcat(info, "{FFFFFF}/g /goto /dodaci /port /vipskin /boombox /tunecar /dodacioff\n\n", sizeof(info));
	}
	if(PI[playerid][Vip] >= 3)
	{
 		strcat(info, "{1fde79}Vip Level 3\n", sizeof(info));
		strcat(info, "{FFFFFF}/g /goto /dodaci /vrtc /port /vipskin /boombox /tunecar /fv /dodacioff\n\n", sizeof(info));
	}
	if(PI[playerid][Vip] >= 4)
	{
 		strcat(info, "{1fde79}Vip Level 4\n", sizeof(info));
		strcat(info, "{FFFFFF}/g /goto /dodaci /vrtc /port /vipskin /vipmenu /boombox /dodacioff /fv /tunecar /vportvozilo /vcarrespawn", sizeof(info));
	}
	Dialog_Show(playerid, dialog_none, DIALOG_STYLE_MSGBOX, "{1fde79}Vip Help", info, "OK", "");
	return 1;
}

CMD:vipskin(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
    if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
	    
    if(IsPlayerInAnyVehicle(playerid))
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ne mozes to u vozilu si");

	Dialog_Show(playerid, dialog_vipskin, DIALOG_STYLE_LIST, "{1fde79}Vip Skinovi", "{FFFFFF}Bumbar\nMrsa\nMiki\nMilos\nMica\nNikola\nCelavi\nProsjak :D\nSeljak\nKokosar\nZoran\nPeder\nGradjevinac\nKlovn\nStreberko", "OK", "Izadji");
	return 1;
}

CMD:dodaci(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
    if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
        
    Dialog_Show(playerid, dialog_none, DIALOG_STYLE_MSGBOX, "{1b71bc}Dodaci", "{FFFFFF}/ak47naledjima /m4naledjima /vodokotlic /pec /nilskikonj /tabla\n\
                                                                               /tec /baklja /ppancir /dollar /vatrenikostur /potkovica /kurcina /moneybag\n\
 																		       /padobran /papagaj /katana /testera /drvo /cigara /pstinger /dodacioff", "OK", "");
	return 1;
}

CMD:m4naledjima(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 0, 356, 1, 0.222186, -0.146085, 0.085346, 0.000000, 151.341934, 0.000000, 1.000000, 1.000000, 1.000000);
	return 1;
}

CMD:ak47naledjima(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 1, 355, 1, 0.253790, -0.141571, 0.094299, 0.000000, 155.042755, 0.000000, 1.000000, 1.000000, 1.000000);
	return 1;
}

CMD:tec(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

  	SetPlayerAttachedObject(playerid, 2, 372, 7, -0.149622, 0.041156, -0.073983, 270.018768, 359.987884, 357.778808, 1.000000, 1.000000, 1.000000);
	return 1;
}

CMD:baklja(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 3, 3461, 6, 0.069429, 0.032604, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000); 
	return 1;
}

CMD:pancir(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 4, 373, 1, 0.286601, -0.014752, -0.169651, 74.940216, 23.071197, 33.927280, 1.000000, 1.000000, 1.000000);
	return 1;
}

CMD:padobran(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 8, 371, 1, 0.087999, -0.125000, -0.014000, 3.299999, 86.200019, -5.300003, 1.000000, 1.000000, 1.000000);
	return 1;
}

CMD:ppancir(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 4, 19142, 1, 0.0789, 0.0449, 0.0040, 0.0000, 0.0000, -2.5999, 1.0000, 1.1139, 1.0880, 0, 0);
    return 1;
}

CMD:pstinger(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 5, 360, 1, 0.1389, -0.1640, -0.0999, 0.0000, 35.4999, 0.0000, 1.0000, 1.0000, 1.0000, 0, 0);
    return 1;
}

CMD:kurcina(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 2, 19086, 8, -0.049768, -0.014062, -0.108385, 87.458297, 263.478149, 184.123764, 0.622413, 1.041609, 1.012785);
	return 1;
}

CMD:dollar(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 5, 1274, 1, 0.806575, 0.052928, 0.013146, 0.000000, 87.540878, 0.000000, 1.000000, 1.000000, 1.000000);
	return 1;
}

CMD:cigara(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerSpecialAction(playerid, 21);
	return 1;
}

CMD:vatrenikostur(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 6, 3524, 6, 0.100679, -0.061841, 2.545831, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
	return 1;
}

CMD:potkovica(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 7, 954, 1, 0.954922, 0.030687, 0.000000, 0.000000, 268.403228, 0.000000, 1.000000, 1.000000, 1.000000);
	return 1;
}

CMD:moneybag(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 0, 1550, 1, -0.008714, -0.188819, -0.026564, 159.138153, 86.558647, 0.000000, 1.005565, 0.984468, 1.014210);
	return 1;
}

CMD:papagaj(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 8, 19078, 1, 0.311434, -0.063826, -0.161611, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
	return 1;
}

CMD:katana(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 9, 339, 1, -0.248040, 0.000000, 0.178634, 88.912078, 172.776626, 5.334595, 1.000000, 1.000000, 1.000000);
	return 1;
}

CMD:testera(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 1, 341, 1, -0.340437, -0.203787, -0.068695, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
	return 1;
}

CMD:drvo(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 2, 674, 1, -1.193789, 0.051014, 0.099190, 0.000000, 90.430030, 0.000000, 1.000000, 1.000000, 1.000000);
	return 1;
}

CMD:vodokotlic(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 3, 1211, 1, 0.916536, 0.012704, -0.003792, 0.000000, 89.479736, 0.000000, 1.000000, 1.000000, 1.000000); 
	return 1;
}

CMD:tabla(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 4, 1233, 6, 0.085374, 0.030156, 1.154913, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000); 
	return 1;
}

CMD:pec(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 5, 1777, 1, -0.455288, 0.122999, 0.000000, 0.000000, 90.075103, 177.894760, 1.000000, 1.000000, 1.000000);
	return 1;
}

CMD:nilskikonj(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Vip] < 1 && PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	SetPlayerAttachedObject(playerid, 6, 1371, 1, 0.177012, 0.000000, -0.008047, 0.000000, 89.795104, 182.353408, 1.000000, 1.000000, 1.000000);
	return 1;
}

CMD:dodacioff(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
    {
		if(IsPlayerAttachedObjectSlotUsed(playerid, i)) RemovePlayerAttachedObject(playerid, i);
    }
    return 1;
}

CMD:bojavozila(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
	if(PI[playerid][Admin] < 3)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	static id,
		col[2];

	if(sscanf(params, "udd", id, col[0], col[1]))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/bojavozila [ID/Ime] [ID Boje 1] [ID Boje 2]");

    if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");
	    
	if(!IsPlayerInAnyVehicle(playerid))
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Igrac mora biti u vozilu!");

	ChangeVehicleColor(GetPlayerVehicleID(id), col[0], col[1]);
	return 1;
}

CMD:setdozvole(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

    if(PI[playerid][Admin] < 4)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
        
    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");
	    
	static id,
		stat;
	    
	if(sscanf(params, "ui", id, stat))
	{
		va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/adozvole [ID/Nick] [Kod (1-6)]");
		va_SendClientMessage(playerid, -1, "| (1). Auto Dozvola | (2). Motor Dozvola | (3). Kamion Dozvola");
		va_SendClientMessage(playerid, -1, "| (4). Avion Dozvola | (5). Brod Dozvola");
		return 1;
	}
	
	if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");
	
	if(stat == 1)
	{
		PI[id][ADozvola] = 1;

		mysql_tqueryEx(SQL, "UPDATE `users` SET `ADozvola` = '%d' WHERE `SQLID` = '%d'", PI[id][ADozvola], PI[id][SQLID]);

		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Dali ste %s dozvolu za voznju.", ReturnPlayerName(id));
		va_SendClientMessage(id, 0xFF0000FF, "[ADMIN]: {FFFFFF}Admin %s vam je dao dozvolu za voznju.", ReturnPlayerName(playerid));
	}
	else if(stat == 2)
	{
		PI[id][MotorDozvola] = 1;

		mysql_tqueryEx(SQL, "UPDATE `users` SET `MotorDozvola` = '%d' WHERE `SQLID` = '%d'", PI[id][MotorDozvola], PI[id][SQLID]);
		
		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Dali ste %s dozvolu za motor.", ReturnPlayerName(id));
		va_SendClientMessage(id, 0xFF0000FF, "[ADMIN]: {FFFFFF}Admin %s vam je dao dozvolu za motor.", ReturnPlayerName(playerid));
	}
	else if(stat == 3)
	{
		PI[id][KamionDozvola] = 1;

		mysql_tqueryEx(SQL, "UPDATE `users` SET `KamionDozvola` = '%d' WHERE `SQLID` = '%d'", PI[id][KamionDozvola], PI[id][SQLID]);

		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Dali ste %s dozvolu za kamion.", ReturnPlayerName(id));
		va_SendClientMessage(id, 0xFF0000FF, "[ADMIN]: {FFFFFF}Admin %s vam je dao dozvolu za kamion.", ReturnPlayerName(playerid));
	}
	else if(stat == 4)
	{
		PI[id][AvionDozvola] = 1;
		
		mysql_tqueryEx(SQL, "UPDATE `users` SET `AvionDozvola` = '%d' WHERE `SQLID` = '%d'", PI[id][AvionDozvola], PI[id][SQLID]);

		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Dali ste %s dozvolu za avion.", ReturnPlayerName(id));
		va_SendClientMessage(id, 0xFF0000FF, "[ADMIN]: {FFFFFF}Admin %s vam je dao dozvolu za avion.", ReturnPlayerName(playerid));
	}
	else if(stat == 5)
	{
		PI[id][BrodDozvola] = 1;
		
		mysql_tqueryEx(SQL, "UPDATE `users` SET `BrodDozvola` = '%d' WHERE `SQLID` = '%d'", PI[id][BrodDozvola], PI[id][SQLID]);
		
		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Dali ste %s dozvolu za brod.", ReturnPlayerName(id));
		va_SendClientMessage(id, 0xFF0000FF, "[ADMIN]: {FFFFFF}Admin %s vam je dao dozvolu za brod.", ReturnPlayerName(playerid));
	}
	else return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresan kod!");
	return 1;
}

CMD:gorivo(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
	if(!IsPlayerInRangeOfPoint(playerid, 8.0, 1004.0422,-937.5357,42.3281) && !IsPlayerInRangeOfPoint(playerid, 8.0, 171.6999,-1923.0776,4.4559) && !IsPlayerInRangeOfPoint(playerid, 8.0, -91.2488,-1169.7260,2.4204) &&
		!IsPlayerInRangeOfPoint(playerid, 8.0, 1942.3732,-1772.7740,13.6406) && !IsPlayerInRangeOfPoint(playerid, 8.0, 1382.2139,460.1810,20.3452) && !IsPlayerInRangeOfPoint(playerid, 8.0, 1004.8034,-937.3431,48.2118) &&
		!IsPlayerInRangeOfPoint(playerid, 8.0, 1532.8367,-2176.9741,13.5853))
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na benzinskoj pumpi da bi sipali gorivo!");

	if(!IsPlayerInAnyVehicle(playerid))
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti u vozilu!");

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na mestu vozaca!");

	if(VoziloJeBicikla(GetVehicleModel(GetPlayerVehicleID(playerid))))
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ne mozete sipati gorivo u biciklo!");

	new l;
	if(sscanf(params, "i", l))
	{
		va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/gorivo [Litara]");
		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Cena po 1 litru je 4$!");
		return 1;
	}

	if(l < 1 || l > 80)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Minimalno Litara 1 - Maximalno Litara 20 odjednom!");

	if(PI[playerid][Novac] < l*4)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dovoljno novca!");

	if(PuniGorivo[playerid] == true)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec tocite gorivo!");

	if(VoziloJeMotor(GetVehicleModel(GetPlayerVehicleID(playerid))))
	{
	    if(floatadd(Fuel[GetPlayerVehicleID(playerid)], l) > 45)
			return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Zapremina tog rezervoara je 45 litara!");
	}
	if(VoziloJeAvion(GetVehicleModel(GetPlayerVehicleID(playerid))) || VoziloJeBrod(GetVehicleModel(GetPlayerVehicleID(playerid))) || VoziloJeKamion(GetVehicleModel(GetPlayerVehicleID(playerid))))
	{
	    if(floatadd(Fuel[GetPlayerVehicleID(playerid)], l) > 80)
			return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Zapremina tog rezervoara je 80 litara!");
	}
	else
	{
		if(floatadd(Fuel[GetPlayerVehicleID(playerid)], l) > 45)
			return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Zapremina tog rezervoara je 45 litara!");
	}
	Fuel[GetPlayerVehicleID(playerid)] = Fuel[GetPlayerVehicleID(playerid)] += l;

	GivePlayerMoney(playerid, -l*4);
	PI[playerid][Novac] -= l*4;
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][SQLID]);
	PuniGorivo[playerid] = true;
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Tocenje Goriva: {FFFFFF}Litara: %d | Cena: %d$.", l, l*4);
	GameTextForPlayer(playerid, "~w~Tocenje goriva~n~u toku...", 7000, 3);
	PlayerTimer[playerid] = SetTimerEx("GorivoFriz", 7000, false, "d", playerid);
	TogglePlayerControllable(playerid, 0);
	return 1;
}

CMD:agorivo(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
	if(PI[playerid][Admin] < 4)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	for(new o; o < MAX_VOZILA; o++)
	{
		if(VoziloJeAvion(GetVehicleModel(o)) || VoziloJeBrod(GetVehicleModel(o)) || VoziloJeKamion(GetVehicleModel(o))) Fuel[o] = 80;
 		else if(VoziloJeMotor(GetVehicleModel(o))) Fuel[o] = 25;
  		else if(VoziloJeBicikla(GetVehicleModel(o)) || GetVehicleModel(o) == 538) Fuel[o] = 1000000;
  		else Fuel[o] = 45;
	}

	static str[256];
	format(str, sizeof(str), "{ddd74e}[AdminInfo]: {FFFFFF}Admin %s je napunio sva vozila gorivom.", ReturnPlayerName(playerid));
	AdminMessage(-1, str);

	foreach(new i: Player)
	{
	    format(str, sizeof(str), "%d", Fuel[GetPlayerVehicleID(i)]),
		PlayerTextDrawSetString(playerid, BrzinaTD[playerid][18], str);
	}
	return 1;
}

CMD:fban(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Admin] < 4)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
	    
	static id,
		razlog[40];

    if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	if(sscanf(params, "us[40]", id, razlog))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/fban [ID/Nick] [Razlog]");

	if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");

	va_SendClientMessageToAll(0xFF0000FF, "#BAN: {FFFFFF}Admin %s je banovao igraca %s | Razlog: %s.", ReturnPlayerName(playerid), ReturnPlayerName(id), razlog);

    va_SendClientMessage(id, 0xA9C4E4AA, "Server closed the connection.");
	va_SendClientMessage(id, 0x1b71bcFF, "#Info: {FFFFFF}Ovo je lazni ban debilu hehe xD.");
	return 1;
}

CMD:setskin(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
	if(PI[playerid][Admin] < 4)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	static id,
		skin;

	if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	if(sscanf(params, "ui", id, skin))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/setskin [ID] [Skin ID]");

	if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");

	PI[id][Skin] = skin;
	SetPlayerSkin(id, skin);

	va_SendClientMessage(id, 0xFF0000FF, "[ADMIN]: {FFFFFF}Admin %s vam je setovao skin ID %d!", ReturnPlayerName(playerid), skin);
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste postavili skin igracu %s!", ReturnPlayerName(id));
	
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Skin` = '%d' WHERE `SQLID` = '%d'", PI[id][Skin], PI[id][SQLID]);
	return 1;
}

CMD:aoruzje(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");
		
	if(PI[playerid][Admin] < 5)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	static id,
		oruzje,
		municija;

	if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	if(sscanf(params, "uii", id, oruzje, municija))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/aoruzje [ID] [Oruzje] [Municija]");

	if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");
	    
	GivePlayerWeapon(id, oruzje, municija);
	
	va_SendClientMessage(id, 0xFF0000FF, "[ADMIN]: {FFFFFF}Admin %s vam je dao oruzje ID %d!", ReturnPlayerName(playerid), oruzje);
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Dali ste oruzje ID %d igracu %s!", oruzje, ReturnPlayerName(id));
	return 1;
}

CMD:ubisve(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Admin] < 6)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
	    
    if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	foreach(new i: Player) { SetPlayerHealth(i,0); }
	va_SendClientMessageToAll(0x1b71bcFF, "#Kill All: {FFFFFF}Admin %s je ubio sve igrace.", ReturnPlayerName(playerid));
	return 1;
}

CMD:fv(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Admin] < 1 && PI[playerid][Vip] < 3)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
	
	if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti!");

	if(!IsPlayerInAnyVehicle(playerid))
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti u vozilu!");

	RepairVehicle(GetPlayerVehicleID(playerid));

	static str[128];
    format(str, sizeof(str), "{ddd74e}[AdminInfo]: {FFFFFF}%s je popravio svoje vozilo!", ReturnPlayerName(playerid));
	AdminMessage(-1, str);

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Vozilo Popravljeno!");
	return 1;
}

CMD:dajnovac(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Admin] < 6)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
	    
	static id,
		novac,
		str[128];

	if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti!");
		
	if(sscanf(params, "ud", id, novac))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/dajnovac [ID/Ime] [Kolicina Novca]");

    if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");
	    
	if(PI[id][Novac] <= 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Igrac je u minusu sa novcem, prvo mu podesi novac na 0!");

	PI[id][Novac] += novac;
    GivePlayerMoney(id, novac);
    
	va_SendClientMessage(id, 0xFF0000FF, "[ADMIN]: {FFFFFF}Admin %s ti je dao $%d novca.", ReturnPlayerName(playerid), novac);
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Dali ste %s %d novca.", ReturnPlayerName(id), novac);

	format(str, sizeof(str), "{ddd74e}[AdminInfo]: {FFFFFF}Admin %s je dao %d$ igracu %s.", ReturnPlayerName(playerid), novac, ReturnPlayerName(id));
	AdminMessage(-1, str);

	mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d' WHERE `SQLID` = '%d'", PI[id][Novac], PI[id][SQLID]);
	return 1;
}

CMD:podesinovac(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Admin] < 6)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	static id,
	    novac,
		str[128];

	if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti!");

	if(sscanf(params, "ud", id, novac))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/podesinovac [ID/Ime] [Novac]");

    if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");

	ResetPlayerMoney(id);
	PI[id][Novac] += novac;
    GivePlayerMoney(id, novac);

	va_SendClientMessage(id, 0xFF0000FF, "[ADMIN]: {FFFFFF}Admin %s ti je podesio novac na $%d.", ReturnPlayerName(playerid), novac);
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Podesi ste novac igracu %s na %d$.", ReturnPlayerName(id), novac);

	format(str, sizeof(str), "{ddd74e}[AdminInfo]: {FFFFFF}Admin %s je podesio %d$ igracu %s.", ReturnPlayerName(playerid), novac, ReturnPlayerName(id));
	AdminMessage(-1, str);

	mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d' WHERE `SQLID` = '%d'", PI[id][Novac], PI[id][SQLID]);
	return 1;
}

CMD:spec(playerid, params[])
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Admin] < 1)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	static id;
	
	if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti!");

	if(sscanf(params, "u", id))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/spec [ID]");
	
	if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");

	TogglePlayerSpectating(playerid, 1);
	PlayerSpectatePlayer(playerid, id);
	SetPlayerInterior(playerid, GetPlayerInterior(id));
	SpecaID[playerid] = id;
	SpecTip[playerid] = 1;
	return 1;
}

CMD:specoff(playerid, params[])
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate se ulogovati da bi koristili komande!");

	if(PI[playerid][Admin] < 1)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
	
 	if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti!");

	TogglePlayerSpectating(playerid, 0);
	SetPlayerHealth(playerid, 99.0);
	SpecaID[playerid] = INVALID_PLAYER_ID;
	SpecTip[playerid] = 0;
	return 1;
}

CMD:avozilo(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Moras se ulogovati da bi koristio ovu komandu!");

    if(PI[playerid][Admin] < 1)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
	
	if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti!");

	if(AdminVozilo[playerid] == -1)
	{
	    Dialog_Show(playerid, dialog_avozila, DIALOG_STYLE_LIST, "{1b71bc}Admin Vozila", "{1b71bc}(1). {FFFFFF}Sultan\n\
																						  {1b71bc}(2). {FFFFFF}NRG-500\n\
																						  {1b71bc}(3). {FFFFFF}Huntley", "Odaberi", "Izadji");
	}
	else
	{
		DestroyVehicle(AdminVozilo[playerid]);
		AdminVozilo[playerid] = -1;
		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Unistili ste Admin Vozilo.");
	}
	return 1;
}

CMD:a(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Moras se ulogovati da bi koristio ovu komandu!");

	if(PI[playerid][Admin] < 1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	static text[128],
		 string[300];

	if(sscanf(params, "s[128]", text))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/a [tekst]");

	format(string, sizeof(string), "{FF0000}[A] %s - %s: {FFFFFF}%s", GetStaffRankName(PI[playerid][Admin]), ReturnPlayerName(playerid), text);
	AdminMessage(-1,string);
	return 1;
}

CMD:g(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Moras se ulogovati da bi koristio ovu komandu!");

	if(PI[playerid][Admin] < 1 && PI[playerid][Vip] < 1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	static text[128],
		 string[300],
		 rank[25];

	if(sscanf(params, "s[128]", text))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/g [tekst]");
		
	switch(PI[playerid][Admin])
	{
	    case 1: rank = "Admin Level 1";
	    case 2: rank = "Admin Level 2";
	    case 3: rank = "Admin Level 3";
	    case 4: rank = "Head Admin";
	    case 5: rank = "Direktor";
	    case 6: rank = "Vlasnik";
	}
	switch(PI[playerid][Vip])
	{
	    case 1: rank = "Vip Level 1";
	    case 2: rank = "Vip Level 2";
	    case 3: rank = "Vip Level 3";
	    case 4: rank = "Vip Level 4";
	}
	
	format(string, sizeof(string), "{1fde79}[G] %s - %s: {FFFFFF}%s", rank, ReturnPlayerName(playerid), text);
	AVipPMessage(-1,string);
	return 1;
}

CMD:warn(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Moras se ulogovati da bi koristio ovu komandu!");
		
	if(PI[playerid][Admin] < 2)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	static id,
		str[128],
		razlog[40];

	if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na admin duznosti!");

	if(sscanf(params, "us[40]", id, razlog))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/warn [ID] [Razlog]");

	if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");
	    

	PI[id][Warn] += 1;
	
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Warn` = '%d' WHERE `SQLID` = '%d'", PI[id][Warn], PI[id][SQLID]);

	va_SendClientMessage(id, 0x1b71bcFF, "#Info: {FFFFFF}Admin %s vam je dao warn (%d po redu) | Razlog: %s", ReturnPlayerName(playerid), PI[id][Warn], razlog);
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Dali ste warn igracu %s | Razlog: %s", ReturnPlayerName(id), razlog);

    format(str, sizeof(str), "{ddd74e}[AdminInfo]: {FFFFFF}Admin %s je dao warn igracu %s | Razlog: %s", ReturnPlayerName(playerid), ReturnPlayerName(id), razlog);
	AdminMessage(-1, str);

	if(PI[id][Warn] >= 5)
	{
		va_SendClientMessageToAll(0xFF0000FF, "#Ban: {FFFFFF}Igrac %s je banovan sa servera zbog ogranicenog broja warnova (5/5)", ReturnPlayerName(id));
		PI[id][Banovan] = 1;
		format(PI[id][BRazlog], 40, "5/5 Warnova");
		mysql_tqueryEx(SQL, "UPDATE `users` SET `Banovan` = '%d', `BRazlog` = '%e' WHERE `SQLID` = '%d'", PI[id][Banovan], PI[id][BRazlog], PI[id][SQLID]);
		PlayerTimer[id] = SetTimerEx("KonektBan", 1000, 0, "d", id);
	}
	return 1;
}

CMD:skiniwarn(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Moras se ulogovati da bi koristio ovu komandu!");

	if(PI[playerid][Admin] < 2)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
		
    if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na admin duznosti!");
		
	static id,
		str[128];

	if(sscanf(params, "u", id))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/skiniwarn [ID/Ime]");

	if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");
	
	va_SendClientMessage(id, 0x1b71bcFF, "#Info: {FFFFFF}Admin %s vam je skinuo warn | Warn: %d/5", ReturnPlayerName(playerid), PI[id][Warn]);
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Skinuli ste warn igracu %s | Warn: %d/5!", ReturnPlayerName(id), PI[id][Warn]);
	
	format(str, sizeof(str), "{ddd74e}[AdminInfo]: {FFFFFF}Admin %s je skinuo warn igracu %s | Warn: %d/5!", ReturnPlayerName(playerid), ReturnPlayerName(id), PI[id][Warn]);
	AdminMessage(-1, str);

	PI[id][Warn] -= 1;
	
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Warn` = '%d' WHERE `SQLID` = '%d'", PI[id][Warn], PI[id][SQLID]);
	return 1;
}

CMD:promenilozinku(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Moras se ulogovati da bi koristio ovu komandu!");
		
	static pass[26];

	if(sscanf(params,"s[26]", pass))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/promijenilozinku [Nova Lozinka (Min 6 - Max 25 znakova)]");

	if(strlen(pass) < 6)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Lozinka je kratka (Min 6 znakova)!");

	if(strlen(pass) > 25)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Lozinka je previse dugacka (Max 25 znakova)!");

    strmid(PI[playerid][Password], pass, 0, strlen(pass), 128);
	SHA256_PassHash(pass, ReturnPlayerName(playerid), PI[playerid][Password], 128);

	mysql_tqueryEx(SQL, "UPDATE `users` SET `Password` = '%e' WHERE `SQLID` = '%d'", PI[playerid][Password], PI[playerid][SQLID]);

	va_SendClientMessage(playerid, 0x1b71bcFF,"--------------------------------------------------------------");
	va_SendClientMessage(playerid, 0xFF0000FF,"- {FFFFFF}Vasa nova Lozinka je {1b71bc}%s{FFFFFF} .", pass);
	va_SendClientMessage(playerid, 0xFF0000FF,"- {FFFFFF}Slikajte sebi ovo ( F8 ) !");
	va_SendClientMessage(playerid, 0x1b71bcFF,"--------------------------------------------------------------");
	return 1;
}

CMD:changename(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Moras se ulogovati da bi koristio ovu komandu!");
		
	if(PI[playerid][Admin] < 6)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
		
    if(AdminDuty[playerid] == 0)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	static id,
		novoime[ MAX_PLAYER_NAME ];

	if(sscanf(params, "us[24]", id, novoime))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/changename [id] [Ime_Prezime]");

	if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");

    new q[128];
	mysql_format(SQL, q, sizeof(q), "SELECT `SQLID` FROM `users` WHERE `Ime` = '%e'", novoime);
	mysql_tquery(SQL, q, "CheckPlayerRename", "iis", playerid, id, novoime);
	return 1;
}

CMD:muzika(playerid, const params[])
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Moras se ulogovati da bi koristio ovu komandu!");
		
    if(PI[playerid][Admin] < 3)
        return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	static link[500],
		pesma[100];

  	if(sscanf(params, "s[100]s[500]", pesma, link))
  		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/muzika [Ime_muzike-izvodjac] [link]");

	strreplace(pesma, '_', ' ');

	foreach(new i : Player)
 	{
		StopAudioStreamForPlayer(i);
		PlayAudioStreamForPlayer(i, link);
    	va_SendClientMessageToAll(-1, "{04CC29}[MUZIKA]: {FFFFFF}Admin %s je pustio pesmu : {04CC29}%s {FFFFFF}(/stopmusic /replay).", ReturnPlayerName(playerid), pesma);
  	}
    return 1;
}

CMD:stopmusic(const playerid)
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Moras se ulogovati da bi koristio ovu komandu!");

    StopAudioStreamForPlayer(playerid);
    return 1;
}

CMD:replay(playerid, const params[])
{
	if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Moras se ulogovati da bi koristio ovu komandu!");
		
	static link[500];

  	StopAudioStreamForPlayer(playerid);
  	PlayAudioStreamForPlayer(playerid, link);
	va_SendClientMessageToAll(-1, "{04CC29}[MUZIKA]: {FFFFFF}Ponovo ste pustili muziku.");
    return 1;
}

CMD:goto(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Moras se ulogovati da bi koristio ovu komandu!");
		
	static id,
		Float:Poz[3];

	if(PI[playerid][Admin] < 1 && PI[playerid][Vip] < 1)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
	    
	if(sscanf(params, "u", id))
	    return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/goto [ID]");
	    
    if(id == playerid)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ne mozete se portati sami do sebe!");

    if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");
	    
    GetPlayerPos(id, Poz[0], Poz[1], Poz[2]);
	    
    if(GetPlayerState(playerid) == 2)
	{
		new tmpcar = GetPlayerVehicleID(playerid);
		SetVehiclePos(tmpcar, Poz[0], Poz[1]+4, Poz[2]);
	}
	else
	{
		SetPlayerPos(playerid, Poz[0], Poz[1]+2, Poz[2]);
	}
	SetPlayerInterior(playerid, GetPlayerInterior(id));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(id));

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Teleportovani ste.");
	va_SendClientMessage(id, 0x1b71bcFF, "#Info: {FFFFFF}%s se teleportovao do Vas.", ReturnPlayerName(playerid));
	return 1;
}

CMD:gethere(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Moras se ulogovati da bi koristio ovu komandu!");
		
	if(PI[playerid][Admin] < 1)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	static id,
		Float:Pos[3];

	if(AdminDuty[playerid] == 0) 
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti.");

	if(sscanf(params, "u", id))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/gethere [ID]");

	if(id == INVALID_PLAYER_ID)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresili ste ID!");
	    
    if(id == playerid)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ne mozete samog sebe!");

	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	SetPlayerPos(id, Pos[0] + 2.0, Pos[1], Pos[2]);
		
    va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Teleportovao si %s-a do sebe!.", ReturnPlayerName(id));
	va_SendClientMessage(id, 0x1b71bcFF, "#Info: {FFFFFF}Admin %s te teleportovao do sebe!", ReturnPlayerName(playerid));
	return 1;
}

CMD:nitro(const playerid)
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Moras se ulogovati da bi koristio ovu komandu!");
		
	if(PI[playerid][Admin] < 1)
	    return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
	    
	if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti!");

	if(!IsPlayerInAnyVehicle(playerid))
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti u vozilu!");

	AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Nitro je uspesno dodat u vozilo!");
	return 1;
}

CMD:podesivreme(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Moras se ulogovati da bi koristio ovu komandu!");
		
	if(PI[playerid][Admin] < 2)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");

	static vreme;

	if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti!");
		
	if(sscanf(params, "i", vreme))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/podesivreme [vreme ID (0 - 45)]");

	if(vreme > 45 || vreme < 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresan ID!");

	va_SendClientMessageToAll(0x3acc51FF, "#Vreme: {FFFFFF}Admin %s je postavio vreme na %d!", ReturnPlayerName(playerid), vreme);
	SetWeather(vreme);
	return 1;
}

CMD:podesisat(playerid, const params[])
{
    if(Ulogovan[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Moras se ulogovati da bi koristio ovu komandu!");

	if(PI[playerid][Admin] < 2)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dozvolu da koristite ovu komandu!");
		
	static sat;

	if(AdminDuty[playerid] == 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti na Admin duznosti!");
		
	if(sscanf(params, "i", sat))
		return va_SendClientMessage(playerid, 0x3acc51FF, "#Koristi: {FFFFFF}/podesisat [vreme (0 - 23)]");
		
    if(sat > 23 || sat < 0)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogresan ID!");
		
	va_SendClientMessageToAll(0x3acc51FF, "#Vreme: {FFFFFF}Admin %s je promenio vreme u %d sat/i!", ReturnPlayerName(playerid), sat);
	SetWorldTime(sat);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	new v = GetPlayerVehicleID(playerid);
	if(!VoziloJeBicikla(GetVehicleModel(GetPlayerVehicleID(playerid))))
	{
		new string[128];
		if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][0]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][0]);
		if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][1]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][1]);
		if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][2]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][2]);
		if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][3]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][3]);
		if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][4]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][4]);
		if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][5]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][5]);
    	if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][6]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][6]);
    	if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][7]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][7]);
    	if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][8]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][8]);
    	if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][9]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][9]);
    	if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][10]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][10]);
    	if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][11]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][11]);
    	if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][12]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][12]);
    	if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][13]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][13]);
    	if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][14]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][14]);
    	if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][15]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][15]);
    	if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][16]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][16]);
    	if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][17]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][17]);
    	if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][18]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][18]), format(string, sizeof(string), "%d", Fuel[GetPlayerVehicleID(playerid)]), PlayerTextDrawSetString(playerid, BrzinaTD[playerid][18], string);
    	if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][19]); else if(newstate == PLAYER_STATE_DRIVER) PlayerTextDrawShow(playerid, BrzinaTD[playerid][19]);
    	if(oldstate-1 && newstate) PlayerTextDrawHide(playerid, BrzinaTD[playerid][20]);
		else if(newstate == PLAYER_STATE_DRIVER)
		{
			PlayerTextDrawSetPreviewModel(playerid, BrzinaTD[playerid][20], GetVehicleModel(GetPlayerVehicleID(playerid)));
			PlayerTextDrawShow(playerid, BrzinaTD[playerid][20]);
		}
	}
    if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER)
	{
	    if(VoziloJeKamion(GetVehicleModel(GetPlayerVehicleID(playerid))))
    	{
        	if(PI[playerid][KamionDozvola] <= 0)
    		{
        		va_SendClientMessage(playerid, 0xFF0000FF, "#Kamion Dozvola: {FFFFFF}Nemate dozvolu za kamion, kupite je u auto skoli!");
    		}
    	}
    	if(VoziloJeAvion(GetVehicleModel(GetPlayerVehicleID(playerid))))
    	{
        	if(PI[playerid][AvionDozvola] <= 0)
    		{
        		va_SendClientMessage(playerid, 0xFF0000FF, "#Avion Dozvola: {FFFFFF}Nemate dozvolu za letjelicu, kupite je u auto skoli!");
        		RemovePlayerFromVehicle(playerid);
    		}
    	}
    	if(VoziloJeBrod(GetVehicleModel(GetPlayerVehicleID(playerid))))
    	{
        	if(PI[playerid][BrodDozvola] <= 0)
        	{
            	va_SendClientMessage(playerid, 0xFF0000FF, "#Brod Dozvola: {FFFFFF}Nemate dozvolu za plovilo, kupite je u auto skoli!");
            	RemovePlayerFromVehicle(playerid);
        	}
    	}
    	if(VoziloJeMotor(GetVehicleModel(GetPlayerVehicleID(playerid))))
    	{
        	if(PI[playerid][MotorDozvola] <= 0)
        	{
            	va_SendClientMessage(playerid, 0xFF0000FF, "#Motor Dozvola: {FFFFFF}Nemate dozvolu za motor, kupite je u auto skoli!");
        	}
    	}
    	if(!VoziloJeMotor(GetVehicleModel(GetPlayerVehicleID(playerid))) && !VoziloJeAvion(GetVehicleModel(GetPlayerVehicleID(playerid))) && !VoziloJeBrod(GetVehicleModel(GetPlayerVehicleID(playerid))) && !VoziloJeKamion(GetVehicleModel(GetPlayerVehicleID(playerid))) && !VoziloJeBicikla(GetVehicleModel(GetPlayerVehicleID(playerid))))
    	{
        	if(PI[playerid][ADozvola] <= 0)
        	{
            	va_SendClientMessage(playerid, 0xFF0000FF, "#Auto Dozvola: {FFFFFF}Nemate dozvolu za voznju, kupite je u auto skoli!");
        	}
    	}
	    if(VoziloJeBicikla(GetVehicleModel(GetPlayerVehicleID(playerid))))
    	{
        	new engine, lights, alarm, doors, bonnet, boot, objective;
        	GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
        	SetVehicleParamsEx(GetPlayerVehicleID(playerid), 1, lights, alarm, doors, bonnet, boot, objective);
    	}
    	if(!VoziloJeBicikla(GetVehicleModel(GetPlayerVehicleID(playerid))))
    	{
	    	new engine, lights, alarm, doors, bonnet, boot, objective;
		    GetVehicleParamsEx(v, engine, lights, alarm, doors, bonnet, boot, objective);
	    	if(engine == -1 && !VoziloJeBicikla(GetVehicleModel(GetPlayerVehicleID(playerid))))
			{
				SetVehicleParamsEx(v, 0, 0, alarm, doors, bonnet, boot, objective);
			}
		}
	}
	return 1;
}

public OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(response == EDIT_RESPONSE_FINAL)
	{
	    new id = eData[playerid], Float:angle;
		GetPlayerFacingAngle(playerid, angle);
		if(id != -1)
		{
			AtmInfo[id][aX] = x; AtmInfo[id][aY] = y; AtmInfo[id][aZ] = z;
			AtmInfo[id][aAngle] = rz; DestroyDynamicObject(AtmInfo[id][aObjekat]);
			KreirajAtm(id);

			mysql_tqueryEx(SQL, "UPDATE `atms` SET `Poz_X` = '%f',`Poz_Y` = '%f',`Poz_Z` = '%f',`Poz_Angle` = '%f' WHERE `SQLID` = '%d'",
				AtmInfo[id][aX], AtmInfo[id][aY], AtmInfo[id][aZ], AtmInfo[id][aAngle], AtmInfo[id][SQLID]);

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Bankomat ID: %d je uspesno editovan!", id);
			id = -1;
			return 1;
		}
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	if(Ulogovan[playerid] == 0)
	{
	    va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Prije spawna se morate ulogovati (kikovani ste)!");
	    PlayerTimer[playerid] = SetTimerEx("KonektKick", 500, 0, "d", playerid);
		return 0;
	}
	else
	{
	    SpawnIgraca(playerid); SpawnPlayer(playerid);
		return 1;
	}
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(newkeys == KEY_SECONDARY_ATTACK)
	{
	    for(new i; i < MAX_KUCA; i++)
		{
			if(IsPlayerInRangeOfPoint(playerid, 3.0, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]))
			{
    			if(PI[playerid][Kuca] == i || KucaInfo[i][kZatvoreno] == 0)
    		   	{
                    SetPlayerVirtualWorld(playerid, KucaInfo[i][kVW]);
                    SetPlayerInterior(playerid, KucaInfo[i][kInt]);
                 	SetPlayerPos(playerid, KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ]);
                }
                else
                {
                    GameTextForPlayer(playerid,"~w~Kuca ~r~zakljucana ~w~- /zvoni",5000,3);
                    return 1;
                }
			}
            if(IsPlayerInRangeOfPoint(playerid, 3.0, KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ]) && GetPlayerVirtualWorld(playerid) == KucaInfo[i][kVW])
	        {
             	SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
             	SetPlayerPos(playerid, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]);
             	return 1;
            }
		}
		for(new i; i < MAX_STANOVA; i++)
		{
			if(IsPlayerInRangeOfPoint(playerid, 3.0, StanInfo[i][sUlazX], StanInfo[i][sUlazY], StanInfo[i][sUlazZ]))
			{
    			if(PI[playerid][Stan] == i || StanInfo[i][sZatvoreno] == 0)
    		   	{
                    SetPlayerVirtualWorld(playerid, StanInfo[i][sVW]);
                    SetPlayerInterior(playerid, StanInfo[i][sInt]);
                 	SetPlayerPos(playerid, StanInfo[i][sIzlazX], StanInfo[i][sIzlazY], StanInfo[i][sIzlazZ]);
                }
                else
                {
                    GameTextForPlayer(playerid,"~w~Stan ~y~zakljucan",5000,3);
                    return 1;
                }
			}
            if(IsPlayerInRangeOfPoint(playerid, 3.0, StanInfo[i][sIzlazX], StanInfo[i][sIzlazY], StanInfo[i][sIzlazZ]) && GetPlayerVirtualWorld(playerid) == StanInfo[i][sVW])
	        {
             	SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
				SetPlayerPos(playerid, StanInfo[i][sUlazX], StanInfo[i][sUlazY], StanInfo[i][sUlazZ]);
             	return 1;
            }
		}
	    if(IsPlayerInRangeOfPoint(playerid, 3.0, 1461.8052,-1022.9484,23.8331) && !IsPlayerInAnyVehicle(playerid)) //banka ulaz
		{
		    new sat, minut, sekund; gettime(sat, minut, sekund);
			if(sat >= 0 && sat <= 9 && PI[playerid][Admin] < 6) return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Banka je zatvorena u ovo vrijeme (09:00 - 01:00), koristite bankomate!");
			SetPlayerPos(playerid, 2947.4983,-1787.1194,1191.0875);
			SetPlayerFacingAngle(playerid, 93.6342);
			Ucitavanje_Objekata(playerid);
	 	    SetPlayerInterior(playerid, 0);
	 	    SetPlayerVirtualWorld(playerid, 0);
	 	    GameTextForPlayer(playerid, "~w~LS Banka", 5000, 1);
		}
		else if(IsPlayerInRangeOfPoint(playerid, 3.0, 2947.4983,-1787.1194,1191.0875) && !IsPlayerInAnyVehicle(playerid)) //banka izlaz
		{
		    Ucitavanje_Objekata(playerid);
			SetPlayerPos(playerid, 1461.8052,-1022.9484,23.8331);
			SetPlayerFacingAngle(playerid, 182.4749);
	 	    SetPlayerInterior(playerid, 0);
	 	    SetPlayerVirtualWorld(playerid, 0);
	 	    GameTextForPlayer(playerid, "~w~Los Santos", 5000, 1);
		}
		else if(IsPlayerInRangeOfPoint(playerid, 3.0, 2022.3917,-1297.5770,23.9948) && !IsPlayerInAnyVehicle(playerid)) //zlatara ulaz
		{
		    new sat, minut, sekund; gettime(sat, minut, sekund);
			if(sat >= 0 && sat <= 9 && PI[playerid][Admin] < 6) return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Zlatara je zatvorena u ovo vrijeme (09:00 - 01:00)!");
			SetPlayerPos(playerid, 1026.2103, 2303.5303, -19.7883);
			SetPlayerFacingAngle(playerid, 93.6342);
			Ucitavanje_Objekata(playerid);
	 	    SetPlayerInterior(playerid, 0);
	 	    SetPlayerVirtualWorld(playerid, 0);
	 	    GameTextForPlayer(playerid, "~w~LS Zlatara", 5000, 1);
		}
		else if(IsPlayerInRangeOfPoint(playerid, 3.0, 1026.2103, 2303.5303, -19.7883) && !IsPlayerInAnyVehicle(playerid)) //zlatara izlaz
		{
			SetPlayerPos(playerid, 2022.3917,-1297.5770,23.9948);
			SetPlayerFacingAngle(playerid, 182.4749);
			Ucitavanje_Objekata(playerid);
	 	    SetPlayerInterior(playerid, 0);
	 	    SetPlayerVirtualWorld(playerid, 0);
	 	    GameTextForPlayer(playerid, "~w~Los Santos", 5000, 1);
		}
		else if(IsPlayerInRangeOfPoint(playerid, 3.0, 1992.1652,-1775.3353,13.7579) && !IsPlayerInAnyVehicle(playerid)) //auto skola ulaz
		{
		    SetPlayerPos(playerid, 1379.2844,1455.0060,-7.7367);
			SetPlayerFacingAngle(playerid, 93.6342);
	 	    SetPlayerInterior(playerid, 0);
	 	    SetPlayerVirtualWorld(playerid, 0);
	 	    GameTextForPlayer(playerid, "~w~Auto Skola", 5000, 1);
		}
		else if(IsPlayerInRangeOfPoint(playerid, 3.0, 1379.2844,1455.0060,-7.7367) && !IsPlayerInAnyVehicle(playerid)) //auto skola izlaz
		{
			SetPlayerPos(playerid, 1992.1652,-1775.3353,13.7579);
			SetPlayerFacingAngle(playerid, 182.4749);
			Ucitavanje_Objekata(playerid);
	 	    SetPlayerInterior(playerid, 0);
	 	    SetPlayerVirtualWorld(playerid, 0);
	 	    GameTextForPlayer(playerid, "~w~Los Santos", 5000, 1);
		}
		else if(IsPlayerInRangeOfPoint(playerid, 3.0, 1363.6647,-1654.7445,13.5449) && !IsPlayerInAnyVehicle(playerid)) //opstina ulaz
		{
		    SetPlayerPos(playerid, -2128.9692,-175.9183,-79.0954);
			SetPlayerFacingAngle(playerid, 93.6342);
			Ucitavanje_Objekata(playerid);
	 	    SetPlayerInterior(playerid, 0);
	 	    SetPlayerVirtualWorld(playerid, 0);
	 	    GameTextForPlayer(playerid, "~w~LS Opstina", 5000, 1);
		}
		else if(IsPlayerInRangeOfPoint(playerid, 3.0, -2128.9692,-175.9183,-79.0954) && !IsPlayerInAnyVehicle(playerid)) //opstina izlaz
		{
			SetPlayerPos(playerid, 1363.6647,-1654.7445,13.5449);
			SetPlayerFacingAngle(playerid, 182.4749);
			Ucitavanje_Objekata(playerid);
	 	    SetPlayerInterior(playerid, 0);
	 	    SetPlayerVirtualWorld(playerid, 0);
	 	    GameTextForPlayer(playerid, "~w~Los Santos", 5000, 1);
		}
	}
	if(newkeys == KEY_FIRE)
	{
		if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
		    new engine, lights, alarm, doors, bonnet, boot, objective, string[80];
			GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
			if(lights == 0 || lights == -1)
			{
			    if(engine == 0 || engine == -1) return 1;
				SetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, 1, alarm, doors, bonnet, boot, objective);
                format(string, sizeof(string), "{C2A2DA}* %s pali svetla na vozilu.", ReturnPlayerName(playerid));
				ProxMessage(playerid, string, 20.0);
			}
			else if(lights == 1)
			{
				SetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, 0, alarm, doors, bonnet, boot, objective);
                format(string, sizeof(string), "{C2A2DA}* %s gasi svetla na vozilu.", ReturnPlayerName(playerid));
				ProxMessage(playerid, string, 20.0);
			}
		}
	}
	if(newkeys == KEY_CTRL_BACK)
	{
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 2933.3809,-1787.2136,1191.0873))
	    {
		    Dialog_Show(playerid, dialog_banka, DIALOG_STYLE_LIST, "{1b71bc}Banka:", "{1b71bc}(1). {FFFFFF}Otvori racun\n\
																	              {1b71bc}(2). {FFFFFF}Ostavi novac\n\
				 																  {1b71bc}(3). {FFFFFF}Podigni novac\n\
																				  {1b71bc}(4). {FFFFFF}Transfer novca\n\
																				  {1b71bc}(5). {FFFFFF}Stanje na racunu\n\
																				  {1b71bc}(6). {FFFFFF}Krediti\n\
																				  {1b71bc}(7). {FFFFFF}Vrati Kredit", "Odaberi", "Izlaz");
		}
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 1026.3081, 2312.2776, -19.7883))
	    {
		    Dialog_Show(playerid, dialog_zlatara, DIALOG_STYLE_TABLIST_HEADERS, "{1b71bc}Zlatara:", "Opcija\tCena Zlata\n\
																					                {1b71bc}(1). {FFFFFF}Kupovina Zlata\t1001$\n\
								 																    {1b71bc}(2). {FFFFFF}Prodaja Zlata\t1000$", "Odaberi", "Izlaz");
		}
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 1376.9954,1461.3077,-7.7367))
		{
			Dialog_Show(playerid, dialog_dozvole, DIALOG_STYLE_TABLIST_HEADERS, "{1b71bc}Dozvola:", "Opcija\tCena Dozvola\n\
				                                                                                     {1b71bc}(1). {FFFFFF}Dozvola za Voznju\t1000$\n\
																	                                 {1b71bc}(2). {FFFFFF}Dozvola za Kamion/Bus\t2000$\n\
																									 {1b71bc}(3). {FFFFFF}Dozvola za Motor\t500$\n\
																									 {1b71bc}(4). {FFFFFF}Dozvola za Avion\t4000$\n\
																									 {1b71bc}(5). {FFFFFF}Dozvola za Brod\t3000$","Odaberi","Izadji");
		}
	}
	if(newkeys & KEY_SUBMISSION)
	{
		if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			new engine, lights, alarm, doors, bonnet, boot, objective, string[100];
			GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
			if(VoziloJeBicikla(GetVehicleModel(GetPlayerVehicleID(playerid)))) return 1;
			if(engine == 0 || engine == -1)
			{
				new Float:HP;
				GetVehicleHealth(GetPlayerVehicleID(playerid), HP);

				if(HP < 400.0)
			 		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vozilo vam je previse osteceno, pozovite mehanicara!");

				if(Fuel[GetPlayerVehicleID(playerid)] <= 0)
					return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate goriva u vozilu pa ne mozete upaliti motor!");

			    SetVehicleParamsEx(GetPlayerVehicleID(playerid), 1, lights, alarm, doors, bonnet, boot, objective);

				format(string,sizeof(string), "{C2A2DA}* %s pali motor na vozilu.", ReturnPlayerName(playerid));
				ProxMessage(playerid, string, 20.0);
			}
			else if(engine == 1)
			{
				SetVehicleParamsEx(GetPlayerVehicleID(playerid), 0, 0, alarm, doors, bonnet, boot, objective);

				format(string,sizeof(string), "{C2A2DA}* %s gasi motor na vozilu.", ReturnPlayerName(playerid));
				ProxMessage(playerid, string, 20.0);
			}
		}
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
    if(!success)
    {
        foreach(new i : Player)
        {
            static igracip[16], string[150];
			GetPlayerIp(i, igracip, sizeof(igracip));
            if(!strcmp(ip, igracip, true))
            {
                if(PI[i][Admin] < 6)
                {
                	va_SendClientMessage(i, 0xFF0000FF, "#Greska: {FFFFFF}Pogresan RCON password | Kikovani ste!");
                	format(string, sizeof(string), "{d8ab74}[RCON WARNING]: {FFFFFF}Igrac %s je pokusao da se uloguje na RCON sa pogresnim passwordom | Kikovan je!", ReturnPlayerName(i));
                    AdminMessage(-1, string);
					Kick(i);
                }
                else if(PI[i][Admin] >= 6)
                {
                	va_SendClientMessage(i, 0xFF0000FF, "#Greska: {FFFFFF}Pogresan RCON password!");
				}
            }
        }
    }
    if(success)
    {
        foreach(new i : Player)
        {
            new igracip[16], string[150]; GetPlayerIp(i, igracip, sizeof(igracip));
            if(!strcmp(ip, igracip, true))
            {
                if(PI[i][Admin] < 6)
                {
                    format(string, sizeof(string), "{d8ab74}[RCON WARNING]: {FFFFFF}%s se uspjesno ulogovao na RCON | Igrac je manji Admin level od 6!", ReturnPlayerName(i));
                    AdminMessage(-1, string);
					va_SendClientMessage(i, -1, "{7ad874}[RCON LOGIN]: {FFFFFF}Uspjesno ste se ulogovali na RCON!");
                }
                else if(PI[i][Admin] >= 6)
                {
                    format(string, sizeof(string), "{7ad874}[RCON LOGIN]: {FFFFFF}%s se uspjesno ulogovao na RCON | Igrac je Admin Level 6!", ReturnPlayerName(i));
                    AdminMessage(-1, string);
                    va_SendClientMessage(i, -1, "{7ad874}[RCON LOGIN]: {FFFFFF}Uspjesno ste se ulogovali na RCON!");
                }
            }
        }
    }
	return 1;
}

public OnPlayerUpdate(playerid)
{
    if(IsPlayerInAnyVehicle(playerid))
   	{
   	    if(!VoziloJeBicikla(GetVehicleModel(GetPlayerVehicleID(playerid))))
   	    {
		   	new sspeed[5];
		   	format(sspeed, sizeof(sspeed), "%03d", GetSpeed(playerid));
		   	PlayerTextDrawSetString(playerid, BrzinaTD[playerid][12], sspeed);
   		}
    }
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

// - > Dialogs
Dialog:dialog_login(playerid, response, listitem, inputtext[])
{
	if(!response) return Kick(playerid);

	new hash_pass[64];
	SHA256_PassHash(inputtext, ReturnPlayerName(playerid), hash_pass, sizeof(hash_pass));
	if(!strcmp(hash_pass, PI[playerid][Password], false) && !isnull(inputtext))
 	{
 	    strmid(accountRealPass[playerid], inputtext, 0, strlen(inputtext), 128);
 	    PlayerLogged(playerid);
 	    CorrectPassword[playerid] = true;
	}
	else
	{
	    IncorrectPassword[playerid] ++; CorrectPassword[playerid] = true;
	    va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Upisali ste pogresnu lozinku (%d/4)!", IncorrectPassword[playerid]);
	    Dialog_Show(playerid, dialog_login, DIALOG_STYLE_PASSWORD, "{1b71bc}Login", "\n{FFFFFF}Dobrodosli nazad {1b71bc}%s, {FFFFFF}na {1b71bc}Vibe Roleplay\n\
																			 {FFFFFF}Vas korisnicki racun {3acc51}je registrovan {FFFFFF}u bazi podataka.\n\
																			 {FFFFFF}Ukoliko pogresite lozinku {FF0000}4 puta {FFFFFF}bicete kickovani.\n\
																			 {FFFFFF}Imate {FF0000}30 {FFFFFF}sekundi da se ulogujete na nas server.\n\n\
																			 {FFFFFF}Ugodnu igru zeli vam {1b71bc}Vibe Roleplay Staff Tim", "Login", "Izlaz", ReturnPlayerName(playerid));
		if(IncorrectPassword[playerid] >= 4)
		{
		    va_SendClientMessage(playerid, 0xFF0000FF, "#Kick: {FFFFFF}Pogresili ste lozinku 4 puta kickovani ste!", IncorrectPassword[playerid]);
		    Kick(playerid);
		}
	}
	return 1;
}

Dialog:dialog_register(playerid, response, listitem, inputtext[])
{
    if(!response) return Kick(playerid);

    if(strlen(inputtext) < 6 || strlen(inputtext) > 24 || !CheckPassword(inputtext))
        return Dialog_Show(playerid, dialog_register, DIALOG_STYLE_PASSWORD, "{1b71bc}Registracija", "{FFFFFF}Dobrodosli {1b71bc}%s, {FFFFFF}na {1b71bc}Vibe Roleplay\n\
																			 {FFFFFF}Vas korisnicki racun {FF0000}nije registrovan {FFFFFF}u bazi podataka.\n\
																			 {FFFFFF}Molimo vas unesite vasu zeljenu lozinku kako bi pristupili nasem serveru.\n\
																			 {FFFFFF}Lozinka mora sadrzati minimum {F0FFFF}6 {FFFFFF}maksimum {F0FFFF}26 {FFFFFF}karaktera.\n\
																			 {FFFFFF}Vasa lozinka moze sadrzati kombinaciju slova i brojeva {FF0000}(RAZMAK ZABRANJEN).", "Registracija", "Izlaz", ReturnPlayerName(playerid));

	strmid(accountRealPass[playerid], inputtext, 0, strlen(inputtext), 128);
	SHA256_PassHash(inputtext, ReturnPlayerName(playerid), PI[playerid][Password], 128);
	InputPassword[playerid] = true;
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Vasa odabrana lozinka je '%s'.", inputtext);

	Dialog_Show(playerid, dialog_mail, DIALOG_STYLE_INPUT, "{1b71bc}Email", "{FFFFFF}U prazno polje upisite vasu email adresu.\n\
																	{FFFFFF}Molimo vas da unesite tacnu email adresu jer pomocu nje mozete vratiti zaboravjenu lozinku.", "Unesi", "Izlaz");
	return 1;
}

Dialog:dialog_mail(playerid, response, listitem, inputtext[])
{
	if(!response) return Kick(playerid);

	if(strlen(inputtext) < 6 || strlen(inputtext) > 70 || !CheckMail(inputtext) || strfind(inputtext, "@", true) == -1 || strfind(inputtext, ".", true) == -1)
	    return Dialog_Show(playerid, dialog_mail, DIALOG_STYLE_INPUT, "{1b71bc}Email", "{FFFFFF}U prazno polje upisite vasu email adresu.\n\
																	{FFFFFF}Molimo vas da unesite tacnu email adresu jer pomocu nje mozete vratiti zaboravjenu lozinku.", "Unesi", "Izlaz");

    strmid(PI[playerid][Email], inputtext, 0, strlen(inputtext), 50);
    InputMail[playerid] = 1;
    va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Vasa odabrana email adresa je '%s'.", inputtext);

    Dialog_Show(playerid, dialog_godine, DIALOG_STYLE_INPUT, "{1b71bc}Godine", "{FFFFFF}U prazno polje upisite koliko imate godina.\n\
                                                                        {FFFFFF}Godine ne smeju ici ispod {F0FFFF}10 {FFFFFF}i iznad {F0FFFF}60 {FFFFFF}godina.", "Unesi", "Izlaz");
	return 1;
}

Dialog:dialog_godine(playerid, response, listitem, inputtext[])
{
    if(!response) return Kick(playerid);

    if(strfind(inputtext, "%", true) != -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Mozete koristi samo brojeve!");

    if(!IsNumeric(inputtext))
        return Dialog_Show(playerid, dialog_godine, DIALOG_STYLE_INPUT, "{1b71bc}Godine", "{FFFFFF}U prazno polje upisite koliko imate godina.\n\
                                                                        {FFFFFF}Godine ne smeju ici ispod {F0FFFF}10 {FFFFFF}i iznad {F0FFFF}60 {FFFFFF}godina.", "Unesi", "Izlaz");
	PI[playerid][Godine] = strval(inputtext);
	InputAge[playerid] = strval(inputtext);

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Odabrali ste da imate '%s' godine.", inputtext);

	Dialog_Show(playerid, dialog_pol, DIALOG_STYLE_MSGBOX, "{1b71bc}Pol", "{FFFFFF}Odaberite sta ce vas karakter da prestavlja u igri.", "Musko", "Zensko");
	return 1;
}

Dialog:dialog_pol(playerid, response, listitem, inputtext[])
{
    if(response)
	{
		InputSex[playerid] = 1;
		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Odabrali ste 'muski' pol.");
		PI[playerid][Pol] = 1;
		PI[playerid][Skin] = 240;

		Dialog_Show(playerid, dialog_drzava, DIALOG_STYLE_LIST, "{1b71bc}Drzava", "{1b71bc}(1). {FFFFFF}Makedonija\n\
                                                                                   {1b71bc}(2). {FFFFFF}Srbija\n\
                                                                                   {1b71bc}(3). {FFFFFF}Hrvatska\n\
                                                                                   {1b71bc}(4). {FFFFFF}Slovenija\n\
                                                                                   {1b71bc}(5). {FFFFFF}Bosna i Hercegovina\n\
                                                                                   {1b71bc}(6). {FFFFFF}Crna Gora\n\
                                                                                   {1b71bc}(7). {FFFFFF}Albanija\n\
                                                                                   {1b71bc}(8). {FFFFFF}Ostalo", "Unesi", "Izlaz");

	}
 	if(!response)
	{
		InputSex[playerid] = 2;
		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Odabrali ste 'zenski' pol.");
		PI[playerid][Pol] = 2;
        PI[playerid][Skin] = 91;

		Dialog_Show(playerid, dialog_drzava, DIALOG_STYLE_LIST, "{1b71bc}Drzava", "{1b71bc}(1). {FFFFFF}Makedonija\n\
                                                                                   {1b71bc}(2). {FFFFFF}Srbija\n\
                                                                                   {1b71bc}(3). {FFFFFF}Hrvatska\n\
                                                                                   {1b71bc}(4). {FFFFFF}Slovenija\n\
                                                                                   {1b71bc}(5). {FFFFFF}Bosna i Hercegovina\n\
                                                                                   {1b71bc}(6). {FFFFFF}Crna Gora\n\
                                                                                   {1b71bc}(7). {FFFFFF}Albanija\n\
                                                                                   {1b71bc}(8). {FFFFFF}Ostalo", "Unesi", "Izlaz");
	}
	return 1;
}

Dialog:dialog_drzava(playerid, response, listitem, inputtext[])
{
    if(!response) return Kick(playerid);

	switch(listitem)
	{
	    case 0:
     	{
      		ChooseCountry[playerid] = 1;
      		PI[playerid][Drzava] = 1;
			InsertAcc(playerid);
       		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Odabrali ste drzavu '%s'.", CheckCountry(ChooseCountry[playerid]));
		}
		case 1:
     	{
      		ChooseCountry[playerid] = 2;
      		PI[playerid][Drzava] = 2;
      		InsertAcc(playerid);
       		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Odabrali ste drzavu '%s'.", CheckCountry(ChooseCountry[playerid]));
		}
		case 2:
     	{
      		ChooseCountry[playerid] = 3;
            PI[playerid][Drzava] = 3;
      		InsertAcc(playerid);
       		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Odabrali ste drzavu '%s'.", CheckCountry(ChooseCountry[playerid]));
		}
		case 3:
     	{
      		ChooseCountry[playerid] = 4;
      		PI[playerid][Drzava] = 4;
      		InsertAcc(playerid);
       		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Odabrali ste drzavu '%s'.", CheckCountry(ChooseCountry[playerid]));
		}
		case 4:
     	{
      		ChooseCountry[playerid] = 5;
      		PI[playerid][Drzava] = 5;
      		InsertAcc(playerid);
       		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Odabrali ste drzavu '%s'.", CheckCountry(ChooseCountry[playerid]));
		}
		case 5:
     	{
      		ChooseCountry[playerid] = 6;
      		PI[playerid][Drzava] = 6;
      		InsertAcc(playerid);
       		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Odabrali ste drzavu '%s'.", CheckCountry(ChooseCountry[playerid]));
		}
		case 6:
     	{
      		ChooseCountry[playerid] = 7;
      		PI[playerid][Drzava] = 7;
      		InsertAcc(playerid);
       		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Odabrali ste drzavu '%s'.", CheckCountry(ChooseCountry[playerid]));
		}
		case 7:
     	{
      		ChooseCountry[playerid] = 8;
      		PI[playerid][Drzava] = 8;
      		InsertAcc(playerid);
       		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Odabrali ste drzavu '%s'.", CheckCountry(ChooseCountry[playerid]));
		}
	}
	return 1;
}

Dialog:dialog_banka(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    switch(listitem)
    {
    	case 0:
		{
  			if(PI[playerid][Kartica] != 0)
		  		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec imate otvoren bankovni racun!");

			if(PI[playerid][Novac] < 100)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dovoljno novca (100$)!");
				
			PI[playerid][Novac] -= 100;
			GivePlayerMoney(playerid, -100);
			new pin = 1000 + random(8999);
			PI[playerid][Kartica] = 1;
			PI[playerid][KarticaPin] = pin;
			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Otvorili ste bankovni racun (-100$).");
			
			mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `Kartica` = '%d', `KarticaPin` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Admin], PI[playerid][Kartica], PI[playerid][KarticaPin], PI[playerid][SQLID]);
		}
		case 1:
		{
  			if(PI[playerid][Kartica] != 1)
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas bankovni racun nemozes koristiti ovu opciju!");

			Dialog_Show(playerid, dialog_bostavi, DIALOG_STYLE_INPUT, "{1b71bc}Ostavi novac:", "{FFFFFF}Unesite kolicinu novca koju zelite da ostavite na Vas bankovni racun:", "Ostavi", "Izlaz");
		}
		case 2:
		{
  			if(PI[playerid][Kartica] != 1)
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas bankovni racun nemozes koristiti ovu opciju!");

			Dialog_Show(playerid, dialog_buzmi, DIALOG_STYLE_INPUT, "{1b71bc}Podigni novac:", "{FFFFFF}Unesite kolicinu novca koju zelite da podignete sa Vaseg bankovnog racuna:", "Podigni", "Izlaz");
		}
		case 3:
		{
			if(PI[playerid][Kartica] != 1)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas bankovni racun nemozes koristiti ovu opciju!");

			if(PI[playerid][Level] < 5)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti minimum level 5 da bi mogli koristiti ovu opciju!");

			Dialog_Show(playerid, dialog_btransfer, DIALOG_STYLE_INPUT, "{1b71bc}Transfer novca:", "{FFFFFF}Unesite ID igraca kome zelite da posaljete novac...", "Unesi", "Izlaz");
		}
		case 4:
		{
  			if(PI[playerid][Kartica] != 1)
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas bankovni racun nemozes koristiti ovu opciju!");

			Dialog_Show(playerid, dialog_none, DIALOG_STYLE_MSGBOX, "{1b71bc}Stanje racuna:", "{FFFFFF}Trenutno stanje na vasem racunu je: {1b71bc}$%d", "OK", "", PI[playerid][NovacBanka]);
		}
		case 5:
		{
  			if(PI[playerid][Kartica] != 1)
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas bankovni racun nemozes koristiti ovu opciju!");

			if(PI[playerid][PreostaloZaOtplatu] > 0)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec ste podigli jedan kredit, prvo ga otplatite!");

			Dialog_Show(playerid, dialog_krediti, DIALOG_STYLE_LIST, "{1b71bc}Podigni Kredit:", "{FFFFFF}Level: 3 {1b71bc}| {FFFFFF}Kredit: 20.000$ {1b71bc}| {FFFFFF}Rata: 700$\n{FFFFFF}Level: 5 {1b71bc}| {FFFFFF}Kredit: 50.000$ {1b71bc}| {FFFFFF}Rata: 1.750$\n{FFFFFF}Level: 7 {1b71bc}| {FFFFFF}Kredit: 100.000$ {1b71bc}| {FFFFFF}Rata: 3.500$\n", "Odaberi", "Izlaz");
		}
		case 6:
		{
  			if(PI[playerid][Kartica] != 1)
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas bankovni racun nemozes koristiti ovu opciju!");

			Dialog_Show(playerid, dialog_vratikredit, DIALOG_STYLE_INPUT, "{1b71bc}Vrati kredit:", "{FFFFFF}Unesite kolicinu novca koju zelite vratiti banci:\nTrenutno imate vratiti jos {1b71bc}%d$", "Unesi", "Izlaz", PI[playerid][PreostaloZaOtplatu]);
		}
	}
	return 1;
}

Dialog:dialog_vratikredit(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

    if(PI[playerid][PreostaloZaOtplatu] <= 0) return 1;

	static iznos,
		string[250];

	if(strfind(inputtext, "%", true) != -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Koristite samo brojeve!");

	if(sscanf(inputtext, "i", iznos))
		return Dialog_Show(playerid, dialog_vratikredit, DIALOG_STYLE_INPUT, "{1b71bc}Vrati kredit:", "{FFFFFF}Unesite kolicinu novca koju zelite vratiti banci:\nTrenutno imate vratiti jos {1b71bc}%d$", "Unesi", "Izlaz", PI[playerid][PreostaloZaOtplatu]);
					
	if(PI[playerid][Novac] < iznos)
		return Dialog_Show(playerid, dialog_vratikredit, DIALOG_STYLE_INPUT, "{1b71bc}Vrati kredit:", "{FFFFFF}Unesite kolicinu novca koju zelite vratiti banci:\nTrenutno imate vratiti jos {1b71bc}%d$", "Unesi", "Izlaz", PI[playerid][PreostaloZaOtplatu]);

	if(iznos < 1000 && PI[playerid][PreostaloZaOtplatu] > 999)
		return Dialog_Show(playerid, dialog_vratikredit, DIALOG_STYLE_INPUT, "{1b71bc}Vrati kredit:", "{FFFFFF}Unesite kolicinu novca koju zelite vratiti banci:\nTrenutno imate vratiti jos {1b71bc}%d$", "Unesi", "Izlaz", PI[playerid][PreostaloZaOtplatu]);

	if(iznos > PI[playerid][PreostaloZaOtplatu])
	    Dialog_Show(playerid, dialog_vratikredit, DIALOG_STYLE_INPUT, "{1b71bc}Vrati kredit:", "{FFFFFF}Unesite kolicinu novca koju zelite vratiti banci:\nTrenutno imate vratiti jos {1b71bc}%d$", "Unesi", "Izlaz", PI[playerid][PreostaloZaOtplatu]);

	PI[playerid][PreostaloZaOtplatu] -= iznos;
	PI[playerid][Novac] -= iznos;
	GivePlayerMoney(playerid, -iznos);
	UpdateBanka(playerid);
	
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `PreostaloZaOtplatu` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][PreostaloZaOtplatu], PI[playerid][SQLID]);

	if(PI[playerid][PreostaloZaOtplatu] > 0)
	{
		va_SendClientMessage(playerid, 0x1b71bcFF, "#Banka: {FFFFFF}Vratili ste %d$ duga, ostalo Vam je jos %d$ da nam vratite!", iznos, PI[playerid][PreostaloZaOtplatu]);
		format(string, sizeof(string), "{C2A2DA}%s vraca ratu kredita.", ReturnPlayerName(playerid));
		ProxMessage(playerid, string, 20.0);
	}
	else if(PI[playerid][PreostaloZaOtplatu] == 0)
	{
		va_SendClientMessage(playerid, 0x1b71bcFF, "#Banka: {FFFFFF}Vratili ste %d$ duga, cime ste vratili sav dug koji ste dugovlali banci!", iznos);
		format(string, sizeof(string), "{C2A2DA}%s vraca kredit.", ReturnPlayerName(playerid));
        ProxMessage(playerid, string, 20.0);
	}
	return 1;
}
Dialog:dialog_krediti(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    
    if(PI[playerid][PreostaloZaOtplatu] > 0) return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec ste podigli jedan kredit, prvo ga otplatite!");

	switch(listitem)
	{
		case 0:
		{
			if(PI[playerid][Level] < 3) return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti minimum level 3 da bih mogli podici ovaj kredit!");

			PI[playerid][IznosKredita] = 20000;
			PI[playerid][IznosRate] = 700;
			PI[playerid][PreostaloZaOtplatu] = PI[playerid][IznosKredita];

			PI[playerid][NovacBanka] += PI[playerid][IznosKredita];

			new string[100];
			format(string, sizeof(string), "{C2A2DA}%s podize kredit.", ReturnPlayerName(playerid));
			ProxMessage(playerid, string, 20.0);

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Podigli ste kredit u iznosu od 20.000$ sa ratom od 700$ (na svaki PayDay).");

			mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `IznosKredita` = '%d', `IznosRate` = '%d', `PreostaloZaOtplatu` = '%d' WHERE `SQLID` = '%d'",
				PI[playerid][Novac], PI[playerid][IznosKredita], PI[playerid][PreostaloZaOtplatu], PI[playerid][SQLID]);

			UpdateBanka(playerid);
		}
		case 1:
		{
		    if(PI[playerid][Level] < 5) return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti minimum level 5 da bih mogli podici ovaj kredit!");

			PI[playerid][IznosKredita] = 50000;
			PI[playerid][IznosRate] = 1750;
			PI[playerid][PreostaloZaOtplatu] = PI[playerid][IznosKredita];

			PI[playerid][NovacBanka] += PI[playerid][IznosKredita];

			new string[100];
			format(string, sizeof(string), "{C2A2DA}%s podize kredit.", ReturnPlayerName(playerid));
			ProxMessage(playerid, string, 20.0);

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Podigli ste kredit u iznosu od 50.000$ sa ratom od 1750$ (na svaki PayDay).");

			mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `IznosKredita` = '%d', `IznosRate` = '%d', `PreostaloZaOtplatu` = '%d' WHERE `SQLID` = '%d'",
				PI[playerid][Novac], PI[playerid][IznosKredita], PI[playerid][PreostaloZaOtplatu], PI[playerid][SQLID]);
				
			UpdateBanka(playerid);
		}
		case 2:
		{
		    if(PI[playerid][Level] < 7) return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Morate biti minimum level 7 da bih mogli podici ovaj kredit!");

			PI[playerid][IznosKredita] = 100000;
			PI[playerid][IznosRate] = 3500;
			PI[playerid][PreostaloZaOtplatu] = PI[playerid][IznosKredita];

			PI[playerid][NovacBanka] += PI[playerid][IznosKredita];

			new string[100];
			format(string, sizeof(string), "{C2A2DA}%s podize kredit.", ReturnPlayerName(playerid));
			ProxMessage(playerid, string, 20.0);

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Podigli ste kredit u iznosu od 100.000$ sa ratom od 3500$ (na svaki PayDay).");

			mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `IznosKredita` = '%d', `IznosRate` = '%d', `PreostaloZaOtplatu` = '%d' WHERE `SQLID` = '%d'",
				PI[playerid][Novac], PI[playerid][IznosKredita], PI[playerid][PreostaloZaOtplatu], PI[playerid][SQLID]);
				
			UpdateBanka(playerid);
		}
	}
	return 1;
}

Dialog:dialog_bostavi(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

	static iznos,
		string[250];

	if(strfind(inputtext, "%", true) != -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Koristite samo brojeve!");

	if(sscanf(inputtext, "i", iznos))
		return Dialog_Show(playerid, dialog_bostavi, DIALOG_STYLE_INPUT, "{1b71bc}Ostavi novac:", "{FFFFFF}Unesite kolicinu novca koju zelite da ostavite na Vas bankovni racun:", "Ostavi", "Izlaz");

	if(PI[playerid][Novac] < iznos)
	    return Dialog_Show(playerid, dialog_bostavi, DIALOG_STYLE_INPUT, "{1b71bc}Ostavi novac:", "{FFFFFF}Unesite kolicinu novca koju zelite da ostavite na Vas bankovni racun:", "Ostavi", "Izlaz");

	PI[playerid][NovacBanka] += iznos;
	PI[playerid][Novac] -= iznos;
	GivePlayerMoney(playerid, -iznos);
	
	UpdateBanka(playerid);
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `NovacBanka` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][NovacBanka], PI[playerid][SQLID]);

	format(string, sizeof(string), "{C2A2DA}* %s ostavlja novac na bankovni racun.", ReturnPlayerName(playerid));
	ProxMessage(playerid, string, 20.0);

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Ostavili ste %d$ na Vas bankovni racun.", iznos);
	return 1;
}

Dialog:dialog_buzmi(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

	static iznos,
		string[250];

	if(strfind(inputtext, "%", true) != -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Koristite samo brojeve!");

	if(sscanf(inputtext, "i", iznos))
		return Dialog_Show(playerid, dialog_buzmi, DIALOG_STYLE_INPUT, "{1b71bc}Podigni novac:", "{FFFFFF}Unesite kolicinu novca koju zelite da podignete sa Vaseg bankovnog racuna:", "Podigni", "Izlaz");

	if(PI[playerid][NovacBanka] < iznos)
        return Dialog_Show(playerid, dialog_buzmi, DIALOG_STYLE_INPUT, "{1b71bc}Podigni novac:", "{FFFFFF}Unesite kolicinu novca koju zelite da podignete sa Vaseg bankovnog racuna:", "Podigni", "Izlaz");

	if(iznos < 1 || iznos > 2000000)
		return Dialog_Show(playerid, dialog_buzmi, DIALOG_STYLE_INPUT, "{1b71bc}Podigni novac:", "{FFFFFF}Unesite kolicinu novca koju zelite da podignete sa Vaseg bankovnog racuna:", "Podigni", "Izlaz");

	PI[playerid][NovacBanka] -= iznos;
	PI[playerid][Novac] += iznos;
	GivePlayerMoney(playerid, iznos);
	
	UpdateBanka(playerid);
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `NovacBanka` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][NovacBanka], PI[playerid][SQLID]);

	format(string, sizeof(string), "{C2A2DA}* %s dize novac sa bankovnog racuna.", ReturnPlayerName(playerid));
	ProxMessage(playerid, string, 20.0);
			
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Podigli ste %d$ sa Vaseg bankovnog racuna.", iznos);
	return 1;
}

Dialog:dialog_btransfer(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

	static id;

	if(strfind(inputtext, "%", true) != -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Koristite samo brojeve!");

	if(sscanf(inputtext, "i", id))
		return Dialog_Show(playerid, dialog_btransfer, DIALOG_STYLE_INPUT, "{1b71bc}Transfer novca:", "{FFFFFF}Unesite ID igraca kome zelite da posaljete novac...", "Unesi", "Izlaz");

	if(!IsPlayerConnected(id))
	{
        Dialog_Show(playerid, dialog_btransfer, DIALOG_STYLE_INPUT, "{1b71bc}Transfer novca:", "{FFFFFF}Unesite ID igraca kome zelite da posaljete novac...", "Unesi", "Izlaz");
		va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Pogrijesili ste ID!");
  		return 1;
	}
	if(PI[id][Kartica] != 1)
	{
		Dialog_Show(playerid, dialog_btransfer, DIALOG_STYLE_INPUT, "{1b71bc}Transfer novca:", "{FFFFFF}Unesite ID igraca kome zelite da posaljete novac...", "Unesi", "Izlaz");
		va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Taj igrac nema otvoren bankovni racun!");
  		return 1;
	}
	if(id == playerid)
	{
		Dialog_Show(playerid, dialog_btransfer, DIALOG_STYLE_INPUT, "{1b71bc}Transfer novca:", "{FFFFFF}Unesite ID igraca kome zelite da posaljete novac...", "Unesi", "Izlaz");
		va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ne mozete sami sebi slati novac!");
  		return 1;
	}

	KomeSalje[playerid] = id;
    Dialog_Show(playerid, dialog_btransfer2, DIALOG_STYLE_INPUT, "{1b71bc}Transfer novca:", "{FFFFFF}Unesite kolicinu novca koju zelite da posaljete igracu %s.", "Posalji", "Izlaz", ReturnPlayerName(id));
    return 1;
}

Dialog:dialog_btransfer2(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    
    new iznos, string[250];

	if(strfind(inputtext, "%", true) != -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Koristite samo brojeve!");

	if(sscanf(inputtext, "i", iznos))
	    return Dialog_Show(playerid, dialog_btransfer2, DIALOG_STYLE_INPUT, "{1b71bc}Transfer novca:", "{FFFFFF}Unesite kolicinu novca koju zelite da posaljete igracu %s.", "Posalji", "Izlaz", ReturnPlayerName(KomeSalje[playerid]));

	if(PI[playerid][NovacBanka] < iznos)
	    return Dialog_Show(playerid, dialog_btransfer2, DIALOG_STYLE_INPUT, "{1b71bc}Transfer novca:", "{FFFFFF}Unesite kolicinu novca koju zelite da posaljete igracu %s.", "Posalji", "Izlaz", ReturnPlayerName(KomeSalje[playerid]));

	if(iznos < 1 || iznos > 5000000)
	    return Dialog_Show(playerid, dialog_btransfer2, DIALOG_STYLE_INPUT, "{1b71bc}Transfer novca:", "{FFFFFF}Unesite kolicinu novca koju zelite da posaljete igracu %s.", "Posalji", "Izlaz", ReturnPlayerName(KomeSalje[playerid]));

	if(PI[KomeSalje[playerid]][Level] < 2)
	{
	    Dialog_Show(playerid, dialog_btransfer2, DIALOG_STYLE_INPUT, "{1b71bc}Transfer novca:", "{FFFFFF}Unesite kolicinu novca koju zelite da posaljete igracu %s.", "Posalji", "Izlaz", ReturnPlayerName(KomeSalje[playerid]));
    	va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Taj igrac mora biti minimum level 2!");
	    return 1;
	}

	PI[playerid][NovacBanka] -= iznos;
	
	UpdateBanka(playerid);
	mysql_tqueryEx(SQL, "UPDATE `users` SET `NovacBanka` = '%d' WHERE `SQLID` = '%d'", PI[playerid][NovacBanka], PI[playerid][SQLID]);

	PI[KomeSalje[playerid]][NovacBanka] += iznos;
	UpdateBanka(KomeSalje[playerid]);

	mysql_tqueryEx(SQL, "UPDATE `users` SET `NovacBanka` = '%d' WHERE `SQLID` = '%d'", PI[KomeSalje[playerid]][NovacBanka], PI[KomeSalje[playerid]][SQLID]);

	format(string, sizeof(string), "{C2A2DA}* %s vrsi transver novca.", ReturnPlayerName(playerid));
	ProxMessage(playerid, string, 20.0);

	va_SendClientMessage(KomeSalje[playerid], 0x1b71bcFF, "[BANKA]: {FFFFFF}Igrac %s Vam je poslao %d$ novca na Vas bankovni racun!", ReturnPlayerName(playerid), iznos);
	va_SendClientMessage(playerid, 0x1b71bcFF, "[BANKA]: {FFFFFF}Poslali ste igracu %s na bankovni racun %s$ novca!", ReturnPlayerName(KomeSalje[playerid]), iznos);
	KomeSalje[playerid] = -1;
	return 1;
}

Dialog:dialog_zlatara(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    switch(listitem)
    {
		case 0:
		{
			Dialog_Show(playerid, dialog_zkupovina, DIALOG_STYLE_INPUT, "{1b71bc}Kupovina zlata:", "{FFFFFF}Unesite kolicinu zlata koju zelite da kupite:", "Kupi", "Izadji");
		}
		case 1:
		{
  			Dialog_Show(playerid, dialog_zprodaja, DIALOG_STYLE_INPUT, "{1b71bc}Prodaja zlata:", "{FFFFFF}Unesite kolicinu zlata koju zelite da prodate:", "Kupi", "Izadji");
		}
	}
	return 1;
}

Dialog:dialog_zkupovina(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

	static kolicina,
		cena = 1001;

	if(strfind(inputtext, "%", true) != -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Koristite samo brojeve!");

	if(sscanf(inputtext, "i", kolicina)) 
	    return Dialog_Show(playerid, dialog_zkupovina, DIALOG_STYLE_INPUT, "{1b71bc}Kupovina zlata:", "{FFFFFF}Unesite kolicinu zlata koju zelite da kupite:", "Kupi", "Izadji");

	if(kolicina < 1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ne mozete ici ispod 1 i iznad max kolicine zlata!");

	if(PI[playerid][Novac] < kolicina*cena)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dovoljno novca!");

	PI[playerid][Novac] -= kolicina*cena;
	GivePlayerMoney(playerid, -kolicina*cena);
	PI[playerid][Zlato] += kolicina;
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `Zlato` = '%d' WHERE `SQLID` = '%d'", PI[playerid][NovacBanka], PI[playerid][Zlato], PI[playerid][SQLID]);
	UpdateZlato(playerid);
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Kupili ste %dg zlata za %d$.", kolicina, kolicina*cena);
	return 1;
}

Dialog:dialog_zprodaja(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

	static kolicina,
		cena = 1000;

	if(strfind(inputtext, "%", true) != -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Koristite samo brojeve!");

	if(sscanf(inputtext, "i", kolicina))
	    return Dialog_Show(playerid, dialog_zprodaja, DIALOG_STYLE_INPUT, "{1b71bc}Prodaja zlata:", "{FFFFFF}Unesite kolicinu zlata koju zelite da prodate:", "Kupi", "Izadji");

	if(kolicina < 1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ne mozete ici ispod 1 i iznad max kolicine zlata!");

	if(PI[playerid][Novac] < kolicina*cena)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dovoljno novca!");

	PI[playerid][Novac] += kolicina*cena;
	GivePlayerMoney(playerid, kolicina*cena);
	PI[playerid][Zlato] -= kolicina;
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `Zlato` = '%d' WHERE `SQLID` = '%d'", PI[playerid][NovacBanka], PI[playerid][Zlato], PI[playerid][SQLID]);
	UpdateZlato(playerid);
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Prodali ste %dg zlata za %d$.", kolicina, kolicina*cena);
	return 1;
}

Dialog:dialog_dozvole(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    
    switch(listitem)
	{
		case 0:
		{
			if(PI[playerid][ADozvola] > 0)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec imate vozacku dozvolu!");

			if(PI[playerid][Novac] < 1000)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas dovljno novac (1000$)!");

			PI[playerid][Novac] -= 1000;
			GivePlayerMoney(playerid, -1000);
			PI[playerid][ADozvola] = 1;
			va_SendClientMessage(playerid, 0x1b71bcFF, "#AS: {FFFFFF}Uspesno ste kupili dozvolu za voznju (-1000$)!");
			
			mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `ADozvola` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][ADozvola], PI[playerid][SQLID]);

		}
		case 1:
		{
			if(PI[playerid][KamionDozvola] > 0)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec posedujes dozvolu za voznju kamiona!");

			if(PI[playerid][Novac] < 2000)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas dovljno novac (2000$)!");

            PI[playerid][Novac] -= 2000;
			GivePlayerMoney(playerid, -2000);
			PI[playerid][KamionDozvola] = 1;
			va_SendClientMessage(playerid, 0x1b71bcFF, "#AS: {FFFFFF}Uspesno ste kupili dozvolu za kamion (-2000$)!");
			
			mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `KamionDozvola` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][KamionDozvola], PI[playerid][SQLID]);
		}
		case 2:
		{
			if(PI[playerid][MotorDozvola] > 0)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec posedujes dozvolu za voznju motora!");

			if(PI[playerid][Novac] < 500)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas dovljno novac (500$)!");

            PI[playerid][Novac] -= 500;
			GivePlayerMoney(playerid, -500);
			PI[playerid][MotorDozvola] = 1;
			va_SendClientMessage(playerid, 0x1b71bcFF, "#AS: {FFFFFF}Uspesno ste kupili dozvolu za motor (-500$)!");

			mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `MotorDozvola` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][MotorDozvola], PI[playerid][SQLID]);
		}
		case 3:
		{
			if(PI[playerid][AvionDozvola] > 0)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec posedujes dozvolu za voznju aviona!");

			if(PI[playerid][Novac] < 4000)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas dovljno novac (4000$)!");

            PI[playerid][Novac] -= 4000;
			GivePlayerMoney(playerid, -4000);
			PI[playerid][AvionDozvola] = 1;
			va_SendClientMessage(playerid, 0x1b71bcFF, "#AS: {FFFFFF}Uspesno ste kupili dozvolu za avion (-4000$)!");

			mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `AvionDozvola` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][AvionDozvola], PI[playerid][SQLID]);
		}
		case 4:
		{
			if(PI[playerid][BrodDozvola] > 0)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec posedujes dozvolu za voznju broda!");

			if(PI[playerid][Novac] < 3000)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas dovljno novac (4000$)!");

            PI[playerid][Novac] -= 3000;
			GivePlayerMoney(playerid, -3000);
			PI[playerid][BrodDozvola] = 1;
			va_SendClientMessage(playerid, 0x1b71bcFF, "#AS: {FFFFFF}Uspesno ste kupili dozvolu za brod (-3000$)!");

			mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `BrodDozvola` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][BrodDozvola], PI[playerid][SQLID]);
		}
	}
	return 1;
}

Dialog:dialog_avozila(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

    switch(listitem)
	{
		case 0:
		{
		    static Float:Pos[4];
			GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
			
	    	vozilo1 = CreateVehicle(560, Pos[0], Pos[1], Pos[2], Pos[3], 1, 1, 500);
			PutPlayerInVehicle(playerid,vozilo1,0);
			AdminVozilo[playerid] = vozilo1;
			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Stvorili ste Admin Vozilo.");

			new engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(GetPlayerVehicleID(playerid), 1, lights, alarm, doors, bonnet, boot, objective);
		}
		case 1:
		{
		    static Float:Pos[4];
			GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
			
	    	vozilo1 = CreateVehicle(522, Pos[0], Pos[1], Pos[2], Pos[3], 1, 1, 500);
			PutPlayerInVehicle(playerid,vozilo1,0);
			AdminVozilo[playerid] = vozilo1;
			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Stvorili ste Admin Vozilo.");

			new engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(GetPlayerVehicleID(playerid), 1, lights, alarm, doors, bonnet, boot, objective);
		}
		case 2:
		{
		    static Float:Pos[4];
			GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
			
	    	vozilo1 = CreateVehicle(579, Pos[0], Pos[1], Pos[2], Pos[3], 1, 1, 500);
			PutPlayerInVehicle(playerid,vozilo1,0);
			AdminVozilo[playerid] = vozilo1;
			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Stvorili ste Admin Vozilo.");

			new engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(GetPlayerVehicleID(playerid), 1, lights, alarm, doors, bonnet, boot, objective);
		}
	}
	return 1;
}

Dialog:dialog_vipskin(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

	switch(listitem)
	{
        case 0:
		{
			SetPlayerSkin(playerid, 5); //Bumbar
		}
		case 1:
		{
			SetPlayerSkin(playerid, 4); //Mrsa
		}
        case 2:
		{
			SetPlayerSkin(playerid, 8); //Riki
		}
        case 3:
		{
			SetPlayerSkin(playerid, 22); //Milos
		}
		case 4:
        {
			SetPlayerSkin(playerid, 66); //Mica
        }
        case 5:
        {
			SetPlayerSkin(playerid, 101); //Nikola
        }
        case 6:
        {
			SetPlayerSkin(playerid, 112); //Celavi
        }
        case 7:
        {
			SetPlayerSkin(playerid, 137); //Prosjak
        }
		case 8:
        {
			SetPlayerSkin(playerid, 158); //Seljak
        }
        case 9:
        {
			SetPlayerSkin(playerid, 167); //Kokosar
        }
        case 10:
        {
			SetPlayerSkin(playerid, 206); //Zoran
        }
        case 11:
        {
			SetPlayerSkin(playerid, 252); //Peder :D
        }
        case 12:
        {
			SetPlayerSkin(playerid, 260); //Gradjevinac :D
        }
        case 13:
        {
			SetPlayerSkin(playerid, 264); //Klovn :D
        }
        case 14:
        {
			SetPlayerSkin(playerid, 289); //Streberko :D
        }
	}
	return 1;
}

Dialog:dialog_bankomat(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    
    switch(listitem)
	{
	    case 0:
		{
			Dialog_Show(playerid, dialog_none, DIALOG_STYLE_MSGBOX, "{1b71bc}Stanje racuna:", "{FFFFFF}Trenutno stanje na vasem racunu je: {1b71bc}$%d", "OK", "", PI[playerid][NovacBanka]);
		}
		case 1:
		{
		    Dialog_Show(playerid, dialog_bauzmi, DIALOG_STYLE_INPUT, "{1b71bc}Podigni novac:", "{FFFFFF}Unesite kolicinu novca koju zelite da podignete sa Vaseg bankovnog racuna:", "Podigni", "Izlaz");
		}
	}
	return 1;
}

Dialog:dialog_bauzmi(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

	static iznos,
		string[250];

	if(strfind(inputtext, "%", true) != -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Koristite samo brojeve!");

	if(sscanf(inputtext, "i", iznos))
		return Dialog_Show(playerid, dialog_bauzmi, DIALOG_STYLE_INPUT, "{1b71bc}Podigni novac:", "{FFFFFF}Unesite kolicinu novca koju zelite da podignete sa Vaseg bankovnog racuna:", "Podigni", "Izlaz");

	if(PI[playerid][NovacBanka] < iznos)
        return Dialog_Show(playerid, dialog_bauzmi, DIALOG_STYLE_INPUT, "{1b71bc}Podigni novac:", "{FFFFFF}Unesite kolicinu novca koju zelite da podignete sa Vaseg bankovnog racuna:", "Podigni", "Izlaz");

	if(iznos < 1 || iznos > 2000000)
		return Dialog_Show(playerid, dialog_bauzmi, DIALOG_STYLE_INPUT, "{1b71bc}Podigni novac:", "{FFFFFF}Unesite kolicinu novca koju zelite da podignete sa Vaseg bankovnog racuna:", "Podigni", "Izlaz");

	PI[playerid][NovacBanka] -= iznos;
	PI[playerid][Novac] += iznos;
	GivePlayerMoney(playerid, iznos);

	UpdateBanka(playerid);
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `NovacBanka` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][NovacBanka], PI[playerid][SQLID]);

	format(string, sizeof(string), "{C2A2DA}* %s dize novac sa bankovnog racuna.", ReturnPlayerName(playerid));
	ProxMessage(playerid, string, 20.0);

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Podigli ste %d$ sa Vaseg bankovnog racuna.", iznos);
	return 1;
}

Dialog:dialog_stan(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    if(PI[playerid][Stan] == -1) return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate stan!");
	new i = PI[playerid][Stan];
	switch(listitem)
	{
		case 0:
		{
		    if(!IsPlayerInRangeOfPoint(playerid, 5.0, StanInfo[i][sIzlazX], StanInfo[i][sIzlazY], StanInfo[i][sIzlazZ]))
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste u vasem stanu!");

			Dialog_Show(playerid, dialog_none, DIALOG_STYLE_MSGBOX, "{1b71bc}Stan Informacije", "{FFFFFF}_______________________________________\n\n\
																							      {1b71bc}Vlasnik stana: {FFFFFF}%s\n\
																								  {1b71bc}Level: {FFFFFF}%d\n\
																								  {1b71bc}Cena: {FFFFFF}%d\n\
																								  {1b71bc}ID stana: {FFFFFF}%d\n\
																								  {1b71bc}Zatvoreno: {FFFFFF}%s\n\
																								  {1b71bc}Novac: {FFFFFF}%d\n\
																								  {1b71bc}Oruzije: {FFFFFF}%s\n\
																								  \n_______________________________________", "Ok", "", StanInfo[i][sVlasnik], StanInfo[i][sLevel], StanInfo[i][sCena], StanInfo[i][SQLID],
									  																													StanInfo[i][sZatvoreno] == 1 ? "Da" : "Ne", StanInfo[i][sNovac], StanInfo[i][sOruzije] == 1 ? "Da" : "Ne");
		}
		case 1:
		{
		    if(!IsPlayerInRangeOfPoint(playerid, 5.0, StanInfo[i][sIzlazX], StanInfo[i][sIzlazY], StanInfo[i][sIzlazZ]))
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste u vasem stanu!");

			if(StanInfo[i][sZatvoreno] == 0)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec je otkljucan!");

			mysql_tqueryEx(SQL, "UPDATE `apartments` SET `Zatvoreno` = '0' WHERE `SQLID` = '%d'", StanInfo[i][SQLID]);

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Stan otkljucan!");
		}
		case 2:
		{
		    if(!IsPlayerInRangeOfPoint(playerid, 5.0, StanInfo[i][sIzlazX], StanInfo[i][sIzlazY], StanInfo[i][sIzlazZ]))
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste u vasoj kuci!");

			if(StanInfo[i][sZatvoreno] == 1)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec je zakljucan!");

			mysql_tqueryEx(SQL, "UPDATE `apartments` SET `Zatvoreno` = '1' WHERE `SQLID` = '%d'", StanInfo[i][SQLID]);

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Stan zakljucan!");
		}
		case 3:
		{
  			if(!IsPlayerInRangeOfPoint(playerid, 5.0, StanInfo[i][sIzlazX], StanInfo[i][sIzlazY], StanInfo[i][sIzlazZ]))
			  	return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste u vasem stanu!");

			Dialog_Show(playerid, dialog_sostavi, DIALOG_STYLE_LIST, "{1b71bc}Ostavi u stanu", "{1b71bc}(1). {FFFFFF}Novac\n\
																							    {1b71bc}(2). {FFFFFF}Oruzije", "Ok", "Izlaz");
		}
		case 4:
		{
  			if(!IsPlayerInRangeOfPoint(playerid, 5.0, StanInfo[i][sIzlazX], StanInfo[i][sIzlazY], StanInfo[i][sIzlazZ]))
			  return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste u vasem stanu!");

			Dialog_Show(playerid, dialog_suzmi, DIALOG_STYLE_LIST, "{1b71bc}Uzmi iz stanu", "{1b71bc}(1). {FFFFFF}Novac\n\
                                                                                             {1b71bc}(2). {FFFFFF}Oruzije", "Ok", "Izlaz");
		}
		case 5:
		{
			if(PI[playerid][Stan] == -1)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate stan!");

			if(!IsPlayerInRangeOfPoint(playerid, 5.0, StanInfo[i][sUlazX], StanInfo[i][sUlazY], StanInfo[i][sUlazZ]))
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste ispred vaseg stana!");

			new cena1 = (StanInfo[i][sCena]/4)*2;
			Dialog_Show(playerid, dialog_sprodaja, DIALOG_STYLE_MSGBOX, "{1b71bc}Prodaja stana drzavi", "{FFFFFF}Prodaja stana drzavi\n\n\
   																						           Dali ste sigurni da zelite da prodate stan drzavi za {1b71bc}%d$!\n\n\
   																								   {FFFFFF}Ako ste sigurni kliknite na 'Prodaj' ako ne kliknite na 'Izlaz'", "Prodaj", "Izlaz", cena1);
		}
		case 6:
		{
  			if(!IsPlayerInRangeOfPoint(playerid, 5.0, StanInfo[i][sUlazX], StanInfo[i][sUlazY], StanInfo[i][sUlazZ]))
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste ispred vaseg stana!");

			Dialog_Show(playerid, dialog_spre, DIALOG_STYLE_TABLIST_HEADERS, "{1b71bc}Preuredjivanje", "Opcija\tCena\n\
		 																		                       {1b71bc}(1). {FFFFFF}Standardan Enterijer\n\
		 																		                       {1b71bc}(2). {FFFFFF}Enterijer 1\t5000$\n\
		 																							   {1b71bc}(3). {FFFFFF}Enterijer 2\t10000$\n\
                             													                       {1b71bc}(4). {FFFFFF}Enterijer 3\t15000$", "Ok", "Izlaz");
		}
	}
	return 1;
}

Dialog:dialog_spre(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    
    if(PI[playerid][Stan] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate stan!");

	new i = PI[playerid][Stan];

	switch(listitem)
	{
		case 0:
		{
  			StanInfo[i][sIzlazX] = 244.1522;
			StanInfo[i][sIzlazY] = 305.0730;
			StanInfo[i][sIzlazZ] = 999.1484;
			StanInfo[i][sInt] = 1;
			
			mysql_tqueryEx(SQL, "UPDATE `apartments` SET `IzlazX` = '%f', `IzlazY` = '%f', `IzlazZ` = '%f', `Interijer` = '%d' WHERE `SQLID` = '%d'", StanInfo[i][sIzlazX], StanInfo[i][sIzlazY], StanInfo[i][sIzlazZ], StanInfo[i][sInt], StanInfo[i][SQLID]);

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste promenili enterijer stana u standardan enterijer!");
		}
		case 1:
		{
  			if(PI[playerid][Novac] < 5000)
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dovoljno novca 5000$!");

			StanInfo[i][sIzlazX] = 267.2224;
			StanInfo[i][sIzlazY] = 304.9358;
			StanInfo[i][sIzlazZ] = 999.1484;
			StanInfo[i][sInt] = 2;
			
			mysql_tqueryEx(SQL, "UPDATE `apartments` SET `IzlazX` = '%f', `IzlazY` = '%f', `IzlazZ` = '%f', `Interijer` = '%d' WHERE `SQLID` = '%d'", StanInfo[i][sIzlazX], StanInfo[i][sIzlazY], StanInfo[i][sIzlazZ], StanInfo[i][sInt], StanInfo[i][SQLID]);

			PI[playerid][Novac] -= 5000;
			GivePlayerMoney(playerid, -5000); 
			
			mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][SQLID]);

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste promenili enterijer stana (5000$)!");
		}
		case 2:
		{
  			if(PI[playerid][Novac] < 10000)
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dovoljno novca 10000$!");

			StanInfo[i][sIzlazX] = 2217.6794;
			StanInfo[i][sIzlazY] = -1076.2312;
			StanInfo[i][sIzlazZ] = 1050.4844;
			StanInfo[i][sInt] = 1;
			
			mysql_tqueryEx(SQL, "UPDATE `apartments` SET `IzlazX` = '%f', `IzlazY` = '%f', `IzlazZ` = '%f', `Interijer` = '%d' WHERE `SQLID` = '%d'", StanInfo[i][sIzlazX], StanInfo[i][sIzlazY], StanInfo[i][sIzlazZ], StanInfo[i][sInt], StanInfo[i][SQLID]);

			PI[playerid][Novac] -= 10000;
			GivePlayerMoney(playerid, -10000);

			mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][SQLID]);

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste promenili enterijer stana (10000$)!");
		}
		case 3:
		{
  			if(PI[playerid][Novac] < 15000)
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dovoljno novca 15000$!");

			StanInfo[i][sIzlazX] = 2282.9861;
			StanInfo[i][sIzlazY] = -1139.9357;
			StanInfo[i][sIzlazZ] = 1050.8984;
			StanInfo[i][sInt] = 11;
    		
    		mysql_tqueryEx(SQL, "UPDATE `apartments` SET `IzlazX` = '%f', `IzlazY` = '%f', `IzlazZ` = '%f', `Interijer` = '%d' WHERE `SQLID` = '%d'", StanInfo[i][sIzlazX], StanInfo[i][sIzlazY], StanInfo[i][sIzlazZ], StanInfo[i][sInt], StanInfo[i][SQLID]);

			PI[playerid][Novac] -= 15000;
			GivePlayerMoney(playerid, -15000);

			mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][SQLID]);

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste promenili enterijer stana (15000$)!");
		}
	}
	return 1;
}

Dialog:dialog_suzmi(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

	if(PI[playerid][Stan] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate stan!");

	new i = PI[playerid][Stan];
	switch(listitem)
	{
		case 0:
		{
  			Dialog_Show(playerid, dialog_sunovac, DIALOG_STYLE_INPUT, "{1b71bc}Uzimanje Novca", "{FFFFFF}Unesite kolicinu novca koju zelite da uzmete", "Ostavi", "Izlaz");
		}
		case 1:
		{
  			if(StanInfo[i][sOruzije] == -1)
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas oruzije u stanu!");

			GivePlayerWeapon(playerid, StanInfo[i][sOruzije], StanInfo[i][sMunicija]);
			StanInfo[i][sOruzije] = -1;
			StanInfo[i][sMunicija] = -1;

			mysql_tqueryEx(SQL, "UPDATE `apartments` SET `Oruzije` = '%d', `Municija` = '%d' WHERE `SQLID` = '%d'", StanInfo[i][sOruzije], StanInfo[i][sMunicija], StanInfo[i][SQLID]);

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uzeli ste oruzije iz vaseg stana!");
		}
	}
	return 1;
}

Dialog:dialog_sunovac(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

	if(PI[playerid][Stan] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate stan!");

	new i = PI[playerid][Stan];
	
	static iznos;

	if(sscanf(inputtext, "i", iznos))
		return Dialog_Show(playerid, dialog_sunovac, DIALOG_STYLE_INPUT, "{1b71bc}Uzimanje Novca", "{FFFFFF}Unesite kolicinu novca koju zelite da uzmete", "Ostavi", "Izlaz");

	if(iznos > StanInfo[i][sNovac])
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate toliko novca u stanu!");

	if(iznos < 1 || iznos > 50000)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Suma ne mozete biti manja od 1 i veca od 50000 odjednom!");

	StanInfo[i][sNovac] -= iznos;
	
	mysql_tqueryEx(SQL, "UPDATE `apartments` SET `Novac` = '%d' WHERE `SQLID` = '%d'", StanInfo[i][sNovac], StanInfo[i][SQLID]);

	PI[playerid][Novac] += iznos;
	GivePlayerMoney(playerid, iznos);
	
    mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][SQLID]);
	
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uzeli ste iz stana %d$ novca!", iznos);
	return 1;
}

Dialog:dialog_sonovac(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

	if(PI[playerid][Stan] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate stan!");

	new i = PI[playerid][Stan];

	static iznos;

	if(sscanf(inputtext, "i", iznos))
		return Dialog_Show(playerid, dialog_sonovac, DIALOG_STYLE_INPUT, "{1b71bc}Ostavljanje Novca", "{FFFFFF}Unesite kolicinu novca koju zelite da ostavite", "Ostavi", "Izlaz");

	if(iznos > PI[playerid][Novac])
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate toliko novca!");

	if(iznos < 1 || iznos > 50000)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Suma ne mozete biti manja od 1 i veca od 50000 odjednom!");

	StanInfo[i][sNovac] += iznos;

	mysql_tqueryEx(SQL, "UPDATE `apartments` SET `Novac` = '%d' WHERE `SQLID` = '%d'", StanInfo[i][sNovac], StanInfo[i][SQLID]);

	PI[playerid][Novac] -= iznos;
	GivePlayerMoney(playerid, -iznos);

    mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][SQLID]);

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Ostavili ste u stanu %d$ novca!", iznos);
	return 1;
}

Dialog:dialog_sostavi(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

	if(PI[playerid][Stan] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate stan!");

	new i = PI[playerid][Stan];
	switch(listitem)
	{
		case 0:
		{
  			Dialog_Show(playerid, dialog_sonovac, DIALOG_STYLE_INPUT, "{1b71bc}Ostavljanje Novca", "{FFFFFF}Unesite kolicinu novca koju zelite da ostavite", "Ostavi", "Izlaz");
		}
		case 1:
		{
  			if(StanInfo[i][sOruzije] != -1)
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec imas oruzije u stanu!");
  				
            if(GetPlayerWeapon(playerid) <= 0)
                return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas oruzije u ruci!");

			StanInfo[i][sOruzije] = GetPlayerWeapon(playerid);
			StanInfo[i][sMunicija] = GetPlayerAmmo(playerid);

			mysql_tqueryEx(SQL, "UPDATE `apartments` SET `Oruzije` = '%d', `Municija` = '%d' WHERE `SQLID` = '%d'", StanInfo[i][sOruzije], StanInfo[i][sMunicija], StanInfo[i][SQLID]);

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Ostavili ste oruzije u vasem stanu!");
		}
	}
	return 1;
}

Dialog:dialog_sprodaja(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    
    if(PI[playerid][Stan] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate stan!");

	new i = PI[playerid][Stan];
	
	new cena1 = (StanInfo[i][sCena]/4)*2;
 	PI[playerid][Novac] += cena1;
	GivePlayerMoney(playerid, cena1);
	PI[playerid][Stan] = -1;
	
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `Stan` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][Stan], PI[playerid][SQLID]);

	StanInfo[i][sProveraVlasnika] = 0;
	StanInfo[i][sNovac] = 0;
	StanInfo[i][sOruzije] = -1;
	StanInfo[i][sMunicija] = 0;
	StanInfo[i][sZatvoreno] = 1;

	strmid(StanInfo[i][sVlasnik], "Niko", 0, strlen("Niko"), 255);
	StanLP(i);
	
	mysql_tqueryEx(SQL, "UPDATE `apartments` SET `ProveraVlasnika` = '%d', `Vlasnik` = 'Niko', `Zatvoreno` = '%d', `Novac` = '%d', `Oruzije` = '%d', `Municija` = '%d' WHERE `SQLID` = '%d'",
		StanInfo[i][sProveraVlasnika], StanInfo[i][sZatvoreno], StanInfo[i][sNovac], StanInfo[i][sOruzije],StanInfo[i][sMunicija], StanInfo[i][SQLID]);

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Prodali ste stan za %d$!", cena1);
	return 1;
}

Dialog:dialog_kuca(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    if(PI[playerid][Kuca] == -1) return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate kucu!");
	new i = PI[playerid][Kuca];
	switch(listitem)
	{
		case 0:
		{
		    if(!IsPlayerInRangeOfPoint(playerid, 5.0, KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ]))
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste u vasoj kuci!");

			Dialog_Show(playerid, dialog_none, DIALOG_STYLE_MSGBOX, "{1b71bc}Kuca Informacije", "{FFFFFF}_______________________________________\n\n\
																							      {1b71bc}Vlasnik kuce: {FFFFFF}%s\n\
																								  {1b71bc}Level: {FFFFFF}%d\n\
																								  {1b71bc}Cena: {FFFFFF}%d\n\
																								  {1b71bc}Cena Renta: {FFFFFF}%d\n\
																								  {1b71bc}ID kuce: {FFFFFF}%d\n\
																								  {1b71bc}Zatvoreno: {FFFFFF}%s\n\
																								  {1b71bc}Novac: {FFFFFF}%d\n\
																								  {1b71bc}Droga: {FFFFFF}%d\n\
																								  {1b71bc}Mats: {FFFFFF}%d\n\
																								  {1b71bc}Odjeca: {FFFFFF}%s\n\
																								  {1b71bc}Oruzije: {FFFFFF}%s\n\
																								  \n_______________________________________", "Ok", "", KucaInfo[i][kVlasnik],KucaInfo[i][kLevel],KucaInfo[i][kCena],KucaInfo[i][kCenaRenta],
																								  															 KucaInfo[i][SQLID], KucaInfo[i][kZatvoreno] == 1 ? "Da" : "Ne", KucaInfo[i][kNovac],KucaInfo[i][kDroga],KucaInfo[i][kMats],
																							   																 KucaInfo[i][kOdjeca] == 1 ? "Da" : "Ne", KucaInfo[i][kOruzije] == 1 ? "Da" : "Ne");
		}
		case 1:
		{
		    if(!IsPlayerInRangeOfPoint(playerid, 5.0, KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ]))
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste u vasoj kuci!");

			if(KucaInfo[i][kZatvoreno] == 0)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec je otkljucana!");

			mysql_tqueryEx(SQL, "UPDATE `houses` SET `Zatvoreno` = '0' WHERE `SQLID` = '%d'", KucaInfo[i][SQLID]);

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Kuca otkljucana!");
		}
		case 2:
		{
		    if(!IsPlayerInRangeOfPoint(playerid, 5.0, KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ]))
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste u vasoj kuci!");

			if(KucaInfo[i][kZatvoreno] == 1)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec je zakljucana!");

			mysql_tqueryEx(SQL, "UPDATE `houses` SET `Zatvoreno` = '1' WHERE `SQLID` = '%d'", KucaInfo[i][SQLID]);

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Kuca zakljucana!");
		}
		case 3:
		{
  			if(!IsPlayerInRangeOfPoint(playerid, 5.0, KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ]))
			  	return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste u vasoj kuci!");

			Dialog_Show(playerid, dialog_kostavi, DIALOG_STYLE_LIST, "{1b71bc}Ostavi u kuci", "{1b71bc}(1). {FFFFFF}Novac\n\
																						       {1b71bc}(2). {FFFFFF}Drogu\n\
																							   {1b71bc}(3). {FFFFFF}Mats\n\
																							   {1b71bc}(4). {FFFFFF}Odelo\n\
																							   {1b71bc}(5). {FFFFFF}Oruzije", "Ok", "Izlaz");
		}
		case 4:
		{
  			if(!IsPlayerInRangeOfPoint(playerid, 5.0, KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ]))
			  return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste u vasoj kuci!");

			Dialog_Show(playerid, dialog_kuzmi, DIALOG_STYLE_LIST, "{1b71bc}Uzmi iz kuce", "{1b71bc}(1). {FFFFFF}Novac\n\
																						       {1b71bc}(2). {FFFFFF}Drogu\n\
																							   {1b71bc}(3). {FFFFFF}Mats\n\
																							   {1b71bc}(4). {FFFFFF}Odelo\n\
																							   {1b71bc}(5). {FFFFFF}Oruzije", "Ok", "Izlaz");
		}
		case 5:
		{
			if(PI[playerid][Kuca] == -1)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate kucu!");

			if(!IsPlayerInRangeOfPoint(playerid, 5.0, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]))
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste ispred vase kuce!");

			new cena1 = (KucaInfo[i][kCena]/4)*2;
			Dialog_Show(playerid, dialog_kprodaja, DIALOG_STYLE_MSGBOX, "{1b71bc}Prodaja kuce drzavi", "{FFFFFF}Prodaja kuce drzavi\n\n\
   																						           Dali ste sigurni da zelite da prodate kucu drzavi za {1b71bc}%d$!\n\n\
   																								   {FFFFFF}Ako ste sigurni kliknite na 'Prodaj' ako ne kliknite na 'Izlaz'", "Prodaj", "Izlaz", cena1);
		}
		case 6:
		{
  			if(!IsPlayerInRangeOfPoint(playerid, 5.0, KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ]))
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste u vasoj kuci!");

			if(KucaInfo[i][kRent] == 0)
			{
				KucaInfo[i][kRent] = 1;
				KuceLP(i);
				
				mysql_tqueryEx(SQL, "UPDATE `houses` SET `Rent` = '1' WHERE `SQLID` = '%d'", KucaInfo[i][SQLID]);
				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Odobrili ste rent kuce!");
			}
			else
			{
				KucaInfo[i][kRent] = 0;
				KuceLP(i);
				
				mysql_tqueryEx(SQL, "UPDATE `houses` SET `Rent` = '0' WHERE `SQLID` = '%d'", KucaInfo[i][SQLID]);
				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Zabranili ste rent kuce!");
			}
		}
		case 7:
		{
  			if(!IsPlayerInRangeOfPoint(playerid, 5.0, KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ]))
		  		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste u vasoj kuci!");

			if(KucaInfo[i][kRent] == 0)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Na vasoj kuci nije dozvoljen rent pa ne mozete podesavati cenu!");

			Dialog_Show(playerid, dialog_krent, DIALOG_STYLE_INPUT, "{1b71bc}Cena Renta", "{FFFFFF}Unesite novu cenu renta", "Promeni", "Izlaz");
		}
		case 8:
		{
  			if(!IsPlayerInRangeOfPoint(playerid, 5.0, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]))
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste ispred vase kuce!");

			Dialog_Show(playerid, dialog_kpre, DIALOG_STYLE_TABLIST_HEADERS, "{1b71bc}Nadogradnja/Preuredjivanje", "Opcija\tCena\n\
																											         {1b71bc}(1). {FFFFFF}Zvono\t2000$\n\
																													 {1b71bc}(2). {FFFFFF}Frizder\t3000$\n\
																													 {1b71bc}(3). {FFFFFF}Standardan Enterijer 1\n\
																													 {1b71bc}(4). {FFFFFF}Enterijer 2\t30000$\n\
																													 {1b71bc}(5). {FFFFFF}Enterijer 3\t40000$", "Ok", "Izlaz");
		}
		case 9:
		{
  			if(!IsPlayerInRangeOfPoint(playerid, 5.0, KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ]))
		  		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste u vasoj kuci!");

			if(KucaInfo[i][kFrizder] == 0)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas frizder u kuci!");

			Dialog_Show(playerid, dialog_knamernice, DIALOG_STYLE_LIST, "{1b71bc}Namernice", "{1b71bc}(1). {FFFFFF}Koristi hranu\n{1b71bc}(2). {FFFFFF}Ostavi hranu", "Ok", "Izlaz");
		}
	}
	return 1;
}

Dialog:dialog_knamernice(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

	if(PI[playerid][Kuca] == -1) return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate kucu!");

	new i = PI[playerid][Kuca];
	switch(listitem)
	{
		case 0:
		{
  			if(KucaInfo[i][kHrana] <= 0)
		  		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nema hrane u kuci!");

			static Float:hp;
			GetPlayerHealth(playerid, hp);

			if(hp >= 100)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Niste gladni!");

			KucaInfo[i][kHrana] --;
			mysql_tqueryEx(SQL, "UPDATE `houses` SET `Hrana` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kHrana], KucaInfo[i][SQLID]);

			SetPlayerHealth(playerid, 100);
			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Pojeli ste nesto hrane iz frizdera!");
		}
		case 1:
		{
  			Dialog_Show(playerid, dialog_konamernice, DIALOG_STYLE_INPUT, "{1b71bc}Namernice", "{FFFFFF}Unesite kolicinu hrane koju zelite da ostavite", "Unesi", "Izlaz");
		}
	}
	return 1;
}

Dialog:dialog_konamernice(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

    if(PI[playerid][Kuca] == -1) return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate kucu!");

	new i = PI[playerid][Kuca];

	static iznos;

	if(sscanf(inputtext, "i", iznos))
		return Dialog_Show(playerid, dialog_konamernice, DIALOG_STYLE_INPUT, "{1b71bc}Namernice", "{FFFFFF}Unesite kolicinu hrane koju zelite da ostavite", "Unesi", "Izlaz");

	if(iznos > PI[playerid][Hrana])
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate toliko hrane!");

	if(iznos < 1 || iznos > 5)
		va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Suma ne mozete biti manja od 1 i veca od 5 odjednom!");

	KucaInfo[i][kHrana] += iznos;
	PI[playerid][Hrana] -= iznos;

	mysql_tqueryEx(SQL, "UPDATE `houses` SET `Hrana` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kHrana], KucaInfo[i][SQLID]);
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Hrana` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Hrana], PI[playerid][SQLID]);
	
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Ostavili ste u kucu %d namernica!", iznos);
	return 1;
}

Dialog:dialog_kpre(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    
    if(PI[playerid][Kuca] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate kucu!");

	new i = PI[playerid][Kuca];

	switch(listitem)
	{
		case 0:
		{
			if(KucaInfo[i][kZvono] == 1)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec imas zvono u kuci!");

			if(PI[playerid][Novac] < 2000)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dovoljno novac!");

			KucaInfo[i][kZvono] = 1;
			PI[playerid][Novac] -= 2000;
			GivePlayerMoney(playerid, -2000);

			mysql_tqueryEx(SQL, "UPDATE `houses` SET `Zvono` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kZvono], KucaInfo[i][SQLID]);
			mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][SQLID]);

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Ugradili ste zvono u vasu kucu /zvoni!");
		}
		case 1:
		{
  			if(KucaInfo[i][kFrizder] == 1)
			  return va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Vec imas frizder u kuci!");

			if(PI[playerid][Novac] < 3000)
				return va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Nemate dovoljno novca!");

			KucaInfo[i][kFrizder] = 1;
			PI[playerid][Novac] -= 3000;
			GivePlayerMoney(playerid, -3000);
			
			mysql_tqueryEx(SQL, "UPDATE `houses` SET `Frizider` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kFrizder], KucaInfo[i][SQLID]);
			mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][SQLID]);

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Ugradili ste frizder u vasu kucu!");
		}
		case 2:
		{
  			if(KucaInfo[i][kVrstaIntKuce] == 1)
	    	{
      			KucaInfo[i][kIzlazX] = 223.0732;
  				KucaInfo[i][kIzlazY] = 1288.3668;
  				KucaInfo[i][kIzlazZ] = 1082.1406;
  				KucaInfo[i][kInt] = 1;
  				SetPlayerInterior(playerid, 0);
			  	SetPlayerVirtualWorld(playerid, 0);
  				SetPlayerPos(playerid, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]);

				mysql_tqueryEx(SQL, "UPDATE `houses` SET `IzlazX` = '%f', `IzlazY` = '%f', `IzlazZ` = '%f', `Interior` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ], KucaInfo[i][kInt], KucaInfo[i][SQLID]);

				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste promenili enterijer kuce u standardan enterijer male kuce!");
		    }
      		else if(KucaInfo[i][kVrstaIntKuce] == 2)
		    {
      			KucaInfo[i][kIzlazX] = 2365.2822;
  				KucaInfo[i][kIzlazY] = -1134.5186;
  				KucaInfo[i][kIzlazZ] = 1050.8750;
  				KucaInfo[i][kInt] = 8;
  				SetPlayerInterior(playerid, 0);
		  		SetPlayerVirtualWorld(playerid, 0);
    			SetPlayerPos(playerid, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]);

				mysql_tqueryEx(SQL, "UPDATE `houses` SET `IzlazX` = '%f', `IzlazY` = '%f', `IzlazZ` = '%f', `Interior` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ], KucaInfo[i][kInt], KucaInfo[i][SQLID]);

				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste promenili enterijer kuce u standardan enterijer srednje kuce!");
		    }
		    else if(KucaInfo[i][kVrstaIntKuce] == 3)
		    {
     			KucaInfo[i][kIzlazX] = 2317.8977;
  				KucaInfo[i][kIzlazY] = -1025.7722;
				KucaInfo[i][kIzlazZ] = 1050.2109;
				KucaInfo[i][kInt] = 9;
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
  				SetPlayerPos(playerid, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]);

                mysql_tqueryEx(SQL, "UPDATE `houses` SET `IzlazX` = '%f', `IzlazY` = '%f', `IzlazZ` = '%f', `Interior` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ], KucaInfo[i][kInt], KucaInfo[i][SQLID]);

				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste promenili enterijer kuce u standardan enterijer velike kuce!");
		    }
		    else if(KucaInfo[i][kVrstaIntKuce] == 4)
		    {
      			KucaInfo[i][kIzlazX] = 140.2605;
  				KucaInfo[i][kIzlazY] = 1367.4221;
  				KucaInfo[i][kIzlazZ] = 1083.8615;
  				KucaInfo[i][kInt] = 5;
  				SetPlayerInterior(playerid, 0);
		  		SetPlayerVirtualWorld(playerid, 0);
    			SetPlayerPos(playerid, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]);

				mysql_tqueryEx(SQL, "UPDATE `houses` SET `IzlazX` = '%f', `IzlazY` = '%f', `IzlazZ` = '%f', `Interior` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ], KucaInfo[i][kInt], KucaInfo[i][SQLID]);

				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste promenili enterijer kuce u standardan enterijer ville!");

			}
		}
		case 3:
		{
  			if(PI[playerid][Novac] < 30000)
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dovoljno novca (30000$)!");

            PI[playerid][Novac] -= 30000;
			GivePlayerMoney(playerid, -30000);

			mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][SQLID]);

			if(KucaInfo[i][kVrstaIntKuce] == 1)
   			{
      			KucaInfo[i][kIzlazX] = 2308.7527;
  				KucaInfo[i][kIzlazY] = -1211.7507;
  				KucaInfo[i][kIzlazZ] = 1049.0234;
  				KucaInfo[i][kInt] = 6;
  				SetPlayerInterior(playerid, 0);
	  			SetPlayerVirtualWorld(playerid, 0);
    			SetPlayerPos(playerid, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]);

				mysql_tqueryEx(SQL, "UPDATE `houses` SET `IzlazX` = '%f', `IzlazY` = '%f', `IzlazZ` = '%f', `Interior` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ], KucaInfo[i][kInt], KucaInfo[i][SQLID]);

				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste promenili enterijer male kuce (30000$)!");
    		}
      		else if(KucaInfo[i][kVrstaIntKuce] == 2)
		    {
      			KucaInfo[i][kIzlazX] = 2195.9036;
				KucaInfo[i][kIzlazY] = -1204.4109;
				KucaInfo[i][kIzlazZ] = 1049.0234;
				KucaInfo[i][kInt] = 6;
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
  				SetPlayerPos(playerid, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]);

				mysql_tqueryEx(SQL, "UPDATE `houses` SET `IzlazX` = '%f', `IzlazY` = '%f', `IzlazZ` = '%f', `Interior` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ], KucaInfo[i][kInt], KucaInfo[i][SQLID]);

				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste promenili enterijer srednje kuce (30000$)!");
		    }
		    else if(KucaInfo[i][kVrstaIntKuce] == 3)
		    {
     			KucaInfo[i][kIzlazX] = 83.1142;
  				KucaInfo[i][kIzlazY] = 1323.1691;
				KucaInfo[i][kIzlazZ] = 1083.8594;
				KucaInfo[i][kInt] = 9;
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
  				SetPlayerPos(playerid, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]);

				mysql_tqueryEx(SQL, "UPDATE `houses` SET `IzlazX` = '%f', `IzlazY` = '%f', `IzlazZ` = '%f', `Interior` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ], KucaInfo[i][kInt], KucaInfo[i][SQLID]);
				
				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste promenili enterijer velike kuce (30000$)!");
		    }
		    else if(KucaInfo[i][kVrstaIntKuce] == 4)
		    {
      			KucaInfo[i][kIzlazX] = 226.9117;
  				KucaInfo[i][kIzlazY] = 1114.2726;
  				KucaInfo[i][kIzlazZ] = 1080.9961;
  				KucaInfo[i][kInt] = 5;
  				SetPlayerInterior(playerid, 0);
		  		SetPlayerVirtualWorld(playerid, 0);
    			SetPlayerPos(playerid, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]);

                mysql_tqueryEx(SQL, "UPDATE `houses` SET `IzlazX` = '%f', `IzlazY` = '%f', `IzlazZ` = '%f', `Interior` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ], KucaInfo[i][kInt], KucaInfo[i][SQLID]);
                
				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste promenili enterijer ville (30000$)!");
			}
		}
		case 4:
		{
		    if(PI[playerid][Novac] < 40000)
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate dovoljno novca (40000$)!");

            PI[playerid][Novac] -= 40000;
			GivePlayerMoney(playerid, -40000);
			
			mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][SQLID]);

			if(KucaInfo[i][kVrstaIntKuce] == 1)
   			{
      			KucaInfo[i][kIzlazX] = 261.0457;
  				KucaInfo[i][kIzlazY] = 1285.4824;
  				KucaInfo[i][kIzlazZ] = 1080.2578;
  				KucaInfo[i][kInt] = 4;
  				SetPlayerInterior(playerid, 0);
	  			SetPlayerVirtualWorld(playerid, 0);
    			SetPlayerPos(playerid, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]);

				mysql_tqueryEx(SQL, "UPDATE `houses` SET `IzlazX` = '%f', `IzlazY` = '%f', `IzlazZ` = '%f', `Interior` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ], KucaInfo[i][kInt], KucaInfo[i][SQLID]);

				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste promenili enterijer male kuce (40000$)!");
		    }
      		else if(KucaInfo[i][kVrstaIntKuce] == 2)
		    {
      			KucaInfo[i][kIzlazX] = 2269.3962;
  				KucaInfo[i][kIzlazY] = -1210.4148;
  				KucaInfo[i][kIzlazZ] = 1047.5625;
  				KucaInfo[i][kInt] = 10;
  				SetPlayerInterior(playerid, 0);
		  		SetPlayerVirtualWorld(playerid, 0);
  				SetPlayerPos(playerid, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]);

                mysql_tqueryEx(SQL, "UPDATE `houses` SET `IzlazX` = '%f', `IzlazY` = '%f', `IzlazZ` = '%f', `Interior` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ], KucaInfo[i][kInt], KucaInfo[i][SQLID]);

				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste promenili enterijer srednje kuce (40000$)!");
		    }
		    else if(KucaInfo[i][kVrstaIntKuce] == 3)
		    {
     			KucaInfo[i][kIzlazX] = 2324.4817;
  				KucaInfo[i][kIzlazY] = -1148.3988;
				KucaInfo[i][kIzlazZ] = 1050.7101;
				KucaInfo[i][kInt] = 12;
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
  				SetPlayerPos(playerid, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]);

				mysql_tqueryEx(SQL, "UPDATE `houses` SET `IzlazX` = '%f', `IzlazY` = '%f', `IzlazZ` = '%f', `Interior` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ], KucaInfo[i][kInt], KucaInfo[i][SQLID]);

				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste promenili enterijer velike kuce (40000$)!");
		    }
		    else if(KucaInfo[i][kVrstaIntKuce] == 4)
		    {
      			KucaInfo[i][kIzlazX] = 225.9810;
  				KucaInfo[i][kIzlazY] = 1022.8190;
  				KucaInfo[i][kIzlazZ] = 1084.0137;
  				KucaInfo[i][kInt] = 7;
  				SetPlayerInterior(playerid, 0);
		  		SetPlayerVirtualWorld(playerid, 0);
  				SetPlayerPos(playerid, KucaInfo[i][kUlazX], KucaInfo[i][kUlazY], KucaInfo[i][kUlazZ]);

				mysql_tqueryEx(SQL, "UPDATE `houses` SET `IzlazX` = '%f', `IzlazY` = '%f', `IzlazZ` = '%f', `Interior` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ], KucaInfo[i][kInt], KucaInfo[i][SQLID]);

				va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste promenili enterijer ville (40000$)!");
	  		}
		}
	}
	return 1;
}

Dialog:dialog_krent(playerid, response, listitem, inputtext[])
{
	if(!response) return 1;
	
	new i = PI[playerid][Kuca],
		cena;

	if(sscanf(inputtext, "i", cena))
		return Dialog_Show(playerid, dialog_krent, DIALOG_STYLE_INPUT, "{1b71bc}Cena Renta", "{FFFFFF}Unesite novu cenu renta", "Promeni", "Izlaz");

	if(cena < 1 || cena > 1000)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Cena ne moze biti manja od 1 i veca od 1000!");

	KucaInfo[i][kCenaRenta] = cena;

	mysql_tqueryEx(SQL, "UPDATE `houses` SET `CenaRenta` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kCenaRenta], KucaInfo[i][SQLID]);
 	KuceLP(i);

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste promenili cenu renta!");
	return 1;
}

Dialog:dialog_kprodaja(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    
    if(PI[playerid][Kuca] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate kucu!");

	new i = PI[playerid][Kuca];

	new cena1 = (KucaInfo[i][kCena]/4)*2;

    PI[playerid][Novac] += cena1;
	GivePlayerMoney(playerid, cena1);
	
	PI[playerid][Kuca] = -1;
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d', `Kuca` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][Kuca], PI[playerid][SQLID]);
	
	KucaInfo[i][kProveraVlasnika] = 0;
	KucaInfo[i][kNovac] = 0;
	KucaInfo[i][kOruzije] = -1;
	KucaInfo[i][kMunicija] = 0;
	KucaInfo[i][kOdjeca] = 0;
	KucaInfo[i][kDroga] = 0;
	KucaInfo[i][kMats] = 0;
	KucaInfo[i][kZatvoreno] = 1;
	KucaInfo[i][kRent] = 0;
	KucaInfo[i][kHrana] = 0;
	strmid(KucaInfo[i][kVlasnik], "Niko", 0, strlen("Niko"), 255);
	
	mysql_tqueryEx(SQL, "UPDATE `houses` SET `ProveraVlasnika` = '%d', `Vlasnik` = 'Niko', `Zatvoreno` = '%d', `Oruzije` = '%d', `Municija` = '%d', `Rent` = '%d', `Mats` = '%d', `Droga` = '%d',\
		`Odjeca` = '%d', `Hrana` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kProveraVlasnika], KucaInfo[i][kZatvoreno], KucaInfo[i][kOruzije], KucaInfo[i][kMunicija], KucaInfo[i][kRent],
		KucaInfo[i][kMats], KucaInfo[i][kDroga], KucaInfo[i][kOdjeca], KucaInfo[i][kHrana], KucaInfo[i][SQLID]);
		
    KuceLP(i);
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Prodali ste kucu za %d$!",cena1);
	return 1;
}

Dialog:dialog_kuzmi(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    
    if(PI[playerid][Kuca] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate kucu!");

	new i = PI[playerid][Kuca];
	
	switch(listitem)
	{
		case 0:
		{
  			Dialog_Show(playerid, dialog_kunovac, DIALOG_STYLE_INPUT, "{1b71bc}Uzimanje Novca", "{FFFFFF}Unesite kolicinu novca koju zelite da uzmete", "Ostavi", "Izlaz");
		}
		case 1:
		{
  			Dialog_Show(playerid, dialog_kudrogu, DIALOG_STYLE_INPUT, "{1b71bc}Uzimanje Droge", "{FFFFFF}Unesite kolicinu droge koju zelite da uzmete", "Ostavi", "Izlaz");
		}
		case 2:
		{
  			Dialog_Show(playerid, dialog_kumats, DIALOG_STYLE_INPUT, "{1b71bc}Uzimanje Materijala", "{FFFFFF}Unesite kolicinu materijala koju zelite da uzmete", "Ostavi", "Izlaz");
		}
		case 3:
		{
  			if(KucaInfo[i][kOdjeca] == 0)
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate odjelo u ormanu!");

			SetPlayerSkin(playerid, KucaInfo[i][kOdjeca]);
			PI[playerid][Skin] = KucaInfo[i][kOdjeca];

			KucaInfo[i][kOdjeca] = 0;
			
			mysql_tqueryEx(SQL, "UPDATE `houses` SET `Odjeca` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kOdjeca], KucaInfo[i][SQLID]);
			mysql_tqueryEx(SQL, "UPDATE `users` SET `Skin` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Skin], PI[playerid][SQLID]);
			
			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste uzeli odelo iz ormana!");
		}
		case 4:
		{
  			if(KucaInfo[i][kOruzije] == -1)
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas oruzije u kuci!");

			GivePlayerWeapon(playerid, KucaInfo[i][kOruzije], KucaInfo[i][kMunicija]);
			KucaInfo[i][kOruzije] = -1;
			KucaInfo[i][kMunicija] = -1;

			mysql_tqueryEx(SQL, "UPDATE `houses` SET `Oruzije` = '%d', `Municija` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kOruzije], KucaInfo[i][kMunicija], KucaInfo[i][SQLID]);

			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uzeli ste oruzije iz vase kuce!");
		}
	}
	return 1;
}

Dialog:dialog_kumats(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    
    if(PI[playerid][Kuca] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate kucu!");

	new i = PI[playerid][Kuca];

	static iznos;

	if(sscanf(inputtext, "i", iznos))
		return Dialog_Show(playerid, dialog_kumats, DIALOG_STYLE_INPUT, "{1b71bc}Uzimanje Materijala", "{FFFFFF}Unesite kolicinu materijala koju zelite da uzmete", "Ostavi", "Izlaz");

	if(iznos > KucaInfo[i][kMats])
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate toliko materijala u kuci!");

	if(iznos < 1 || iznos > 50000)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Suma ne mozete biti manja od 1 i veca od 50000 odjednom!");

	KucaInfo[i][kMats] -= iznos;
	PI[playerid][Mats] += iznos;
	
	mysql_tqueryEx(SQL, "UPDATE `houses` SET `Mats` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kMats], KucaInfo[i][SQLID]);
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Mats` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Mats], PI[playerid][SQLID]);
	
	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uzeli ste iz kuce %d materijala!", iznos);
	return 1;
}

Dialog:dialog_kudrogu(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    
    if(!response) return 1;

    if(PI[playerid][Kuca] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate kucu!");

	new i = PI[playerid][Kuca];

	static iznos;

	if(sscanf(inputtext, "i", iznos))
		return Dialog_Show(playerid, dialog_kudrogu, DIALOG_STYLE_INPUT, "{1b71bc}Uzimanje Droge", "{FFFFFF}Unesite kolicinu droge koju zelite da uzmete", "Ostavi", "Izlaz");

	if(iznos > KucaInfo[i][kDroga])
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate toliko droge u kuci!");

	if(iznos < 1 || iznos > 50000)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Suma ne mozete biti manja od 1 i veca od 50000 odjednom!");

	KucaInfo[i][kDroga] -= iznos;
	PI[playerid][Droga] += iznos;

	mysql_tqueryEx(SQL, "UPDATE `houses` SET `Droga` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kDroga], KucaInfo[i][SQLID]);
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Droga` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Droga], PI[playerid][SQLID]);

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uzeli ste iz kuce %d droge!", iznos);
	return 1;
}

Dialog:dialog_kunovac(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

    if(!response) return 1;

    if(PI[playerid][Kuca] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate kucu!");

	new i = PI[playerid][Kuca];

	static iznos;

	if(sscanf(inputtext, "i", iznos))
		return Dialog_Show(playerid, dialog_kunovac, DIALOG_STYLE_INPUT, "{1b71bc}Uzimanje Novca", "{FFFFFF}Unesite kolicinu novca koju zelite da uzmete", "Ostavi", "Izlaz");

	if(iznos > KucaInfo[i][kNovac])
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate toliko droge u kuci!");

	if(iznos < 1 || iznos > 50000)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Suma ne mozete biti manja od 1 i veca od 50000 odjednom!");

	KucaInfo[i][kNovac] -= iznos;
	PI[playerid][Novac] += iznos;

	mysql_tqueryEx(SQL, "UPDATE `houses` SET `Novac` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kNovac], KucaInfo[i][SQLID]);
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][SQLID]);

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uzeli ste iz kuce %d droge!", iznos);
	return 1;
}

Dialog:dialog_kostavi(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

    if(PI[playerid][Kuca] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate kucu!");

	new i = PI[playerid][Kuca];

	switch(listitem)
	{
		case 0:
		{
  			Dialog_Show(playerid, dialog_konovac, DIALOG_STYLE_INPUT, "{1b71bc}Ostavljanje Novca", "{FFFFFF}Unesite kolicinu novca koju zelite da ostavite", "Ostavi", "Izlaz");
		}
		case 1:
		{
  			Dialog_Show(playerid, dialog_kodrogu, DIALOG_STYLE_INPUT, "{1b71bc}Ostavljanje Droge", "{FFFFFF}Unesite kolicinu droge koju zelite da ostavite", "Ostavi", "Izlaz");
		}
		case 2:
		{
  			Dialog_Show(playerid, dialog_komats, DIALOG_STYLE_INPUT, "{1b71bc}Ostavljanje Materijala", "{FFFFFF}Unesite kolicinu materijala koju zelite da ostavite", "Ostavi", "Izlaz");
		}
		case 3:
		{
  			if(KucaInfo[i][kOdjeca] != 0)
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vec imas odelo u ormanu!");

			KucaInfo[i][kOdjeca] = GetPlayerSkin(playerid);
			mysql_tqueryEx(SQL, "UPDATE `houses` SET `Odjeca` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kOdjeca], KucaInfo[i][SQLID]);
			
			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste ostavili odecu u ormar!");
		}
		case 4:
		{
  			if(KucaInfo[i][kOruzije] != -1)
  				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas oruzije u kuci!");
  				
            if(GetPlayerWeapon(playerid) <= 0)
				return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemas oruzije u ruci!");

			KucaInfo[i][kOruzije] = GetPlayerWeapon(playerid);
			KucaInfo[i][kMunicija] = GetPlayerAmmo(playerid);
			SetPlayerAmmo(playerid, GetPlayerWeapon(playerid), 0);

            mysql_tqueryEx(SQL, "UPDATE `houses` SET `Oruzije` = '%d', `Municija` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kOruzije], KucaInfo[i][kMunicija], KucaInfo[i][SQLID]);
			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Ostavili ste oruzije u kucu!");
		}
	}
	return 1;
}

Dialog:dialog_komats(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

    if(PI[playerid][Kuca] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate kucu!");

	new i = PI[playerid][Kuca];
	
	static iznos;

	if(sscanf(inputtext, "i", iznos))
		return Dialog_Show(playerid, dialog_komats, DIALOG_STYLE_INPUT, "{1b71bc}Ostavljanje Materijala", "{FFFFFF}Unesite kolicinu materijala koju zelite da ostavite", "Ostavi", "Izlaz");

	if(iznos > PI[playerid][Mats])
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate toliko materijala!");

	if(iznos < 1 || iznos > 50000)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Suma ne mozete biti manja od 1 i veca od 50000 odjednom!");

	KucaInfo[i][kMats] += iznos;
	PI[playerid][Mats] -= iznos;

	mysql_tqueryEx(SQL, "UPDATE `houses` SET `Mats` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kMats], KucaInfo[i][SQLID]);
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Mats` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Mats], PI[playerid][SQLID]);

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Ostavili ste u kucu %d materijala!", iznos);
	return 1;
}

Dialog:dialog_kodrogu(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

    if(PI[playerid][Kuca] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate kucu!");

	new i = PI[playerid][Kuca];

	static iznos;

	if(sscanf(inputtext, "i", iznos))
		return Dialog_Show(playerid, dialog_kodrogu, DIALOG_STYLE_INPUT, "{1b71bc}Ostavljanje Droge", "{FFFFFF}Unesite kolicinu droge koju zelite da ostavite", "Ostavi", "Izlaz");

	if(iznos > PI[playerid][Droga])
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate toliko droge!");

	if(iznos < 1 || iznos > 50000)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Suma ne mozete biti manja od 1 i veca od 50000 odjednom!");

	KucaInfo[i][kDroga] += iznos;
	PI[playerid][Droga] -= iznos;

	mysql_tqueryEx(SQL, "UPDATE `houses` SET `Droga` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kDroga], KucaInfo[i][SQLID]);
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Droga` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Droga], PI[playerid][SQLID]);

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Ostavili ste u kucu %d droge!", iznos);
	return 1;
}

Dialog:dialog_konovac(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

    if(PI[playerid][Kuca] == -1)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate kucu!");

	new i = PI[playerid][Kuca];

	static iznos;

	if(sscanf(inputtext, "i", iznos))
		return Dialog_Show(playerid, dialog_konovac, DIALOG_STYLE_INPUT, "{1b71bc}Ostavljanje Novca", "{FFFFFF}Unesite kolicinu novca koju zelite da ostavite", "Ostavi", "Izlaz");

	if(iznos > PI[playerid][Novac])
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate toliko novca!");

	if(iznos < 1 || iznos > 50000)
		return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Suma ne mozete biti manja od 1 i veca od 50000 odjednom!");

	KucaInfo[i][kNovac] += iznos;
	PI[playerid][Novac] -= iznos;

	mysql_tqueryEx(SQL, "UPDATE `houses` SET `Novac` = '%d' WHERE `SQLID` = '%d'", KucaInfo[i][kNovac], KucaInfo[i][SQLID]);
	mysql_tqueryEx(SQL, "UPDATE `users` SET `Novac` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Novac], PI[playerid][SQLID]);

	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Ostavili ste u kucu %d$!", iznos);
	return 1;
}

Dialog:dialog_pspawn(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;

	switch(listitem)
	{
		case 0:
		{
			PI[playerid][Spawn] = SPAWN_NORMAL;
			mysql_tqueryEx(SQL, "UPDATE `users` SET `Spawn` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Spawn], PI[playerid][SQLID]);
   			va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste odabrali spawn | Market Stanica!");
		}
		case 1:
		{
  			if(PI[playerid][Kuca] != -1)
	    	{
      			PI[playerid][Spawn] = SPAWN_KUCA;
      			mysql_tqueryEx(SQL, "UPDATE `users` SET `Spawn` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Spawn], PI[playerid][SQLID]);
	        	va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste odabrali spawn | Kuca!");
			}
			else return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Ne posedujete kucu!");
		}
		case 2:
		{
  			if(PI[playerid][Rent] != -1)
	    	{
      			PI[playerid][Spawn] = SPAWN_RENTKUCA;
      			mysql_tqueryEx(SQL, "UPDATE `users` SET `Spawn` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Spawn], PI[playerid][SQLID]);
         		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste odabrali spawn | Rent Kuca!");
			}
			else return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate rentanu kucu!");
		}
		case 3:
		{
  			if(PI[playerid][Stan] != -1)
	    	{
      			PI[playerid][Spawn] = SPAWN_STAN;
      			mysql_tqueryEx(SQL, "UPDATE `users` SET `Spawn` = '%d' WHERE `SQLID` = '%d'", PI[playerid][Spawn], PI[playerid][SQLID]);
         		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Uspesno ste odabrali spawn | Stan!");
			}
			else return va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Nemate stan!");
		}
	}
	return 1;
}
// - > Forwards & Publics
forward SQL_PlayerCheck(const playerid);
public SQL_PlayerCheck(const playerid)
{
	static rows;
	cache_get_row_count(rows);
	if(rows)
	{
	    cache_get_value_name_int(0, "SQLID", PI[playerid][SQLID]);
	    cache_get_value_name(0, "Password", PI[playerid][Password], 128);
	    cache_get_value_name(0, "Email", PI[playerid][Email], 50);
		cache_get_value_name_int(0, "Skin", PI[playerid][Skin]);
		cache_get_value_name_int(0, "Admin", PI[playerid][Admin]);
		cache_get_value_name_int(0, "Level", PI[playerid][Level]);
		cache_get_value_name_int(0, "Respekti", PI[playerid][Respekti]);
		cache_get_value_name_int(0, "SatiIgre", PI[playerid][SatiIgre]);
        cache_get_value_name_int(0, "Novac", PI[playerid][Novac]);
        cache_get_value_name_int(0, "Pol", PI[playerid][Pol]);
        cache_get_value_name_int(0, "Drzava", PI[playerid][Drzava]);
        cache_get_value_name_int(0, "Godine", PI[playerid][Godine]);
        cache_get_value_name_int(0, "NovacBanka", PI[playerid][NovacBanka]);
        cache_get_value_name_int(0, "Zlato", PI[playerid][Zlato]);
        cache_get_value_name_int(0, "Banovan", PI[playerid][Banovan]);
        cache_get_value_name(0, "BRazlog", PI[playerid][BRazlog], 40);
        cache_get_value_name_int(0, "Kartica", PI[playerid][Kartica]);
        cache_get_value_name_int(0, "KarticaPin", PI[playerid][KarticaPin]);
        cache_get_value_name_int(0, "Warn", PI[playerid][Warn]);
        cache_get_value_name_int(0, "ADozvola", PI[playerid][ADozvola]);
		cache_get_value_name_int(0, "KamionDozvola", PI[playerid][KamionDozvola]);
		cache_get_value_name_int(0, "MotorDozvola", PI[playerid][MotorDozvola]);
		cache_get_value_name_int(0, "AvionDozvola", PI[playerid][AvionDozvola]);
		cache_get_value_name_int(0, "BrodDozvola", PI[playerid][BrodDozvola]);
		cache_get_value_name_int(0, "Kuca", PI[playerid][Kuca]);
		cache_get_value_name_int(0, "RentKuca", PI[playerid][Rent]);
		cache_get_value_name_int(0, "Spawn", PI[playerid][Spawn]);
		cache_get_value_name_int(0, "Droga", PI[playerid][Droga]);
		cache_get_value_name_int(0, "Mats", PI[playerid][Mats]);
		cache_get_value_name_int(0, "Hrana", PI[playerid][Hrana]);
		cache_get_value_name_int(0, "Stan", PI[playerid][Stan]);
		cache_get_value_name_int(0, "IznosKredita", PI[playerid][IznosKredita]);
		cache_get_value_name_int(0, "IznosRate", PI[playerid][IznosRate]);
		cache_get_value_name_int(0, "PreostaloZaOtplatu", PI[playerid][PreostaloZaOtplatu]);
		cache_get_value_name_int(0, "Vip", PI[playerid][Vip]);
		cache_get_value_name_int(0, "Mutiran", PI[playerid][Mutiran]);

		if(PI[playerid][Banovan] == 1)
		{
		    Dialog_Show(playerid, dialog_none, DIALOG_STYLE_MSGBOX, "{1b71bc}Banovan Status", "{1b71bc}%s, {FFFFFF}vi ste banovani sa {1b71bc}Vibe Roleplay {FFFFFF}servera.\n\
																				 {FFFFFF}Razlog bana: %s\n\
																				 {FFFFFF}Ukoliko mislite da je greska prijavite na forumu {1b71bc}(www.vibe-ogc.samp.info).", "OK", "",
																				 ReturnPlayerName(playerid), PI[playerid][BRazlog]);
			Kick(playerid);
		}
		else
		{
		    ClearChat(playerid, 16);
		    PlayerTextDrawShow(playerid, LoginTD[playerid][0]);
			PlayerTextDrawShow(playerid, LoginTD[playerid][1]);
			PlayerTextDrawShow(playerid, LoginTD[playerid][2]);
			PlayerTextDrawShow(playerid, LoginTD[playerid][3]);
			PlayerTextDrawShow(playerid, LoginTD[playerid][4]);
		    InterpolateCameraPos(playerid,2299.325439,-2159.766113,42.211368,2584.985839,-2327.650146,46.299079,15000);
    		InterpolateCameraLookAt(playerid,2304.060546,-2161.342529,41.906867,2580.122314,-2326.588378,45.831016,15000);
    		PlayAudioStreamForPlayer(playerid, "http://www.coolradio.rs/download/playlist.pls");
			Dialog_Show(playerid, dialog_login, DIALOG_STYLE_PASSWORD, "{1b71bc}Login", "\n{FFFFFF}Dobrodosli nazad {1b71bc}%s, {FFFFFF}na {1b71bc}Vibe Roleplay\n\
																					 {FFFFFF}Vas korisnicki racun {3acc51}je registrovan {FFFFFF}u bazi podataka.\n\
																					 {FFFFFF}Ukoliko pogresite lozinku {FF0000}4 puta {FFFFFF}bicete kickovani.\n\
																					 {FFFFFF}Imate {FF0000}30 {FFFFFF}sekundi da se ulogujete na nas server.\n\n\
																					 {FFFFFF}Ugodnu igru zeli vam {1b71bc}Vibe Roleplay Staff Tim", "Login", "Izlaz", ReturnPlayerName(playerid));

			LoginTimer[playerid] = SetTimerEx("KickLogin", 30000, false, "d", playerid);
		}
	}
	else
	{
	    switch(RolePlayIme(playerid, _, _, false))
		{
		    case 1: Register(playerid);
			case 2: { va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vase ime nema niti jednu povlaku!"); Ulogovan[playerid] = 0; Kick(playerid); return 1; }
			case 3: { va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vase ime ne smije imati vise od 1 povlake!"); Ulogovan[playerid] = 0; Kick(playerid); return 1; }
			case 4: { va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vase ime ne smije imati zabranjene znakove!"); Ulogovan[playerid] = 0; Kick(playerid); return 1; }
			case 5: { va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Prvo slovo imena ili prezimena nije veliko slovo!"); Ulogovan[playerid] = 0; Kick(playerid); return 1; }
			case 6: { va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Slova poslije prvog slova imena i prezimena moraju biti mala!"); Ulogovan[playerid] = 0; Kick(playerid); return 1; }
			case 7: { va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Povlaka ne smije biti prvo slovo vašeg imena! Koristi povlaku za odvajanje Imena od Prezimena!"); Ulogovan[playerid] = 0; Kick(playerid); return 1; }
			case 8: { va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vase ime ima manje od 2 slova!"); Ulogovan[playerid] = 0; Kick(playerid); return 1; }
			case 9: { va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Vase prezime ima manje od 3 slova!"); Kick(playerid); return 1; }
		}
	}
	return 1;
}

forward PlayerRegistered(const playerid);
public PlayerRegistered(const playerid)
{
	PI[playerid][SQLID] = cache_insert_id();
	SetPlayerSkin(playerid, PI[playerid][Skin]);
	ClearChat(playerid, 30);
	PI[playerid][Level] = 1;
	SetPlayerScore(playerid, PI[playerid][Level]);
	PI[playerid][Novac] = 5000;
 	GivePlayerMoney(playerid, PI[playerid][Novac]);
	Ulogovan[playerid] = 1;
	TogglePlayerSpectating(playerid, false);
	TogglePlayerControllable(playerid, true);
	TextDrawShowForPlayer(playerid, InGameTD[0]);
    TextDrawShowForPlayer(playerid, InGameTD[1]);
    TextDrawShowForPlayer(playerid, InGameTD[2]);
    TextDrawShowForPlayer(playerid, InGameTD[3]);
    TextDrawShowForPlayer(playerid, InGameTD[4]);
    TextDrawShowForPlayer(playerid, InGameTD[5]);
	PlayerTextDrawShow(playerid, BankaTD[playerid]);
	PlayerTextDrawShow(playerid, ZlatoTD[playerid]);
	UpdateBanka(playerid);
	UpdateZlato(playerid);
	va_SendClientMessage(playerid, 0x1b71bcFF, "VIBE: {FFFFFF}Dobrodosli %s u Los Santos", ReturnPlayerName(playerid));
	SendClientMessage(playerid, 0x1b71bcFF, "> {FFFFFF}Ukoliko nemate prevoz iznajmite rent ili pozovite taksi /call 444.");
	SendClientMessage(playerid, 0x1b71bcFF, "> {FFFFFF}Ukoliko vam je potrebna pomoc obratite se Staff Timu /askq ili report.");
	new str[256];
	format(str, sizeof(str), "{1b71bc}#Novi Igrac: {FFFFFF}Igrac %s (ID: %d), se upravo registrovao na server.", ReturnPlayerName(playerid), playerid);
	AdminMessage(-1, str);
	SpawnIgraca(playerid);
	SpawnPlayer(playerid);
	SavePlayer(playerid);
	return 1;
}

forward CheckPlayerUnBan(playerid, const imeigraca[]);
public CheckPlayerUnBan(playerid, const imeigraca[])
{
    new rows;
    cache_get_row_count(rows);
	if(!rows)
	{
        va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Taj igrac nije banovan!");
    }
    else
	{
	    new user_id;
		cache_get_value_name_int(0, "SQLID", user_id);

		new q[100];
		mysql_format(SQL, q, sizeof(q), "UPDATE `users` SET `Banovan` = '0', `BRazlog` = 'Prazno' WHERE `SQLID` = '%d'", user_id);
		mysql_tquery(SQL, q);

		new str[200];
		format(str, sizeof(str), "{ddd74e}[AdminInfo]: {FFFFFF}Admin %s je unbanovao igraca %s", ReturnPlayerName(playerid), imeigraca);
		AdminMessage(-1, str);
		
		va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Unbanovali ste igraca %s.", imeigraca);
    }
	return 1;
}

forward CheckPlayerDelete(playerid, const acc[]);
public CheckPlayerDelete(playerid, const acc[])
{
    new rows;
    cache_get_row_count(rows);
	if(!rows)
	{
        va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Taj igrac ne postoji u bazi podataka!");
    }
    else
	{
	    va_SendClientMessage(playerid, 0x1b71bcFF, "#Info: {FFFFFF}Obrisali ste nalog igracu %s.", acc);
	    new str[200];
		format(str, sizeof(str), "{ddd74e}[AdminInfo]: {FFFFFF}Admin %s je obrisao nalog igracu %s", ReturnPlayerName(playerid), acc);
		AdminMessage(-1, str);
    }
    return 1;
}

forward ZalediOdledi(playerid);
public ZalediOdledi(playerid)
{
    if(Ulogovan[playerid] == 0) return KillTimer(PlayerTimer[playerid]);
   	KillTimer(PlayerTimer[playerid]);
   	TogglePlayerControllable(playerid, 1);
    return 1;
}

forward PayDay(i);
public PayDay(i)
{
	if(!IsPlayerConnected(i) || Ulogovan[i] == 0) return 1;
	new iskustvo = 0, iznosplate = 0, osnova = 0, struja = 0, voda = 0, smece = 0, grijanje = 0, porez = 0, kucanajam = 0, prihod = 0, rashod = 0;
	new starirespekt = PI[i][Respekti];
	new stariiznos = PI[i][NovacBanka];
	if(PI[i][PreostaloZaOtplatu] < PI[i][IznosRate])
    {
        PI[i][IznosRate] = PI[i][PreostaloZaOtplatu];
	}
    PI[i][PreostaloZaOtplatu] -= PI[i][IznosRate];
    PI[i][NovacBanka] -= PI[i][IznosRate];
    
    if(PI[i][PreostaloZaOtplatu] < 0) PI[i][PreostaloZaOtplatu] = 0;
    if(PI[i][PreostaloZaOtplatu] <= 0) { PI[i][IznosKredita] = 0; PI[i][IznosRate] = 0; }
	if(PI[i][Rent] != -1)
	{
		if(PI[i][NovacBanka] < KucaInfo[PI[i][Rent]][kCenaRenta])
		{
			PI[i][Rent] = -1;
			PI[i][Spawn] = SPAWN_NORMAL;
			va_SendClientMessage(i, 0x1b71bcFF, "#Info: {FFFFFF}Niste imali da platiti kiriju za kucu, iseljeni ste!");
		}
		PI[i][NovacBanka] -= KucaInfo[PI[i][Rent]][kCenaRenta];
	}
	if(PI[i][Rent] == -1) kucanajam = 0;
	else if(PI[i][Rent] != -1) kucanajam = KucaInfo[PI[i][Rent]][kCenaRenta];
    PI[i][Respekti]++;
	PI[i][SatiIgre]++;
	iskustvo = (PI[i][Level] * 2) + 2;
	if(PI[i][Kuca] != -1) { struja += (10 + random(15)); voda += (10 + random(5)); porez += 10; smece += 8; grijanje += 5; }
	if(PI[i][Stan] != -1) { struja += (3 + random(5)); voda += (5 + random(8)); porez += 10; smece += 4; grijanje += 3; }
	osnova = 100 + random(150);
	iznosplate = osnova*PI[i][Level];
    if(PI[i][Respekti] < iskustvo)
    {
		Dialog_Show(i, dialog_none, DIALOG_STYLE_MSGBOX, "{1b71bc}Plata", "{FFFFFF}Plata stigla na vas bankovni racun\n{FFFFFF}Plata: {1b71bc}%d$\n\n\
																	              {FFFFFF}Kredit Informacije\n{FFFFFF}Iznos Kredita: {1b71bc}%d$\n{FFFFFF}Iznos Rate: {1b71bc}%d$\n\
																				  {FFFFFF}Preostalo za otplatu: {1b71bc}%d$\n\n\
  																				  {FFFFFF}Platili ste\n{FFFFFF}Porez: {1b71bc}%d$\n{FFFFFF}Struja: {1b71bc}%d$\n{FFFFFF}Voda: {1b71bc}%d$\n\
																				  {FFFFFF}Smece: {1b71bc}%d$\n{FFFFFF}Grijanje: {1b71bc}%d$\n{FFFFFF}Iznajmljena kuca: {1b71bc}%d$\n\n\
																				  {FFFFFF}Stari respekti: {1b71bc}%d\n{FFFFFF}Novi respekti: {1b71bc}%d\n\n\
																				  {FFFFFF}Stari iznos: {1b71bc}%d$\n{FFFFFF}Novi iznos: {1b71bc}%d$", "OK", "",
																				  iznosplate, PI[i][IznosKredita], PI[i][IznosRate], PI[i][PreostaloZaOtplatu], porez, struja, voda, smece, grijanje, kucanajam,
																				  starirespekt, PI[i][Respekti], stariiznos, PI[i][NovacBanka]+iznosplate);
	}
	else if(PI[i][Respekti] >= iskustvo)
	{
	    PI[i][Level]++;
	    SetPlayerScore(i, PI[i][Level]);
	    PI[i][Respekti] = 0;
	    Dialog_Show(i, dialog_none, DIALOG_STYLE_MSGBOX, "{1b71bc}Plata", "{FFFFFF}Plata stigla na vas bankovni racun\n{FFFFFF}Plata: {1b71bc}%d$\n\n\
																	              {FFFFFF}Kredit Informacije\n{FFFFFF}Iznos Kredita: {1b71bc}%d$\n{FFFFFF}Iznos Rate: {1b71bc}%d$\n\
																				  {FFFFFF}Preostalo za otplatu: {1b71bc}%d$\n\n\
  																				  {FFFFFF}Platili ste\n{FFFFFF}Porez: {1b71bc}%d$\n{FFFFFF}Struja: {1b71bc}%d$\n{FFFFFF}Voda: {1b71bc}%d$\n\
																				  {FFFFFF}Smece: {1b71bc}%d$\n{FFFFFF}Grijanje: {1b71bc}%d$\n{FFFFFF}Iznajmljena kuca: {1b71bc}%d$\n\n\
																				  {FFFFFF}Stari respekti: {1b71bc}%d\n{FFFFFF}Novi respekti: {1b71bc}%d\n\n\
																				  {FFFFFF}Stari iznos: {1b71bc}%d$\n{FFFFFF}Novi iznos: {1b71bc}%d$\n\n\
																				  {FFFFFF}Cestitamo presli ste na sledeci nivo - {FF0000}LEVEL UP", "OK", "",
																				  iznosplate, PI[i][IznosKredita], PI[i][IznosRate], PI[i][PreostaloZaOtplatu], porez, struja, voda, smece, grijanje, kucanajam,
																				  starirespekt, PI[i][Respekti], stariiznos, PI[i][NovacBanka]+iznosplate);
	}
	prihod = iznosplate;
	rashod = struja + voda + porez + smece + grijanje;
	PI[i][NovacBanka] += prihod;
	PI[i][NovacBanka] -= rashod;
	UpdateBanka(i);
	DobioPay[i] = 1;
	SavePlayer(i);
	return 1;
}

forward AdminMessage(color, const string[]);
public AdminMessage(color, const string[])
{
	foreach(new i: Player)
	{
		if(PI[i][Admin] >= 1)
		{
			SendClientMessage(i, color, string);
		}
	}
}

forward AVipPMessage(color, const string[]);
public AVipPMessage(color, const string[])
{
    foreach(new i: Player)
	{
		if(PI[i][Admin] >= 1 || PI[i][Vip] >= 1)
		{
			SendClientMessage(i, color, string);
		}
	}
}

forward KickLogin(playerid);
public KickLogin(playerid)
{
	va_SendClientMessage(playerid, 0xFF0000FF, "#Kick: {FFFFFF}Kikovani ste jer niste upisali lozinku za 30 sekundi!");
	KillTimer(LoginTimer[playerid]);
	PlayerTimer[playerid] = SetTimerEx("KonektKick", 1000, false, "d", playerid);
	return 1;
}

forward KonektKick(playerid);
public KonektKick(playerid)
{
	Kick(playerid);
	return 1;
}

forward KonektBan(playerid);
public KonektBan(playerid)
{
	Ban(playerid);
	return 1;
}

forward CheckPlayerRename(playerid, id, novoime[]);
public CheckPlayerRename(playerid, id, novoime[])
{
    new rows;
    cache_get_row_count(rows);
	if(rows)
	{
	    va_SendClientMessage(playerid, 0xFF0000FF, "#Greska: {FFFFFF}Novo ime vec postoji u bazi podataka!");
    }
    else
	{
		RenamePlayer(id, novoime);
		va_SendClientMessage(id, 0x1b71bcFF, "#Info: {FFFFFF}Admin %s vam je promenio ime u %s.", ReturnPlayerName(playerid), novoime);

		new playername[MAX_PLAYER_NAME];
        GetPlayerName(id, playername, sizeof(playername));

		new str[128];
		format(str, sizeof(str), "{ddd74e}[AdminInfo]: {FFFFFF}Admin %s je promenio ime igracu %s u %s", ReturnPlayerName(playerid), playername, novoime);
		AdminMessage(-1, str);
    }
    return 1;
}

forward GorivoFriz(playerid);
public GorivoFriz(playerid)
{
	TogglePlayerControllable(playerid, 1);
	GameTextForPlayer(playerid, "~g~Gorivo napunjeno", 5000, 3);
	PuniGorivo[playerid] = false;
	new string[50];
	format(string, sizeof(string), "%d", Fuel[GetPlayerVehicleID(playerid)]);
	PlayerTextDrawSetString(playerid, BrzinaTD[playerid][18], string);
	return 1;
}

// - > Stocks
SavePlayer(playerid)
{
	static buffer[200];
	mysql_format(SQL, buffer, sizeof(buffer), "UPDATE `users` SET `Email` = '%e', `Skin` = '%d', `Admin` = '%d', `Level` = '%d', `Respekti` = '%d', `SatiIgre` = '%d', `Novac` = '%d' WHERE `SQLID` = '%d'",
	    PI[playerid][Email],
	    PI[playerid][Skin],
	    PI[playerid][Admin],
	    PI[playerid][Level],
	    PI[playerid][Respekti],
		PI[playerid][SatiIgre],
		PI[playerid][Novac],
		PI[playerid][SQLID]);
	mysql_tquery(SQL, buffer);

	mysql_format(SQL, buffer, sizeof(buffer), "UPDATE `users` SET `Pol` = '%d', `Drzava` = '%d', `Godine` = '%d', `NovacBanka` = '%d', `Zlato` = '%d', `Banovan` = '%d', `BRazlog` = '%e' WHERE `SQLID` = '%d'",
	    PI[playerid][Pol],
	    PI[playerid][Drzava],
	    PI[playerid][Godine],
	    PI[playerid][NovacBanka],
	    PI[playerid][Zlato],
	    PI[playerid][Banovan],
	    PI[playerid][BRazlog],
	    PI[playerid][SQLID]);
    mysql_tquery(SQL, buffer);
    
    mysql_format(SQL, buffer, sizeof(buffer), "UPDATE `users` SET `Kartica` = '%d', `KarticaPin` = '%d', `Warn` = '%d', `ADozvola` = '%d', `KamionDozvola` = '%d', `MotorDozvola` = '%d'  WHERE `SQLID` = '%d'",
	    PI[playerid][Kartica],
	    PI[playerid][KarticaPin],
	    PI[playerid][Warn],
	    PI[playerid][ADozvola],
	    PI[playerid][KamionDozvola],
	    PI[playerid][MotorDozvola],
	    PI[playerid][SQLID]);
    mysql_tquery(SQL, buffer);
    
    mysql_format(SQL, buffer, sizeof(buffer), "UPDATE `users` SET `AvionDozvola` = '%d', `BrodDozvola` = '%d', `Kuca` = '%d', `RentKuca` = '%d', `Spawn` = '%d' WHERE `SQLID` = '%d'",
	    PI[playerid][AvionDozvola],
	    PI[playerid][BrodDozvola],
	    PI[playerid][Kuca],
	    PI[playerid][Rent],
	    PI[playerid][Spawn],
	    PI[playerid][SQLID]);
    mysql_tquery(SQL, buffer);
    
    mysql_format(SQL, buffer, sizeof(buffer), "UPDATE `users` SET `Droga` = '%d', `Mats` = '%d', `Hrana` = '%d', `Stan` = '%d', `IznosKredita` = '%d', `IznosRate` = '%d' WHERE `SQLID` = '%d'",
	    PI[playerid][Droga],
	    PI[playerid][Mats],
	    PI[playerid][Hrana],
	    PI[playerid][Stan],
	    PI[playerid][IznosKredita],
	    PI[playerid][IznosRate],
	    PI[playerid][SQLID]);
    mysql_tquery(SQL, buffer);
    
    mysql_format(SQL, buffer, sizeof(buffer), "UPDATE `users` SET `PreostaloZaOtplatu` = '%d', `Vip` = '%d', `Mutiran` = '%d' WHERE `SQLID` = '%d'",
	    PI[playerid][PreostaloZaOtplatu],
	    PI[playerid][Vip],
	    PI[playerid][Mutiran],
	    PI[playerid][SQLID]);
    mysql_tquery(SQL, buffer);
    return 1;
}

InsertAcc(playerid)
{
    new q[256];
	mysql_format(SQL, q, sizeof(q),
		"INSERT INTO `users` (Ime, Password, Email, Skin, Level, Novac, Pol, Drzava, Godine, NovacBanka, Zlato) \
		VALUES('%e', '%e', '%e', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d')",

				ReturnPlayerName(playerid), PI[playerid][Password], PI[playerid][Email], PI[playerid][Skin], PI[playerid][Level],
		        PI[playerid][Novac], PI[playerid][Pol], PI[playerid][Drzava], PI[playerid][Godine],
		        PI[playerid][NovacBanka], PI[playerid][Zlato]);

	mysql_tquery(SQL, q, "PlayerRegistered", "i", playerid);
	return 1;
}

SpawnIgraca(playerid)
{
	if(PI[playerid][Spawn] == SPAWN_KUCA)
	{
	    if(PI[playerid][Kuca] != -1)
	    {
	        new i = PI[playerid][Kuca];
	    	SetPlayerInterior(playerid, KucaInfo[i][kInt]); SetPlayerVirtualWorld(playerid, KucaInfo[i][kVW]);
			SetSpawnInfo(playerid, NO_TEAM, PI[playerid][Skin], KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ], 180.0, 0, 0, 0, 0, 0, 0);
		}
		else
		{
	        PI[playerid][Spawn] = SPAWN_NORMAL;
			new rand = random(sizeof(RandomSpawn2));
			SetSpawnInfo(playerid, NO_TEAM, PI[playerid][Skin], RandomSpawn2[rand][0], RandomSpawn2[rand][1], RandomSpawn2[rand][2], RandomSpawn2[rand][3], 0, 0, 0, 0, 0, 0);
			SetPlayerInterior(playerid, 0);
		}
	}
	else if(PI[playerid][Spawn] == SPAWN_RENTKUCA)
	{
	    if(PI[playerid][Rent] != -1)
	    {
	        new i = PI[playerid][Rent];
	        SetPlayerInterior(playerid, KucaInfo[i][kInt]); SetPlayerVirtualWorld(playerid, KucaInfo[i][kVW]);
			SetSpawnInfo(playerid, NO_TEAM, PI[playerid][Skin], KucaInfo[i][kIzlazX], KucaInfo[i][kIzlazY], KucaInfo[i][kIzlazZ], 180.0, 0, 0, 0, 0, 0, 0);
		}
		else
		{
	        PI[playerid][Spawn] = SPAWN_NORMAL;
			new rand = random(sizeof(RandomSpawn2));
			SetSpawnInfo(playerid, NO_TEAM, PI[playerid][Skin], RandomSpawn2[rand][0], RandomSpawn2[rand][1], RandomSpawn2[rand][2], RandomSpawn2[rand][3], 0, 0, 0, 0, 0, 0);
			SetPlayerInterior(playerid, 0);
		}
	}
	else if(PI[playerid][Spawn] == SPAWN_STAN)
	{
	    if(PI[playerid][Stan] != -1)
	    {
	        new i = PI[playerid][Stan];
	    	SetPlayerInterior(playerid, StanInfo[i][sInt]); SetPlayerVirtualWorld(playerid, StanInfo[i][sVW]);
	    	SetSpawnInfo(playerid, NO_TEAM, PI[playerid][Skin], StanInfo[i][sIzlazX], StanInfo[i][sIzlazY], StanInfo[i][sIzlazZ], 180.0, 0, 0, 0, 0, 0, 0);
		}
		else
		{
	        PI[playerid][Spawn] = SPAWN_NORMAL;
			new rand = random(sizeof(RandomSpawn2));
			SetSpawnInfo(playerid, NO_TEAM, PI[playerid][Skin], RandomSpawn2[rand][0], RandomSpawn2[rand][1], RandomSpawn2[rand][2], RandomSpawn2[rand][3], 0, 0, 0, 0, 0, 0);
			SetPlayerInterior(playerid, 0);
		}
	}
	else
	{
	    new rand = random(sizeof(RandomSpawn2));
		SetSpawnInfo(playerid, NO_TEAM, PI[playerid][Skin], RandomSpawn2[rand][0], RandomSpawn2[rand][1], RandomSpawn2[rand][2], RandomSpawn2[rand][3], 0, 0, 0, 0, 0, 0);
	}
	return 1;
}

Register(playerid)
{
    ClearChat(playerid, 16);
    InterpolateCameraPos(playerid,382.858856,-2267.440185,-7.373182,380.098632,-2015.352783,61.335002,15000);
	InterpolateCameraLookAt(playerid,382.723236,-2262.481933,-8.004306,379.970703,-2018.090576,57.153160,15000);
    Dialog_Show(playerid, dialog_register, DIALOG_STYLE_PASSWORD, "{1b71bc}Registracija", "{FFFFFF}Dobrodosli {1b71bc}%s, {FFFFFF}na {1b71bc}Vibe Roleplay\n\
																			 {FFFFFF}Vas korisnicki racun {FF0000}nije registrovan {FFFFFF}u bazi podataka.\n\
																			 {FFFFFF}Molimo vas unesite vasu zeljenu lozinku kako bi pristupili nasem serveru.\n\
																			 {FFFFFF}Lozinka mora sadrzati minimum {F0FFFF}6 {FFFFFF}maksimum {F0FFFF}26 {FFFFFF}karaktera.\n\
																			 {FFFFFF}Vasa lozinka moze sadrzati kombinaciju slova i brojeva {FF0000}(RAZMAK ZABRANJEN).", "Registracija", "Izlaz", ReturnPlayerName(playerid));
	return 1;
}
PlayerLogged(playerid)
{
    GivePlayerMoney(playerid, PI[playerid][Novac]);
	TogglePlayerControllable(playerid, 1);
	ClearChat(playerid, 30);
	Ulogovan[playerid] = 1;
	SetPlayerScore(playerid, PI[playerid][Level]);
	KillTimer(LoginTimer[playerid]);
	PlayerTextDrawDestroy(playerid, LoginTD[playerid][0]);
	PlayerTextDrawDestroy(playerid, LoginTD[playerid][1]);
	PlayerTextDrawDestroy(playerid, LoginTD[playerid][2]);
	PlayerTextDrawDestroy(playerid, LoginTD[playerid][3]);
	PlayerTextDrawDestroy(playerid, LoginTD[playerid][4]);
	StopAudioStreamForPlayer(playerid);
	TextDrawShowForPlayer(playerid, InGameTD[0]);
    TextDrawShowForPlayer(playerid, InGameTD[1]);
    TextDrawShowForPlayer(playerid, InGameTD[2]);
    TextDrawShowForPlayer(playerid, InGameTD[3]);
    TextDrawShowForPlayer(playerid, InGameTD[4]);
    TextDrawShowForPlayer(playerid, InGameTD[5]);
	PlayerTextDrawShow(playerid, BankaTD[playerid]);
	PlayerTextDrawShow(playerid, ZlatoTD[playerid]);
	UpdateBanka(playerid);
	UpdateZlato(playerid);
	TogglePlayerSpectating(playerid, false);
	TogglePlayerControllable(playerid, true);
	new iskustvo;
	iskustvo = (PI[playerid][Level] * 2) + 2;
	va_SendClientMessage(playerid, -1, "Dobrodosao nazad {1b71bc}%s {FFFFFF}na {1b71bc}Vibe Roleplay.", ReturnPlayerName(playerid));
	va_SendClientMessage(playerid, 0x1b71bcFF, "[INFORMACIJE]: {FFFFFF}Level : %d | Respekti: %d/%d | Sati Igre : %d", PI[playerid][Level], PI[playerid][Respekti], iskustvo, PI[playerid][SatiIgre]);
	SpawnIgraca(playerid); SpawnPlayer(playerid);
	return 1;
}

CheckPassword(const password[])
{
    for(new i = 0; password[i] != EOS; ++i)
    {
        switch(password[i])
        {
            case '0'..'9', 'A'..'Z', 'a'..'z': continue;
            default: return 0;
        }
    }
    return 1;
}

CheckMail(const email[])
{
    for(new i = 0; email[i] != EOS; ++i)
    {
        switch(email[i])
        {
            case '0'..'9', 'A'..'Z', 'a'..'z', '@', '.', '_': continue;
            default: return 0;
        }
    }
    return 1;
}

CheckCountry(cout)
{
    new string[25];
    switch(cout)
    {
        case 8: string = "Ostalo";
		case 7: string = "Albanija";
		case 6: string = "Crna Gora";
        case 5: string = "Bosna i Hercegovina";
        case 4: string = "Slovenija";
        case 3: string = "Hrvatska";
    	case 2: string = "Srbija";
        case 1: string = "Makedonija";
        case 0: string = "Nema";
        default: string = "Nema";
    }
    return string;
}

RGB(red, green, blue)
{
    return ((red & 0xFF) << 16) | ((green & 0xFF) << 8) | (blue & 0xFF);
}

ProxMessage(playerid, const message[], Float: range = 10.0)
{
    new Float:playerpos[3], Float:otherpos[3], Float:distance, Float:alpha, color;
    GetPlayerPos(playerid, playerpos[0], playerpos[1], playerpos[2]);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;

        GetPlayerPos(i, otherpos[0], otherpos[1], otherpos[2]);
        distance = VectorSize(playerpos[0] - otherpos[0], playerpos[1] - otherpos[1], playerpos[2] - otherpos[2]);

        if (distance <= range)
        {
            alpha = (1.0 - (distance / range) < 0.5) ? 0.5 : 1.0 - (distance / range);
			color = RGB(floatround((1.0 - (distance / range))) * 205 + 50, floatround((1.0 - (distance / range))) * 205 + 50, floatround((1.0 - (distance / range))) * 205 + 50);
			color |= (floatround(alpha * 255) << 24);
            SendClientMessage(i, color, message);
        }
    }
    return 1;
}

Map_CreateObject(object, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, world = 0, interior = 0, playerid = 0, Float:viewdist = 600.00)
{
    if(world == 0) world = -1;
    if(interior == 0) interior = -1;
    if(playerid == 0) playerid = -1;
    return CreateObject(object, x, y, z, rx, ry, rz, viewdist);
}

Map_CreateDynamicObject(object, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, world = 0, interior = 15, playerid = 0, Float:viewdist = 600.00, Float:drdist = 600.00)
{
    if(world == 0) world = -1;
    if(interior == 0) interior = -1;
    if(playerid == 0) playerid = -1;
    return CreateDynamicObjectEx(object, x, y, z, rx, ry, rz, viewdist, drdist);
}

Load3DLabels()
{
    CreateDynamic3DTextLabel("{FF0000}[ {FFFFFF}BANKA {FF0000}]\n{FFFFFF}Radno vreme: {FF0000}09:00 do 01:00h\n{FFFFFF}Za ulaz koristite tipku {FF0000}[F]", -1, 1461.8052,-1022.9484,23.8331, 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
    CreateDynamic3DTextLabel("{FFFFFF}[ {FF0000}H {FFFFFF}] Banka", -1, 2933.3809,-1787.2136,1191.0873, 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
    CreateDynamic3DTextLabel("{FF0000}[ {FFFFFF}ZLATARA {FF0000}]\n{FFFFFF}Radno vreme: {FF0000}09:00 do 01:00h\n{FFFFFF}Za ulaz koristite tipku {FF0000}[F]", -1, 2022.3917,-1297.5770,23.9948, 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
    CreateDynamic3DTextLabel("{FFFFFF}[ {FF0000}H {FFFFFF}] Zlatara", -1, 1026.3081, 2312.2776, -19.7883, 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
    CreateDynamic3DTextLabel("{FF0000}[ {FFFFFF}AUTO SKOLA {FF0000}]\n{FFFFFF}Za ulaz koristite tipku {FF0000}[F]", -1, 1992.1652,-1775.3353,13.7579, 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
    CreateDynamic3DTextLabel("{FFFFFF}[ {FF0000}H {FFFFFF}] Dozvole", -1, 1376.9954,1461.3077,-7.7367, 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
    CreateDynamic3DTextLabel("{FF0000}[ P U M P A ]\n{FFFFFF}Da naspete gorivo kucajte\n{FF0000}/gorivo", -1, 1004.0422,-937.5357,42.3281, 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 25.0);
    CreateDynamic3DTextLabel("{FF0000}[ P U M P A ]\n{FFFFFF}Da naspete gorivo kucajte\n{FF0000}/gorivo", -1, 171.6999,-1923.0776,4.4559, 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 25.0);
    CreateDynamic3DTextLabel("{FF0000}[ P U M P A ]\n{FFFFFF}Da naspete gorivo kucajte\n{FF0000}/gorivo", -1, -91.2488,-1169.7260,2.4204, 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 25.0);
    CreateDynamic3DTextLabel("{FF0000}[ P U M P A ]\n{FFFFFF}Da naspete gorivo kucajte\n{FF0000}/gorivo", -1, 1942.3732,-1772.7740,13.6406, 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 25.0);
    CreateDynamic3DTextLabel("{FF0000}[ P U M P A ]\n{FFFFFF}Da naspete gorivo kucajte\n{FF0000}/gorivo", -1, 1382.2139,460.1810,20.3452, 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 25.0);
    CreateDynamic3DTextLabel("{FF0000}[ P U M P A ]\n{FFFFFF}Da naspete gorivo kucajte\n{FF0000}/gorivo", -1, 1532.8367,-2176.9741,13.5853, 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 25.0);
    CreateDynamic3DTextLabel("{FF0000}[ {FFFFFF}OPSTINA {FF0000}]\n{FFFFFF}Za ulaz koristite tipku {FF0000}[F]", -1, 1363.6647,-1654.7445,13.5449, 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
	return 1;
}

LoadPickups()
{
    CreateDynamicPickup(19135, 1, 1461.8052,-1022.9484,23.8331); 					//banka ulaz
 	CreateDynamicPickup(19135, 1, 2947.4983,-1787.1194,1191.0875); 					//banka izlaz
 	CreateDynamicPickup(19197, 1, 2933.3809,-1787.2136,1191.0873-0.9); 				//banka salter
 	CreateDynamicPickup(19135, 1, 2022.3917,-1297.5770,23.9948); 					//zlatara ulaz
 	CreateDynamicPickup(19135, 1, 1026.2103, 2303.5303, -19.7883); 					//zlatara izlaz
 	CreateDynamicPickup(19197, 1, 1026.3081, 2312.2776, -19.7883-0.9); 				//zlatara salter
 	CreateDynamicPickup(19135, 1, 1992.1652,-1775.3353,13.7579); 					//auto skola ulaz
 	CreateDynamicPickup(19135, 1, 1379.2844,1455.0060,-7.7367); 					//auto skola izlaz
 	CreateDynamicPickup(19197, 1, 1376.9954,1461.3077,-7.7367-0.9); 				//auto skola dozvcle
 	CreateDynamicPickup(1650, 1, 1004.0422,-937.5357,42.3281);                      //pumpa 1
 	CreateDynamicPickup(1650, 1, 171.6999,-1923.0776,4.4559);                       //pumpa 2
 	CreateDynamicPickup(1650, 1, -91.2488,-1169.7260,2.4204);                       //pumpa 3
 	CreateDynamicPickup(1650, 1, 1942.3732,-1772.7740,13.6406);                     //pumpa 4
 	CreateDynamicPickup(1650, 1, 1382.2139,460.1810,20.3452);                       //pumpa 5
 	CreateDynamicPickup(1650, 1, 1532.8367,-2176.9741,13.5853);                     //pumpa 6
 	CreateDynamicPickup(19135, 1, 1363.6647,-1654.7445,13.5449); 					//opstina ulaz
 	CreateDynamicPickup(19135, 1, -2128.9692,-175.9183,-79.0954); 					//opstina izlaz
 	return 1;
}

RolePlayIme(playerid, const zanemari[MAX_PLAYER_NAME] = "-1", bool:senzitivno = true, bool:autoRegulacija = true) // by Slay_
{
	#define SL@Y__KLJUC(%0) ("_V([%0])V_")
	new ime[MAX_PLAYER_NAME] = "\0";
	GetPlayerName(playerid, ime, MAX_PLAYER_NAME);
	if(strcmp(ime, zanemari, senzitivno) == 0 || strcmp(ime, SL@Y__KLJUC(playerid), true) == 0) return (1);
	new s = strlen(ime), povlaka[2], i = (0), znakovi = (0), Zabranjeni_Znakovi[19] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '[', ']', '.', ')', '(', '@', '{', '}', '$' }, Brojac_Slova[2];
	povlaka[0] = strfind(ime, "_", true);
    povlaka[1] = strfind(ime, "_", true, povlaka[0]+1);
	if(povlaka[0] == -1) return (2);
	else if(povlaka[1] != -1) return (3);
	else if(ime[0] == '_' || ime[s-1] == '_') return (7);
	else
	{
		do
		{
			while(znakovi < sizeof(Zabranjeni_Znakovi))
			{
				if(ime[i] == Zabranjeni_Znakovi[znakovi]) return (4);
				++ znakovi;
			}
			if(i == 0 || i == povlaka[0]+1)
			{
				if(ime[i] < 'A' || ime[i] > 'Z')
				{
					if(autoRegulacija == false) return (5);
					else if(autoRegulacija != false)
					{
						SetPlayerName(playerid, SL@Y__KLJUC(playerid));
						ime[i] = toupper(ime[i]);
					}
				}
			}
			else if(i != 0 && i != povlaka[0])
			{
				if(ime[i] < 'a' || ime[i] > 'z')
				{
					if(autoRegulacija == false) return (6);
					else if(autoRegulacija != false)
					{
						SetPlayerName(playerid, SL@Y__KLJUC(playerid));
						ime[i] = tolower(ime[i]);
					}
				}
				if(i != 0 && i < povlaka[0]+1) ++ Brojac_Slova[0];
				else if(i != 0 && i > povlaka[0]+1) ++ Brojac_Slova[1];
			}
			++ i;
		}
		while(i < s && ime[i] != EOS);
		if(Brojac_Slova[0] < 1) return (8);
		else if(Brojac_Slova[1] < 2) return (9);
		if(autoRegulacija == true) SetPlayerName(playerid, ime);
	}
	return (1);
}

GetStaffRankName(rank)
{
	new admin[25];
	switch(rank)
	{
		case 1: admin = "Admin Level 1";
		case 2: admin = "Admin Level 2";
		case 3: admin = "Admin Level 3";
		case 4: admin = "Head Admin";
		case 5: admin = "Direktor";
		case 6: admin = "Vlasnik";
	}
	return admin;
}

UpdateBanka(playerid)
{
    new string[60];
	format(string, sizeof(string), "~b~%d$", PI[playerid][NovacBanka]);
	PlayerTextDrawSetString(playerid, BankaTD[playerid], string);
	return 1;
}

UpdateZlato(playerid)
{
    new string[60];
	format(string, sizeof(string), "~y~zlato:_%dG", PI[playerid][Zlato]);
	PlayerTextDrawSetString(playerid, ZlatoTD[playerid], string);
	return 1;
}

RenamePlayer(playerid, name[])
{
	SetPlayerName(playerid, name);
	
	new hash_pass[64];
	SHA256_PassHash(accountRealPass[playerid], ReturnPlayerName(playerid), hash_pass, sizeof hash_pass);
	strmid(PI[playerid][Password], hash_pass, 0, strlen(hash_pass), 128);

	mysql_tqueryEx(SQL, "UPDATE `users` SET `Ime` = '%e', `Password` = '%e' WHERE `SQLID` = '%d'", name, PI[playerid][Password], PI[playerid][SQLID]);
	
	if(PI[playerid][Kuca] != -1)
	{
        strmid(KucaInfo[PI[playerid][Kuca]][kVlasnik], name, 0, strlen(name), 255);
        mysql_tqueryEx(SQL, "UPDATE `houses` SET `Vlasnik` = '%s' WHERE `SQLID` = '%d'", name, PI[playerid][Kuca]);
        KuceLP(PI[playerid][Kuca]);
	}
	if(PI[playerid][Stan] != -1)
	{
        strmid(StanInfo[PI[playerid][Stan]][sVlasnik], name, 0, strlen(name), 255);
        mysql_tqueryEx(SQL, "UPDATE `apartments` SET `Vlasnik` = '%s' WHERE `SQLID` = '%d'", name, PI[playerid][Stan]);
        StanLP(PI[playerid][Stan]);
	}
	return 1;
}

strreplace(string[], find, replace)
{
    for(new i = 0; string[i]; i++)
    {
        if(string[i] == find)
        {
            string[i] = replace;
        }
    }
}

VoziloJeAvion(id)
{
	if(id == 592 || id == 577 || id == 511 || id == 512 || id == 593 || id == 520 || id == 553 || id == 476 || id == 519 || id == 460 || id == 513) return 1;
	else if(id == 548 || id == 425 || id == 417 || id == 487 || id == 488 || id == 497 || id == 563 || id == 447 || id == 469) return 1;
	else return 0;
}

VoziloJeBrod(id)
{
  	if(id == 472 || id == 473 || id == 493 || id == 484 || id == 430 || id == 454 || id == 453 || id == 452 || id == 446) return 1;
  	return 0;
}

VoziloJeMotor(id)
{
	if(id == 462 || id == 448 || id == 581 || id == 522 || id == 461 || id == 521 || id == 523 || id == 463 || id == 468 || id == 471) return 1;
	return 0;
}

VoziloJeBicikla(id)
{
	if(id == 481 || id == 509 || id == 510) return 1;
	return 0;
}

VoziloJeKamion(id)
{
	if(id == 499 || id == 498 || id == 609 || id == 524 || id == 578 || id == 455 || id == 403 || id == 414 || id == 443 || id == 514 || id == 515 || id == 408 || id == 431 || id == 437 || id == 538) return 1;
	return 0;
}

GetSpeed(playerid)
{
    new Float:ST[4];
    if(IsPlayerInAnyVehicle(playerid))
    GetVehicleVelocity(GetPlayerVehicleID(playerid),ST[0],ST[1],ST[2]);
    else GetPlayerVelocity(playerid,ST[0],ST[1],ST[2]);
    ST[3] = floatsqroot(floatpower(floatabs(ST[0]), 2.0) + floatpower(floatabs(ST[1]), 2.0) + floatpower(floatabs(ST[2]), 2.0)) * 178.8617875;
    return floatround(ST[3]);
}

mysql_tqueryEx(MySQL:handle, const fmat[],  va_args<>)
{
    new str[1500];
    va_format(str, sizeof (str), fmat, va_start<2>);
    return mysql_tquery( handle, str, "", "");
}

Ucitavanje_Objekata(playerid)
{
	TogglePlayerControllable(playerid, 0);
	GameTextForPlayer( playerid, "~g~Ucitavanje ~w~objekata...", 1000, 3);
	PlayerTimer[playerid] = SetTimerEx("ZalediOdledi", 2*1000, false, "i", playerid);
	SetCameraBehindPlayer(playerid);
	return 1;
}

KreirajAtm(i)
{
	if(AtmInfo[i][aPostavljen] == 1)
	{
	    AtmInfo[i][aAtmLabel] = CreateDynamic3DTextLabel("{1b71bc}[BANKOMAT]\n{FFFFFF}Da koristite bankomat\nKomanda: {1b71bc}/bankomat", 0x1b71bcFF, AtmInfo[i][aX], AtmInfo[i][aY], AtmInfo[i][aZ]+1.0, 15.0,_,_,_, AtmInfo[i][aVW], AtmInfo[i][aInt],_,_);
		AtmInfo[i][aObjekat] = CreateDynamicObject(ATM_OBJEKAT, AtmInfo[i][aX], AtmInfo[i][aY], AtmInfo[i][aZ], 0.0, 0.0, AtmInfo[i][aAngle], AtmInfo[i][aVW], AtmInfo[i][aInt],_,_);
	}
	else printf("Bankomat ID: %d nije kreiran jer mu je var postavljen nije na 1.", i);
	return 1;
}

UlicaKuce(h)
{
	new imeulice[MAX_ZONE_NAME];
   	UlicaKuce2D(h,imeulice,sizeof(imeulice));
   	return imeulice;
}

UlicaKuce2D(h, zone[], len)
{
	new Float:x22, Float:y22;
	x22 = KucaInfo[h][kUlazX]; y22 = KucaInfo[h][kUlazY];
	for(new i = 0; i != sizeof(gSAZones); i++ )
	{
		if(x22 >= gSAZones[i][SAZONE_AREA][0] && x22 <= gSAZones[i][SAZONE_AREA][3] && y22 >= gSAZones[i][SAZONE_AREA][1] && y22 <= gSAZones[i][SAZONE_AREA][4])
		{
		    return format(zone, len, gSAZones[i][SAZONE_NAME], 0);
		}
	}
	return 0;
}

KuceLP(idkuce)
{
	new string[500];
	if(KucaInfo[idkuce][kProveraVlasnika] == 0)
	{
		DestroyDynamic3DTextLabel(KucaLabel[idkuce]);
		DestroyDynamicPickup(KucaPickup[idkuce]);
        format(string,sizeof(string),"{04CC29}[ KUCA NA PRODAJU ]\nVrsta: {FFFFFF}%s\n{04CC29}Cena: {FFFFFF}%d$\n{04CC29}Level: {FFFFFF}%d\n{04CC29}Adresa: {FFFFFF}%s\n{04CC29}Za kupovinu kuce /kupikucu",Vrsta_Kuce(KucaInfo[idkuce][kVrsta]),KucaInfo[idkuce][kCena],KucaInfo[idkuce][kLevel],UlicaKuce(idkuce));
        KucaLabel[idkuce] = CreateDynamic3DTextLabel(string ,0x33CCFFAA,KucaInfo[idkuce][kUlazX],KucaInfo[idkuce][kUlazY],KucaInfo[idkuce][kUlazZ], 30);
        KucaPickup[idkuce] = CreateDynamicPickup(19522, 1, KucaInfo[idkuce][kUlazX], KucaInfo[idkuce][kUlazY], KucaInfo[idkuce][kUlazZ]);
	}
	else if(KucaInfo[idkuce][kProveraVlasnika] == 1)
	{
		DestroyDynamic3DTextLabel(KucaLabel[idkuce]);
		DestroyDynamicPickup(KucaPickup[idkuce]);
        if(KucaInfo[idkuce][kRent] == 0)
		{
			format(string,sizeof(string),"{04CC29}[ KUCA ]\nVlasnik: {FFFFFF}%s\n{04CC29}Vrsta: {FFFFFF}%s\n{04CC29}Level: {FFFFFF}%d\n{04CC29}Cena: {FFFFFF}%d$\n{04CC29}Adresa: {FFFFFF}%s",KucaInfo[idkuce][kVlasnik],Vrsta_Kuce(KucaInfo[idkuce][kVrsta]),KucaInfo[idkuce][kLevel],KucaInfo[idkuce][kCena],UlicaKuce(idkuce));
		}
		else if(KucaInfo[idkuce][kRent] == 1)
		{
			format(string,sizeof(string),"{04CC29}[ KUCA ]\nVlasnik: {FFFFFF}%s\n{04CC29}Vrsta: {FFFFFF}%s\n{04CC29}Level: {FFFFFF}%d\n{04CC29}Cena: {FFFFFF}%d$\n{04CC29}Cena Renta: {FFFFFF}%d$\n{04CC29}Adresa: {FFFFFF}%s\n{04CC29}Za rent kuce /rentajkucu",KucaInfo[idkuce][kVlasnik],Vrsta_Kuce(KucaInfo[idkuce][kVrsta]),KucaInfo[idkuce][kLevel],KucaInfo[idkuce][kCena],KucaInfo[idkuce][kCenaRenta],UlicaKuce(idkuce));
		}
        KucaLabel[idkuce] = CreateDynamic3DTextLabel(string ,0x33CCFFAA, KucaInfo[idkuce][kUlazX],KucaInfo[idkuce][kUlazY],KucaInfo[idkuce][kUlazZ],30);
        KucaPickup[idkuce] = CreateDynamicPickup(19524, 1, KucaInfo[idkuce][kUlazX], KucaInfo[idkuce][kUlazY], KucaInfo[idkuce][kUlazZ]);
	}
	return 1;
}

StanLP(s)
{
	new string[300];
    if(StanInfo[s][sProveraVlasnika] == 0)
	{
	    DestroyDynamic3DTextLabel(StanLabel[s]);
		DestroyDynamicPickup(StanPickup[s]);
		format(string,sizeof(string),"{56dc7d}[ STAN NA PRODAJU ]\nCena: {FFFFFF}%d$\n{56dc7d}Level: {FFFFFF}%d\nZa kupovinu {56dc7d}/kupistan", StanInfo[s][sCena], StanInfo[s][sLevel]);
		StanLabel[s] = CreateDynamic3DTextLabel(string, -1, StanInfo[s][sUlazX], StanInfo[s][sUlazY], StanInfo[s][sUlazZ], 30);
		StanPickup[s] = CreateDynamicPickup(19605, 1, StanInfo[s][sUlazX], StanInfo[s][sUlazY], StanInfo[s][sUlazZ]);
	}
	else if(StanInfo[s][sProveraVlasnika] == 1)
	{
	    DestroyDynamic3DTextLabel(StanLabel[s]);
		DestroyDynamicPickup(StanPickup[s]);
		format(string,sizeof(string),"{56dc7d}[ STAN ]\nVlasnik: {FFFFFF}%s\n{56dc7d}Cena: {FFFFFF}%d$\n{56dc7d}Level: {FFFFFF}%d", StanInfo[s][sVlasnik], StanInfo[s][sCena], StanInfo[s][sLevel]);
		StanLabel[s] = CreateDynamic3DTextLabel(string, -1, StanInfo[s][sUlazX], StanInfo[s][sUlazY], StanInfo[s][sUlazZ], 30);
		StanPickup[s] = CreateDynamicPickup(19606, 1, StanInfo[s][sUlazX], StanInfo[s][sUlazY], StanInfo[s][sUlazZ]);
	}
	return 1;
}

Vrsta_Kuce(ku_id)
{
	new string[15];
	switch(ku_id)
	{
		case MALA_KUCA: string = "Mala Kuca";
		case SREDNJA_KUCA: string = "Srednja Kuca";
		case VELIKA_KUCA: string = "Velika Kuca";
		case VILLA: string = "Vila";
		default: string = "Nepoznata";
	}
	return string;
}

GetNearestAtm( playerid )
{
	for(new i = 1; i < MAX_ATM; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 1.5, AtmInfo[i][aX], AtmInfo[i][aY], AtmInfo[i][aZ]))
		{
			return i;
		}
	}
	return -1;
}

// - > Timeri
task PayPoeni[60000]()
{
    new sat, minut, sekund, godina, mesec, dan;
	gettime(sat, minut, sekund);
	getdate(godina, mesec, dan);
	foreach(new i: Player)
 	{
        if(minut >= 0 && minut <= 3)
		{
			if(DobioPay[i] == 0)
			{
				PayDay(i);
			}
		}
		else if(minut > 3) DobioPay[i] = 0;
	}
	return 1;
}

task GorivoDole[70000]()
{
	foreach(new i: Player)
 	{
		new engine, lights, alarm, doors, bonnet, boot, objective;
		GetVehicleParamsEx(GetPlayerVehicleID(i), engine, lights, alarm, doors, bonnet, boot, objective);
		if(engine == 1)
		{
	        Fuel[GetPlayerVehicleID(i)] --;
			if(Fuel[GetPlayerVehicleID(i)] < 1)
			{
				Fuel[GetPlayerVehicleID(i)] = 0;
			    SetVehicleParamsEx(GetPlayerVehicleID(i), 0, lights, alarm, doors, bonnet, boot, objective);
				GameTextForPlayer(i, "~w~Nema vise ~r~goriva ~w~u vozilu!", 5000, 3);
				va_SendClientMessage(i, 0x1b71bcFF, "#Info: {FFFFFF}Nema vise goriva u vozilu, pa ga ne mozete upaliti!");
			}
			new string[128];
			format(string, sizeof(string), "%d", Fuel[GetPlayerVehicleID(i)]);
			PlayerTextDrawSetString(i, BrzinaTD[i][18], string);
		}
	}
	return 1;
}

task GlobalTimer[1000]()
{
    new sat, minut, sekund, godina, mesec, dan;
	gettime(sat, minut, sekund);
	getdate(godina, mesec, dan);
	foreach(new i: Player)
	{
	    new str[30];
		format(str, sizeof(str), "%02d:%02d:%02d_-_%02d.%02d.%02d", sat, minut, sekund, dan, mesec, godina);
		TextDrawSetString(InGameTD[1], str);
	
	    if(PI[i][Level] < 4) SetPlayerChatBubble(i, "[ POCETNIK ]", 0x1b71bcFF, 30.0, 60000);
	    if(PI[i][Mutiran] != 0) SetPlayerChatBubble(i, "[ MUTIRAN ]", 0xd46161FF, 30.0, 60000);
	    switch(PI[i][Admin])
	    {
	        case 1..3: SetPlayerChatBubble(i, "[ ADMIN ]", 0xFF0000FF, 20.0, 30000);
	        case 4: SetPlayerChatBubble(i, "[ HEAD ADMIN ]", 0xFF0000FF, 20.0, 30000);
	        case 5: SetPlayerChatBubble(i, "[ DIREKTOR ]", 0xFF0000FF, 20.0, 30000);
	        case 6: SetPlayerChatBubble(i, "[ VLASNIK ]", 0xFF0000FF, 20.0, 30000);
	    }
	    switch(PI[i][Vip])
	    {
	        case 1..4: SetPlayerChatBubble(i, "[ VIP ]", 0x1fde79FF, 20.0, 30000);
	    }
	}
    return 1;
}

// - //
AntiDeAMX()
{
    new a[][] =
    {
        "Unarmed (Fist)",
        "Brass K"
    };
    #pragma unused a
}
