// TileEdit.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "TileEdit.h"
#include "NESPalette.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CTileEdit dialog


CTileEdit::CTileEdit(CWnd* pParent /*=NULL*/)
	: CDialog(CTileEdit::IDD, pParent)
{
	//{{AFX_DATA_INIT(CTileEdit)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void CTileEdit::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CTileEdit)
	DDX_Control(pDX, IDC_SMALL, m_small);
	DDX_Control(pDX, IDC_LARGE, m_large);
	DDX_Control(pDX, IDC_SHOWROOM, m_showroom);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CTileEdit, CDialog)
	//{{AFX_MSG_MAP(CTileEdit)
	ON_WM_PAINT()
	ON_BN_CLICKED(IDC_SHOWROOM, OnShowroom)
	ON_WM_LBUTTONDOWN()
	ON_WM_LBUTTONUP()
	ON_WM_RBUTTONUP()
	ON_WM_RBUTTONDOWN()
	ON_WM_MOUSEMOVE()
	ON_WM_LBUTTONDBLCLK()
	ON_BN_CLICKED(IDC_SAVE, OnSave)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CTileEdit message handlers

BOOL CTileEdit::OnInitDialog() 
{
	CDialog::OnInitDialog();

	redpen.CreatePen(PS_SOLID,1,RGB(255,0,0));
	int offset;
	if(tileset) offset = TILESETPATTERNTABLE_ASSIGNMENT + ((tileset - 1) << 9) + tile;
	else offset = OVERWORLDPATTERNTABLE_ASSIGNMENT + tile;
	for(int co = 0; co < 4; co++, offset += 0x80)
		PicFormation[co] = cart->ROM[offset];

	if(tileset) offset = TILESETPALETTE_ASSIGNMENT + ((tileset - 1) << 7) + tile;
	else offset = OVERWORLDPALETTE_ASSIGNMENT + tile;
	palassign = cart->ROM[offset] & 3;

	for(int co2 = 0; co2 < 2; co2++){
		for(co = 0; co < 16; co++)
			palette[co2][co] = pal[co2][co];
		if(!tileset) break;}

	draw.bitmap = bitmap;
	draw.PicFormation = PicFormation;
	draw.palmax = 4;
	draw.Width = 2;
	draw.Height = 2;
	if(tileset) draw.Max = 0x80;
	else draw.Max = 0x100;
	draw.rcPalette.SetRect(35,97,35 + 48,97 + 64);
	draw.rcFinger = draw.rcPalette;
	draw.rcFinger.top = draw.rcPalette.bottom;
	draw.rcFinger.bottom = draw.rcPalette.bottom + 16;
	draw.rcCloseup.SetRect(103,28,103 + 128,28 + 128);
	draw.rcGraphic.SetRect(51,28,51 + 32,28 + 32);
	curblock = 0;
	draw.curblock = PicFormation[curblock];
	draw.curpal = 1;
	draw.PalFormation = NULL;
	draw.mousedown = 0;

	rcPatternTables.SetRect(253,28,253 + 256,28 + draw.Max);
	rcFinger = draw.rcPalette;
	rcFinger.left -= 16; rcFinger.right = draw.rcPalette.left;

	if(tileset) offset = TILESETPATTERNTABLE_OFFSET + ((tileset - 1) << 11);
	else offset = OVERWORLDPATTERNTABLE_OFFSET;
	Draw_ROM_Buffer(cart,offset,&draw);

	m_showroom.ShowWindow(tileset != 0);
	m_small.ShowWindow(tileset != 0);
	m_large.ShowWindow(tileset == 0);
	
	return 1;
}

void CTileEdit::OnPaint() 
{
	CPaintDC dc(this);
	CPen* oldpen = dc.SelectObject(&redpen);
	
	BYTE* thispal = &palette[m_showroom.GetCheck()][palassign << 2];
	Draw_DrawPatternTables(&dc,&draw,cart,thispal,rcPatternTables,draw.Max,1);
	Draw_DrawPalette(&dc,draw.rcPalette.left,draw.rcPalette.top,cart,&palette[m_showroom.GetCheck()][0]);
	Draw_DrawPalette(&dc,draw.rcPalette.left,draw.rcPalette.top + 16,cart,&palette[m_showroom.GetCheck()][4]);
	Draw_DrawPalette(&dc,draw.rcPalette.left,draw.rcPalette.top + 32,cart,&palette[m_showroom.GetCheck()][8]);
	Draw_DrawPalette(&dc,draw.rcPalette.left,draw.rcPalette.top + 48,cart,&palette[m_showroom.GetCheck()][12]);
	Draw_DrawFinger(&dc,&draw,cart);
	Draw_DrawCloseup(&dc,&draw,cart,thispal);
	Draw_DrawGraphic(&dc,&draw,cart,thispal,0,0);

	CPoint pt(rcFinger.left,rcFinger.top + (palassign << 4));
	cart->Finger.Draw(&dc,0,pt,ILD_TRANSPARENT);

	pt.x = ((curblock & 1) << 4) + draw.rcGraphic.left;
	pt.y = ((curblock & 2) << 3) + draw.rcGraphic.top;
	dc.MoveTo(pt); dc.LineTo(pt.x + 15,pt.y); dc.LineTo(pt.x + 15,pt.y + 15);
	dc.LineTo(pt.x,pt.y + 15); dc.LineTo(pt);

	dc.SelectObject(oldpen);
}

