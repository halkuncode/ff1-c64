// Classes.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "Classes.h"
#include "BattlePic.h"
#include "Mapman.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CClasses dialog


CClasses::CClasses(CWnd* pParent /*=NULL*/)
	: CDialog(CClasses::IDD, pParent)
{
	//{{AFX_DATA_INIT(CClasses)
	//}}AFX_DATA_INIT
}


void CClasses::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CClasses)
	DDX_Control(pDX, IDC_HITPCTUP, m_hitpctup);
	DDX_Control(pDX, IDC_MEAN, m_mean);
	DDX_Control(pDX, IDC_VIT4, m_vit4);
	DDX_Control(pDX, IDC_VIT2, m_vit2);
	DDX_Control(pDX, IDC_VIT3, m_vit3);
	DDX_Control(pDX, IDC_VIT1, m_vit1);
	DDX_Control(pDX, IDC_TOTALVIT4, m_totalvit4);
	DDX_Control(pDX, IDC_TOTALVIT3, m_totalvit3);
	DDX_Control(pDX, IDC_TOTALVIT2, m_totalvit2);
	DDX_Control(pDX, IDC_TOTALVIT1, m_totalvit1);
	DDX_Control(pDX, IDC_TOTALSTR4, m_totalstr4);
	DDX_Control(pDX, IDC_TOTALSTR3, m_totalstr3);
	DDX_Control(pDX, IDC_TOTALSTR2, m_totalstr2);
	DDX_Control(pDX, IDC_TOTALSTR1, m_totalstr1);
	DDX_Control(pDX, IDC_TOTALMAG4, m_totalmag4);
	DDX_Control(pDX, IDC_TOTALMAG3, m_totalmag3);
	DDX_Control(pDX, IDC_TOTALMAG2, m_totalmag2);
	DDX_Control(pDX, IDC_TOTALMAG1, m_totalmag1);
	DDX_Control(pDX, IDC_TOTALLUC4, m_totalluc4);
	DDX_Control(pDX, IDC_TOTALLUC3, m_totalluc3);
	DDX_Control(pDX, IDC_TOTALLUC2, m_totalluc2);
	DDX_Control(pDX, IDC_TOTALLUC1, m_totalluc1);
	DDX_Control(pDX, IDC_TOTALINT4, m_totalint4);
	DDX_Control(pDX, IDC_TOTALINT3, m_totalint3);
	DDX_Control(pDX, IDC_TOTALINT2, m_totalint2);
	DDX_Control(pDX, IDC_TOTALINT1, m_totalint1);
	DDX_Control(pDX, IDC_TOTALHP4, m_totalhp4);
	DDX_Control(pDX, IDC_TOTALHP3, m_totalhp3);
	DDX_Control(pDX, IDC_TOTALHP2, m_totalhp2);
	DDX_Control(pDX, IDC_TOTALHP1, m_totalhp1);
	DDX_Control(pDX, IDC_TOTALAGI4, m_totalagi4);
	DDX_Control(pDX, IDC_TOTALAGI3, m_totalagi3);
	DDX_Control(pDX, IDC_TOTALAGI2, m_totalagi2);
	DDX_Control(pDX, IDC_TOTALAGI1, m_totalagi1);
	DDX_Control(pDX, IDC_STRONG4, m_strong4);
	DDX_Control(pDX, IDC_STRONG3, m_strong3);
	DDX_Control(pDX, IDC_STRONG2, m_strong2);
	DDX_Control(pDX, IDC_STRONG1, m_strong1);
	DDX_Control(pDX, IDC_STR4, m_str4);
	DDX_Control(pDX, IDC_STR3, m_str3);
	DDX_Control(pDX, IDC_STR2, m_str2);
	DDX_Control(pDX, IDC_STR1, m_str1);
	DDX_Control(pDX, IDC_SCROLL, m_scroll);
	DDX_Control(pDX, IDC_MIN, m_min);
	DDX_Control(pDX, IDC_MAX, m_max);
	DDX_Control(pDX, IDC_MAGICRANGEMIN, m_magicrangemin);
	DDX_Control(pDX, IDC_MAGICRANGEMAX, m_magicrangemax);
	DDX_Control(pDX, IDC_MAGIC, m_magic);
	DDX_Control(pDX, IDC_LUC4, m_luc4);
	DDX_Control(pDX, IDC_LUC3, m_luc3);
	DDX_Control(pDX, IDC_LUC2, m_luc2);
	DDX_Control(pDX, IDC_LUC1, m_luc1);
	DDX_Control(pDX, IDC_LEVEL4, m_level4);
	DDX_Control(pDX, IDC_LEVEL3, m_level3);
	DDX_Control(pDX, IDC_LEVEL2, m_level2);
	DDX_Control(pDX, IDC_LEVEL1, m_level1);
	DDX_Control(pDX, IDC_INT4, m_int4);
	DDX_Control(pDX, IDC_INT3, m_int3);
	DDX_Control(pDX, IDC_INT2, m_int2);
	DDX_Control(pDX, IDC_INT1, m_int1);
	DDX_Control(pDX, IDC_HPRANGEMIN, m_hprangemin);
	DDX_Control(pDX, IDC_HPRANGEMAX, m_hprangemax);
	DDX_Control(pDX, IDC_EXP4, m_exp4);
	DDX_Control(pDX, IDC_EXP3, m_exp3);
	DDX_Control(pDX, IDC_EXP2, m_exp2);
	DDX_Control(pDX, IDC_EXP1, m_exp1);
	DDX_Control(pDX, IDC_CLASS2, m_class2);
	DDX_Control(pDX, IDC_CLASS1, m_class1);
	DDX_Control(pDX, IDC_AGI4, m_agi4);
	DDX_Control(pDX, IDC_AGI3, m_agi3);
	DDX_Control(pDX, IDC_AGI2, m_agi2);
	DDX_Control(pDX, IDC_AGI1, m_agi1);
	DDX_Control(pDX, IDC_8M4, m_8m4);
	DDX_Control(pDX, IDC_8M3, m_8m3);
	DDX_Control(pDX, IDC_8M2, m_8m2);
	DDX_Control(pDX, IDC_8M1, m_8m1);
	DDX_Control(pDX, IDC_7M4, m_7m4);
	DDX_Control(pDX, IDC_7M3, m_7m3);
	DDX_Control(pDX, IDC_7M2, m_7m2);
	DDX_Control(pDX, IDC_7M1, m_7m1);
	DDX_Control(pDX, IDC_6M4, m_6m4);
	DDX_Control(pDX, IDC_6M3, m_6m3);
	DDX_Control(pDX, IDC_6M2, m_6m2);
	DDX_Control(pDX, IDC_6M1, m_6m1);
	DDX_Control(pDX, IDC_5M4, m_5m4);
	DDX_Control(pDX, IDC_5M3, m_5m3);
	DDX_Control(pDX, IDC_5M2, m_5m2);
	DDX_Control(pDX, IDC_5M1, m_5m1);
	DDX_Control(pDX, IDC_4M4, m_4m4);
	DDX_Control(pDX, IDC_4M3, m_4m3);
	DDX_Control(pDX, IDC_4M2, m_4m2);
	DDX_Control(pDX, IDC_4M1, m_4m1);
	DDX_Control(pDX, IDC_3M4, m_3m4);
	DDX_Control(pDX, IDC_3M3, m_3m3);
	DDX_Control(pDX, IDC_3M2, m_3m2);
	DDX_Control(pDX, IDC_3M1, m_3m1);
	DDX_Control(pDX, IDC_2M4, m_2m4);
	DDX_Control(pDX, IDC_2M3, m_2m3);
	DDX_Control(pDX, IDC_2M2, m_2m2);
	DDX_Control(pDX, IDC_2M1, m_2m1);
	DDX_Control(pDX, IDC_1M4, m_1m4);
	DDX_Control(pDX, IDC_1M3, m_1m3);
	DDX_Control(pDX, IDC_1M2, m_1m2);
	DDX_Control(pDX, IDC_1M1, m_1m1);
	DDX_Control(pDX, IDC_VIT, m_vit);
	DDX_Control(pDX, IDC_UNKNOWN, m_unknown);
	DDX_Control(pDX, IDC_STR, m_str);
	DDX_Control(pDX, IDC_STARTINGHP, m_startinghp);
	DDX_Control(pDX, IDC_MAGDEF, m_magdef);
	DDX_Control(pDX, IDC_LUCK, m_luck);
	DDX_Control(pDX, IDC_INT, m_int);
	DDX_Control(pDX, IDC_HIT, m_hit);
	DDX_Control(pDX, IDC_EVADEPCT, m_evade);
	DDX_Control(pDX, IDC_CLASSLIST, m_classlist);
	DDX_Control(pDX, IDC_BASEDAMAGE, m_damage);
	DDX_Control(pDX, IDC_AGILITY, m_agility);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CClasses, CDialog)
	//{{AFX_MSG_MAP(CClasses)
	ON_LBN_SELCHANGE(IDC_CLASSLIST, OnSelchangeClasslist)
	ON_WM_VSCROLL()
	ON_BN_CLICKED(IDC_MAX, OnMax)
	ON_BN_CLICKED(IDC_MIN, OnMin)
	ON_EN_CHANGE(IDC_STARTINGHP, RecalculateRunningTotals)
	ON_EN_CHANGE(IDC_HPRANGEMAX, OnChangeHprangemax)
	ON_EN_CHANGE(IDC_HPRANGEMIN, OnChangeHprangemin)
	ON_BN_CLICKED(IDC_1M1, OnCheckBox)
	ON_BN_CLICKED(IDC_SAVE, OnSave)
	ON_BN_CLICKED(IDC_MEAN, OnMean)
	ON_BN_CLICKED(IDC_BATTLEPIC, OnBattlepic)
	ON_EN_CHANGE(IDC_STR, RecalculateRunningTotals)
	ON_EN_CHANGE(IDC_VIT, RecalculateRunningTotals)
	ON_EN_CHANGE(IDC_AGILITY, RecalculateRunningTotals)
	ON_EN_CHANGE(IDC_LUCK, RecalculateRunningTotals)
	ON_EN_CHANGE(IDC_INT, RecalculateRunningTotals)
	ON_EN_CHANGE(IDC_MAGIC, RecalculateRunningTotals)
	ON_EN_CHANGE(IDC_MAGICRANGEMAX, RecalculateRunningTotals)
	ON_EN_CHANGE(IDC_MAGICRANGEMIN, RecalculateRunningTotals)
	ON_BN_CLICKED(IDC_1M2, OnCheckBox)
	ON_BN_CLICKED(IDC_1M3, OnCheckBox)
	ON_BN_CLICKED(IDC_1M4, OnCheckBox)
	ON_BN_CLICKED(IDC_2M1, OnCheckBox)
	ON_BN_CLICKED(IDC_2M2, OnCheckBox)
	ON_BN_CLICKED(IDC_2M3, OnCheckBox)
	ON_BN_CLICKED(IDC_2M4, OnCheckBox)
	ON_BN_CLICKED(IDC_3M1, OnCheckBox)
	ON_BN_CLICKED(IDC_3M2, OnCheckBox)
	ON_BN_CLICKED(IDC_3M3, OnCheckBox)
	ON_BN_CLICKED(IDC_3M4, OnCheckBox)
	ON_BN_CLICKED(IDC_4M1, OnCheckBox)
	ON_BN_CLICKED(IDC_4M2, OnCheckBox)
	ON_BN_CLICKED(IDC_4M3, OnCheckBox)
	ON_BN_CLICKED(IDC_4M4, OnCheckBox)
	ON_BN_CLICKED(IDC_5M1, OnCheckBox)
	ON_BN_CLICKED(IDC_5M2, OnCheckBox)
	ON_BN_CLICKED(IDC_5M3, OnCheckBox)
	ON_BN_CLICKED(IDC_5M4, OnCheckBox)
	ON_BN_CLICKED(IDC_6M1, OnCheckBox)
	ON_BN_CLICKED(IDC_6M2, OnCheckBox)
	ON_BN_CLICKED(IDC_6M3, OnCheckBox)
	ON_BN_CLICKED(IDC_6M4, OnCheckBox)
	ON_BN_CLICKED(IDC_7M1, OnCheckBox)
	ON_BN_CLICKED(IDC_7M2, OnCheckBox)
	ON_BN_CLICKED(IDC_7M3, OnCheckBox)
	ON_BN_CLICKED(IDC_7M4, OnCheckBox)
	ON_BN_CLICKED(IDC_8M1, OnCheckBox)
	ON_BN_CLICKED(IDC_8M2, OnCheckBox)
	ON_BN_CLICKED(IDC_8M3, OnCheckBox)
	ON_BN_CLICKED(IDC_8M4, OnCheckBox)
	ON_BN_CLICKED(IDC_AGI1, OnCheckBox)
	ON_BN_CLICKED(IDC_AGI2, OnCheckBox)
	ON_BN_CLICKED(IDC_AGI3, OnCheckBox)
	ON_BN_CLICKED(IDC_AGI4, OnCheckBox)
	ON_BN_CLICKED(IDC_STR1, OnCheckBox)
	ON_BN_CLICKED(IDC_STR2, OnCheckBox)
	ON_BN_CLICKED(IDC_STR3, OnCheckBox)
	ON_BN_CLICKED(IDC_STR4, OnCheckBox)
	ON_BN_CLICKED(IDC_INT1, OnCheckBox)
	ON_BN_CLICKED(IDC_INT2, OnCheckBox)
	ON_BN_CLICKED(IDC_INT3, OnCheckBox)
	ON_BN_CLICKED(IDC_INT4, OnCheckBox)
	ON_BN_CLICKED(IDC_LUC1, OnCheckBox)
	ON_BN_CLICKED(IDC_LUC2, OnCheckBox)
	ON_BN_CLICKED(IDC_LUC3, OnCheckBox)
	ON_BN_CLICKED(IDC_LUC4, OnCheckBox)
	ON_BN_CLICKED(IDC_VIT1, OnCheckBox)
	ON_BN_CLICKED(IDC_VIT2, OnCheckBox)
	ON_BN_CLICKED(IDC_VIT3, OnCheckBox)
	ON_BN_CLICKED(IDC_VIT4, OnCheckBox)
	ON_BN_CLICKED(IDC_STRONG1, OnCheckBox)
	ON_BN_CLICKED(IDC_STRONG2, OnCheckBox)
	ON_BN_CLICKED(IDC_STRONG3, OnCheckBox)
	ON_BN_CLICKED(IDC_STRONG4, OnCheckBox)
	ON_BN_CLICKED(IDC_MAPMANPIC, OnMapmanpic)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CClasses message handlers

