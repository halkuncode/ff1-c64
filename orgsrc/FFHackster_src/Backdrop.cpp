// Backdrop.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "Backdrop.h"
#include "NESPalette.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CBackdrop dialog


CBackdrop::CBackdrop(CWnd* pParent /*=NULL*/)
	: CDialog(CBackdrop::IDD, pParent)
{
	//{{AFX_DATA_INIT(CBackdrop)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void CBackdrop::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CBackdrop)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CBackdrop, CDialog)
	//{{AFX_MSG_MAP(CBackdrop)
	ON_WM_PAINT()
	ON_WM_LBUTTONDOWN()
	ON_WM_LBUTTONUP()
	ON_WM_RBUTTONDOWN()
	ON_WM_RBUTTONUP()
	ON_WM_MOUSEMOVE()
	ON_WM_LBUTTONDBLCLK()
	ON_BN_CLICKED(IDC_SAVE, OnSave)
	ON_COMMAND(ID_EXPORTBITMAP, OnExportbitmap)
	ON_COMMAND(ID_IMPORTBITMAP, OnImportbitmap)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CBackdrop message handlers

const BYTE ConstPicFormation[32] = {
 0, 1, 2, 3, 2, 3, 0, 1,
 4, 5, 6, 7, 6, 7, 4, 5,
 8, 9,10,11,10,11, 8, 9,
12,13,14,15,14,15,12,13};

BOOL CBackdrop::OnInitDialog() 
{
	CDialog::OnInitDialog();

	for(BYTE co = 0; co < 32; co++)
		PicFormation[co] = ConstPicFormation[co];
	
	draw.bitmap = bitmap;
	draw.PicFormation = PicFormation;
	draw.Width = 8;
	draw.Height = 4;
	draw.Max = 16;
	draw.palmax = 4;
	draw.curblock = 0;
	draw.curpal = 1;
	draw.rcGraphic.SetRect(20,26,20 + 128,26 + 64);
	draw.rcCloseup.SetRect(20,112,20 + 128,112 + 128);
	draw.rcPalette.SetRect(165,26,165 + 48,26 + 16);
	draw.rcFinger = draw.rcPalette;
	draw.rcFinger.top += 16; draw.rcFinger.bottom += 16;
	draw.PalFormation = NULL;
	draw.mousedown = 0;

	int offset = BATTLEBACKDROPPALETTE_OFFSET + (backdrop << 2);
	for(co = 0; co < 4; co++, offset++)
		palette[co] = cart->ROM[offset];
	palette[0] = 0x0F;

	Draw_ROM_Buffer(cart,BATTLEPATTERNTABLE_OFFSET + 0x10 + (backdrop << 11),&draw);
	
	return 1;
}

void CBackdrop::OnPaint() 
{
	CPaintDC dc(this);
	Draw_DrawAll(&dc,&draw,cart,palette);
}

void CBackdrop::OnLButtonDown(UINT nFlags, CPoint pt) 
{
	BYTE ret = Draw_ButtonDown(&draw,pt,0);
	if(ret & 1){
		InvalidateRect(draw.rcGraphic,0);
		InvalidateRect(draw.rcCloseup,0);}
	if(ret & 2)
		InvalidateRect(draw.rcFinger);
}

void CBackdrop::OnLButtonUp(UINT nFlags, CPoint point) 
{draw.mousedown = 0;}

void CBackdrop::OnRButtonUp(UINT nFlags, CPoint point) 
{draw.mousedown = 0;}

void CBackdrop::OnRButtonDown(UINT nFlags, CPoint pt) 
{
	BYTE ret = Draw_ButtonDown(&draw,pt,1);
	if(ret & 1){
		InvalidateRect(draw.rcGraphic,0);
		InvalidateRect(draw.rcCloseup,0);}
	if(ret & 2)
		InvalidateRect(draw.rcFinger);
}

void CBackdrop::OnMouseMove(UINT nFlags, CPoint point) 
{
	if(Draw_MouseMove(&draw,point)){
		InvalidateRect(draw.rcCloseup,0);
		InvalidateRect(draw.rcGraphic,0);}
}

void CBackdrop::OnLButtonDblClk(UINT nFlags, CPoint pt) 
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

void CBackdrop::StoreValues()
{
	int offset = BATTLEBACKDROPPALETTE_OFFSET + (backdrop << 2);
	for(BYTE co = 0; co < 4; co++, offset++)
		cart->ROM[offset] = palette[co];

	Draw_Buffer_ROM(cart,BATTLEPATTERNTABLE_OFFSET + 0x10 + (backdrop << 11),&draw);
}

void CBackdrop::OnSave() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to Save ROM");
}

void CBackdrop::OnOK() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to Save ROM");
	else
		CDialog::OnOK();
}

void CBackdrop::OnExportbitmap() 
{Draw_ExportToBmp(&draw,cart,palette);}

void CBackdrop::OnImportbitmap() 
{
	Draw_ImportFromBmp(&draw,cart,palette);
	InvalidateRect(draw.rcGraphic,0);
	InvalidateRect(draw.rcCloseup,0);
}
