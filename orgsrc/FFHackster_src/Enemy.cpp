// Enemy.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "Enemy.h"
#include "BattlePatternTables.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CEnemy dialog


CEnemy::CEnemy(CWnd* pParent /*=NULL*/)
	: CDialog(CEnemy::IDD, pParent)
{
	//{{AFX_DATA_INIT(CEnemy)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void CEnemy::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CEnemy)
	DDX_Control(pDX, IDC_EDITLABEL, m_editlabel);
	DDX_Control(pDX, IDC_WEAK8, m_weak8);
	DDX_Control(pDX, IDC_WEAK7, m_weak7);
	DDX_Control(pDX, IDC_WEAK6, m_weak6);
	DDX_Control(pDX, IDC_WEAK5, m_weak5);
	DDX_Control(pDX, IDC_WEAK4, m_weak4);
	DDX_Control(pDX, IDC_WEAK3, m_weak3);
	DDX_Control(pDX, IDC_WEAK2, m_weak2);
	DDX_Control(pDX, IDC_WEAK1, m_weak1);
	DDX_Control(pDX, IDC_UNKNOWN, m_unknown);
	DDX_Control(pDX, IDC_STR, m_str);
	DDX_Control(pDX, IDC_RES8, m_res8);
	DDX_Control(pDX, IDC_RES7, m_res7);
	DDX_Control(pDX, IDC_RES6, m_res6);
	DDX_Control(pDX, IDC_RES5, m_res5);
	DDX_Control(pDX, IDC_RES4, m_res4);
	DDX_Control(pDX, IDC_RES3, m_res3);
	DDX_Control(pDX, IDC_RES2, m_res2);
	DDX_Control(pDX, IDC_RES1, m_res1);
	DDX_Control(pDX, IDC_MORALE, m_morale);
	DDX_Control(pDX, IDC_MAGDEF, m_magdef);
	DDX_Control(pDX, IDC_HP, m_hp);
	DDX_Control(pDX, IDC_HITS, m_hits);
	DDX_Control(pDX, IDC_HITPCT, m_hit);
	DDX_Control(pDX, IDC_GOLD, m_gold);
	DDX_Control(pDX, IDC_EXP, m_exp);
	DDX_Control(pDX, IDC_ENEMYLIST, m_enemylist);
	DDX_Control(pDX, IDC_EFF5, m_eff5);
	DDX_Control(pDX, IDC_EFF4, m_eff4);
	DDX_Control(pDX, IDC_EFF3, m_eff3);
	DDX_Control(pDX, IDC_EFF2, m_eff2);
	DDX_Control(pDX, IDC_EFF1, m_eff1);
	DDX_Control(pDX, IDC_DEF, m_def);
	DDX_Control(pDX, IDC_CRITICAL, m_critical);
	DDX_Control(pDX, IDC_CAT8, m_cat8);
	DDX_Control(pDX, IDC_CAT7, m_cat7);
	DDX_Control(pDX, IDC_CAT6, m_cat6);
	DDX_Control(pDX, IDC_CAT5, m_cat5);
	DDX_Control(pDX, IDC_CAT4, m_cat4);
	DDX_Control(pDX, IDC_CAT3, m_cat3);
	DDX_Control(pDX, IDC_CAT2, m_cat2);
	DDX_Control(pDX, IDC_CAT1, m_cat1);
	DDX_Control(pDX, IDC_AI_MAGICRATE, m_ai_magicrate);
	DDX_Control(pDX, IDC_AI_MAGIC8, m_ai_magic8);
	DDX_Control(pDX, IDC_AI_MAGIC7, m_ai_magic7);
	DDX_Control(pDX, IDC_AI_MAGIC6, m_ai_magic6);
	DDX_Control(pDX, IDC_AI_MAGIC5, m_ai_magic5);
	DDX_Control(pDX, IDC_AI_MAGIC4, m_ai_magic4);
	DDX_Control(pDX, IDC_AI_MAGIC3, m_ai_magic3);
	DDX_Control(pDX, IDC_AI_MAGIC2, m_ai_magic2);
	DDX_Control(pDX, IDC_AI_MAGIC1, m_ai_magic1);
	DDX_Control(pDX, IDC_AI_ABILITYRATE, m_ai_abilityrate);
	DDX_Control(pDX, IDC_AI_ABILITY4, m_ai_ability4);
	DDX_Control(pDX, IDC_AI_ABILITY3, m_ai_ability3);
	DDX_Control(pDX, IDC_AI_ABILITY2, m_ai_ability2);
	DDX_Control(pDX, IDC_AI_ABILITY1, m_ai_ability1);
	DDX_Control(pDX, IDC_AI, m_ai);
	DDX_Control(pDX, IDC_AGILITY, m_agility);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CEnemy, CDialog)
	//{{AFX_MSG_MAP(CEnemy)
	ON_LBN_SELCHANGE(IDC_ENEMYLIST, OnSelchangeEnemylist)
	ON_CBN_SELCHANGE(IDC_AI, OnSelchangeAi)
	ON_BN_CLICKED(IDC_EDITLABEL, OnEditlabel)
	ON_BN_CLICKED(IDC_SAVE, OnSave)
	ON_BN_CLICKED(IDC_EDITPIC, OnEditpic)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CEnemy message handlers

