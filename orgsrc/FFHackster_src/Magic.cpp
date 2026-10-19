// Magic.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "Magic.h"
#include "WepMagGraphic.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CMagic dialog


CMagic::CMagic(CWnd* pParent /*=NULL*/)
	: CDialog(CMagic::IDD, pParent)
{
	//{{AFX_DATA_INIT(CMagic)
	//}}AFX_DATA_INIT
}


void CMagic::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CMagic)
	DDX_Control(pDX, IDC_OUTMINBOX, m_outminbox);
	DDX_Control(pDX, IDC_OUTMAXBOX, m_outmaxbox);
	DDX_Control(pDX, IDC_OUTMIN, m_outmin);
	DDX_Control(pDX, IDC_OUTMAX, m_outmax);
	DDX_Control(pDX, IDC_OUTBATTLELIST, m_outbattlelist);
	DDX_Control(pDX, IDC_EDITGFX, m_editgfx);
	DDX_Control(pDX, IDC_USE9, m_use9);
	DDX_Control(pDX, IDC_USE8, m_use8);
	DDX_Control(pDX, IDC_USE7, m_use7);
	DDX_Control(pDX, IDC_USE6, m_use6);
	DDX_Control(pDX, IDC_USE5, m_use5);
	DDX_Control(pDX, IDC_USE4, m_use4);
	DDX_Control(pDX, IDC_USE3, m_use3);
	DDX_Control(pDX, IDC_USE2, m_use2);
	DDX_Control(pDX, IDC_USE12, m_use12);
	DDX_Control(pDX, IDC_USE11, m_use11);
	DDX_Control(pDX, IDC_USE10, m_use10);
	DDX_Control(pDX, IDC_USE1, m_use1);
	DDX_Control(pDX, IDC_BATTLEMESSAGE, m_battlemessage);
	DDX_Control(pDX, IDC_PRICE, m_price);
	DDX_Control(pDX, IDC_UNKNOWN, m_unknown);
	DDX_Control(pDX, IDC_TARGET5, m_target5);
	DDX_Control(pDX, IDC_TARGET4, m_target4);
	DDX_Control(pDX, IDC_TARGET3, m_target3);
	DDX_Control(pDX, IDC_TARGET2, m_target2);
	DDX_Control(pDX, IDC_TARGET1, m_target1);
	DDX_Control(pDX, IDC_MAGICLIST, m_magiclist);
	DDX_Control(pDX, IDC_GFX, m_gfx);
	DDX_Control(pDX, IDC_ELEM8, m_elem8);
	DDX_Control(pDX, IDC_ELEM7, m_elem7);
	DDX_Control(pDX, IDC_ELEM6, m_elem6);
	DDX_Control(pDX, IDC_ELEM5, m_elem5);
	DDX_Control(pDX, IDC_ELEM4, m_elem4);
	DDX_Control(pDX, IDC_ELEM3, m_elem3);
	DDX_Control(pDX, IDC_ELEM2, m_elem2);
	DDX_Control(pDX, IDC_ELEM1, m_elem1);
	DDX_Control(pDX, IDC_EFFECTBOX, m_effectbox);
	DDX_Control(pDX, IDC_EFFECT8, m_effect8);
	DDX_Control(pDX, IDC_EFFECT7, m_effect7);
	DDX_Control(pDX, IDC_EFFECT6, m_effect6);
	DDX_Control(pDX, IDC_EFFECT5, m_effect5);
	DDX_Control(pDX, IDC_EFFECT4, m_effect4);
	DDX_Control(pDX, IDC_EFFECT3, m_effect3);
	DDX_Control(pDX, IDC_EFFECT2, m_effect2);
	DDX_Control(pDX, IDC_EFFECT1, m_effect1);
	DDX_Control(pDX, IDC_EFF9, m_eff9);
	DDX_Control(pDX, IDC_EFF8, m_eff8);
	DDX_Control(pDX, IDC_EFF7, m_eff7);
	DDX_Control(pDX, IDC_EFF6, m_eff6);
	DDX_Control(pDX, IDC_EFF5, m_eff5);
	DDX_Control(pDX, IDC_EFF4, m_eff4);
	DDX_Control(pDX, IDC_EFF3, m_eff3);
	DDX_Control(pDX, IDC_EFF2, m_eff2);
	DDX_Control(pDX, IDC_EFF17, m_eff17);
	DDX_Control(pDX, IDC_EFF16, m_eff16);
	DDX_Control(pDX, IDC_EFF15, m_eff15);
	DDX_Control(pDX, IDC_EFF14, m_eff14);
	DDX_Control(pDX, IDC_EFF13, m_eff13);
	DDX_Control(pDX, IDC_EFF12, m_eff12);
	DDX_Control(pDX, IDC_EFF11, m_eff11);
	DDX_Control(pDX, IDC_EFF10, m_eff10);
	DDX_Control(pDX, IDC_EFF1, m_eff1);
	DDX_Control(pDX, IDC_EDITLABEL, m_editlabel);
	DDX_Control(pDX, IDC_DAMAGEBOX, m_damagebox);
	DDX_Control(pDX, IDC_DAMAGE, m_damage);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CMagic, CDialog)
	//{{AFX_MSG_MAP(CMagic)
	ON_LBN_SELCHANGE(IDC_MAGICLIST, OnSelchangeMagiclist)
	ON_WM_PAINT()
	ON_WM_LBUTTONDOWN()
	ON_CBN_SELCHANGE(IDC_GFX, OnSelchangeGfx)
	ON_WM_TIMER()
	ON_BN_CLICKED(IDC_TARGET1, OnTarget1)
	ON_BN_CLICKED(IDC_TARGET2, OnTarget2)
	ON_BN_CLICKED(IDC_TARGET3, OnTarget3)
	ON_BN_CLICKED(IDC_TARGET4, OnTarget4)
	ON_BN_CLICKED(IDC_TARGET5, OnTarget5)
	ON_BN_CLICKED(IDC_EFF1, OnEff1)
	ON_BN_CLICKED(IDC_EFF10, OnEff10)
	ON_BN_CLICKED(IDC_EFF11, OnEff11)
	ON_BN_CLICKED(IDC_EFF12, OnEff12)
	ON_BN_CLICKED(IDC_EFF13, OnEff13)
	ON_BN_CLICKED(IDC_EFF14, OnEff14)
	ON_BN_CLICKED(IDC_EFF15, OnEff15)
	ON_BN_CLICKED(IDC_EFF16, OnEff16)
	ON_BN_CLICKED(IDC_EFF17, OnEff17)
	ON_BN_CLICKED(IDC_EFF2, OnEff2)
	ON_BN_CLICKED(IDC_EFF3, OnEff3)
	ON_BN_CLICKED(IDC_EFF4, OnEff4)
	ON_BN_CLICKED(IDC_EFF5, OnEff5)
	ON_BN_CLICKED(IDC_EFF6, OnEff6)
	ON_BN_CLICKED(IDC_EFF7, OnEff7)
	ON_BN_CLICKED(IDC_EFF8, OnEff8)
	ON_BN_CLICKED(IDC_EFF9, OnEff9)
	ON_BN_CLICKED(IDC_SAVE, OnSave)
	ON_BN_CLICKED(IDC_EDITLABEL, OnEditlabel)
	ON_BN_CLICKED(IDC_EDITGFX, OnEditgfx)
	ON_CBN_SELCHANGE(IDC_OUTBATTLELIST, OnSelchangeOutbattlelist)
	ON_EN_CHANGE(IDC_OUTMAX, OnChangeOutmax)
	ON_EN_CHANGE(IDC_OUTMIN, OnChangeOutmin)
	ON_CBN_EDITCHANGE(IDC_OUTMAXBOX, OnEditchangeOutmaxbox)
	ON_CBN_EDITCHANGE(IDC_OUTMINBOX, OnEditchangeOutminbox)
	ON_CBN_SELCHANGE(IDC_OUTMAXBOX, OnSelchangeOutmaxbox)
	ON_CBN_SELCHANGE(IDC_OUTMINBOX, OnSelchangeOutminbox)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CMagic message handlers