BOOL CClasses::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	if(!ReLoadROM(cart)){
		CDialog::OnCancel();
		return 0;}
	
	ar_1m[0] = &m_1m1;ar_1m[1] = &m_1m2;ar_1m[2] = &m_1m3;ar_1m[3] = &m_1m4;ar_2m[0] = &m_2m1;
	ar_2m[1] = &m_2m2;ar_2m[2] = &m_2m3;ar_2m[3] = &m_2m4;ar_3m[0] = &m_3m1;ar_3m[1] = &m_3m2;
	ar_3m[2] = &m_3m3;ar_3m[3] = &m_3m4;ar_4m[0] = &m_4m1;ar_4m[1] = &m_4m2;ar_4m[2] = &m_4m3;
	ar_4m[3] = &m_4m4;ar_5m[0] = &m_5m1;ar_5m[1] = &m_5m2;ar_5m[2] = &m_5m3;ar_5m[3] = &m_5m4;
	ar_6m[0] = &m_6m1;ar_6m[1] = &m_6m2;ar_6m[2] = &m_6m3;ar_6m[3] = &m_6m4;ar_7m[0] = &m_7m1;
	ar_7m[1] = &m_7m2;ar_7m[2] = &m_7m3;ar_7m[3] = &m_7m4;ar_8m[0] = &m_8m1;ar_8m[1] = &m_8m2;
	ar_8m[2] = &m_8m3;ar_8m[3] = &m_8m4;ar_strong[0] = &m_strong1;ar_strong[1] = &m_strong2;
	ar_strong[2] = &m_strong3;ar_strong[3] = &m_strong4;
	ar_str[0] = &m_str1;ar_str[1] = &m_str2;ar_str[2] = &m_str3;ar_str[3] = &m_str4;
	ar_agi[0] = &m_agi1;ar_agi[1] = &m_agi2;ar_agi[2] = &m_agi3;ar_agi[3] = &m_agi4;
	ar_int[0] = &m_int1;ar_int[1] = &m_int2;ar_int[2] = &m_int3;ar_int[3] = &m_int4;
	ar_vit[0] = &m_vit1;ar_vit[1] = &m_vit2;ar_vit[2] = &m_vit3;ar_vit[3] = &m_vit4;
	ar_luc[0] = &m_luc1;ar_luc[1] = &m_luc2;ar_luc[2] = &m_luc3;ar_luc[3] = &m_luc4;
	ar_exp[0] = &m_exp1;ar_exp[1] = &m_exp2;ar_exp[2] = &m_exp3;ar_exp[3] = &m_exp4;
	ar_level[0] = &m_level1;ar_level[1] = &m_level2;ar_level[2] = &m_level3;ar_level[3] = &m_level4;

	ar_totalhp[0] = &m_totalhp1;ar_totalhp[1] = &m_totalhp2;ar_totalhp[2] = &m_totalhp3;ar_totalhp[3] = &m_totalhp4;
	ar_totalstr[0] = &m_totalstr1;ar_totalstr[1] = &m_totalstr2;ar_totalstr[2] = &m_totalstr3;ar_totalstr[3] = &m_totalstr4;
	ar_totalagi[0] = &m_totalagi1;ar_totalagi[1] = &m_totalagi2;ar_totalagi[2] = &m_totalagi3;ar_totalagi[3] = &m_totalagi4;
	ar_totalint[0] = &m_totalint1;ar_totalint[1] = &m_totalint2;ar_totalint[2] = &m_totalint3;ar_totalint[3] = &m_totalint4;
	ar_totalvit[0] = &m_totalvit1;ar_totalvit[1] = &m_totalvit2;ar_totalvit[2] = &m_totalvit3;ar_totalvit[3] = &m_totalvit4;
	ar_totalluc[0] = &m_totalluc1;ar_totalluc[1] = &m_totalluc2;ar_totalluc[2] = &m_totalluc3;ar_totalluc[3] = &m_totalluc4;
	ar_totalmagic[0] = &m_totalmag1;ar_totalmagic[1] = &m_totalmag2;ar_totalmagic[2] = &m_totalmag3;ar_totalmagic[3] = &m_totalmag4;

	CButton* m_class[2] = {&m_class1,&m_class2};
	CString text = PutHexToList(cart,CLASSTEXT_OFFSET,BASICTEXT_PTRADD,CLASS_COUNT,cart->dat.TextViewInDTE[5],&m_classlist,NULL);
	ViewScale = 1;
	m_max.SetCheck(0);
	m_min.SetCheck(0);
	m_mean.SetCheck(1);
	
	int find;
	CString parttext;
	for(int co = 0; co < 2; co++){
		find = text.Find("\\b");
		if(find == -1) find = text.GetLength();
		parttext = text.Left(find);
		m_class[co]->SetWindowText(parttext);
		text = text.Right(text.GetLength() - find - 2);}

	level_offset = 0;
	m_scroll.SetScrollRange(0,45);
	m_scroll.SetScrollPos(0);

	cur_class = -1;
	m_classlist.SetCurSel(0);
	OnSelchangeClasslist();
	
	return 1;
}