BOOL CEnemy::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	if(!ReLoadROM(cart)){
		CDialog::OnCancel();
		return 0;}
	
	PutHexToList(cart,ENEMYTEXT_OFFSET,ENEMYTEXT_PTRADD,ENEMY_COUNT,cart->dat.TextViewInDTE[7],&m_enemylist,NULL);
	PutHexToList(cart,MAGICTEXT_OFFSET,BASICTEXT_PTRADD,MAGIC_COUNT,cart->dat.TextViewInDTE[4],NULL,&m_ai_magic1);
	PutHexToList(cart,MAGICTEXT_OFFSET,BASICTEXT_PTRADD,MAGIC_COUNT,cart->dat.TextViewInDTE[4],NULL,&m_ai_magic2);
	PutHexToList(cart,MAGICTEXT_OFFSET,BASICTEXT_PTRADD,MAGIC_COUNT,cart->dat.TextViewInDTE[4],NULL,&m_ai_magic3);
	PutHexToList(cart,MAGICTEXT_OFFSET,BASICTEXT_PTRADD,MAGIC_COUNT,cart->dat.TextViewInDTE[4],NULL,&m_ai_magic4);
	PutHexToList(cart,MAGICTEXT_OFFSET,BASICTEXT_PTRADD,MAGIC_COUNT,cart->dat.TextViewInDTE[4],NULL,&m_ai_magic5);
	PutHexToList(cart,MAGICTEXT_OFFSET,BASICTEXT_PTRADD,MAGIC_COUNT,cart->dat.TextViewInDTE[4],NULL,&m_ai_magic6);
	PutHexToList(cart,MAGICTEXT_OFFSET,BASICTEXT_PTRADD,MAGIC_COUNT,cart->dat.TextViewInDTE[4],NULL,&m_ai_magic7);
	PutHexToList(cart,MAGICTEXT_OFFSET,BASICTEXT_PTRADD,MAGIC_COUNT,cart->dat.TextViewInDTE[4],NULL,&m_ai_magic8);
	PutHexToList(cart,ATTACKTEXT_OFFSET,ATTACKTEXT_PTRADD,ATTACK_COUNT,cart->dat.TextViewInDTE[6],NULL,&m_ai_ability1);
	PutHexToList(cart,ATTACKTEXT_OFFSET,ATTACKTEXT_PTRADD,ATTACK_COUNT,cart->dat.TextViewInDTE[6],NULL,&m_ai_ability2);
	PutHexToList(cart,ATTACKTEXT_OFFSET,ATTACKTEXT_PTRADD,ATTACK_COUNT,cart->dat.TextViewInDTE[6],NULL,&m_ai_ability3);
	PutHexToList(cart,ATTACKTEXT_OFFSET,ATTACKTEXT_PTRADD,ATTACK_COUNT,cart->dat.TextViewInDTE[6],NULL,&m_ai_ability4);
	for(int co = 0; co < AI_COUNT; co++)
		m_ai.InsertString(co,cart->dat.AILabels[co]);
	m_ai.InsertString(0,"--none--");
	m_ai_magic1.InsertString(0,"--none--");
	m_ai_magic2.InsertString(0,"--none--");
	m_ai_magic3.InsertString(0,"--none--");
	m_ai_magic4.InsertString(0,"--none--");
	m_ai_magic5.InsertString(0,"--none--");
	m_ai_magic6.InsertString(0,"--none--");
	m_ai_magic7.InsertString(0,"--none--");
	m_ai_magic8.InsertString(0,"--none--");
	m_ai_ability1.InsertString(0,"--none--");
	m_ai_ability2.InsertString(0,"--none--");
	m_ai_ability3.InsertString(0,"--none--");
	m_ai_ability4.InsertString(0,"--none--");

	cur = -1;
	m_enemylist.SetCurSel(0);
	OnSelchangeEnemylist();

	return 1;
}