CString mintext[9] = {"0","1","2","4","8","16","32","64","128"};
CString maxtext[9] = {"0","1","3","7","15","31","63","127","255"};

BOOL CMagic::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	if(!ReLoadROM(cart)){
		CDialog::OnCancel();
		return 0;}

	haltwrite = 1;

	for(int co = 0; co < 9; co++){
		m_outminbox.InsertString(co,mintext[co]);
		m_outmaxbox.InsertString(co,maxtext[co]);}

	m_graphics.Create(32,32,ILC_COLOR16,1,0);
	
	PutHexToList(cart,BATTLEMESSAGETEXT_OFFSET,BATTLEMESSAGETEXT_PTRADD,BATTLEMESSAGE_COUNT,cart->dat.TextViewInDTE[9],NULL,&m_battlemessage);
	PutHexToList(cart,BASICTEXT_OFFSET + 48,BASICTEXT_PTRADD,2,cart->dat.TextViewInDTE[0],&m_magiclist,NULL);
	PutHexToList(cart,MAGICTEXT_OFFSET,BASICTEXT_PTRADD,MAGIC_COUNT,cart->dat.TextViewInDTE[4],&m_magiclist,NULL);

	for(co = 0; co < OUTBATTLELIST_COUNT; co++)
		m_outbattlelist.InsertString(co,const_outbattlelist[co]);
	m_outbattlelist.InsertString(0,"--none--");
		
	int find;
	CString text = PutHexToList(cart,CLASSTEXT_OFFSET,BASICTEXT_PTRADD,CLASS_COUNT,cart->dat.TextViewInDTE[5],NULL,NULL);
	CString parttext;
	CButton* classlists[CLASS_COUNT] = {
		&m_use1,&m_use2,&m_use3,&m_use4,&m_use5,&m_use6,
		&m_use7,&m_use8,&m_use9,&m_use10,&m_use11,&m_use12};
	for(co = 0; co < CLASS_COUNT; co++){
		find = text.Find("\\b");
		if(find == -1) find = text.GetLength();
		parttext = text.Left(find);
		classlists[co]->SetWindowText(parttext);
		text = text.Right(text.GetLength() - find - 2);}
	for(co = 0; co < WEAPONMAGICGRAPHIC_COUNT; co++)
		m_gfx.InsertString(co,cart->dat.WepMagLabels[co]);
	m_gfx.InsertString(0,"--None--");
	m_battlemessage.InsertString(0,"--None--");

	rcPalette.SetRect(315,300,315 + 256,300 + 16);
	rcGraphic = rcPalette;
	rcGraphic.left = rcGraphic.right - 32;
	rcGraphic.top -= 48;
	rcGraphic.bottom -= 32;
	rcFinger = rcPalette;
	rcFinger.top += 16;
	rcFinger.bottom += 16;
	cur_pal = 0;

	cur = -1;
	m_magiclist.SetCurSel(0);

	OnSelchangeMagiclist();

	SetTimer(1,400,NULL);
	
	return 1;
}

