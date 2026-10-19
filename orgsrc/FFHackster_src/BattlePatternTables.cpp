// BattlePatternTables.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "BattlePatternTables.h"
#include "NESPalette.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CBattlePatternTables dialog


CBattlePatternTables::CBattlePatternTables(CWnd* pParent /*=NULL*/)
	: CDialog(CBattlePatternTables::IDD, pParent)
{
	//{{AFX_DATA_INIT(CBattlePatternTables)
	//}}AFX_DATA_INIT
}


void CBattlePatternTables::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CBattlePatternTables)
	DDX_Control(pDX, IDC_RESHAPE, m_reshape);
	DDX_Control(pDX, IDC_REPALETTE, m_repalette);
	DDX_Control(pDX, IDC_BACKDROP, m_backdrop);
	DDX_Control(pDX, IDC_PAL4, m_pal4);
	DDX_Control(pDX, IDC_PAL3, m_pal3);
	DDX_Control(pDX, IDC_PAL2, m_pal2);
	DDX_Control(pDX, IDC_PAL1, m_pal1);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CBattlePatternTables, CDialog)
	//{{AFX_MSG_MAP(CBattlePatternTables)
	ON_WM_PAINT()
	ON_WM_LBUTTONDOWN()
	ON_BN_CLICKED(IDC_PAL1, OnPal1)
	ON_BN_CLICKED(IDC_PAL2, OnPal2)
	ON_BN_CLICKED(IDC_PAL3, OnPal3)
	ON_BN_CLICKED(IDC_PAL4, OnPal4)
	ON_CBN_SELCHANGE(IDC_BACKDROP, OnSelchangeBackdrop)
	ON_WM_RBUTTONDOWN()
	ON_WM_MOUSEMOVE()
	ON_WM_LBUTTONUP()
	ON_WM_RBUTTONUP()
	ON_BN_CLICKED(IDC_REPALETTE, OnRepalette)
	ON_BN_CLICKED(IDC_RESHAPE, OnReshape)
	ON_BN_CLICKED(IDC_SAVE, OnSave)
	ON_COMMAND(ID_EXPORTBITMAP, OnExportbitmap)
	ON_WM_LBUTTONDBLCLK()
	ON_COMMAND(ID_IMPORTBITMAP, OnImportbitmap)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

const BYTE ConstPicFormation[120] = {
0x12,0x13,0x14,0x15,0x22,0x23,0x24,0x25,0xFF,0xFF,0xFF,0xFF,
0x16,0x17,0x18,0x19,0x26,0x27,0x28,0x29,0xFF,0xFF,0xFF,0xFF,
0x1A,0x1B,0x1C,0x1D,0x2A,0x2B,0x2C,0x2D,0xFF,0xFF,0xFF,0xFF,
0x1E,0x1F,0x20,0x21,0x2E,0x2F,0x30,0x31,0xFF,0xFF,0xFF,0xFF,
0x32,0x33,0x34,0x35,0x36,0x37,0x56,0x57,0x58,0x59,0x5A,0x5B,
0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x5C,0x5D,0x5E,0x5F,0x60,0x61,
0x3E,0x3F,0x40,0x41,0x42,0x43,0x62,0x63,0x64,0x65,0x66,0x67,
0x44,0x45,0x46,0x47,0x48,0x49,0x68,0x69,0x6A,0x6B,0x6C,0x6D,
0x4A,0x4B,0x4C,0x4D,0x4E,0x4F,0x6E,0x6F,0x70,0x71,0x72,0x73,
0x50,0x51,0x52,0x53,0x54,0x55,0x74,0x75,0x76,0x77,0x78,0x79};

/////////////////////////////////////////////////////////////////////////////
// CBattlePatternTables message handlers