void CEnemy::OnSelchangeEnemylist() 
{
	if(cur != -1) StoreValues();

	cur = m_enemylist.GetCurSel();

	LoadValues();
}

void CEnemy::LoadValues()
{
	int offset = ENEMY_OFFSET + (cur * ENEMY_BYTES);
	int temp;
	CString text;

	temp = cart->ROM[offset] + (cart->ROM[offset + 1] << 8);
	text.Format("%d",temp);
	m_exp.SetWindowText(text);

	temp = cart->ROM[offset + 2] + (cart->ROM[offset + 3] << 8);
	text.Format("%d",temp);
	m_gold.SetWindowText(text);

	temp = cart->ROM[offset + 4] + (cart->ROM[offset + 5] << 8);
	text.Format("%d",temp);
	m_hp.SetWindowText(text);

	text.Format("%d",cart->ROM[offset + 6]);
	m_morale.SetWindowText(text);

	cur_ai = (cart->ROM[offset + 7] + 1) & 0xFF;
	m_ai.SetCurSel(cur_ai);
	LoadAI();

	text.Format("%d",cart->ROM[offset + 8]);
	m_agility.SetWindowText(text);

	text.Format("%d",cart->ROM[offset + 9]);
	m_def.SetWindowText(text);
	
	text.Format("%d",cart->ROM[offset + 10]);
	m_hits.SetWindowText(text);
	
	text.Format("%d",cart->ROM[offset + 11]);
	m_hit.SetWindowText(text);
	
	text.Format("%d",cart->ROM[offset + 12]);
	m_str.SetWindowText(text);
	
	text.Format("%d",cart->ROM[offset + 13]);
	m_critical.SetWindowText(text);
	
	text.Format("%X",cart->ROM[offset + 14]);
	if(text.GetLength() == 1) text = "0" + text;
	m_unknown.SetWindowText(text);

	temp = cart->ROM[offset + 15];
	m_eff1.SetCheck(temp & 0x01);
	m_eff2.SetCheck(temp & 0x02);
	m_eff3.SetCheck(temp & 0x04);
	m_eff4.SetCheck(temp & 0x08);
	m_eff5.SetCheck(temp & 0x10);
	
	temp = cart->ROM[offset + 16];
	m_cat1.SetCheck(temp & 0x01);
	m_cat2.SetCheck(temp & 0x02);
	m_cat3.SetCheck(temp & 0x04);
	m_cat4.SetCheck(temp & 0x08);
	m_cat5.SetCheck(temp & 0x10);
	m_cat6.SetCheck(temp & 0x20);
	m_cat7.SetCheck(temp & 0x40);
	m_cat8.SetCheck(temp & 0x80);
	
	text.Format("%d",cart->ROM[offset + 17]);
	m_magdef.SetWindowText(text);
	
	temp = cart->ROM[offset + 18];
	m_weak1.SetCheck(temp & 0x01);
	m_weak2.SetCheck(temp & 0x02);
	m_weak3.SetCheck(temp & 0x04);
	m_weak4.SetCheck(temp & 0x08);
	m_weak5.SetCheck(temp & 0x10);
	m_weak6.SetCheck(temp & 0x20);
	m_weak7.SetCheck(temp & 0x40);
	m_weak8.SetCheck(temp & 0x80);
	
	temp = cart->ROM[offset + 19];
	m_res1.SetCheck(temp & 0x01);
	m_res2.SetCheck(temp & 0x02);
	m_res3.SetCheck(temp & 0x04);
	m_res4.SetCheck(temp & 0x08);
	m_res5.SetCheck(temp & 0x10);
	m_res6.SetCheck(temp & 0x20);
	m_res7.SetCheck(temp & 0x40);
	m_res8.SetCheck(temp & 0x80);
}