void CClasses::LoadValues()
{
	int offset = CLASS_OFFSET + (cur_class * CLASS_BYTES);
	int temp;
	CString text;

	//basic stats
	temp = cart->ROM[offset];
	if(temp < 0x10) text.Format("0%X",temp);
	else text.Format("%X",temp);
	m_unknown.SetWindowText(text);

	text.Format("%d",cart->ROM[offset + 1]);
	m_startinghp.SetWindowText(text);
	text.Format("%d",cart->ROM[offset + 2]);
	m_str.SetWindowText(text);
	text.Format("%d",cart->ROM[offset + 3]);
	m_agility.SetWindowText(text);
	text.Format("%d",cart->ROM[offset + 4]);
	m_int.SetWindowText(text);
	text.Format("%d",cart->ROM[offset + 5]);
	m_vit.SetWindowText(text);
	text.Format("%d",cart->ROM[offset + 6]);
	m_luck.SetWindowText(text);
	text.Format("%d",cart->ROM[offset + 7]);
	m_damage.SetWindowText(text);
	text.Format("%d",cart->ROM[offset + 8]);
	m_hit.SetWindowText(text);
	text.Format("%d",cart->ROM[offset + 9]);
	m_evade.SetWindowText(text);
	text.Format("%d",cart->ROM[offset + 10]);
	m_magdef.SetWindowText(text);
	text.Format("%d",cart->ROM[HITPCTINCREASE_OFFSET + cur_class]);
	m_hitpctup.SetWindowText(text);

	//ranges, etc
	text.Format("%d",cart->ROM[STARTINGMP_OFFSET]);
	m_magic.SetWindowText(text);
	text.Format("%d",cart->ROM[MAGICMIN_OFFSET]);
	m_magicrangemin.SetWindowText(text);
	text.Format("%d",cart->ROM[MAGICMAX_OFFSET]);
	m_magicrangemax.SetWindowText(text);
	text.Format("%d",cart->ROM[HPRANGEMIN_OFFSET]);
	m_hprangemin.SetWindowText(text);
	text.Format("%d",cart->ROM[HPRANGEMAX_OFFSET]);
	m_hprangemax.SetWindowText(text);
	
	//block fighter/thief MP ability
	offset = LOCKFIGHTERTHIEF_OFFSET;
	bool legit = 1;
	for(int co = 0; co < 2; co++){
		if(cart->ROM[offset + co] != LockFighterThiefCode[co]) legit = 0;}
	m_class1.SetCheck(legit);
	legit = 1;
	for(co = 2; co < 6; co++){
		if(cart->ROM[offset + co] != LockFighterThiefCode[co]) legit = 0;}
	m_class2.SetCheck(legit);

	//level up data
	for(co = 0; co < 4; co++){
		offset = ((cur_class % 6) * 98) + ((level_offset + co) << 1) + LEVELUP_OFFSET;

		temp = cart->ROM[offset];
		ar_strong[co]->SetCheck(temp & 0x20);
		ar_str[co]->SetCheck(temp & 0x10);
		ar_agi[co]->SetCheck(temp & 0x08);
		ar_int[co]->SetCheck(temp & 0x04);
		ar_vit[co]->SetCheck(temp & 0x02);
		ar_luc[co]->SetCheck(temp & 0x01);

		temp = cart->ROM[offset + 1];
		ar_1m[co]->SetCheck(temp & 0x01);
		ar_2m[co]->SetCheck(temp & 0x02);
		ar_3m[co]->SetCheck(temp & 0x04);
		ar_4m[co]->SetCheck(temp & 0x08);
		ar_5m[co]->SetCheck(temp & 0x10);
		ar_6m[co]->SetCheck(temp & 0x20);
		ar_7m[co]->SetCheck(temp & 0x40);
		ar_8m[co]->SetCheck(temp & 0x80);

		offset = EXP_OFFSET + ((level_offset + co) * 3);
		temp = cart->ROM[offset] + (cart->ROM[offset + 1] << 8) + (cart->ROM[offset + 2] << 16);
		text.Format("%d",temp);
		ar_exp[co]->SetWindowText(text);
	}
	DisplayRunningTotals();
}