void CMagic::OnSelchangeMagiclist() 
{
	if(cur != -1) StoreValues();

	cur = m_magiclist.GetCurSel();

	LoadValues();
}

void CMagic::UpdateTarget(int temp)
{
	cur_targ = temp;
	m_target1.SetCheck(temp == 0x01);
	m_target2.SetCheck(temp == 0x02);
	m_target3.SetCheck(temp == 0x04);
	m_target4.SetCheck(temp == 0x08);
	m_target5.SetCheck(temp == 0x10);
}

void CMagic::UpdateEffect(int temp)
{
	cur_eff = temp;
	m_eff1.SetCheck(temp == 0x00);
	m_eff2.SetCheck(temp == 0x01);
	m_eff3.SetCheck(temp == 0x02);
	m_eff4.SetCheck(temp == 0x03);
	m_eff5.SetCheck(temp == 0x04);
	m_eff6.SetCheck(temp == 0x05);
	m_eff7.SetCheck(temp == 0x07);
	m_eff8.SetCheck(temp == 0x08);
	m_eff9.SetCheck(temp == 0x09);
	m_eff10.SetCheck(temp == 0x0A);
	m_eff11.SetCheck(temp == 0x0C);
	m_eff12.SetCheck(temp == 0x0D);
	m_eff13.SetCheck(temp == 0x0E);
	m_eff14.SetCheck(temp == 0x0F);
	m_eff15.SetCheck(temp == 0x10);
	m_eff16.SetCheck(temp == 0x11);
	m_eff17.SetCheck(temp == 0x12);

	CString text[8];
	for(int co = 0; co < 8; co++) text[co] = "Unknown";
	CButton* m_effect[8] = {
		&m_effect1,&m_effect2,&m_effect3,&m_effect4,
		&m_effect5,&m_effect6,&m_effect7,&m_effect8};

	temp = UsesChecks(temp);
	switch(temp){
	case 1:
		text[0] = "Death";
		text[1] = "Stone";
		text[2] = "Poison";
		text[3] = "Dark";
		text[4] = "Stun";
		text[5] = "Sleep";
		text[6] = "Mute";
		text[7] = "Conf"; break;
	case 2:
		text[2] = "Cure Poison";
		text[3] = "Cure Dark";
		text[4] = "Cure Stun";
		text[5] = "Cure Sleep";
		text[6] = "Cures Mute"; break;
	case 3:
		text[4] = "Fire";
		text[5] = "Ice";
		text[6] = "Lit";
		text[7] = "Rub"; break;
	case 4:
		text[0] = "Death";
		text[3] = "Dark";
		text[4] = "Stun"; break;
	}

	m_damagebox.ShowWindow(!temp);
	m_damage.ShowWindow(!temp);
	m_effectbox.ShowWindow(temp != 0);
	for(co = 0; co < 8; co++){
		m_effect[co]->SetWindowText(text[co]);
		m_effect[co]->ShowWindow(temp != 0);}
}