void CEnemy::StoreValues()
{
	if(m_ai.GetCurSel()) StoreAI();

	int offset = ENEMY_OFFSET + (cur * ENEMY_BYTES);
	int temp;
	CString text;

	m_exp.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFFFF) temp = 0xFFFF;
	cart->ROM[offset] = temp & 0xFF; cart->ROM[offset + 1] = temp >> 8;

	m_gold.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFFFF) temp = 0xFFFF;
	cart->ROM[offset + 2] = temp & 0xFF; cart->ROM[offset + 3] = temp >> 8;

	m_hp.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFFFF) temp = 0xFFFF;
	cart->ROM[offset + 4] = temp & 0xFF; cart->ROM[offset + 5] = temp >> 8;

	m_morale.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 6] = temp;

	temp = m_ai.GetCurSel(); if(!temp) temp = 0x100;
	cart->ROM[offset + 7] = temp - 1;

	m_agility.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 8] = temp;

	m_def.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 9] = temp;

	m_hits.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 10] = temp;

	m_hit.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 11] = temp;

	m_str.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 12] = temp;

	m_critical.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 13] = temp;

	m_unknown.GetWindowText(text); temp = StringToInt_HEX(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 14] = temp;

	temp = 0;
	if(m_eff1.GetCheck()) temp |= 0x01;
	if(m_eff2.GetCheck()) temp |= 0x02;
	if(m_eff3.GetCheck()) temp |= 0x04;
	if(m_eff4.GetCheck()) temp |= 0x08;
	if(m_eff5.GetCheck()) temp |= 0x10;
	cart->ROM[offset + 15] = temp;
	
	temp = 0;
	if(m_cat1.GetCheck()) temp |= 0x01;
	if(m_cat2.GetCheck()) temp |= 0x02;
	if(m_cat3.GetCheck()) temp |= 0x04;
	if(m_cat4.GetCheck()) temp |= 0x08;
	if(m_cat5.GetCheck()) temp |= 0x10;
	if(m_cat6.GetCheck()) temp |= 0x20;
	if(m_cat7.GetCheck()) temp |= 0x40;
	if(m_cat8.GetCheck()) temp |= 0x80;
	cart->ROM[offset + 16] = temp;

	m_magdef.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 17] = temp;

	temp = 0;
	if(m_weak1.GetCheck()) temp |= 0x01;
	if(m_weak2.GetCheck()) temp |= 0x02;
	if(m_weak3.GetCheck()) temp |= 0x04;
	if(m_weak4.GetCheck()) temp |= 0x08;
	if(m_weak5.GetCheck()) temp |= 0x10;
	if(m_weak6.GetCheck()) temp |= 0x20;
	if(m_weak7.GetCheck()) temp |= 0x40;
	if(m_weak8.GetCheck()) temp |= 0x80;
	cart->ROM[offset + 18] = temp;

	temp = 0;
	if(m_res1.GetCheck()) temp |= 0x01;
	if(m_res2.GetCheck()) temp |= 0x02;
	if(m_res3.GetCheck()) temp |= 0x04;
	if(m_res4.GetCheck()) temp |= 0x08;
	if(m_res5.GetCheck()) temp |= 0x10;
	if(m_res6.GetCheck()) temp |= 0x20;
	if(m_res7.GetCheck()) temp |= 0x40;
	if(m_res8.GetCheck()) temp |= 0x80;
	cart->ROM[offset + 19] = temp;
}