void CClasses::StoreValues()
{
	int offset = CLASS_OFFSET + (cur_class * CLASS_BYTES);
	int temp;
	CString text;

	//basic stats
	m_unknown.GetWindowText(text); temp = StringToInt_HEX(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset] = temp;
	m_startinghp.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 1] = temp;
	m_str.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 2] = temp;
	m_agility.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 3] = temp;
	m_int.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 4] = temp;
	m_vit.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 5] = temp;
	m_luck.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 6] = temp;
	m_damage.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 7] = temp;
	m_hit.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 8] = temp;
	m_evade.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 9] = temp;
	m_magdef.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 10] = temp;
	m_hitpctup.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[HITPCTINCREASE_OFFSET + cur_class] = temp;
	
	//ranges, etc
	m_magic.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF; cart->ROM[STARTINGMP_OFFSET] = temp;
	m_magicrangemin.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF; cart->ROM[MAGICMIN_OFFSET] = temp;
	m_magicrangemax.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF; cart->ROM[MAGICMAX_OFFSET] = temp;
	m_hprangemin.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF; cart->ROM[HPRANGEMIN_OFFSET] = temp;
	m_hprangemax.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF; cart->ROM[HPRANGEMAX_OFFSET] = temp;
	
	//block fighter/thief MP ability
	offset = LOCKFIGHTERTHIEF_OFFSET;
	for(int co = 0; co < 6; co++)
		cart->ROM[offset + co] = LockFighterThiefCode[co];
	if(!m_class1.GetCheck()){ //Lock Fighter
		for(co = 0; co < 2; co++)
			cart->ROM[offset + co] = 0xEA;}
	if(!m_class2.GetCheck()){ //Lock Thief
		for(co = 2; co < 6; co++)
			cart->ROM[offset + co] = 0xEA;}
	
	//level up data
	for(co = 0; co < 4; co++){
		offset = ((cur_class % 6) * 98) + ((level_offset + co) << 1) + LEVELUP_OFFSET;

		temp = 0;
		if(ar_strong[co]->GetCheck()) temp |= 0x20;
		if(ar_str[co]->GetCheck()) temp |= 0x10;
		if(ar_agi[co]->GetCheck()) temp |= 0x08;
		if(ar_int[co]->GetCheck()) temp |= 0x04;
		if(ar_vit[co]->GetCheck()) temp |= 0x02;
		if(ar_luc[co]->GetCheck()) temp |= 0x01;
		cart->ROM[offset] = temp;

		temp = 0;
		if(ar_1m[co]->GetCheck()) temp |= 0x01;
		if(ar_2m[co]->GetCheck()) temp |= 0x02;
		if(ar_3m[co]->GetCheck()) temp |= 0x04;
		if(ar_4m[co]->GetCheck()) temp |= 0x08;
		if(ar_5m[co]->GetCheck()) temp |= 0x10;
		if(ar_6m[co]->GetCheck()) temp |= 0x20;
		if(ar_7m[co]->GetCheck()) temp |= 0x40;
		if(ar_8m[co]->GetCheck()) temp |= 0x80;
		cart->ROM[offset + 1] = temp;

		offset = EXP_OFFSET + ((level_offset + co) * 3);
		ar_exp[co]->GetWindowText(text);
		temp = StringToInt(text);
		if(temp > 0xFFFFFF) temp = 0xFFFFFF;
		cart->ROM[offset] = temp & 0xFF;
		cart->ROM[offset + 1] = (temp >> 8) & 0xFF;
		cart->ROM[offset + 2] = temp >> 16;
	}
}

