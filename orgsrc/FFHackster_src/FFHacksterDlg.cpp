// FFHacksterDlg.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "FFHacksterDlg.h"

#include "OverworldMap.h"
#include "Minimap.h"
#include "Text.h"
#include "Armor.h"
#include "Weapon.h"
#include "Enemy.h"
#include "Attack.h"
#include "Magic.h"
#include "Shop.h"
#include "Battle.h"
#include "Maps.h"
#include "Classes.h"
#include "About.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CFFHacksterDlg dialog

CFFHacksterDlg::CFFHacksterDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CFFHacksterDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CFFHacksterDlg)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CFFHacksterDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CFFHacksterDlg)
	DDX_Control(pDX, IDC_ROMPATH, m_rompath);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CFFHacksterDlg, CDialog)
	//{{AFX_MSG_MAP(CFFHacksterDlg)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_OVERWORLDMAP, OnOverworldmap)
	ON_BN_CLICKED(IDC_TEXT, OnText)
	ON_BN_CLICKED(IDC_ARMOR, OnArmor)
	ON_BN_CLICKED(IDC_WEAPON, OnWeapon)
	ON_BN_CLICKED(IDC_ENEMY, OnEnemy)
	ON_BN_CLICKED(IDC_ATTACK, OnAttack)
	ON_BN_CLICKED(IDC_MAGIC, OnMagic)
	ON_BN_CLICKED(IDC_SHOP, OnShop)
	ON_BN_CLICKED(IDC_BATTLE, OnBattle)
	ON_BN_CLICKED(IDC_MAPS, OnMaps)
	ON_BN_CLICKED(IDC_CLASSES, OnClasses)
	ON_BN_CLICKED(IDC_ABOUT, OnAbout)
	ON_COMMAND(IDMENU_OPEN, OnOpen)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CFFHacksterDlg message handlers

BOOL CFFHacksterDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	//Load the Icon  :)
	SetIcon(m_hIcon, TRUE);
	SetIcon(m_hIcon, FALSE);

	//first... boot up the palette.
	FILE* file = fopen(PALETTEFILE_NAME,"rb");
	BYTE pal[0xC0];
	BYTE rgb[3];
	if(file == NULL)
		AfxMessageBox("Error loading palette...\nImages will not display correctly");
	else{
		fread(pal,1,0xC0,file);
		fclose(file);}

	int co1, co;
	for(co = 0, co1 = 0; co < 64; co++, co1 += 3){
		rgb[0] = pal[co1]; rgb[1] = pal[co1 + 1]; rgb[2] = pal[co1 + 2];
		cart.Palette[0][co] = RGB(rgb[0],rgb[1],rgb[2]);
		if(cart.Palette[0][co] == TRANSPARENTCOLOR)
			cart.Palette[0][co] = TRANSPARENTCOLORREPLACEMENT;}
	for(co = 0; co < 9; co++)
		cart.Palette[co][0x40] = TRANSPARENTCOLOR;

	//okay... break out the 'finger' ImageList
	cart.Finger.Create(16,16,ILC_COLOR16 + ILC_MASK,2,0);
	cart.OK_overworldtiles = 0;
	for(co = 0; co < MAP_COUNT; co++)
		cart.OK_tiles[co] = 0;

	//now... let's get our Tables
	file = fopen(STANDARDTABLEFILE_NAME,"rb");
	if(file == NULL)
		AfxMessageBox("Error loading Standard Table...\nSome text will not display correctly");
	else
		LoadTable(&cart,0,file);

	file = fopen(DTETABLEFILE_NAME,"rb");
	if(file == NULL)
		AfxMessageBox("Error loading DTE Table...\nSome text will not display correctly");
	else
		LoadTable(&cart,1,file);


	//boot up the data file...if non exists, create one.
	cart.datafile = fopen(DATAFILE_NAME,"r+b");
	if(cart.datafile == NULL) CreateNewDataFile(&cart);
	else{
		BYTE header[4];
		fread(header,1,1,cart.datafile);
		if(header[0] == 199){
			DATA_FROM_V995 olddata;
			fread(&olddata,sizeof(DATA_FROM_V995),1,cart.datafile);
			CreateNewDataFile(&cart);
			for(int co = 0; co < 0xD0; co++)
				lstrcpy(cart.dat.SpriteLabels[co],olddata.SpriteLabels[co]);
			for(co = 0; co < 0x100; co++)
				lstrcpy(cart.dat.TextLabels[co],olddata.TextLabels[co]);
			for(co = 0; co < 0x10; co++)
				lstrcpy(cart.dat.BattlePatternTableLabels[co],olddata.EnemyPatternLabels[co]);
			for(co = 0; co < 0x80; co++)
				lstrcpy(cart.dat.BattleLabels[co],olddata.BattleLabels[co]);
			for(co = 0; co < 0x2C; co++)
				lstrcpy(cart.dat.AILabels[co],olddata.AiLabels[co]);
		}
		else{
			fread(&header[1],1,3,cart.datafile);
			for(int co = 0; co < 4; co++){
				if(header[co] != HEADER[co]){
					AfxMessageBox("Invalid FFHackster data file");
					fclose(cart.datafile);
					CreateNewDataFile(&cart);
					break;
				}}
			if(co == 4) fread(&cart.dat,sizeof(DATA),1,cart.datafile);
		}
	}


	//Now that we have the data file... boot up the ROM.. open a new one if needed
	if(!LoadROM(&cart,this)){
		CFileDialog FileDlg(1,".nes",NULL,OFN_HIDEREADONLY,"NES rom files (*.nes)|*.nes|All files|*.*||");
		if(FileDlg.DoModal() == IDOK){
			CString path = FileDlg.GetPathName();
			for(int co = 0; co < path.GetLength(); co++)
				cart.dat.ROMPath[co] = path.GetAt(co);
			cart.dat.ROMPath[co] = 0;
			if(!LoadROM(&cart,this)){
				AfxMessageBox("Error opening rom file.");
				CDialog::OnCancel();
				return 0;}
		}
		else{
			CDialog::OnCancel();
			return 0;}
	}

	m_rompath.SetWindowText(cart.dat.ROMPath);

	
	ReTintPalette(&cart);

	cart.curFollowup = 0;
	cart.maxFollowup = 0;

	return 1;
}