void CMagic::LoadValues()
{
	CString text;
	int temp;
	int offset = MAGIC_OFFSET + (MAGIC_BYTES * cur);

	temp = cart->ROM[offset];
	if(temp < 0x10) text.Format("0%X",temp);
	else text.Format("%X",temp);
	m_unknown.SetWindowText(text);

	temp = cart->ROM[offset + 2];
	m_elem1.SetCheck(temp & 0x01);
	m_elem2.SetCheck(temp & 0x02);
	m_elem3.SetCheck(temp & 0x04);
	m_elem4.SetCheck(temp & 0x08);
	m_elem5.SetCheck(temp & 0x10);
	m_elem6.SetCheck(temp & 0x20);
	m_elem7.SetCheck(temp & 0x40);
	m_elem8.SetCheck(temp & 0x80);

	UpdateTarget(cart->ROM[offset + 3]);

	temp = cart->ROM[offset + 5];
	if(temp > 0){
		temp -= 0x80;
		temp >>= 2;
		temp += 1;
		m_gfx.SetCurSel(temp);}
	else m_gfx.SetCurSel(0);

	temp = cart->ROM[offset + 4];
	UpdateEffect(temp);
	if(UsesChecks(temp)){
		temp = cart->ROM[offset + 1];
		m_effect1.SetCheck(temp & 0x01);
		m_effect2.SetCheck(temp & 0x02);
		m_effect3.SetCheck(temp & 0x04);
		m_effect4.SetCheck(temp & 0x08);
		m_effect5.SetCheck(temp & 0x10);
		m_effect6.SetCheck(temp & 0x20);
		m_effect7.SetCheck(temp & 0x40);
		m_effect8.SetCheck(temp & 0x80);}
	else{
		text.Format("%d",cart->ROM[offset + 1]);
		m_damage.SetWindowText(text);}

	cur_pal = cart->ROM[offset + 6] - 0x20;


	offset = MAGICPRICE_OFFSET + (cur << 1);
	temp = cart->ROM[offset] + (cart->ROM[offset + 1] << 8);
	text.Format("%d",temp);
	m_price.SetWindowText(text);


	offset = (cur >> 3) + MAGICPERMISSIONS_OFFSET;
	temp = 1 << (7 - (cur & 7));
	m_use1.SetCheck(!(cart->ROM[offset + 0x00] & temp));
	m_use2.SetCheck(!(cart->ROM[offset + 0x08] & temp));
	m_use3.SetCheck(!(cart->ROM[offset + 0x10] & temp));
	m_use4.SetCheck(!(cart->ROM[offset + 0x18] & temp));
	m_use5.SetCheck(!(cart->ROM[offset + 0x20] & temp));
	m_use6.SetCheck(!(cart->ROM[offset + 0x28] & temp));
	m_use7.SetCheck(!(cart->ROM[offset + 0x30] & temp));
	m_use8.SetCheck(!(cart->ROM[offset + 0x38] & temp));
	m_use9.SetCheck(!(cart->ROM[offset + 0x40] & temp));
	m_use10.SetCheck(!(cart->ROM[offset + 0x48] & temp));
	m_use11.SetCheck(!(cart->ROM[offset + 0x50] & temp));
	m_use12.SetCheck(!(cart->ROM[offset + 0x58] & temp));

	m_battlemessage.SetCurSel(cart->ROM[BATTLEMESSAGE_OFFSET + cur]);

	m_editgfx.EnableWindow(m_gfx.GetCurSel());

	offset = cur + 0xB0;
	temp = -1;
	
	m_outbattlelist.SetCurSel(0);
	for(int co = 0; co < OUTBATTLELIST_COUNT; co++){
		if(cart->ROM[OUTBATTLE_OFFSETS[co]] == offset){
			m_outbattlelist.SetCurSel(co + 1);
			temp = co;
			break;}}

	bool hide = cur < MAGIC_COUNT;
	m_use1.EnableWindow(hide);
	m_use2.EnableWindow(hide);
	m_use3.EnableWindow(hide);
	m_use4.EnableWindow(hide);
	m_use5.EnableWindow(hide);
	m_use6.EnableWindow(hide);
	m_use7.EnableWindow(hide);
	m_use8.EnableWindow(hide);
	m_use9.EnableWindow(hide);
	m_use10.EnableWindow(hide);
	m_use11.EnableWindow(hide);
	m_use12.EnableWindow(hide);
	m_battlemessage.EnableWindow(hide);
	m_price.EnableWindow(hide);
	m_outbattlelist.EnableWindow(hide);

	OnSelchangeOutbattlelist();

	ResetGraphicList();
	InvalidateRect(rcFinger);
}