void CClasses::OnSelchangeClasslist() 
{
	if(cur_class != -1) StoreValues();
	cur_class = m_classlist.GetCurSel();
	RecalculateRunningTotals();
	LoadValues();
}

void CClasses::OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar) 
{
	StoreValues();
	switch(nSBCode){
	case 0: level_offset -= 1; break;
	case 1: level_offset += 1; break;
	case 2: level_offset -= 4; break;
	case 3: level_offset += 4; break;
	case 5: level_offset = nPos; break;
	}
	if(level_offset < 0) level_offset = 0;
	if(level_offset > 45) level_offset = 45;

	m_scroll.SetScrollPos(level_offset);
	LoadValues();
}

void CClasses::DisplayRunningTotals()
{
	CString text, texter;
	int lvl = level_offset;
	int co2;
	for(int co = 0; co < 4; co++, lvl++)
	{
		text.Format("Level: %d",lvl + 2);
		ar_level[co]->SetWindowText(text);

		text.Format("HP: %d",TotalHP[lvl]);
		ar_totalhp[co]->SetWindowText(text);

		text.Format("Str: %d",TotalStr[lvl]);
		ar_totalstr[co]->SetWindowText(text);
		text.Format("Int: %d",TotalInt[lvl]);
		ar_totalint[co]->SetWindowText(text);
		text.Format("Vit: %d",TotalVit[lvl]);
		ar_totalvit[co]->SetWindowText(text);
		text.Format("Agi: %d",TotalAgi[lvl]);
		ar_totalagi[co]->SetWindowText(text);
		text.Format("Luc: %d",TotalLuc[lvl]);
		ar_totalluc[co]->SetWindowText(text);

		text = "";
		for(co2 = 0; co2 < 8; co2++){
			if(co2 & 0x03) text += "/";
			if(co2 == 4) text += "\n";
			texter.Format("%X",TotalMagic[lvl][co2]);
			if(texter.GetLength() > 1) texter = "?";
			text += texter;}
		ar_totalmagic[co]->SetWindowText(text);
	}
}