void CEnemy::LoadAI()
{
	m_ai_magicrate.EnableWindow(cur_ai);
	m_ai_magic1.EnableWindow(cur_ai);
	m_ai_magic2.EnableWindow(cur_ai);
	m_ai_magic3.EnableWindow(cur_ai);
	m_ai_magic4.EnableWindow(cur_ai);
	m_ai_magic5.EnableWindow(cur_ai);
	m_ai_magic6.EnableWindow(cur_ai);
	m_ai_magic7.EnableWindow(cur_ai);
	m_ai_magic8.EnableWindow(cur_ai);
	m_ai_abilityrate.EnableWindow(cur_ai);
	m_ai_ability1.EnableWindow(cur_ai);
	m_ai_ability2.EnableWindow(cur_ai);
	m_ai_ability3.EnableWindow(cur_ai);
	m_ai_ability4.EnableWindow(cur_ai);
	m_editlabel.EnableWindow(cur_ai);

	CString text = "";
	if(!cur_ai){
		m_ai_magicrate.SetWindowText(text);
		m_ai_abilityrate.SetWindowText(text);
		m_ai_magic1.SetCurSel(0);
		m_ai_magic2.SetCurSel(0);
		m_ai_magic3.SetCurSel(0);
		m_ai_magic4.SetCurSel(0);
		m_ai_magic5.SetCurSel(0);
		m_ai_magic6.SetCurSel(0);
		m_ai_magic7.SetCurSel(0);
		m_ai_magic8.SetCurSel(0);
		m_ai_ability1.SetCurSel(0);
		m_ai_ability2.SetCurSel(0);
		m_ai_ability3.SetCurSel(0);
		m_ai_ability4.SetCurSel(0);
		return;}

	int ref = AI_OFFSET + ((cur_ai - 1) << 4);

	text.Format("%d",cart->ROM[ref]);
	m_ai_magicrate.SetWindowText(text);
	
	text.Format("%d",cart->ROM[ref + 1]);
	m_ai_abilityrate.SetWindowText(text);

	m_ai_magic1.SetCurSel((cart->ROM[ref + 2] + 1) & 0xFF);
	m_ai_magic2.SetCurSel((cart->ROM[ref + 3] + 1) & 0xFF);
	m_ai_magic3.SetCurSel((cart->ROM[ref + 4] + 1) & 0xFF);
	m_ai_magic4.SetCurSel((cart->ROM[ref + 5] + 1) & 0xFF);
	m_ai_magic5.SetCurSel((cart->ROM[ref + 6] + 1) & 0xFF);
	m_ai_magic6.SetCurSel((cart->ROM[ref + 7] + 1) & 0xFF);
	m_ai_magic7.SetCurSel((cart->ROM[ref + 8] + 1) & 0xFF);
	m_ai_magic8.SetCurSel((cart->ROM[ref + 9] + 1) & 0xFF);

	m_ai_ability1.SetCurSel((cart->ROM[ref + 11] + 1) & 0xFF);
	m_ai_ability2.SetCurSel((cart->ROM[ref + 12] + 1) & 0xFF);
	m_ai_ability3.SetCurSel((cart->ROM[ref + 13] + 1) & 0xFF);
	m_ai_ability4.SetCurSel((cart->ROM[ref + 14] + 1) & 0xFF);
}