void CMagic::StoreValues()
{
	int temp;
	CString text;
	int offset = MAGIC_OFFSET + (MAGIC_BYTES * cur);

	m_unknown.GetWindowText(text); temp = StringToInt_HEX(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset] = temp;

	if(UsesChecks(cur_eff)){
		temp = 0;
		if(m_effect1.GetCheck()) temp |= 0x01;
		if(m_effect2.GetCheck()) temp |= 0x02;
		if(m_effect3.GetCheck()) temp |= 0x04;
		if(m_effect4.GetCheck()) temp |= 0x08;
		if(m_effect5.GetCheck()) temp |= 0x10;
		if(m_effect6.GetCheck()) temp |= 0x20;
		if(m_effect7.GetCheck()) temp |= 0x40;
		if(m_effect8.GetCheck()) temp |= 0x80;}
	else{
		m_damage.GetWindowText(text); temp = StringToInt(text);
		if(temp > 0xFF) temp = 0xFF;}
	cart->ROM[offset + 1] = temp;

	temp = 0;
	if(m_elem1.GetCheck()) temp |= 0x01;
	if(m_elem2.GetCheck()) temp |= 0x02;
	if(m_elem3.GetCheck()) temp |= 0x04;
	if(m_elem4.GetCheck()) temp |= 0x08;
	if(m_elem5.GetCheck()) temp |= 0x10;
	if(m_elem6.GetCheck()) temp |= 0x20;
	if(m_elem7.GetCheck()) temp |= 0x40;
	if(m_elem8.GetCheck()) temp |= 0x80;
	cart->ROM[offset + 2] = temp;

	cart->ROM[offset + 3] = cur_targ;

	cart->ROM[offset + 4] = cur_eff;

	temp = m_gfx.GetCurSel();
	if(temp){
		temp -= 1;
		temp <<= 2;
		temp += 0x80;}
	cart->ROM[offset + 5] = temp;

	cart->ROM[offset + 6] = cur_pal + 0x20;
	

	offset = MAGICPRICE_OFFSET + (cur << 1);
	m_price.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFFFF) temp = 0xFFFF;
	cart->ROM[offset] = temp & 0xFF;
	cart->ROM[offset + 1] = temp >> 8;

	//for the life of me I can't remember how/why this formula works, but it does
	int byteref = (cur >> 3) + MAGICPERMISSIONS_OFFSET;
	int bitref = 1 << (7 - (cur & 7));
	int invbitref = 255 - bitref;
	int co;
	CButton* m_s[CLASS_COUNT] = {
		&m_use1,&m_use2,&m_use3,&m_use4,&m_use5,&m_use6,
		&m_use7,&m_use8,&m_use9,&m_use10,&m_use11,&m_use12};
	for(co = 0; co < CLASS_COUNT; co++){
		offset = byteref + (co << 3);
		cart->ROM[offset] &= invbitref;
		if(!m_s[co]->GetCheck()) cart->ROM[offset] |= bitref;}


	cart->ROM[BATTLEMESSAGE_OFFSET + cur] = m_battlemessage.GetCurSel();

	
	temp = cur + 0xB0;
	for(co = 0; co < OUTBATTLELIST_COUNT; co++){
		if(m_outbattlelist.GetCurSel() == (co + 1))
			cart->ROM[OUTBATTLE_OFFSETS[co]] = temp;
		else if(cart->ROM[OUTBATTLE_OFFSETS[co]] == temp)
			cart->ROM[OUTBATTLE_OFFSETS[co]] = 0xFF;}
}