void CClasses::RecalculateRunningTotals()
{
	int offset;
	BYTE temp, line, tco;
	CString text;

	m_startinghp.GetWindowText(text);
	short RunningHP = StringToInt(text);
	m_str.GetWindowText(text);
	short RunningStr = StringToInt(text) << 1;
	m_agility.GetWindowText(text);
	short RunningAgi = StringToInt(text) << 1;
	m_int.GetWindowText(text);
	short RunningInt = StringToInt(text) << 1;
	m_vit.GetWindowText(text);
	short RunningVit = StringToInt(text) << 1;
	m_luck.GetWindowText(text);
	short RunningLuc = StringToInt(text) << 1;

	int HPGain;
	m_hprangemax.GetWindowText(text);
	if(ViewScale) HPGain = StringToInt(text);
	m_hprangemin.GetWindowText(text);
	if(!ViewScale) HPGain = StringToInt(text);
	else if(ViewScale == 1){
		temp = StringToInt(text);
		HPGain = ((HPGain - temp) >> 1) + temp;}
	
	m_magic.GetWindowText(text);
	temp = StringToInt(text);
	BYTE RunningMag[8] = {temp,0,0,0,0,0,0,0};
	offset = cur_class % 6;
	m_magicrangemin.GetWindowText(text);
	if(offset < StringToInt(text)) RunningMag[0] = 0;
	m_magicrangemax.GetWindowText(text);
	if(offset >= StringToInt(text)) RunningMag[0] = 0;

	offset = ((cur_class % 6) * 98) + LEVELUP_OFFSET;
	for(int co = 0; co < 49; co++, offset += 2)
	{
		RunningHP += 1 + (RunningVit >> 3);
		temp = cart->ROM[offset];
		if(temp & 0x20) //if strong level up
			RunningHP += HPGain;
		if(ViewScale == 2){
			RunningStr += 2;
			RunningAgi += 2;
			RunningInt += 2;
			RunningVit += 2;
			RunningLuc += 2;}
		else{
			if(temp & 0x10) RunningStr += 2;
			else RunningStr += ViewScale;
			if(temp & 0x08) RunningAgi += 2;
			else RunningAgi += ViewScale;
			if(temp & 0x04) RunningInt += 2;
			else RunningInt += ViewScale;
			if(temp & 0x02) RunningVit += 2;
			else RunningVit += ViewScale;
			if(temp & 0x01) RunningLuc += 2;
			else RunningLuc += ViewScale;}

		temp = cart->ROM[offset + 1];
		for(tco = 0, line = 1; tco < 8; tco++, line <<= 1)
			RunningMag[tco] += (temp & line) != 0;


		TotalHP[co] = RunningHP;
		TotalStr[co] = RunningStr >> 1;
		TotalAgi[co] = RunningAgi >> 1;
		TotalInt[co] = RunningInt >> 1;
		TotalVit[co] = RunningVit >> 1;
		TotalLuc[co] = RunningLuc >> 1;
		for(tco = 0; tco < 8; tco++)
			TotalMagic[co][tco] = RunningMag[tco];
	}

	DisplayRunningTotals();
}