void CEnemy::StoreAI()
{
	int ref = AI_OFFSET + ((cur_ai - 1) << 4);
	CString text;
	int temp;

	m_ai_magicrate.GetWindowText(text);
	temp = StringToInt(text); if(temp > 0xFF) temp = 0xFF;
	cart->ROM[ref] = temp;

	m_ai_abilityrate.GetWindowText(text);
	temp = StringToInt(text); if(temp > 0xFF) temp = 0xFF;
	cart->ROM[ref + 1] = temp;

	temp = m_ai_magic1.GetCurSel();
	if(temp) cart->ROM[ref + 2] = temp - 1;
	else cart->ROM[ref + 2] = 0xFF;
	temp = m_ai_magic2.GetCurSel();
	if(temp) cart->ROM[ref + 3] = temp - 1;
	else cart->ROM[ref + 3] = 0xFF;
	temp = m_ai_magic3.GetCurSel();
	if(temp) cart->ROM[ref + 4] = temp - 1;
	else cart->ROM[ref + 4] = 0xFF;
	temp = m_ai_magic4.GetCurSel();
	if(temp) cart->ROM[ref + 5] = temp - 1;
	else cart->ROM[ref + 5] = 0xFF;
	temp = m_ai_magic5.GetCurSel();
	if(temp) cart->ROM[ref + 6] = temp - 1;
	else cart->ROM[ref + 6] = 0xFF;
	temp = m_ai_magic6.GetCurSel();
	if(temp) cart->ROM[ref + 7] = temp - 1;
	else cart->ROM[ref + 7] = 0xFF;
	temp = m_ai_magic7.GetCurSel();
	if(temp) cart->ROM[ref + 8] = temp - 1;
	else cart->ROM[ref + 8] = 0xFF;
	temp = m_ai_magic8.GetCurSel();
	if(temp) cart->ROM[ref + 9] = temp - 1;
	else cart->ROM[ref + 9] = 0xFF;

	temp = m_ai_ability1.GetCurSel();
	if(temp) cart->ROM[ref + 11] = temp - 1;
	else cart->ROM[ref + 11] = 0xFF;
	temp = m_ai_ability2.GetCurSel();
	if(temp) cart->ROM[ref + 12] = temp - 1;
	else cart->ROM[ref + 12] = 0xFF;
	temp = m_ai_ability3.GetCurSel();
	if(temp) cart->ROM[ref + 13] = temp - 1;
	else cart->ROM[ref + 13] = 0xFF;
	temp = m_ai_ability4.GetCurSel();
	if(temp) cart->ROM[ref + 14] = temp - 1;
	else cart->ROM[ref + 14] = 0xFF;
}

void CEnemy::OnSelchangeAi() 
{
	if(cur_ai > 0) StoreAI();

	cur_ai = m_ai.GetCurSel();

	LoadAI();
}

void CEnemy::OnEditlabel() 
{
	int temp = m_ai.GetCurSel();
	ChangeLabel(AILABEL_SIZE,cart->dat.AILabels[temp - 1],temp,NULL,&m_ai);
}

void CEnemy::OnSave() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
}

void CEnemy::OnOK() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
	else
		CDialog::OnOK();
}

void CEnemy::OnCancel() 
{
	ReLoadROM(cart);
	CDialog::OnCancel();
}

void CEnemy::OnEditpic() 
{
	OnSave();
	BYTE temp;
	BYTE battle = 0;
	BYTE pal[2];
	BYTE graphic;
	BYTE enref = 0xFF;
	BYTE battletype;
	int en = m_enemylist.GetCurSel();
	int co;
	for(co = BATTLE_OFFSET; battle < 0x80; co += 0x10, battle++){
		for(temp = 2; temp < 6; temp++){
			if(cart->ROM[co + temp] == en){
				enref = temp - 2;
				break;}}
		if(enref != 0xFF) break;}

	if(enref == 0xFF){
		AfxMessageBox("Enemy is not placed in any battles.\nCould not find enemy pic");
		return;}

	battletype = cart->ROM[co] >> 4;
	if(battletype < 3) battletype = 0;
	else if(battletype == 4) battletype = 5;
	else battletype = ((cart->ROM[co + 1] >> (enref << 1)) & 3) + 1;
	

	graphic = cart->ROM[co] & 0x0F;
	pal[0] = cart->ROM[co + 10];
	pal[1] = cart->ROM[co + 11];
	if(!battletype){
		if((cart->ROM[co + 13] >> (7 - enref)) & 1)
			pal[0] = pal[1];
		else
			pal[1] = pal[0];}

	CBattlePatternTables dlg;
	dlg.cart = cart;
	dlg.patterntable = graphic;
	dlg.palvalues[0] = pal[0];
	dlg.palvalues[1] = pal[1];
	dlg.view = battletype;

	dlg.DoModal();
}
