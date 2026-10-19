// WepMagGraphic.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "WepMagGraphic.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CWepMagGraphic dialog


CWepMagGraphic::CWepMagGraphic(CWnd* pParent /*=NULL*/)
	: CDialog(CWepMagGraphic::IDD, pParent)
{
	//{{AFX_DATA_INIT(CWepMagGraphic)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void CWepMagGraphic::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CWepMagGraphic)
	DDX_Control(pDX, IDC_WEAPON, m_weapon);
	DDX_Control(pDX, IDC_MAGIC, m_magic);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CWepMagGraphic, CDialog)
	//{{AFX_MSG_MAP(CWepMagGraphic)
	ON_WM_PAINT()
	ON_WM_LBUTTONDOWN()
	ON_WM_RBUTTONDOWN()
	ON_WM_LBUTTONUP()
	ON_WM_RBUTTONUP()
	ON_WM_MOUSEMOVE()
	ON_BN_CLICKED(IDC_SAVE, OnSave)
	ON_COMMAND(ID_EXPORTBITMAP, OnExportbitmap)
	ON_COMMAND(ID_IMPORTBITMAP, OnImportbitmap)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CWepMagGraphic message handlers

const BYTE ConstPicFormationMag[8] = {
0,1,4,5,
2,3,6,7};

const BYTE ConstPicFormationWep[4] = {
0,1,
2,3};

BOOL CWepMagGraphic::OnInitDialog() 
{
	CDialog::OnInitDialog();

	m_magic.ShowWindow(!IsWeapon);
	m_weapon.ShowWindow(IsWeapon);

	BYTE co;

	draw.bitmap = bitmap;
	if(IsWeapon){
		for(co = 0; co < 4; co++)
			PicFormation[co] = ConstPicFormationWep[co];
		draw.Width = 2;
		draw.Max = 4;}
	else{
		for(co = 0; co < 8; co++)
			PicFormation[co] = ConstPicFormationMag[co];
		draw.Width = 4;
		draw.Max = 8;}
	draw.PicFormation = PicFormation;
	draw.Height = 2;
	draw.palmax = 4;
	draw.curblock = 0;
	draw.curpal = 1;
	draw.rcGraphic.SetRect(20,25,20 + 32,25 + 32);
	if(!IsWeapon) draw.rcGraphic.right += 32;
	draw.rcCloseup.SetRect(20,130,20 + 128,130 + 128);
	draw.rcPalette.SetRect(20,80,20 + 48,80 + 16);
	draw.rcFinger = draw.rcPalette;
	draw.rcFinger.top += 16; draw.rcFinger.bottom += 16;
	draw.PalFormation = NULL;
	draw.mousedown = 0;
	palette[0] = 0x0F;
	palette[1] = 0x20 + paletteref;
	palette[2] = 0x10 + paletteref;
	if(IsWeapon) palette[3] = paletteref;
	else palette[3] = 0x30;

	Draw_ROM_Buffer(cart,WEAPONMAGICGRAPHIC_OFFSET + (graphic << 6),&draw);
	
	return 1;
}

void CWepMagGraphic::OnPaint() 
{
	CPaintDC dc(this);
	Draw_DrawAll(&dc,&draw,cart,palette);
}

void CWepMagGraphic::OnLButtonDown(UINT nFlags, CPoint pt) 
{
	BYTE ref = Draw_ButtonDown(&draw,pt,0);
	if(ref & 1){
		InvalidateRect(draw.rcGraphic,0);
		InvalidateRect(draw.rcCloseup,0);}
	if(ref & 2)
		InvalidateRect(draw.rcFinger);
}

void CWepMagGraphic::OnRButtonDown(UINT nFlags, CPoint pt) 
{
	BYTE ref = Draw_ButtonDown(&draw,pt,1);
	if(ref & 1){
		InvalidateRect(draw.rcGraphic,0);
		InvalidateRect(draw.rcCloseup,0);}
	if(ref & 2)
		InvalidateRect(draw.rcFinger);
}
void CWepMagGraphic::OnLButtonUp(UINT nFlags, CPoint point) 
{draw.mousedown = 0;}
void CWepMagGraphic::OnRButtonUp(UINT nFlags, CPoint point) 
{draw.mousedown = 0;}

void CWepMagGraphic::OnMouseMove(UINT nFlags, CPoint pt) 
{
	if(Draw_MouseMove(&draw,pt)){
		InvalidateRect(draw.rcGraphic,0);
		InvalidateRect(draw.rcCloseup,0);}
}

void CWepMagGraphic::StoreGraphic()
{Draw_Buffer_ROM(cart,WEAPONMAGICGRAPHIC_OFFSET + (graphic << 6),&draw);}

void CWepMagGraphic::OnSave() 
{
	StoreGraphic();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to Save ROM");
}

void CWepMagGraphic::OnOK() 
{
	StoreGraphic();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to Save ROM");
	else
		CDialog::OnOK();
}

void CWepMagGraphic::OnExportbitmap() 
{Draw_ExportToBmp(&draw,cart,palette);}

void CWepMagGraphic::OnImportbitmap() 
{
	Draw_ImportFromBmp(&draw,cart,palette);
	InvalidateRect(draw.rcGraphic,0);
	InvalidateRect(draw.rcCloseup,0);
}