int CMagic::UsesChecks(int temp)
{
	switch(temp){
	case 0x03: return 1; break;
	case 0x08: return 2; break;
	case 0x0A: return 3; break;
	case 0x12: return 4; break;
	default: return 0; break;}
}

void CMagic::ResetGraphicList()
{
	while(m_graphics.GetImageCount()) m_graphics.Remove(0);
	CBitmap bmp;
	CPaintDC dc(this);
	CDC mDC; mDC.CreateCompatibleDC(&dc);
	bmp.CreateCompatibleBitmap(&dc,64,32);
	mDC.SelectObject(&bmp);

	if(m_gfx.GetCurSel()){
		int offset = WEAPONMAGICGRAPHIC_OFFSET + ((m_gfx.GetCurSel() - 1) << 6);
		BYTE palette[4];
		palette[0] = 0x0F;
		palette[1] = 0x20 + cur_pal;
		palette[2] = 0x10 + cur_pal;
		palette[3] = 0x30;

		BYTE co, coX, coY;
		for(co = 0; co < 64; co += 32){
		for(coY = 0; coY < 32; coY += 16){
		for(coX = 0; coX < 32; coX += 16, offset += 16){
			DrawTileScale(&mDC,co + coX,coY,cart,offset,palette,2);}}}
	}
	else{
		CRect rec(0,0,64,32);
		CBrush br; br.CreateSolidBrush(cart->Palette[0][0x0F]);
		mDC.FillRect(rec,&br);
		br.DeleteObject();}
	mDC.DeleteDC();
	m_graphics.Add(&bmp,RGB(0,0,0));
	bmp.DeleteObject();

	InvalidateRect(rcGraphic,0);
}

