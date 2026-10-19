// NewLabel.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "NewLabel.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CNewLabel dialog


CNewLabel::CNewLabel(CWnd* pParent /*=NULL*/)
	: CDialog(CNewLabel::IDD, pParent)
{
	//{{AFX_DATA_INIT(CNewLabel)
	m_label = _T("");
	//}}AFX_DATA_INIT
}


void CNewLabel::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CNewLabel)
	DDX_Text(pDX, IDC_LABEL, m_label);
	DDV_MaxChars(pDX, m_label, length);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CNewLabel, CDialog)
	//{{AFX_MSG_MAP(CNewLabel)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CNewLabel message handlers
