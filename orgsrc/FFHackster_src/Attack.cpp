// Attack.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "Attack.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CAttack dialog


CAttack::CAttack(CWnd* pParent /*=NULL*/)
	: CDialog(CAttack::IDD, pParent)
{
	//{{AFX_DATA_INIT(CAttack)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void CAttack::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAttack)
	DDX_Control(pDX, IDC_EFF_EFFECT, m_eff_effect);
	DDX_Control(pDX, IDC_EFF_DAMAGE, m_eff_damage);
	DDX_Control(pDX, IDC_UNKNOWN, m_unknown);
	DDX_Control(pDX, IDC_TARGET, m_target);
	DDX_Control(pDX, IDC_ELEM8, m_elem8);
	DDX_Control(pDX, IDC_ELEM7, m_elem7);
	DDX_Control(pDX, IDC_ELEM6, m_elem6);
	DDX_Control(pDX, IDC_ELEM5, m_elem5);
	DDX_Control(pDX, IDC_ELEM4, m_elem4);
	DDX_Control(pDX, IDC_ELEM3, m_elem3);
	DDX_Control(pDX, IDC_ELEM2, m_elem2);
	DDX_Control(pDX, IDC_ELEM1, m_elem1);
	DDX_Control(pDX, IDC_EFFECTBOX, m_effectbox);
	DDX_Control(pDX, IDC_EFF5, m_eff5);
	DDX_Control(pDX, IDC_EFF4, m_eff4);
	DDX_Control(pDX, IDC_EFF3, m_eff3);
	DDX_Control(pDX, IDC_EFF2, m_eff2);
	DDX_Control(pDX, IDC_EFF1, m_eff1);
	DDX_Control(pDX, IDC_DAMAGETEXT, m_damagetext);
	DDX_Control(pDX, IDC_DAMAGE, m_damage);
	DDX_Control(pDX, IDC_ATTACKLIST, m_attacklist);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CAttack, CDialog)
	//{{AFX_MSG_MAP(CAttack)
	ON_LBN_SELCHANGE(IDC_ATTACKLIST, OnSelchangeAttacklist)
	ON_BN_CLICKED(IDC_EFF_DAMAGE, OnEffDamage)
	ON_BN_CLICKED(IDC_EFF_EFFECT, OnEffEffect)
	ON_BN_CLICKED(IDC_SAVE, OnSave)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CAttack message handlers

BOOL CAttack::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	if(!ReLoadROM(cart)){
		CDialog::OnCancel();
		return 0;}
	
	PutHexToList(cart,ATTACKTEXT_OFFSET,ATTACKTEXT_PTRADD,ATTACK_COUNT,cart->dat.TextViewInDTE[6],&m_attacklist,NULL);

	cur = -1;
	m_attacklist.SetCurSel(0);
	OnSelchangeAttacklist();
	
	return 1;
}

void CAttack::OnSelchangeAttacklist() 
{
	if(cur != -1) StoreValues();

	cur = m_attacklist.GetCurSel();

	LoadValues();
}

void CAttack::LoadValues()
{
	int offset = ATTACK_OFFSET + (cur * ATTACK_BYTES);
	CString text;
	int temp;

	text.Format("%X",cart->ROM[offset]);
	if(text.GetLength() == 1) text = "0" + text;
	m_unknown.SetWindowText(text);

	m_target.SetCheck(cart->ROM[offset + 3] == 1);

	temp = cart->ROM[offset + 2];
	m_elem1.SetCheck(temp & 0x01);
	m_elem2.SetCheck(temp & 0x02);
	m_elem3.SetCheck(temp & 0x04);
	m_elem4.SetCheck(temp & 0x08);
	m_elem5.SetCheck(temp & 0x10);
	m_elem6.SetCheck(temp & 0x20);
	m_elem7.SetCheck(temp & 0x40);
	m_elem8.SetCheck(temp & 0x80);

	temp = cart->ROM[offset + 4];
	m_damagetext.ShowWindow(temp == 1);
	m_damage.ShowWindow(temp == 1);
	m_effectbox.ShowWindow(temp == 3);
	m_eff1.ShowWindow(temp == 3);
	m_eff2.ShowWindow(temp == 3);
	m_eff3.ShowWindow(temp == 3);
	m_eff4.ShowWindow(temp == 3);
	m_eff5.ShowWindow(temp == 3);
	m_eff_damage.SetCheck(temp == 1);
	m_eff_effect.SetCheck(temp == 3);

	if(temp == 1){
		text.Format("%d",cart->ROM[offset + 1]);
		m_damage.SetWindowText(text);}
	else{
		temp = cart->ROM[offset + 1];
		m_eff1.SetCheck(temp & 0x01);
		m_eff2.SetCheck(temp & 0x02);
		m_eff3.SetCheck(temp & 0x04);
		m_eff4.SetCheck(temp & 0x08);
		m_eff5.SetCheck(temp & 0x10);}
}

void CAttack::StoreValues()
{
	int offset = ATTACK_OFFSET + (cur * ATTACK_BYTES);
	CString text;
	int temp;

	m_unknown.GetWindowText(text); temp = StringToInt_HEX(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset] = temp;

	temp = 0;
	if(m_eff_damage.GetCheck()){
		m_damage.GetWindowText(text); temp = StringToInt(text);
		if(temp > 0xFF) temp = 0xFF;}
	if(m_eff_effect.GetCheck()){
		if(m_eff1.GetCheck()) temp |= 0x01;
		if(m_eff2.GetCheck()) temp |= 0x02;
		if(m_eff3.GetCheck()) temp |= 0x04;
		if(m_eff4.GetCheck()) temp |= 0x08;
		if(m_eff5.GetCheck()) temp |= 0x10;}
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

	cart->ROM[offset + 3] = 2 - m_target.GetCheck();

	temp = 1;
	if(m_eff_effect.GetCheck()) temp = 3;
	cart->ROM[offset + 4] = temp;
}

void CAttack::ChangeEffect(bool eff)
{
	m_eff_damage.SetCheck(!eff);
	m_damagetext.ShowWindow(!eff);
	m_damage.ShowWindow(!eff);
	m_effectbox.ShowWindow(eff);
	m_eff_effect.SetCheck(eff);
	m_eff1.ShowWindow(eff);
	m_eff2.ShowWindow(eff);
	m_eff3.ShowWindow(eff);
	m_eff4.ShowWindow(eff);
	m_eff5.ShowWindow(eff);
}

void CAttack::OnEffDamage() 
{ChangeEffect(0);}

void CAttack::OnEffEffect() 
{ChangeEffect(1);}

void CAttack::OnSave() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
}

void CAttack::OnOK() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
	else
		CDialog::OnOK();
}

void CAttack::OnCancel()
{
	ReLoadROM(cart);
	CDialog::OnCancel();
}
