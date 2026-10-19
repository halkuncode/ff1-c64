// BattlePic.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "BattlePic.h"
#include "NESPalette.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CBattlePic dialog


CBattlePic::CBattlePic(CWnd* pParent /*=NULL*/)
	: CDialog(CBattlePic::IDD, pParent)
{
	//{{AFX_DATA_INIT(CBattlePic)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void CBattlePic::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CBattlePic)
	DDX_Control(pDX, IDC_PALETTE4, m_palette4);
	DDX_Control(pDX, IDC_PALETTE3, m_palette3);
	DDX_Control(pDX, IDC_PALETTE2, m_palette2);
	DDX_Control(pDX, IDC_PALETTE1, m_palette1);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CBattlePic, CDialog)
	//{{AFX_MSG_MAP(CBattlePic)
	ON_WM_PAINT()
	ON_WM_LBUTTONDOWN()
	ON_WM_RBUTTONDOWN()
	ON_WM_RBUTTONUP()
	ON_WM_LBUTTONUP()
	ON_WM_MOUSEMOVE()
	ON_BN_CLICKED(IDC_PALETTE1, OnPalette1)
	ON_BN_CLICKED(IDC_PALETTE2, OnPalette2)
	ON_BN_CLICKED(IDC_PALETTE3, OnPalette3)
	ON_BN_CLICKED(IDC_PALETTE4, OnPalette4)
	ON_WM_LBUTTONDBLCLK()
	ON_BN_CLICKED(IDC_SAVE, OnSave)
	ON_COMMAND(ID_EXPORTBITMAP, OnExportbitmap)
	ON_COMMAND(ID_IMPORTBITMAP, OnImportbitmap)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CBattlePic message handlers

const BYTE ConstPicFormation[39] = {	//3 x 13 pic formation
 0, 1, 0, 1, 8, 9,14,15,20,21,255,255,255,
 2, 3, 2, 3,10,11,16,17,22,23,26,27,28,
 4, 5, 6, 7,12,13,18,19,24,25,29,30,31};


BOOL CBattlePic::OnInitDialog() 
{
	CDialog::OnInitDialog();

	for(BYTE co = 0; co < 39; co++)
		PicFormation[co] = ConstPicFormation[co];

	draw.bitmap = bitmap;
	draw.PicFormation = PicFormation;
	draw.Width = 13;
	draw.Height = 3;
	draw.Max = 32;
	draw.palmax = 4;
	draw.curblock = 0;
	draw.curpal = 1;
	draw.rcGraphic.SetRect(20,27,20 + 208,27 + 48);
	draw.rcCloseup.SetRect(20,93,20 + 128,93 + 128);
	draw.rcPalette.SetRect(162,93,162 + 48,93 + 16);
	draw.rcFinger = draw.rcPalette;
	draw.rcFinger.top += 16; draw.rcFinger.bottom += 16;
	draw.PalFormation = NULL;
	draw.mousedown = 0;

	palette[0] = 0x0F;

	PalAssign = 255;
	UpdatePalAssignment(cart->ROM[CHARBATTLEPALETTE_ASSIGNMENT1 + Class] & 0x03);

	Draw_ROM_Buffer(cart,CHARBATTLEPIC_OFFSET + (Class << 9),&draw);

	return 1;
}

void CBattlePic::ReLoadPalette()
{
	int offset = CHARBATTLEPALETTE_OFFSET + (PalAssign << 2) + 1;
	for(int co = 1; co < 4; offset++, co++)
		palette[co] = cart->ROM[offset];
}

void CBattlePic::StorePalette()
{
	int offset = CHARBATTLEPALETTE_OFFSET + (PalAssign << 2) + 1;
	for(int co = 1; co < 4; offset++, co++)
		cart->ROM[offset] = palette[co];
}

void CBattlePic::OnPaint() 
{
	CPaintDC dc(this);
	Draw_DrawAll(&dc,&draw,cart,palette);
}

void CBattlePic::OnLButtonDown(UINT nFlags, CPoint pt) 
{
	BYTE ret = Draw_ButtonDown(&draw,pt,0);
	if(ret & 1){
		InvalidateRect(draw.rcGraphic,0);
		InvalidateRect(draw.rcCloseup,0);}
	if(ret & 2)
		InvalidateRect(draw.rcFinger);
}

void CBattlePic::OnRButtonDown(UINT nFlags, CPoint pt) 
{
	BYTE ret = Draw_ButtonDown(&draw,pt,1);
	if(ret & 1){
		InvalidateRect(draw.rcGraphic,0);
		InvalidateRect(draw.rcCloseup,0);}
	if(ret & 2)
		InvalidateRect(draw.rcFinger);
}
void CBattlePic::OnRButtonUp(UINT nFlags, CPoint point) 
{draw.mousedown = 0;}
void CBattlePic::OnLButtonUp(UINT nFlags, CPoint point) 
{draw.mousedown = 0;}
void CBattlePic::OnMouseMove(UINT nFlags, CPoint pt) 
{
	if(Draw_MouseMove(&draw,pt)){
		InvalidateRect(draw.rcGraphic,0);
		InvalidateRect(draw.rcCloseup,0);}
}

void CBattlePic::UpdatePalAssignment(BYTE update)
{
	if(PalAssign != 255) StorePalette();
	PalAssign = update;
	m_palette1.SetCheck(update == 0);
	m_palette2.SetCheck(update == 1);
	m_palette3.SetCheck(update == 2);
	m_palette4.SetCheck(update == 3);
	ReLoadPalette();
	InvalidateRect(draw.rcPalette,0);
	InvalidateRect(draw.rcGraphic,0);
	InvalidateRect(draw.rcCloseup,0);
}
void CBattlePic::OnPalette1() 
{UpdatePalAssignment(0);}
void CBattlePic::OnPalette2() 
{UpdatePalAssignment(1);}
void CBattlePic::OnPalette3() 
{UpdatePalAssignment(2);}
void CBattlePic::OnPalette4() 
{UpdatePalAssignment(3);}

void CBattlePic::OnLButtonDblClk(UINT nFlags, CPoint pt) 
{
	if(PtInRect(draw.rcPalette,pt)){
		CNESPalette dlg;
		dlg.cart = cart;
		dlg.color = &palette[draw.curpal];
		if(dlg.DoModal() == IDOK){
			InvalidateRect(draw.rcPalette,0);
			InvalidateRect(draw.rcGraphic,0);
			InvalidateRect(draw.rcCloseup,0);}
	}
}

void CBattlePic::OnCancel() 
{
	LoadROM(cart,this);
	CDialog::OnCancel();
}

void CBattlePic::OnSave() 
{
	StoreGraphic();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to Save ROM");
}

void CBattlePic::OnOK() 
{
	StoreGraphic();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to Save ROM");
	else
		CDialog::OnOK();
}

void CBattlePic::StoreGraphic()
{
	Draw_Buffer_ROM(cart,CHARBATTLEPIC_OFFSET + (Class << 9),&draw);

	cart->ROM[CHARBATTLEPALETTE_ASSIGNMENT1 + Class] = PalAssign;
	cart->ROM[CHARBATTLEPALETTE_ASSIGNMENT2 + Class] = PalAssign;

	StorePalette();
}

void CBattlePic::OnExportbitmap() 
{Draw_ExportToBmp(&draw,cart,palette);}

void CBattlePic::OnImportbitmap() 
{
	Draw_ImportFromBmp(&draw,cart,palette);
	InvalidateRect(draw.rcGraphic,0);
	InvalidateRect(draw.rcCloseup,0);
}