BOOL CBattlePatternTables::OnInitDialog() 
{
	CDialog::OnInitDialog();

	for(BYTE co = 0; co < 120; co++)
		PicFormation[co] = ConstPicFormation[co];

	for(co = 0; co < 16; co++)
		m_backdrop.InsertString(co,cart->dat.BackdropLabels[co]);
	cur_backdrop = -1;
	m_backdrop.SetCurSel(0);
	OnSelchangeBackdrop();

	BYTE GRPal[4] = {0x0F,0x00,0x0F,0x30};
	for(co = 0; co < 4; co++)
		palette[co + 12] = GRPal[co];
	
	int temp;
	temp = BATTLEPALETTE_OFFSET + (palvalues[0] << 2) - 4;
	for(co = 4; co < 8; co++) palette[co] = cart->ROM[temp + co];
	temp = BATTLEPALETTE_OFFSET + (palvalues[1] << 2) - 8;
	for(co = 8; co < 12; co++) palette[co] = cart->ROM[temp + co];

	rcMaxGraphic.SetRect(20,27,20 + 224,27 + 192);

	draw.bitmap = bitmap;
	draw.Max = 0x80;
	draw.palmax = 16;
	draw.curblock = 0x12;
	draw.curpal = 1;
	draw.rcGraphic.SetRect(20,27,20 + 224,27 + 192);
	draw.rcCloseup.SetRect(260,177,260 + 128,177 + 128);
	draw.rcPalette.SetRect(107,234,107 + 48,234 + 64);
	draw.rcFinger = draw.rcPalette;
	draw.rcFinger.top += 64; draw.rcFinger.bottom += 16;
	draw.mousedown = 0;

	rcFinger = draw.rcPalette;
	rcFinger.left -= 16;
	rcFinger.right = rcFinger.left + 16;

	UpdatePalView(4,0);
	InitView();

	rcPattern.SetRect(260,27,260 + 256,27 + 128);

	Draw_ROM_Buffer(cart,(patterntable << 11) + BATTLEPATTERNTABLE_OFFSET,&draw);

	return 1;
}

void CBattlePatternTables::InitView()
{
	int offset;
	switch(view){
	case 0:
		m_reshape.ShowWindow(0);
		m_repalette.ShowWindow(0);
		offset = -1;
		draw.Width = 12;
		draw.Height = 10;
		draw.PalFormation = NULL;
		draw.PicFormation = PicFormation; break;
	case 5:
		offset = CHAOSPALETTE_TABLE;
		draw.Width = 14;
		draw.Height = 12;
		draw.PalFormation = PalFormation;
		draw.PicFormation = &cart->ROM[CHAOSDRAW_TABLE]; break;
	default:
		offset = FIENDPALETTE_TABLE + ((view - 1) * FIENDDRAW_SHIFT);
		draw.Width = 8;
		draw.Height = 8;
		draw.PalFormation = PalFormation;
		draw.PicFormation = &cart->ROM[FIENDDRAW_TABLE + ((view - 1) * FIENDDRAW_SHIFT)];break;
	}

	draw.rcGraphic.right = draw.rcGraphic.left + (draw.Width << 4);
	draw.rcGraphic.bottom = draw.rcGraphic.top + (draw.Height << 4);

	if(offset != -1){
		BYTE TempAssign[8][8];
		BYTE temp;
		int coY, coX, co;
		for(coY = 0; coY < 8; coY += 2){
		for(coX = 0; coX < 8; coX += 2, offset++){
			temp = cart->ROM[offset];
			TempAssign[coY + 1][coX + 1] = (temp >> 6) & 3;
			TempAssign[coY + 1][coX] = (temp >> 4) & 3;
			TempAssign[coY][coX + 1] = (temp >> 2) & 3;
			TempAssign[coY][coX] = temp & 3;}}
		if(view != 5){
			co = 0;
			for(coY = 2; coY < 6; coY++, co += 8){
				for(coX = 2; coX < 6; coX++, co += 2){
					temp = TempAssign[coY][coX];
					PalFormation[co] = temp;
					PalFormation[co + 1] = temp;
					PalFormation[co + 8] = temp;
					PalFormation[co + 9] = temp;}}
		}
		else{
			co = 0;
			for(coY = 1; coY < 7; coY++, co += 14){
				for(coX = 1; coX < 8; coX++, co += 2){
					temp = TempAssign[coY][coX];
					PalFormation[co] = temp;
					PalFormation[co + 1] = temp;
					PalFormation[co + 14] = temp;
					PalFormation[co + 15] = temp;}}
		}
	}

	UpdatePaletteRadios();
}

void CBattlePatternTables::UpdatePalView(BYTE up, bool redraw)
{
	m_pal1.SetCheck(up == 0);
	m_pal2.SetCheck(up == 4);
	m_pal3.SetCheck(up == 8);
	m_pal4.SetCheck(up == 12);
	palview = up;

	if(m_repalette.GetCheck()){
		up >>= 2;
		PalFormation[draw.curblock] = up;
		PalFormation[draw.curblock + 1] = up;
		PalFormation[draw.curblock + draw.Width] = up;
		PalFormation[draw.curblock + draw.Width + 1] = up;}


	if(redraw){
		InvalidateRect(draw.rcGraphic,0);
		InvalidateRect(draw.rcCloseup,0);
		InvalidateRect(rcPattern,0);
		if(!m_repalette.GetCheck())
			InvalidateRect(rcFinger);
	}
}

