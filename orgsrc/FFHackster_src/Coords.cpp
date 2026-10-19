// Coords.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "OverworldMap.h"
#include "Maps.h"
#include "Coords.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CCoords dialog


CCoords::CCoords(CWnd* pParent /*=NULL*/)
	: CDialog(CCoords::IDD, pParent)
{
	//{{AFX_DATA_INIT(CCoords)
	//}}AFX_DATA_INIT
}


void CCoords::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CCoords)
	DDX_Control(pDX, IDC_TELEPORTLIST, m_teleportlist);
	DDX_Control(pDX, IDC_MOUSECLICK, m_mouseclick);
	DDX_Control(pDX, IDC_FOLLOWUP_FORWARD, m_followup_forward);
	DDX_Control(pDX, IDC_FOLLOWUP_BACK, m_followup_back);
	DDX_Control(pDX, IDC_COORD_Y, m_coord_y);
	DDX_Control(pDX, IDC_COORD_X, m_coord_x);
	DDX_Control(pDX, IDC_COORD_L, m_coord_l);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CCoords, CDialog)
	//{{AFX_MSG_MAP(CCoords)
	ON_CBN_SELCHANGE(IDC_TELEPORTLIST, OnSelchangeTeleportlist)
	ON_CBN_SELCHANGE(IDC_COORD_L, OnSelchangeCoordL)
	ON_EN_CHANGE(IDC_COORD_X, OnChangeCoordX)
	ON_EN_CHANGE(IDC_COORD_Y, OnChangeCoordY)
	ON_BN_CLICKED(IDC_MOUSECLICK, OnMouseclick)
	ON_BN_CLICKED(IDC_EDITLABEL, OnEditlabel)
	ON_BN_CLICKED(IDC_FOLLOWUP, OnFollowup)
	ON_BN_CLICKED(IDC_FOLLOWUP_BACK, OnFollowupBack)
	ON_BN_CLICKED(IDC_FOLLOWUP_FORWARD, OnFollowupForward)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CCoords message handlers

BOOL CCoords::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	return 1;
}

void CCoords::Boot()
{
	int co;
	for(co = 0; co < NOTELEPORT_COUNT; co++)
		m_teleportlist.InsertString(co,cart->dat.NOTeleportLabels[co]);
	for(co = 0; co < NNTELEPORT_COUNT; co++)
		m_teleportlist.InsertString(co,cart->dat.NNTeleportLabels[co]);
	for(co = 0; co < ONTELEPORT_COUNT; co++)
		m_teleportlist.InsertString(co,cart->dat.ONTeleportLabels[co]);

	for(co = 0; co < MAP_COUNT; co++)
		m_coord_l.InsertString(co,cart->dat.MapLabels[co]);

	cur = -1;
	m_teleportlist.SetCurSel(0);
	OnSelchangeTeleportlist();

	UpdateButtons();
}

void CCoords::OnSelchangeTeleportlist() 
{
	cur = m_teleportlist.GetCurSel();
	LoadValues();
}

void CCoords::LoadValues()
{
	type = 2;
	if(cur < ONTELEPORT_COUNT) type = 0;
	else if(cur < (ONTELEPORT_COUNT + NNTELEPORT_COUNT)) type = 1;
	m_coord_l.ShowWindow(type < 2);
	switch(type){
	case 0: offset = ONTELEPORT_OFFSET + cur;
		count = ONTELEPORT_COUNT; break;
	case 1: offset = NNTELEPORT_OFFSET + cur - ONTELEPORT_COUNT;
		count = NNTELEPORT_COUNT; break;
	case 2: offset = NOTELEPORT_OFFSET + cur - ONTELEPORT_COUNT - NNTELEPORT_COUNT;
		count = NOTELEPORT_COUNT; break;
	}

	CString text;

	text.Format("%X",cart->ROM[offset]);
	m_coord_x.SetWindowText(text);

	text.Format("%X",cart->ROM[offset + count]);
	m_coord_y.SetWindowText(text);
	if(type < 2)
		m_coord_l.SetCurSel(cart->ROM[offset + (count << 1)]);
}

void CCoords::OnSelchangeCoordL() 
{
	cart->ROM[offset + (count << 1)] = m_coord_l.GetCurSel();
}

void CCoords::OnChangeCoordX() 
{
	CString text;
	m_coord_x.GetWindowText(text);
	cart->ROM[offset] = StringToInt_HEX(text);
}

void CCoords::OnChangeCoordY() 
{
	CString text;
	m_coord_y.GetWindowText(text);
	cart->ROM[offset + count] = StringToInt_HEX(text);
}