void CFFHacksterDlg::OnPaint() 
{
	//Here's some lame stuff put in by AppWizard
	if (IsIconic())
	{
		CPaintDC dc(this);

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CFFHacksterDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

void CFFHacksterDlg::OnCancel() 
{
	//when the user exits... we want to save & close the data file
	rewind(cart.datafile);
	fwrite(HEADER,1,4,cart.datafile);
	fwrite(&cart.dat,sizeof(DATA),1,cart.datafile);
	fclose(cart.datafile);

	CDialog::OnCancel();
}

void CFFHacksterDlg::GoToMapScreen(bool OV)
{
	bool teleport = 0;
	COverworldMap dlg;
	dlg.cart = &cart;
	CMaps ndlg;
	ndlg.cart = &cart;

	if(OV) goto LBL_overworld;
	else goto LBL_standard;

LBL_overworld:
	dlg.BootToTeleportFollowup = teleport;
	if(dlg.DoModal() == IDOK){
		teleport = dlg.BootToTeleportFollowup;
		if(teleport) goto LBL_standard;}
	goto LBL_end;

LBL_standard:
	ndlg.BootToTeleportFollowup = teleport;
	if(ndlg.DoModal() == IDOK){
		teleport = ndlg.BootToTeleportFollowup;
		if(teleport) goto LBL_overworld;}
	goto LBL_end;

LBL_end:
	return;
}

void CFFHacksterDlg::OnOverworldmap() 
{GoToMapScreen(1);}

void CFFHacksterDlg::OnText() 
{
	CText dlg;
	dlg.cart = &cart;
	dlg.DoModal();
}

void CFFHacksterDlg::OnArmor() 
{
	CArmor dlg;
	dlg.cart = &cart;
	dlg.DoModal();
}

void CFFHacksterDlg::OnWeapon() 
{
	CWeapon dlg;
	dlg.cart = &cart;
	dlg.DoModal();
}

void CFFHacksterDlg::OnEnemy() 
{
	CEnemy dlg;
	dlg.cart = &cart;
	dlg.DoModal();
}

void CFFHacksterDlg::OnAttack() 
{
	CAttack dlg;
	dlg.cart = &cart;
	dlg.DoModal();
}

void CFFHacksterDlg::OnMagic() 
{
	CMagic dlg;
	dlg.cart = &cart;
	dlg.DoModal();
}

void CFFHacksterDlg::OnShop() 
{
	CShop dlg;
	dlg.cart = &cart;
	dlg.DoModal();
}

void CFFHacksterDlg::OnBattle() 
{
	CBattle dlg;
	dlg.cart = &cart;
	dlg.DoModal();
}

void CFFHacksterDlg::OnMaps() 
{GoToMapScreen(0);}

void CFFHacksterDlg::OnClasses() 
{
	CClasses dlg;
	dlg.cart = &cart;
	dlg.DoModal();
}

void CFFHacksterDlg::OnAbout() 
{
	CAbout dlg;
	dlg.DoModal();
}

void CFFHacksterDlg::OnOpen() 
{
	CFileDialog FileDlg(1,".nes",NULL,OFN_HIDEREADONLY,"NES rom files (*.nes)|*.nes|All files|*.*||");
	if(FileDlg.DoModal() == IDOK){
		
		CString path = FileDlg.GetPathName();
		for(int co = 0; co < path.GetLength(); co++)
			cart.dat.ROMPath[co] = path.GetAt(co);
		cart.dat.ROMPath[co] = 0;
		m_rompath.SetWindowText(cart.dat.ROMPath);

		if(!LoadROM(&cart,this)){
			AfxMessageBox("Error opening rom file.");
			return;}

		for(co = 0; co < MAP_COUNT; co++){
			cart.OK_tiles[co] = 0;
			cart.m_standardtiles[co][0].DeleteImageList();
			cart.m_standardtiles[co][1].DeleteImageList();}
		cart.OK_overworldtiles = 0;
		cart.m_overworldtiles.DeleteImageList();
	}
}