// Weapon.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "Weapon.h"
#include "WepMagGraphic.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CWeapon dialog


CWeapon::CWeapon(CWnd* pParent /*=NULL*/)
	: CDialog(CWeapon::IDD, pParent)
{
	//{{AFX_DATA_INIT(CWeapon)
	//}}AFX_DATA_INIT
}


void CWeapon::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CWeapon)
	DDX_Control(pDX, IDC_ELEM8, m_elem8);
	DDX_Control(pDX, IDC_ELEM7, m_elem7);
	DDX_Control(pDX, IDC_ELEM6, m_elem6);
	DDX_Control(pDX, IDC_ELEM5, m_elem5);
	DDX_Control(pDX, IDC_ELEM3, m_elem3);
	DDX_Control(pDX, IDC_ELEM4, m_elem4);
	DDX_Control(pDX, IDC_ELEM2, m_elem2);
	DDX_Control(pDX, IDC_ELEM1, m_elem1);
	DDX_Control(pDX, IDC_EDITGFX, m_editgfx);
	DDX_Control(pDX, IDC_WEAPONLIST, m_weaponlist);
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
	DDX_Control(pDX, IDC_UNKNOWN, m_unknown);
	DDX_Control(pDX, IDC_SPELLCAST, m_spellcast);
	DDX_Control(pDX, IDC_PRICE, m_price);
	DDX_Control(pDX, IDC_HIT, m_hit);
	DDX_Control(pDX, IDC_GFX, m_gfx);
	DDX_Control(pDX, IDC_DAMAGE, m_damage);
	DDX_Control(pDX, IDC_CAT8, m_cat8);
	DDX_Control(pDX, IDC_CAT7, m_cat7);
	DDX_Control(pDX, IDC_CAT6, m_cat6);
	DDX_Control(pDX, IDC_CAT5, m_cat5);
	DDX_Control(pDX, IDC_CAT4, m_cat4);
	DDX_Control(pDX, IDC_CAT3, m_cat3);
	DDX_Control(pDX, IDC_CAT2, m_cat2);
	DDX_Control(pDX, IDC_CAT1, m_cat1);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CWeapon, CDialog)
	//{{AFX_MSG_MAP(CWeapon)
	ON_LBN_SELCHANGE(IDC_WEAPONLIST, OnSelchangeWeaponlist)
	ON_BN_CLICKED(IDC_EDITLABEL, OnEditlabel)
	ON_WM_PAINT()
	ON_WM_LBUTTONDOWN()
	ON_CBN_SELCHANGE(IDC_GFX, OnSelchangeGfx)
	ON_BN_CLICKED(IDC_SAVE, OnSave)
	ON_BN_CLICKED(IDC_EDITGFX, OnEditgfx)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CWeapon message handlers

BOOL CWeapon::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	if(!ReLoadROM(cart)){
		CDialog::OnCancel();
		return 0;}

	PutHexToList(cart,WEAPONTEXT_OFFSET,BASICTEXT_PTRADD,WEAPON_COUNT,cart->dat.TextViewInDTE[1],&m_weaponlist,NULL);
	PutHexToList(cart,ATTACKTEXT_OFFSET,ATTACKTEXT_PTRADD,ATTACK_COUNT,cart->dat.TextViewInDTE[6],NULL,&m_spellcast);
	PutHexToList(cart,MAGICTEXT_OFFSET,BASICTEXT_PTRADD,MAGIC_COUNT,cart->dat.TextViewInDTE[4],NULL,&m_spellcast);
	m_spellcast.InsertString(0,"--None--");
	CString text = PutHexToList(cart,CLASSTEXT_OFFSET,BASICTEXT_PTRADD,CLASS_COUNT,cart->dat.TextViewInDTE[5],NULL,NULL);
	CString parttext;
	int find;

	CButton* classlists[CLASS_COUNT] = {
		&m_use1,&m_use2,&m_use3,&m_use4,&m_use5,&m_use6,
		&m_use7,&m_use8,&m_use9,&m_use10,&m_use11,&m_use12};
	for(int co = 0; co < CLASS_COUNT; co++){
		find = text.Find("\\b");
		if(find == -1) find = text.GetLength();
		parttext = text.Left(find);
		classlists[co]->SetWindowText(parttext);
		text = text.Right(text.GetLength() - find - 2);}
	for(co = 0; co < WEAPONMAGICGRAPHIC_COUNT; co++)
		m_gfx.InsertString(co,cart->dat.WepMagLabels[co]);
	m_gfx.InsertString(0,"--None--");

	rcPalette.SetRect(160,205,416,221);
	rcGraphic = rcPalette;
	rcGraphic.left = rcGraphic.right - 32;
	rcGraphic.top -= 48;
	rcGraphic.bottom -= 32;
	rcFinger = rcPalette;
	rcFinger.top += 16;
	rcFinger.bottom += 16;
	cur_pal = 0;

	m_graphics.Create(32,32,ILC_COLOR16,1,0);

	cur = -1;
	m_weaponlist.SetCurSel(0);
	OnSelchangeWeaponlist();

	return 1;
}

