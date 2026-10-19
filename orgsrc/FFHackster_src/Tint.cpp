// Tint.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "Tint.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CTint dialog


CTint::CTint(CWnd* pParent /*=NULL*/)
	: CDialog(CTint::IDD, pParent)
{
	//{{AFX_DATA_INIT(CTint)
	m_tintvariant = 0;
	//}}AFX_DATA_INIT
}


void CTint::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CTint)
	DDX_Control(pDX, IDC_TINT8, m_tint8);
	DDX_Control(pDX, IDC_TINT7, m_tint7);
	DDX_Control(pDX, IDC_TINT6, m_tint6);
	DDX_Control(pDX, IDC_TINT5, m_tint5);
	DDX_Control(pDX, IDC_TINT4, m_tint4);
	DDX_Control(pDX, IDC_TINT3, m_tint3);
	DDX_Control(pDX, IDC_TINT2, m_tint2);
	DDX_Control(pDX, IDC_TINT1, m_tint1);
	DDX_Control(pDX, IDC_TINT0, m_tint0);
	DDX_Text(pDX, IDC_TINTVARIANT, m_tintvariant);
	DDV_MinMaxInt(pDX, m_tintvariant, 0, 255);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CTint, CDialog)
	//{{AFX_MSG_MAP(CTint)
	ON_BN_CLICKED(IDC_TINT0, OnTint0)
	ON_BN_CLICKED(IDC_TINT1, OnTint1)
	ON_BN_CLICKED(IDC_TINT2, OnTint2)
	ON_BN_CLICKED(IDC_TINT3, OnTint3)
	ON_BN_CLICKED(IDC_TINT4, OnTint4)
	ON_BN_CLICKED(IDC_TINT5, OnTint5)
	ON_BN_CLICKED(IDC_TINT6, OnTint6)
	ON_BN_CLICKED(IDC_TINT7, OnTint7)
	ON_BN_CLICKED(IDC_TINT8, OnTint8)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CTint message handlers

BOOL CTint::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	UpdateTint(tintvalue);

	return 1;
}

void CTint::UpdateTint(int update){
	tintvalue = update;
	m_tint0.SetCheck(tintvalue == 0);
	m_tint1.SetCheck(tintvalue == 1);
	m_tint2.SetCheck(tintvalue == 2);
	m_tint3.SetCheck(tintvalue == 3);
	m_tint4.SetCheck(tintvalue == 4);
	m_tint5.SetCheck(tintvalue == 5);
	m_tint6.SetCheck(tintvalue == 6);
	m_tint7.SetCheck(tintvalue == 7);
	m_tint8.SetCheck(tintvalue == 8);}

void CTint::OnTint0() 
{UpdateTint(0);}
void CTint::OnTint1() 
{UpdateTint(1);}
void CTint::OnTint2() 
{UpdateTint(2);}
void CTint::OnTint3() 
{UpdateTint(3);}
void CTint::OnTint4() 
{UpdateTint(4);}
void CTint::OnTint5() 
{UpdateTint(5);}
void CTint::OnTint6() 
{UpdateTint(6);}
void CTint::OnTint7() 
{UpdateTint(7);}
void CTint::OnTint8() 
{UpdateTint(8);}