void CMagic::OnPaint() 
{
	CPaintDC dc(this);
	
	CBrush br;
	CRect temp = rcPalette;
	temp.right = temp.left + 16;
	for(int co = 0; co < 16; co++, temp.left += 16, temp.right += 16){
		br.CreateSolidBrush(cart->Palette[0][32 + co]);
		dc.FillRect(temp,&br);
		br.DeleteObject();}

	CPoint pt(rcFinger.left + (cur_pal << 4),rcFinger.top);
	if(cur_pal < 0) pt.x = rcFinger.left;
	cart->Finger.Draw(&dc,1,pt,ILD_TRANSPARENT);

	pt.x = rcGraphic.left;
	pt.y = rcGraphic.top;
	m_graphics.Draw(&dc,cur_graphic,pt,ILD_TRANSPARENT);
}

void CMagic::OnLButtonDown(UINT nFlags, CPoint pt) 
{
	if(PtInRect(rcPalette,pt)){
		cur_pal = (pt.x - rcPalette.left) >> 4;
		ResetGraphicList();
		InvalidateRect(rcFinger);
	}
}

void CMagic::OnSelchangeGfx() 
{ResetGraphicList(); InvalidateRect(rcPalette,0); InvalidateRect(rcFinger,0);
m_editgfx.EnableWindow(m_gfx.GetCurSel());}

void CMagic::OnTimer(UINT nIDEvent) 
{
	cur_graphic = !cur_graphic;
	InvalidateRect(rcGraphic,0);
}

void CMagic::OnTarget1() 
{UpdateTarget(0x01);}
void CMagic::OnTarget2() 
{UpdateTarget(0x02);}
void CMagic::OnTarget3() 
{UpdateTarget(0x04);}
void CMagic::OnTarget4() 
{UpdateTarget(0x08);}
void CMagic::OnTarget5() 
{UpdateTarget(0x10);}
void CMagic::OnEff1()
{UpdateEffect(0x00);}
void CMagic::OnEff2()
{UpdateEffect(0x01);}
void CMagic::OnEff3()
{UpdateEffect(0x02);}
void CMagic::OnEff4()
{UpdateEffect(0x03);}
void CMagic::OnEff5()
{UpdateEffect(0x04);}
void CMagic::OnEff6()
{UpdateEffect(0x05);}
void CMagic::OnEff7()
{UpdateEffect(0x07);}
void CMagic::OnEff8()
{UpdateEffect(0x08);}
void CMagic::OnEff9()
{UpdateEffect(0x09);}
void CMagic::OnEff10()
{UpdateEffect(0x0A);}
void CMagic::OnEff11()
{UpdateEffect(0x0C);}
void CMagic::OnEff12()
{UpdateEffect(0x0D);}
void CMagic::OnEff13()
{UpdateEffect(0x0E);}
void CMagic::OnEff14()
{UpdateEffect(0x0F);}
void CMagic::OnEff15()
{UpdateEffect(0x10);}
void CMagic::OnEff16()
{UpdateEffect(0x11);}
void CMagic::OnEff17()
{UpdateEffect(0x12);}

void CMagic::OnSave() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
}

void CMagic::OnOK() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
	else
		CDialog::OnOK();
}

void CMagic::OnCancel() 
{
	ReLoadROM(cart);
	CDialog::OnCancel();
}

void CMagic::OnEditlabel() 
{
	int temp = m_gfx.GetCurSel();
	ChangeLabel(WEAPONMAGICGRAPHICLABEL_SIZE,cart->dat.WepMagLabels[temp - 1],temp,NULL,&m_gfx);
}

void CMagic::OnEditgfx() 
{
	KillTimer(1);
	CWepMagGraphic dlg;
	dlg.cart = cart;
	dlg.paletteref = cur_pal;
	dlg.graphic = m_gfx.GetCurSel() - 1;
	dlg.IsWeapon = 0;
	dlg.DoModal();
	InvalidateRect(rcPalette,0);
	ResetGraphicList();
	SetTimer(1,400,NULL);
}