void CClasses::OnMean() 
{ViewScale = 1; m_min.SetCheck(0); m_max.SetCheck(0); RecalculateRunningTotals();}
void CClasses::OnMax() 
{ViewScale = 2; m_min.SetCheck(0); m_mean.SetCheck(0); RecalculateRunningTotals();}
void CClasses::OnMin() 
{ViewScale = 0; m_max.SetCheck(0); m_mean.SetCheck(0); RecalculateRunningTotals();}
void CClasses::OnChangeHprangemax() 
{if(ViewScale != 0) RecalculateRunningTotals();}
void CClasses::OnChangeHprangemin() 
{if(ViewScale != 2) RecalculateRunningTotals();}
void CClasses::OnCheckBox() 
{StoreValues(); RecalculateRunningTotals();}

void CClasses::OnSave() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
}

void CClasses::OnOK() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
	else
		CDialog::OnOK();
}

void CClasses::OnCancel() 
{
	ReLoadROM(cart);
	CDialog::OnCancel();
}

void CClasses::OnBattlepic() 
{
	CBattlePic dlg;
	dlg.cart = cart;
	dlg.Class = cur_class;
	dlg.DoModal();
}

void CClasses::OnMapmanpic() 
{
	CMapman dlg;
	dlg.cart = cart;
	dlg.graphicoffset = MAPMANGRAPHIC_OFFSET + (cur_class << 8);
	dlg.paletteoffset = -cur_class - 1;
	dlg.DoModal();
}