void CBattlePatternTables::OnPaint() 
{
	CPaintDC dc(this);
	CPen redpen; redpen.CreatePen(PS_SOLID,1,RGB(255,0,0));
	CPen* oldpen = dc.SelectObject(&redpen);

	bool drawbox = (m_repalette.GetCheck() == 0) && (m_reshape.GetCheck() == 0);
	BYTE* temppal = palette;
	if(!view) temppal = &palette[palview];
	Draw_DrawGraphic(&dc,&draw,cart,temppal,drawbox,1);

	int coX, coY;
	if(m_repalette.GetCheck()){
		coX = draw.rcGraphic.left + ((draw.curblock % draw.Width) << 4);
		coY = draw.rcGraphic.top + ((draw.curblock / draw.Width) << 4);
		dc.MoveTo(coX,coY); dc.LineTo(coX + 31,coY); dc.LineTo(coX + 31,coY + 31);
		dc.LineTo(coX,coY + 31); dc.LineTo(coX,coY);}
	else if(m_reshape.GetCheck()){
		coX = draw.rcGraphic.left + ((draw.curblock % draw.Width) << 4);
		coY = draw.rcGraphic.top + ((draw.curblock / draw.Width) << 4);
		dc.MoveTo(coX,coY); dc.LineTo(coX + 15,coY); dc.LineTo(coX + 15,coY + 15);
		dc.LineTo(coX,coY + 15); dc.LineTo(coX,coY);
		Draw_DrawPatternTables(&dc,&draw,cart,&palette[palview],rcPattern,128,0);

		coX = rcPattern.left + ((draw.PicFormation[draw.curblock] & 0x0F) << 4);
		coY = rcPattern.top + (draw.PicFormation[draw.curblock] & 0xF0);
		dc.MoveTo(coX,coY); dc.LineTo(coX + 15,coY); dc.LineTo(coX + 15,coY + 15);
		dc.LineTo(coX,coY + 15); dc.LineTo(coX,coY);}
	else{
		Draw_DrawPatternTables(&dc,&draw,cart,&palette[palview],rcPattern,128);
		Draw_DrawCloseup(&dc,&draw,cart,&palette[palview]);}

	long& drawY = draw.rcPalette.top;
	Draw_DrawPalette(&dc,draw.rcPalette.left,drawY,cart,&palette[0]);
	Draw_DrawPalette(&dc,draw.rcPalette.left,drawY + 16,cart,&palette[4]);
	Draw_DrawPalette(&dc,draw.rcPalette.left,drawY + 32,cart,&palette[8]);
	Draw_DrawPalette(&dc,draw.rcPalette.left,drawY + 48,cart,&palette[12]);
	Draw_DrawFinger(&dc,&draw,cart);

	CPoint pt;
	pt.x = rcFinger.left;
	pt.y = rcFinger.top + (palview << 2);
	cart->Finger.Draw(&dc,0,pt,ILD_TRANSPARENT);

	dc.SelectObject(oldpen);
	redpen.DeleteObject();
}

void CBattlePatternTables::OnLButtonDown(UINT nFlags, CPoint pt) 
{
	if(m_repalette.GetCheck()){
		if(PtInRect(draw.rcGraphic,pt)){
			pt.x = ((pt.x - draw.rcGraphic.left) >> 4) & 0xFE;
			pt.y = ((pt.y - draw.rcGraphic.top) >> 4) & 0xFE;
			draw.curblock = (BYTE)(pt.x + (pt.y * draw.Width));
			UpdatePalView(PalFormation[draw.curblock] << 2,1);
			InvalidateRect(draw.rcGraphic,0);
		}
	}
	else if(m_reshape.GetCheck())
	{
		if(PtInRect(draw.rcGraphic,pt)){
			pt.x = (pt.x - draw.rcGraphic.left) >> 4;
			pt.y = (pt.y - draw.rcGraphic.top) >> 4;
			draw.curblock = (BYTE)(pt.x + (pt.y * draw.Width));
			InvalidateRect(draw.rcGraphic,0);
			InvalidateRect(rcPattern,0);}
		else if(PtInRect(rcPattern,pt)){
			int max = draw.Width * draw.Height;
			pt.x = (pt.x - rcPattern.left) >> 4;
			pt.y = (pt.y - rcPattern.top) & 0xF0;
			draw.PicFormation[draw.curblock] = (BYTE)(pt.x + pt.y);
			draw.curblock += 1;
			if(draw.curblock >= max) draw.curblock = 0;
			InvalidateRect(draw.rcGraphic,0);
			InvalidateRect(rcPattern,0);
		}
	}
	else{
		BYTE ret = Draw_ButtonDown(&draw,pt,0);
		if(ret & 1){
			InvalidateRect(rcPattern,0);
			InvalidateRect(draw.rcGraphic,0);
			InvalidateRect(draw.rcCloseup,0);}
		if(ret & 2){
			pt.y -= draw.rcPalette.top;
			UpdatePalView((BYTE)(pt.y & 0xF0) >> 2);
			InvalidateRect(draw.rcFinger);}

		if(PtInRect(rcPattern,pt)){
			pt.x = (pt.x - rcPattern.left) >> 4;
			pt.y = (pt.y - rcPattern.top) & 0xF0;
			draw.curblock = BYTE(pt.x + pt.y);
			InvalidateRect(draw.rcCloseup,0);
			InvalidateRect(draw.rcGraphic,0);
			InvalidateRect(rcPattern,0);
		}

		else if(nFlags & 0x08){
			CString text;
			text.Format("%d,%d",pt.x,pt.y);
			AfxMessageBox(text);}}
}