void CWeapon::ResetGraphicList()
{
	while(m_graphics.GetImageCount()) m_graphics.Remove(0);
	CBitmap bmp;
	CPaintDC dc(this);
	CDC mDC; mDC.CreateCompatibleDC(&dc);
	bmp.CreateCompatibleBitmap(&dc,32,32);
	mDC.SelectObject(&bmp);

	int offset = WEAPONMAGICGRAPHIC_OFFSET + ((m_gfx.GetCurSel() - 1) << 6);

	BYTE palette[4] = {0x0F,0x20 + cur_pal,0x10 + cur_pal,cur_pal};

	BYTE coX, coY;
	for(coY = 0; coY < 32; coY += 16){
	for(coX = 0; coX < 32; coX += 16, offset += 16){
		DrawTileScale(&mDC,coX,coY,cart,offset,palette,2);}}

	mDC.DeleteDC();
	m_graphics.Add(&bmp,RGB(0,0,0));
	bmp.DeleteObject();

	InvalidateRect(rcGraphic,0);
}

void CWeapon::OnSelchangeWeaponlist() 
{
	if(cur != -1) StoreValues();

	cur = m_weaponlist.GetCurSel();

	LoadValues();
}

void CWeapon::OnEditlabel() 
{
	int temp = m_gfx.GetCurSel();
	ChangeLabel(WEAPONMAGICGRAPHICLABEL_SIZE,cart->dat.WepMagLabels[temp - 1],temp,NULL,&m_gfx);
}

void CWeapon::OnPaint() 
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
	cart->Finger.Draw(&dc,1,pt,ILD_TRANSPARENT);

	if(m_gfx.GetCurSel()){
		pt.x = rcGraphic.left;
		pt.y = rcGraphic.top;
		m_graphics.Draw(&dc,0,pt,ILD_TRANSPARENT);}
	else{
		br.CreateSolidBrush(cart->Palette[0][0x0F]);
		dc.FillRect(rcGraphic,&br);
		br.DeleteObject();}
}

void CWeapon::OnLButtonDown(UINT nFlags, CPoint pt) 
{
	if(PtInRect(rcPalette,pt)){
		cur_pal = (pt.x - rcPalette.left) >> 4;
		ResetGraphicList();
		InvalidateRect(rcFinger);
	}
}

void CWeapon::StoreValues()
{
	int temp;
	CString text;
	int offset = WEAPON_OFFSET + (cur * WEAPON_BYTES);

	m_hit.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF; cart->ROM[offset] = temp;

	m_damage.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF; cart->ROM[offset + 1] = temp;

	m_unknown.GetWindowText(text); temp = StringToInt_HEX(text);
	if(temp > 0xFF) temp = 0xFF; cart->ROM[offset + 2] = temp;
	
	temp = m_spellcast.GetCurSel();
	if(temp >= 0x41) temp += 0x02;
	cart->ROM[offset + 3] = temp;

	temp = 0;
	if(m_elem1.GetCheck()) temp |= 0x01;
	if(m_elem2.GetCheck()) temp |= 0x02;
	if(m_elem3.GetCheck()) temp |= 0x04;
	if(m_elem4.GetCheck()) temp |= 0x08;
	if(m_elem5.GetCheck()) temp |= 0x10;
	if(m_elem6.GetCheck()) temp |= 0x20;
	if(m_elem7.GetCheck()) temp |= 0x40;
	if(m_elem8.GetCheck()) temp |= 0x80;
	cart->ROM[offset + 4] = temp;

	temp = 0;
	if(m_cat1.GetCheck()) temp |= 0x01;
	if(m_cat2.GetCheck()) temp |= 0x02;
	if(m_cat3.GetCheck()) temp |= 0x04;
	if(m_cat4.GetCheck()) temp |= 0x08;
	if(m_cat5.GetCheck()) temp |= 0x10;
	if(m_cat6.GetCheck()) temp |= 0x20;
	if(m_cat7.GetCheck()) temp |= 0x40;
	if(m_cat8.GetCheck()) temp |= 0x80;
	cart->ROM[offset + 5] = temp;

	temp = m_gfx.GetCurSel() << 2;
	if(temp) temp += 0x7C;
	cart->ROM[offset + 6] = temp;

	cart->ROM[offset + 7] = cur_pal + 0x20;
	

	offset = WEAPONPRICE_OFFSET + (cur << 1);
	m_price.GetWindowText(text);
	temp = StringToInt(text); if(temp > 0xFFFF) temp = 0xFFFF;
	cart->ROM[offset] = temp & 0xFF;
	cart->ROM[offset + 1] = temp >> 8;
	
	temp = 0;
	if(!m_use1.GetCheck() ) temp |= 0x800;
	if(!m_use2.GetCheck() ) temp |= 0x400;
	if(!m_use3.GetCheck() ) temp |= 0x200;
	if(!m_use4.GetCheck() ) temp |= 0x100;
	if(!m_use5.GetCheck() ) temp |= 0x080;
	if(!m_use6.GetCheck() ) temp |= 0x040;
	if(!m_use7.GetCheck() ) temp |= 0x020;
	if(!m_use8.GetCheck() ) temp |= 0x010;
	if(!m_use9.GetCheck() ) temp |= 0x008;
	if(!m_use10.GetCheck()) temp |= 0x004;
	if(!m_use11.GetCheck()) temp |= 0x002;
	if(!m_use12.GetCheck()) temp |= 0x001;

	offset = WEAPONPERMISSIONS_OFFSET + (cur << 1);
	cart->ROM[offset] = temp & 0xFF;
	cart->ROM[offset + 1] = temp >> 8;
}

