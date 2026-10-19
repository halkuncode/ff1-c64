//////////////////////////////////////////////////
//functions.h
//
//  Defines global functions and structs

struct DATA
{
	char ROMPath[1000];
	bool TextViewInDTE[10];
	bool ShowLastClick;
	bool DrawDomainGrid;
	char TextLabels[DIALOGUE_COUNT][TEXTLABEL_SIZE + 1];
	char WepMagLabels[WEAPONMAGICGRAPHIC_COUNT][WEAPONMAGICGRAPHICLABEL_SIZE + 1];
	char AILabels[AI_COUNT][AILABEL_SIZE + 1];
	char ShopLabels[SHOP_COUNT][SHOPLABEL_SIZE + 1];
	char BattleLabels[BATTLE_COUNT][BATTLELABEL_SIZE + 1];
	char BattlePatternTableLabels[BATTLEPATTERNTABLE_COUNT][BATTLEPATTERNTABLELABEL_SIZE + 1];
	char BackdropLabels[16][BACKDROPLABEL_SIZE + 1];
	char ONTeleportLabels[ONTELEPORT_COUNT][TELEPORTLABEL_SIZE + 1];
	char NNTeleportLabels[NNTELEPORT_COUNT][TELEPORTLABEL_SIZE + 1];
	char NOTeleportLabels[NOTELEPORT_COUNT][TELEPORTLABEL_SIZE + 1];
	char TCLabels[TREASURE_COUNT][TCLABEL_SIZE + 1];
	char MapLabels[MAP_COUNT][MAPLABEL_SIZE + 1];
	char TilesetLabels[TILESET_COUNT][TILESETLABEL_SIZE + 1];
	char SpriteLabels[SPRITE_COUNT][SPRITELABEL_SIZE + 1];
	char SpriteGraphicLabels[MAPSPRITEGRAPHIC_COUNT][SPRITEGRAPHICLABEL_SIZE + 1];
	BYTE TintVariant;
	BYTE TintTiles[9][128];
	BYTE SmartTools[19][9];
};

struct DATA_FROM_V995
{
	int NumOfTables;
	short BattleMessageTable;
	short MagicTable;
	short ItemTable;
	short ArmorTable;
	short WeaponTable;
	short TextTable;
	short EnemyTable;
	short CharacterTable;
	short AttackTable;
	char Tables[10][256][3];
	char TableName[10][21];
	char SavedFileName[1000];

	char SpriteLabels[0xD0][31];
	char TextLabels[0x100][46];
	char EnemyPatternLabels[0x10][36];
	char BattleLabels[0x80][21];
	char AiLabels[0x2C][16];
};

struct CARTRIDGE
{
	BYTE ROM[ROM_SIZE];
	DATA dat;
	FILE* datafile;
	COLORREF Palette[9][65];		//64 NES colors (plus transparency)... 9 sets
									// 0 = normal
									// 1 = tint black
									// 2 = tint blue
									// 3 = tint green
									// 4 = tint red
									// 5 = tint blue-green
									// 6 = tint purple
									// 7 = tint yellow
									// 8 = tint white
	CString Tables[2][256];			//Standard and DTE tables
	CImageList Finger;

	CImageList m_overworldtiles;
	bool OK_overworldtiles;
	CImageList m_standardtiles[MAP_COUNT][2];
	bool OK_tiles[MAP_COUNT];

	BYTE TeleportFollowup[0x80][3];
	BYTE curFollowup;
	BYTE maxFollowup;
};

struct DRAW_STRUCT
{
	BYTE* bitmap;		//pointer to the bitmap
	BYTE* PicFormation;	//pointer to the bitmap formation
	BYTE* PalFormation;	//pointer to the palette formation

	BYTE palmax;		//the max number of valid palette entries

	BYTE Width;			//width of the bitmap formation
	BYTE Height;		//height
	short Max;			//last tile used in the bitmap formation

	CRect rcPalette;	//the RECT for the palette to be drawn
	CRect rcGraphic;	//the RECT for the graphic
	CRect rcCloseup;	//the closeup
	CRect rcFinger;		//the "finger" cursor

	BYTE curblock;		//the block we are currently editing
	BYTE curpal;		//the current palette selection

	BYTE mousedown;		//is the mouse button down?
	CPoint mouseclick;	//where was the last place clicked (used for drag-drawing)
};

///////////////////
/////Functions/////
///////////////////

//General Use
void CreateNewDataFile(CARTRIDGE*);
bool ReLoadROM(CARTRIDGE* cart);
bool LoadROM(CARTRIDGE*,CWnd*);
CString PutHexToList(CARTRIDGE*,int,int,int,bool,CListBox*,CComboBox*);
void LoadTable(CARTRIDGE*,bool,FILE*);
int StringToInt_HEX(CString);
int StringToInt(CString);
void ChangeLabel(int,char*,int,CListBox*,CComboBox*);
bool SaveRomToFile(CARTRIDGE*);
void ReTintPalette(CARTRIDGE*);
bool CompareStrings(BYTE*,BYTE*,int);

//Drawing

void Draw_ROM_Buffer(CARTRIDGE*,int,DRAW_STRUCT*);
void Draw_Buffer_ROM(CARTRIDGE*,int,DRAW_STRUCT*);
void Draw_DrawGraphic(CDC* mDC,DRAW_STRUCT* draw,CARTRIDGE* cart,BYTE* pal,bool drawbox,bool hideFF);
void Draw_DrawBufferTile(CDC* mDC,int pX,int pY,CARTRIDGE* cart,DRAW_STRUCT* draw,BYTE* bitmap,BYTE* pal,int size);
void Draw_DrawCloseup(CDC* mDC,DRAW_STRUCT* draw,CARTRIDGE* cart,BYTE* pal);
void Draw_DrawPalette(CDC* mDC,int pX, int pY,CARTRIDGE* cart,BYTE* pal);
void Draw_DrawPatternTables(CDC* mDC,DRAW_STRUCT* draw,CARTRIDGE* cart,BYTE* pal,CRect rc,int max,bool drawbox = 1);
void Draw_DrawFinger(CDC* mDC,DRAW_STRUCT* draw,CARTRIDGE* cart);
void Draw_DrawAll(CDC* mDC,DRAW_STRUCT* draw,CARTRIDGE* cart,BYTE* pal);
BYTE Draw_ButtonDown(DRAW_STRUCT* draw,CPoint pt,bool rbutton);
bool Draw_MouseMove(DRAW_STRUCT* draw,CPoint pt);

void Draw_ExportToBmp(DRAW_STRUCT*, CARTRIDGE*, BYTE*);
void Draw_ImportFromBmp(DRAW_STRUCT*, CARTRIDGE*, BYTE*);

//not in sync with the other drawing functions... this is only used for prepping image lists
//   not for drawing raw data to the screen.  Only used in the map editors.
void DrawTile(CDC*,int,int,CARTRIDGE*,int,BYTE*,BYTE tint = 0);
void DrawTileScale(CDC* dc,int tX, int tY,CARTRIDGE* cart,int offset,BYTE* palette, int scale, BYTE tint = 0);