void CBattlePatternTables::OnPal1() 
{UpdatePalView(0);}
void CBattlePatternTables::OnPal2() 
{UpdatePalView(4);}
void CBattlePatternTables::OnPal3() 
{UpdatePalView(8);}
void CBattlePatternTables::OnPal4() 
{UpdatePalView(12);}

void CBattlePatternTables::OnSelchangeBackdrop() 
{
	int offset;
	if(cur_backdrop != -1){
		offset = BATTLEBACKDROPPALETTE_OFFSET + cur_backdrop;
		for(BYTE co = 0; co < 4; offset++, co++)
			cart->ROM[offset] = palette[co];}

	cur_backdrop = m_backdrop.GetCurSel() << 2;
	
	offset = BATTLEBACKDROPPALETTE_OFFSET + cur_backdrop;
	for(BYTE co = 0; co < 4; offset++, co++)
		palette[co] = cart->ROM[offset];

	InvalidateRect(draw.rcPalette,0);
	InvalidateRect(draw.rcGraphic,0);
	InvalidateRect(draw.rcCloseup,0);
	InvalidateRect(rcPattern,0);
}

void CBattlePatternTables::OnRButtonDown(UINT nFlags, CPoint pt) 
{
	if(m_repalette.GetCheck() || m_reshape.GetCheck())
		OnLButtonDown(nFlags,pt);
	else{
		BYTE ret = Draw_ButtonDown(&draw,pt,1);
		if(ret & 1){
			InvalidateRect(rcPattern,0);
			InvalidateRect(draw.rcGraphic,0);
			InvalidateRect(draw.rcCloseup,0);}
		if(ret & 2){
			pt.y -= draw.rcPalette.top;
			UpdatePalView((BYTE)(pt.y & 0xF0) >> 2);
			InvalidateRect(draw.rcFinger);}

		if(PtInRect(rcPattern,pt)){
			pt.x = (pt.x - rcPattern.left) >> 4;
			pt.y = (pt.y - rcPattern.top) & 0xF0;
			draw.curblock = BYTE(pt.x + pt.y);
			InvalidateRect(draw.rcCloseup,0);
			InvalidateRect(draw.rcGraphic,0);
			InvalidateRect(rcPattern,0);
	}}
}

void CBattlePatternTables::OnMouseMove(UINT nFlags, CPoint pt) 
{
	if(Draw_MouseMove(&draw,pt)){
		InvalidateRect(rcPattern,0);
		InvalidateRect(draw.rcCloseup,0);
		InvalidateRect(draw.rcGraphic,0);}
}
void CBattlePatternTables::OnLButtonUp(UINT nFlags, CPoint point) 
{draw.mousedown = 0;}
void CBattlePatternTables::OnRButtonUp(UINT nFlags, CPoint point) 
{draw.mousedown = 0;}

void CBattlePatternTables::UpdatePaletteRadios()
{
	m_pal1.ShowWindow(m_repalette.GetCheck());
	m_pal2.ShowWindow(m_repalette.GetCheck());
	m_pal3.ShowWindow(m_repalette.GetCheck());
	m_pal4.ShowWindow(m_repalette.GetCheck());
}

void CBattlePatternTables::OnRepalette() 
{
	UpdatePaletteRadios();
	draw.curblock = 0;
	m_reshape.SetCheck(0);
	InvalidateRect(rcPattern);
	InvalidateRect(draw.rcCloseup);
	InvalidateRect(draw.rcGraphic,0);
	if(m_repalette.GetCheck())
		UpdatePalView(PalFormation[0] << 2,1);
}