void CCoords::OnMouseclick() 
{
	if(((type < 2) && IsOV) || ((type == 2) && !IsOV)){
		m_mouseclick.SetCheck(0);
		AfxMessageBox("Cannot read coord from this Map editor");}
}

void CCoords::OnEditlabel() 
{
	int arid = cur;
	if(type > 0) arid -= ONTELEPORT_COUNT;
	if(type > 1) arid -= NNTELEPORT_COUNT;
	char* label[3] = {cart->dat.ONTeleportLabels[arid],cart->dat.NNTeleportLabels[arid],cart->dat.NOTeleportLabels[arid]};

	ChangeLabel(TELEPORTLABEL_SIZE,label[type],cur,NULL,&m_teleportlist);

	if(!type && IsOV)
		OVparent->UpdateTeleportLabel(arid);
	else if(type && !IsOV)
		STparent->UpdateTeleportLabel(arid,type == 1);
}

void CCoords::InputCoords(CPoint pt)
{
	CString text;
	text.Format("%X",pt.x);
	m_coord_x.SetWindowText(text); OnChangeCoordX();
	text.Format("%X",pt.y);
	m_coord_y.SetWindowText(text); OnChangeCoordY();
	m_mouseclick.SetCheck(0);
}

void CCoords::OnCancel() 
{
	if(IsOV){
		OVparent->m_viewcoords.SetCheck(0);
		OVparent->OnViewcoords();}
	else{
		STparent->m_viewcoords.SetCheck(0);
		STparent->OnViewcoords();}
}

void CCoords::UpdateButtons()
{
	BYTE& cu = cart->curFollowup;
	BYTE& ma = cart->maxFollowup;
	m_followup_forward.EnableWindow(!(cu == (ma & 0x7F)));
	m_followup_back.EnableWindow(!(
		(cu == ((ma + 1) & 0x7F)) ||
		(!cu && !(ma & 0x80))));
}

void CCoords::OnFollowup() 
{
	BYTE* Flw = cart->TeleportFollowup[cart->curFollowup];
	//place the last click in current Followup
	if(IsOV){
		Flw[0] = 0xFF;
		Flw[1] = (BYTE)OVparent->ptLastClick.x;
		Flw[2] = (BYTE)OVparent->ptLastClick.y;}
	else{
		Flw[0] = (BYTE)STparent->cur_map;
		Flw[1] = (BYTE)STparent->ptLastClick.x;
		Flw[2] = (BYTE)STparent->ptLastClick.y;}

	//increment curFollowup (and maxFollowup if needed)
	if(cart->curFollowup == (cart->maxFollowup & 0x7F)){
		if(cart->maxFollowup == 0xFF) cart->maxFollowup = 0x80;
		else cart->maxFollowup += 1;}
	cart->curFollowup = (cart->curFollowup + 1) & 0x7F;

	Flw = cart->TeleportFollowup[cart->curFollowup];

	//place the followup spot in the current followup
	Flw[1] = cart->ROM[offset];
	Flw[2] = cart->ROM[offset + count];
	if(type == 2) Flw[0] = 0xFF;
	else Flw[0] = cart->ROM[offset + (count << 1)];
	TeleportHere();
}

void CCoords::OnFollowupBack() 
{
	if(!cart->curFollowup) cart->curFollowup = 0x7F;
	else cart->curFollowup -= 1;
	TeleportHere();
}

void CCoords::OnFollowupForward() 
{
	cart->curFollowup = (cart->curFollowup + 1) & 0x7F;
	TeleportHere();
}

void CCoords::TeleportHere()
{
	UpdateButtons();
	BYTE _l = cart->TeleportFollowup[cart->curFollowup][0];
	BYTE _x = cart->TeleportFollowup[cart->curFollowup][1];
	BYTE _y = cart->TeleportFollowup[cart->curFollowup][2];

	if(IsOV){
		if(_l == 0xFF){
			OVparent->ptLastClick = CPoint(_x,_y);
			OVparent->OnHScroll(5,_x - 8,NULL);
			OVparent->OnVScroll(5,_y - 8,NULL);
			OVparent->cur_tile = OVparent->DecompressedMap[_y][_x];
			OVparent->LoadTileData();}
		else{
			OVparent->BootToTeleportFollowup = 1;
			OVparent->OnOK();}
	}
	else{
		if(_l == 0xFF){
			STparent->BootToTeleportFollowup = 1;
			STparent->OnOK();}
		else{
			STparent->ptLastClick = CPoint(_x,_y);
			STparent->OnHScroll(5,_x - 8,NULL);
			STparent->OnVScroll(5,_y - 8,NULL);
			STparent->m_maplist.SetCurSel(_l);
			STparent->BootToTeleportFollowup = 1;
			STparent->OnSelchangeMaplist();}
	}
}