void CWeapon::LoadValues()
{
	int temp;
	CString text;
	int offset = WEAPON_OFFSET + (cur * WEAPON_BYTES);

	text.Format("%d",cart->ROM[offset]);
	m_hit.SetWindowText(text);

	text.Format("%d",cart->ROM[offset + 1]);
	m_damage.SetWindowText(text);

	text.Format("%X",cart->ROM[offset + 2]);
	if(text.GetLength() == 1) text = "0" + text;
	m_unknown.SetWindowText(text);
	
	temp = cart->ROM[offset + 3];
	if(temp >= 0x43) temp -= 0x02;
	m_spellcast.SetCurSel(temp);

	temp = cart->ROM[offset + 4];
	m_elem1.SetCheck(temp & 0x01);
	m_elem2.SetCheck(temp & 0x02);
	m_elem3.SetCheck(temp & 0x04);
	m_elem4.SetCheck(temp & 0x08);
	m_elem5.SetCheck(temp & 0x10);
	m_elem6.SetCheck(temp & 0x20);
	m_elem7.SetCheck(temp & 0x40);
	m_elem8.SetCheck(temp & 0x80);

	temp = cart->ROM[offset + 5];
	m_cat1.SetCheck(temp & 0x01);
	m_cat2.SetCheck(temp & 0x02);
	m_cat3.SetCheck(temp & 0x04);
	m_cat4.SetCheck(temp & 0x08);
	m_cat5.SetCheck(temp & 0x10);
	m_cat6.SetCheck(temp & 0x20);
	m_cat7.SetCheck(temp & 0x40);
	m_cat8.SetCheck(temp & 0x80);

	temp = cart->ROM[offset + 6];
	if(temp > 0){
		temp -= 0x80;
		temp >>= 2;
		temp += 1;
		m_gfx.SetCurSel(temp);}
	else m_gfx.SetCurSel(0);

	
	m_editgfx.EnableWindow(m_gfx.GetCurSel());

	cur_pal = cart->ROM[offset + 7] - 0x20;



	offset = WEAPONPRICE_OFFSET + (cur << 1);
	temp = cart->ROM[offset] + (cart->ROM[offset + 1] << 8);
	text.Format("%d",temp);
	m_price.SetWindowText(text);
	
	offset = WEAPONPERMISSIONS_OFFSET + (cur << 1);
	temp = cart->ROM[offset] + (cart->ROM[offset + 1] << 8);
	m_use1.SetCheck( !(temp & 0x800));
	m_use2.SetCheck( !(temp & 0x400));
	m_use3.SetCheck( !(temp & 0x200));
	m_use4.SetCheck( !(temp & 0x100));
	m_use5.SetCheck( !(temp & 0x080));
	m_use6.SetCheck( !(temp & 0x040));
	m_use7.SetCheck( !(temp & 0x020));
	m_use8.SetCheck( !(temp & 0x010));
	m_use9.SetCheck( !(temp & 0x008));
	m_use10.SetCheck(!(temp & 0x004));
	m_use11.SetCheck(!(temp & 0x002));
	m_use12.SetCheck(!(temp & 0x001));
	
	ResetGraphicList();
	InvalidateRect(rcFinger);
}

void CWeapon::OnSelchangeGfx() 
{
	ResetGraphicList();
	m_editgfx.EnableWindow(m_gfx.GetCurSel());
}

void CWeapon::OnSave() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
}

void CWeapon::OnOK() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
	else
		CDialog::OnOK();
}

void CWeapon::OnCancel() 
{
	ReLoadROM(cart);
	CDialog::OnCancel();
}

void CWeapon::OnEditgfx() 
{
	CWepMagGraphic dlg;
	dlg.cart = cart;
	dlg.paletteref = cur_pal;
	dlg.graphic = m_gfx.GetCurSel() - 1;
	dlg.IsWeapon = 1;
	dlg.DoModal();
	InvalidateRect(rcPalette,0);
	ResetGraphicList();
}