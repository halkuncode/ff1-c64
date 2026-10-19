// MiniMap.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "OverworldMap.h"
#include "MiniMap.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CMiniMap dialog


CMiniMap::CMiniMap(CWnd* pParent /*=NULL*/)
	: CDialog(CMiniMap::IDD, pParent)
{
	//{{AFX_DATA_INIT(CMiniMap)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void CMiniMap::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CMiniMap)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CMiniMap, CDialog)
	//{{AFX_MSG_MAP(CMiniMap)
	ON_WM_PAINT()
	ON_WM_LBUTTONDOWN()
	ON_WM_MOUSEMOVE()
	ON_WM_LBUTTONUP()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CMiniMap message handlers

void CMiniMap::OnPaint() 
{
	CPaintDC dc(this);
	CPen redpen; redpen.CreatePen(PS_SOLID,1,RGB(255,0,0));
	CPen* oldpen = dc.SelectObject(&redpen);
	int coX, coY, co = 0;
	for(coY = 0; coY < 256; coY++){
	for(coX = 0; coX < 256; coX++, co++)
		dc.SetPixelV(coX,coY,cart->Palette[0][palette[(PalAssign[Map[co]] << 2) + 3]]);}

	dc.MoveTo(rcNew.TopLeft()); dc.LineTo(rcNew.left + 15,rcNew.top); dc.LineTo(rcNew.left + 15,rcNew.top + 15);
	dc.LineTo(rcNew.left,rcNew.top + 15); dc.LineTo(rcNew.TopLeft());

	dc.SelectObject(oldpen);
	redpen.DeleteObject();
}

void CMiniMap::FixRects(CPoint pt)
{
	rcNew.SetRect(pt.x,pt.y,pt.x + 16,pt.y + 16);
	InvalidateRect(rcNew,0);
	InvalidateRect(rcOld,0);
	rcOld = rcNew;
}

void CMiniMap::OnCancel() 
{
	OVmap->m_minimap.SetCheck(0);
	OVmap->OnMinimap();
}

void CMiniMap::OnLButtonDown(UINT nFlags, CPoint pt) 
{
	mousedown = 1;
	OnMouseMove(nFlags,pt);
}

void CMiniMap::UpdateAll()
{InvalidateRect(NULL,0);}
void CMiniMap::UpdateCur()
{InvalidateRect(rcNew,0);}

void CMiniMap::OnMouseMove(UINT nFlags, CPoint pt) 
{
	if(mousedown){
		OVmap->OnHScroll(5,pt.x - 8,NULL);
		OVmap->OnVScroll(5,pt.y - 8,NULL);
	}
}

void CMiniMap::OnLButtonUp(UINT nFlags, CPoint point) 
{mousedown = 0;}

BOOL CMiniMap::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	mousedown = 0;
	
	return 1;
}