void CBattlePatternTables::OnReshape() 
{
	draw.curblock = 0;
	m_repalette.SetCheck(0);
	UpdatePaletteRadios();
	InvalidateRect(draw.rcCloseup);
	InvalidateRect(draw.rcGraphic,0);
	InvalidateRect(rcPattern,0);
}

void CBattlePatternTables::StoreValues()
{
	OnSelchangeBackdrop();

	int temp, co;
	temp = BATTLEPALETTE_OFFSET + (palvalues[0] << 2) - 4;
	for(co = 4; co < 8; co++) cart->ROM[temp + co] = palette[co];
	temp = BATTLEPALETTE_OFFSET + (palvalues[1] << 2) - 8;
	for(co = 8; co < 12; co++) cart->ROM[temp + co] = palette[co];


	int offset, baseoffset;
	switch(view){
	case 0:
		return;
	case 5:
		baseoffset = CHAOSPALETTE_TABLE; break;
	default:
		baseoffset = FIENDPALETTE_TABLE + ((view - 1) * FIENDDRAW_SHIFT); break;
	}

	offset = baseoffset;
	BYTE TempAssign[8][8];
	int coY, coX;
	for(coY = 0; coY < 8; coY += 2){
	for(coX = 0; coX < 8; coX += 2, offset++){
		temp = cart->ROM[offset];
		TempAssign[coY + 1][coX + 1] = (temp >> 6) & 3;
		TempAssign[coY + 1][coX] = (temp >> 4) & 3;
		TempAssign[coY][coX + 1] = (temp >> 2) & 3;
		TempAssign[coY][coX] = temp & 3;}}
	if(view != 5 && view){
		co = 0;	
		for(coY = 2; coY < 6; coY++, co += 8){
		for(coX = 2; coX < 6; coX++, co += 2)
			TempAssign[coY][coX] = PalFormation[co];}

	}
	else if(view){
		co = 0;
		for(coY = 1; coY < 7; coY++, co += 14){
		for(coX = 1; coX < 8; coX++, co += 2)
			TempAssign[coY][coX] = PalFormation[co];}
	}
	offset = baseoffset;
	for(coY = 0; coY < 8; coY += 2){
	for(coX = 0; coX < 8; coX += 2, offset++){
		temp  = TempAssign[coY + 1][coX + 1] << 6;
		temp += TempAssign[coY + 1][coX] << 4;
		temp += TempAssign[coY][coX + 1] << 2;
		temp += TempAssign[coY][coX];
		cart->ROM[offset] = temp;}}

	Draw_Buffer_ROM(cart,(patterntable << 11) + BATTLEPATTERNTABLE_OFFSET,&draw);
}

void CBattlePatternTables::OnOK() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
	else
		CDialog::OnOK();
}

void CBattlePatternTables::OnSave() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
}

void CBattlePatternTables::OnCancel() 
{
	ReLoadROM(cart);
	CDialog::OnCancel();
}

void CBattlePatternTables::OnExportbitmap() 
{
	BYTE* sendpalette = palette;
	if(!view){
		sendpalette = &palette[palview];
		draw.palmax = 4;}
	Draw_ExportToBmp(&draw,cart,sendpalette);
	draw.palmax = 16;
}

void CBattlePatternTables::OnLButtonDblClk(UINT nFlags, CPoint pt) 
{
	if(PtInRect(draw.rcPalette,pt))
	{
		pt.x = (pt.x - draw.rcPalette.left) >> 4;
		pt.y = (pt.y - draw.rcPalette.top) >> 4;
		if(pt.y == 3) return;
		CNESPalette dlg;
		dlg.cart = cart;
		dlg.color = &palette[(pt.y << 2) + pt.x + 1];
		if(dlg.DoModal() == IDOK){
			if((palvalues[0] == palvalues[1]) && (pt.y > 0)){
				palette[5 + pt.x] = *dlg.color;
				palette[9 + pt.x] = *dlg.color;}
			InvalidateRect(draw.rcCloseup,0);
			InvalidateRect(draw.rcPalette,0);
			InvalidateRect(draw.rcGraphic,0);
			InvalidateRect(rcPattern,0);}
	}
}

void CBattlePatternTables::OnImportbitmap() 
{
	BYTE* sendpalette = palette;
	if(!view){
		sendpalette = &palette[palview];
		draw.palmax = 4;}
	Draw_ImportFromBmp(&draw,cart,sendpalette);
	draw.palmax = 16;
	InvalidateRect(draw.rcGraphic,0);
	InvalidateRect(draw.rcCloseup,0);
	InvalidateRect(rcPattern,0);
}
