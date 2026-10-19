// Armor.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "Armor.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CArmor dialog


CArmor::CArmor(CWnd* pParent /*=NULL*/)
	: CDialog(CArmor::IDD, pParent)
{
	//{{AFX_DATA_INIT(CArmor)
	//}}AFX_DATA_INIT
}


void CArmor::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CArmor)
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
	DDX_Control(pDX, IDC_PRICE, m_price);
	DDX_Control(pDX, IDC_EVADE, m_evade);
	DDX_Control(pDX, IDC_DEF8, m_def8);
	DDX_Control(pDX, IDC_DEF7, m_def7);
	DDX_Control(pDX, IDC_DEF6, m_def6);
	DDX_Control(pDX, IDC_DEF5, m_def5);
	DDX_Control(pDX, IDC_DEF4, m_def4);
	DDX_Control(pDX, IDC_DEF3, m_def3);
	DDX_Control(pDX, IDC_DEF2, m_def2);
	DDX_Control(pDX, IDC_DEF1, m_def1);
	DDX_Control(pDX, IDC_DEF, m_def);
	DDX_Control(pDX, IDC_SPELLCAST, m_spellcast);
	DDX_Control(pDX, IDC_ARMORLIST, m_armorlist);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CArmor, CDialog)
	//{{AFX_MSG_MAP(CArmor)
	ON_LBN_SELCHANGE(IDC_ARMORLIST, OnSelchangeArmorlist)
	ON_BN_CLICKED(IDC_SAVE, OnSave)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CArmor message handlers

BOOL CArmor::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	if(!ReLoadROM(cart)){
		CDialog::OnCancel();
		return 0;}

		
	CButton* classlists[CLASS_COUNT] = {
		&m_use1,&m_use2,&m_use3,&m_use4,&m_use5,&m_use6,
		&m_use7,&m_use8,&m_use9,&m_use10,&m_use11,&m_use12};
	PutHexToList(cart,ARMORTEXT_OFFSET,BASICTEXT_PTRADD,ARMOR_COUNT,cart->dat.TextViewInDTE[2],&m_armorlist,NULL);
	PutHexToList(cart,ATTACKTEXT_OFFSET,ATTACKTEXT_PTRADD,ATTACK_COUNT,cart->dat.TextViewInDTE[6],NULL,&m_spellcast);
	PutHexToList(cart,MAGICTEXT_OFFSET,BASICTEXT_PTRADD,MAGIC_COUNT,cart->dat.TextViewInDTE[4],NULL,&m_spellcast);
	m_spellcast.InsertString(0,"--None--");
	CString text = PutHexToList(cart,CLASSTEXT_OFFSET,BASICTEXT_PTRADD,CLASS_COUNT,cart->dat.TextViewInDTE[5],NULL,NULL);
	CString parttext;
	int find;

	for(int co = 0; co < CLASS_COUNT; co++){
		find = text.Find("\\b");
		if(find == -1) find = text.GetLength();
		parttext = text.Left(find);
		classlists[co]->SetWindowText(parttext);
		text = text.Right(text.GetLength() - find - 2);}

	cur = -1;
	m_armorlist.SetCurSel(0);
	OnSelchangeArmorlist();

	return 1;
}

void CArmor::OnSelchangeArmorlist() 
{
	if(cur != -1) StoreValues();

	cur = m_armorlist.GetCurSel();

	LoadValues();
}

void CArmor::LoadValues()
{
	int offset = ARMOR_OFFSET + (ARMOR_BYTES * cur);
	int temp;
	CString text;


	temp = cart->ROM[offset];
	text.Format("%d",temp);
	m_evade.SetWindowText(text);

	temp = cart->ROM[offset + 1];
	text.Format("%d",temp);
	m_def.SetWindowText(text);

	temp = cart->ROM[offset + 2];
	m_def1.SetCheck(temp & 0x01);
	m_def2.SetCheck(temp & 0x02);
	m_def3.SetCheck(temp & 0x04);
	m_def4.SetCheck(temp & 0x08);
	m_def5.SetCheck(temp & 0x10);
	m_def6.SetCheck(temp & 0x20);
	m_def7.SetCheck(temp & 0x40);
	m_def8.SetCheck(temp & 0x80);

	temp = cart->ROM[offset + 3];
	if(temp >= 0x43) temp -= 0x02;
	m_spellcast.SetCurSel(temp);



	offset = ARMORPRICE_OFFSET + (cur << 1);
	temp = cart->ROM[offset] + (cart->ROM[offset + 1] << 8);
	text.Format("%d",temp);
	m_price.SetWindowText(text);

	offset = ARMORPERMISSIONS_OFFSET + (cur << 1);
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
}

void CArmor::StoreValues()
{
	int offset = ARMOR_OFFSET + (ARMOR_BYTES * cur);
	int temp;
	CString text;

	m_evade.GetWindowText(text);
	temp = StringToInt(text); if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset] = temp;

	m_def.GetWindowText(text);
	temp = StringToInt(text); if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 1] = temp;

	temp = 0;
	if(m_def1.GetCheck()) temp |= 0x01;
	if(m_def2.GetCheck()) temp |= 0x02;
	if(m_def3.GetCheck()) temp |= 0x04;
	if(m_def4.GetCheck()) temp |= 0x08;
	if(m_def5.GetCheck()) temp |= 0x10;
	if(m_def6.GetCheck()) temp |= 0x20;
	if(m_def7.GetCheck()) temp |= 0x40;
	if(m_def8.GetCheck()) temp |= 0x80;
	cart->ROM[offset + 2] = temp;

	temp = m_spellcast.GetCurSel();
	if(temp >= 0x41) temp += 0x02;
	cart->ROM[offset + 3] = temp;

	offset = ARMORPRICE_OFFSET + (cur << 1);
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

	offset = ARMORPERMISSIONS_OFFSET + (cur << 1);
	cart->ROM[offset] = temp & 0xFF;
	cart->ROM[offset + 1] = temp >> 8;
}

void CArmor::OnSave() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
}

void CArmor::OnOK() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
	else
		CDialog::OnOK();
}

void CArmor::OnCancel() 
{
	ReLoadROM(cart);
	CDialog::OnCancel();
}