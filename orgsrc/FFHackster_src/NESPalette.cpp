// NESPalette.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "NESPalette.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CNESPalette dialog


CNESPalette::CNESPalette(CWnd* pParent /*=NULL*/)
	: CDialog(CNESPalette::IDD, pParent)
{
	//{{AFX_DATA_INIT(CNESPalette)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void CNESPalette::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CNESPalette)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CNESPalette, CDialog)
	//{{AFX_MSG_MAP(CNESPalette)
	ON_WM_PAINT()
	ON_WM_LBUTTONDOWN()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CNESPalette message handlers

BOOL CNESPalette::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	rcPalette.SetRect(12,40,12 + 256,40 + 64);
	
	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

void CNESPalette::OnPaint() 
{
	CPaintDC dc(this);
	CRect rc;
	rc.left = rcPalette.left;
	rc.top = rcPalette.top;
	rc.right = rc.left + 16;
	rc.bottom = rc.top + 16;
	CBrush br;
	int coY, coX, co = 0;
	for(coY = 0; coY < 4; coY++, rc.top += 16, rc.bottom += 16){
		for(coX = 0; coX < 16; coX++, co++, rc.left += 16, rc.right += 16){
			br.CreateSolidBrush(cart->Palette[0][co]);
			dc.FillRect(rc,&br);
			br.DeleteObject();}
		rc.left = rcPalette.left;
		rc.right = rc.left + 16;
	}

	dc.SetBkMode(TRANSPARENT);
	dc.SetTextColor(RGB(0,0,0));

	rc.SetRect(85,10,85 + 16,26);
	co = *color;
	br.CreateSolidBrush(cart->Palette[0][co]);
	dc.FillRect(rc,&br);
	br.DeleteObject();

	coX = ((co & 0x0F) << 4) + rcPalette.left;
	coY = (co & 0xF0) + rcPalette.top;
	dc.TextOut(coX,coY,"*");
}

void CNESPalette::OnLButtonDown(UINT nFlags, CPoint pt) 
{
	if(PtInRect(rcPalette,pt)){
		pt.x = (pt.x - rcPalette.left) >> 4;
		pt.y = (pt.y - rcPalette.top) & 0xF0;
		*color = BYTE(pt.x + pt.y);
		CDialog::OnOK();
	}
}