void CMagic::OnSelchangeOutbattlelist() 
{
	haltwrite = 1;
	m_outmin.SetWindowText("");
	m_outmax.SetWindowText("");
	CString text = "";
	int temp = m_outbattlelist.GetCurSel() - 1;
	if((temp >= 0) && (temp <= 2)){
		m_outminbox.ShowWindow(1);
		m_outmaxbox.ShowWindow(1);
		m_outmin.ShowWindow(0);
		m_outmax.ShowWindow(0);
		text.Format("%d",cart->ROM[OUTBATTLERANGE_OFFSETS[temp][0]]);
		m_outminbox.SetWindowText(text);
		text.Format("%d",cart->ROM[OUTBATTLERANGE_OFFSETS[temp][1]]);
		m_outmaxbox.SetWindowText(text);
	}
	else if((temp >= 4) && (temp <= 6)){
		m_outminbox.ShowWindow(0);
		m_outmaxbox.ShowWindow(0);
		m_outmin.ShowWindow(1);
		m_outmax.ShowWindow(1);
		m_outmin.EnableWindow(1);
		m_outmax.EnableWindow(1);
		text.Format("%d",cart->ROM[OUTBATTLERANGE_OFFSETS[temp][0]]);
		m_outmin.SetWindowText(text);
		text.Format("%d",cart->ROM[OUTBATTLERANGE_OFFSETS[temp][1]]);
		m_outmax.SetWindowText(text);
	}
	else if(cur == MAGIC_COUNT){
		m_outminbox.ShowWindow(0);
		m_outmaxbox.ShowWindow(0);
		m_outmin.ShowWindow(1);
		m_outmax.ShowWindow(1);
		m_outmin.EnableWindow(1);
		m_outmax.EnableWindow(0);
		m_outmax.SetWindowText(text);
		text.Format("%d",cart->ROM[OUTBATTLERANGE_OFFSETS[3][0]]);
		m_outmin.SetWindowText(text);
	}
	else{
		m_outmin.ShowWindow(1);
		m_outmax.ShowWindow(1);
		m_outminbox.ShowWindow(0);
		m_outmaxbox.ShowWindow(0);
		m_outmin.EnableWindow(0);
		m_outmax.EnableWindow(0);}
	haltwrite = 0;
}

void CMagic::OnChangeOutmax() 
{ChangeOutBattles(1);}
void CMagic::OnChangeOutmin() 
{ChangeOutBattles(0);}

void CMagic::ChangeOutBattles(bool minmax)
{
	if(haltwrite) return;
	int temp = m_outbattlelist.GetCurSel() - 1;

	if(cur == MAGIC_COUNT) temp = 3;
	else if(temp < 0 || temp == 3 || temp > 6) return;

	CString text;
	if(temp < 3){
		if(minmax) m_outmaxbox.GetWindowText(text);
		else m_outminbox.GetWindowText(text);}
	else{
		if(minmax) m_outmax.GetWindowText(text);
		else m_outmin.GetWindowText(text);}

	int value = StringToInt(text); if(value > 255) value = 255;
	cart->ROM[OUTBATTLERANGE_OFFSETS[temp][minmax]] = value;
}

void CMagic::OnEditchangeOutmaxbox() 
{ChangeOutBattles(1);}
void CMagic::OnEditchangeOutminbox() 
{ChangeOutBattles(0);}

void CMagic::OnSelchangeOutmaxbox() 
{
	if(m_outmaxbox.GetCurSel() != -1){
		m_outmaxbox.SetWindowText(maxtext[m_outmaxbox.GetCurSel()]);
		ChangeOutBattles(1);}
}

void CMagic::OnSelchangeOutminbox() 
{
	if(m_outminbox.GetCurSel() != -1){
		m_outminbox.SetWindowText(mintext[m_outminbox.GetCurSel()]);
		ChangeOutBattles(0);}
}