void CTileEdit::OnShowroom()
{
	InvalidateRect(draw.rcPalette,0);
	InvalidateRect(draw.rcGraphic,0);
	InvalidateRect(draw.rcCloseup,0);
	InvalidateRect(rcPatternTables,0);
}

void CTileEdit::OnLButtonDown(UINT nFlags, CPoint pt) 
{
	BYTE redraw = 0;
	if(PtInRect(draw.rcPalette,pt)){
		palassign = BYTE((pt.y - draw.rcPalette.top) >> 4);
		draw.curpal = BYTE((pt.x - draw.rcPalette.left) >> 4) + 1;
		redraw = 3;}
	if(PtInRect(draw.rcCloseup,pt)){
		Draw_ButtonDown(&draw,pt,0);
		redraw = 1;}
	if(PtInRect(draw.rcGraphic,pt)){
		curblock = (BYTE)((((pt.y - draw.rcGraphic.top) & 0xF0) >> 3) + 
			       (((pt.x - draw.rcGraphic.left) & 0xF0) >> 4));
		draw.curblock = PicFormation[curblock];
		redraw = 1;}
	if(PtInRect(rcPatternTables,pt)){
		draw.curblock = BYTE(((pt.y - rcPatternTables.top) & 0xF0) + 
			            ((pt.x - rcPatternTables.left) >> 4));
		PicFormation[curblock] = draw.curblock;
		redraw = 1;}

	if(redraw & 1){
		InvalidateRect(draw.rcGraphic,0);
		InvalidateRect(draw.rcCloseup,0);
		InvalidateRect(rcPatternTables,0);}
	if(redraw & 2){
		InvalidateRect(rcFinger);
		InvalidateRect(draw.rcFinger);}
}
void CTileEdit::OnLButtonUp(UINT nFlags, CPoint point) 
{draw.mousedown = 0;}
void CTileEdit::OnRButtonUp(UINT nFlags, CPoint point) 
{draw.mousedown = 0;}

void CTileEdit::OnRButtonDown(UINT nFlags, CPoint pt)
{
	if(PtInRect(draw.rcCloseup,pt)){
		Draw_ButtonDown(&draw,pt,1);
		InvalidateRect(draw.rcGraphic,0);
		InvalidateRect(draw.rcCloseup,0);
		InvalidateRect(rcPatternTables,0);}
	else OnLButtonDown(nFlags,pt);
}

void CTileEdit::OnMouseMove(UINT nFlags, CPoint pt)
{
	if(Draw_MouseMove(&draw,pt)){
		InvalidateRect(rcPatternTables,0);
		InvalidateRect(draw.rcGraphic,0);
		InvalidateRect(draw.rcCloseup,0);}
}

void CTileEdit::OnLButtonDblClk(UINT nFlags, CPoint pt) 
{
	if(PtInRect(draw.rcPalette,pt)){
		CNESPalette dlg;
		dlg.cart = cart;
		dlg.color = &palette[m_showroom.GetCheck()][(palassign << 2) + draw.curpal];
		if(dlg.DoModal() == IDOK){
			InvalidateRect(draw.rcPalette,0);
			InvalidateRect(draw.rcGraphic,0);
			InvalidateRect(rcPatternTables,0);
			InvalidateRect(draw.rcCloseup,0);}
	}
}

void CTileEdit::StoreValues()
{
	int offset;
	if(tileset) offset = TILESETPATTERNTABLE_ASSIGNMENT + ((tileset - 1) << 9) + tile;
	else offset = OVERWORLDPATTERNTABLE_ASSIGNMENT + tile;
	for(int co = 0; co < 4; co++, offset += 0x80)
		cart->ROM[offset] = PicFormation[co];

	if(tileset) offset = TILESETPALETTE_ASSIGNMENT + ((tileset - 1) << 7) + tile;
	else offset = OVERWORLDPALETTE_ASSIGNMENT + tile;
	cart->ROM[offset] = (palassign << 6) + (palassign << 4) + (palassign << 2) + (palassign);

	if(tileset) offset = TILESETPATTERNTABLE_OFFSET + ((tileset - 1) << 11);
	else offset = OVERWORLDPATTERNTABLE_OFFSET;
	Draw_Buffer_ROM(cart,offset,&draw);
	
	for(int co2 = 0; co2 < 2; co2++){
		for(co = 0; co < 16; co++)
			pal[co2][co] = palette[co2][co];
		if(!tileset) break;}
}

void CTileEdit::OnSave() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to Save ROM");
}

void CTileEdit::OnOK() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to Save ROM");
	else
		CDialog::OnOK();
}
