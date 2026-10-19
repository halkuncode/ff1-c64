// Battle.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "Battle.h"
#include "NESPalette.h"
#include "BattlePalettes.h"
#include "BattlePatternTables.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CBattle dialog


CBattle::CBattle(CWnd* pParent /*=NULL*/)
	: CDialog(CBattle::IDD, pParent)
{
	//{{AFX_DATA_INIT(CBattle)
	//}}AFX_DATA_INIT
}


void CBattle::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CBattle)
	DDX_Control(pDX, IDC_VIEWMIN, m_viewmin);
	DDX_Control(pDX, IDC_VIEWMEAN, m_viewmean);
	DDX_Control(pDX, IDC_VIEWMAX, m_viewmax);
	DDX_Control(pDX, IDC_FORM2, m_form2);
	DDX_Control(pDX, IDC_FORM1, m_form1);
	DDX_Control(pDX, IDC_TYPE5, m_type5);
	DDX_Control(pDX, IDC_TYPE4, m_type4);
	DDX_Control(pDX, IDC_TYPE3, m_type3);
	DDX_Control(pDX, IDC_TYPE2, m_type2);
	DDX_Control(pDX, IDC_TYPE1, m_type1);
	DDX_Control(pDX, IDC_SUPRISED, m_suprised);
	DDX_Control(pDX, IDC_QTYMIN_4, m_qtymin_4);
	DDX_Control(pDX, IDC_QTYMIN_3, m_qtymin_3);
	DDX_Control(pDX, IDC_QTYMIN_2, m_qtymin_2);
	DDX_Control(pDX, IDC_QTYMIN_1, m_qtymin_1);
	DDX_Control(pDX, IDC_QTYMAX_4, m_qtymax_4);
	DDX_Control(pDX, IDC_QTYMAX_3, m_qtymax_3);
	DDX_Control(pDX, IDC_QTYMAX_2, m_qtymax_2);
	DDX_Control(pDX, IDC_QTYMAX_1, m_qtymax_1);
	DDX_Control(pDX, IDC_PICD_4, m_picd_4);
	DDX_Control(pDX, IDC_PICD_3, m_picd_3);
	DDX_Control(pDX, IDC_PICD_2, m_picd_2);
	DDX_Control(pDX, IDC_PICD_1, m_picd_1);
	DDX_Control(pDX, IDC_PICC_4, m_picc_4);
	DDX_Control(pDX, IDC_PICC_3, m_picc_3);
	DDX_Control(pDX, IDC_PICC_2, m_picc_2);
	DDX_Control(pDX, IDC_PICC_1, m_picc_1);
	DDX_Control(pDX, IDC_PICB_4, m_picb_4);
	DDX_Control(pDX, IDC_PICB_3, m_picb_3);
	DDX_Control(pDX, IDC_PICB_2, m_picb_2);
	DDX_Control(pDX, IDC_PICB_1, m_picb_1);
	DDX_Control(pDX, IDC_PICA_4, m_pica_4);
	DDX_Control(pDX, IDC_PICA_3, m_pica_3);
	DDX_Control(pDX, IDC_PICA_2, m_pica_2);
	DDX_Control(pDX, IDC_PICA_1, m_pica_1);
	DDX_Control(pDX, IDC_PATTERNTABLES, m_patterntables);
	DDX_Control(pDX, IDC_PALETTE2, m_palette2);
	DDX_Control(pDX, IDC_PALETTE1, m_palette1);
	DDX_Control(pDX, IDC_PALB_4, m_palb_4);
	DDX_Control(pDX, IDC_PALB_3, m_palb_3);
	DDX_Control(pDX, IDC_PALB_2, m_palb_2);
	DDX_Control(pDX, IDC_PALB_1, m_palb_1);
	DDX_Control(pDX, IDC_PALA_4, m_pala_4);
	DDX_Control(pDX, IDC_PALA_3, m_pala_3);
	DDX_Control(pDX, IDC_PALA_2, m_pala_2);
	DDX_Control(pDX, IDC_PALA_1, m_pala_1);
	DDX_Control(pDX, IDC_NORUN, m_norun);
	DDX_Control(pDX, IDC_ENEMY4, m_enemy4);
	DDX_Control(pDX, IDC_ENEMY3, m_enemy3);
	DDX_Control(pDX, IDC_ENEMY2, m_enemy2);
	DDX_Control(pDX, IDC_ENEMY1, m_enemy1);
	DDX_Control(pDX, IDC_BATTLELIST, m_battlelist);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CBattle, CDialog)
	//{{AFX_MSG_MAP(CBattle)
	ON_LBN_SELCHANGE(IDC_BATTLELIST, OnSelchangeBattlelist)
	ON_WM_PAINT()
	ON_EN_CHANGE(IDC_QTYMIN_1, UpdateQtyMin)
	ON_EN_CHANGE(IDC_QTYMAX_1, UpdateQtyMax)
	ON_BN_CLICKED(IDC_VIEWMAX, OnViewmax)
	ON_BN_CLICKED(IDC_VIEWMEAN, OnViewmean)
	ON_BN_CLICKED(IDC_VIEWMIN, OnViewmin)
	ON_BN_CLICKED(IDC_FORM1, OnForm1)
	ON_BN_CLICKED(IDC_FORM2, OnForm2)
	ON_CBN_SELCHANGE(IDC_PATTERNTABLES, OnSelchangePatterntables)
	ON_BN_CLICKED(IDC_TYPE1, OnType1)
	ON_BN_CLICKED(IDC_TYPE2, OnType2)
	ON_BN_CLICKED(IDC_TYPE3, OnType3)
	ON_BN_CLICKED(IDC_TYPE4, OnType4)
	ON_BN_CLICKED(IDC_TYPE5, OnType5)
	ON_BN_CLICKED(IDC_PALA_1, OnPala1)
	ON_BN_CLICKED(IDC_PALA_2, OnPala2)
	ON_BN_CLICKED(IDC_PALA_3, OnPala3)
	ON_BN_CLICKED(IDC_PALA_4, OnPala4)
	ON_BN_CLICKED(IDC_PALB_1, OnPalb1)
	ON_BN_CLICKED(IDC_PALB_2, OnPalb2)
	ON_BN_CLICKED(IDC_PALB_3, OnPalb3)
	ON_BN_CLICKED(IDC_PALB_4, OnPalb4)
	ON_BN_CLICKED(IDC_PICA_1, OnPica1)
	ON_BN_CLICKED(IDC_PICA_2, OnPica2)
	ON_BN_CLICKED(IDC_PICA_3, OnPica3)
	ON_BN_CLICKED(IDC_PICA_4, OnPica4)
	ON_BN_CLICKED(IDC_PICB_1, OnPicb1)
	ON_BN_CLICKED(IDC_PICB_2, OnPicb2)
	ON_BN_CLICKED(IDC_PICB_3, OnPicb3)
	ON_BN_CLICKED(IDC_PICB_4, OnPicb4)
	ON_BN_CLICKED(IDC_PICC_1, OnPicc1)
	ON_BN_CLICKED(IDC_PICC_2, OnPicc2)
	ON_BN_CLICKED(IDC_PICC_3, OnPicc3)
	ON_BN_CLICKED(IDC_PICC_4, OnPicc4)
	ON_BN_CLICKED(IDC_PICD_1, OnPicd1)
	ON_BN_CLICKED(IDC_PICD_2, OnPicd2)
	ON_BN_CLICKED(IDC_PICD_3, OnPicd3)
	ON_BN_CLICKED(IDC_PICD_4, OnPicd4)
	ON_BN_CLICKED(IDC_EDITBATLABEL, OnEditbatlabel)
	ON_BN_CLICKED(IDC_EDITPATLABEL, OnEditpatlabel)
	ON_WM_LBUTTONDOWN()
	ON_BN_CLICKED(IDC_CHANGEPAL1, OnChangepal1)
	ON_BN_CLICKED(IDC_CHANGEPAL2, OnChangepal2)
	ON_BN_CLICKED(IDC_EDITGRAPHIC, OnEditgraphic)
	ON_EN_CHANGE(IDC_QTYMAX_2, UpdateQtyMax)
	ON_EN_CHANGE(IDC_QTYMAX_3, UpdateQtyMax)
	ON_EN_CHANGE(IDC_QTYMAX_4, UpdateQtyMax)
	ON_EN_CHANGE(IDC_QTYMIN_2, UpdateQtyMin)
	ON_EN_CHANGE(IDC_QTYMIN_3, UpdateQtyMin)
	ON_EN_CHANGE(IDC_QTYMIN_4, UpdateQtyMin)
	ON_BN_CLICKED(IDC_SAVE, OnSave)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CBattle message handlers

BOOL CBattle::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	if(!ReLoadROM(cart)){
		CDialog::OnCancel();
		return 0;}

	for(int co = 0; co < BATTLE_COUNT; co++)
		m_battlelist.InsertString(co,cart->dat.BattleLabels[co]);
	for(co = 0; co < BATTLEPATTERNTABLE_COUNT; co++)
		m_patterntables.InsertString(co,cart->dat.BattlePatternTableLabels[co]);
	PutHexToList(cart,ENEMYTEXT_OFFSET,ENEMYTEXT_PTRADD,ENEMY_COUNT,cart->dat.TextViewInDTE[7],NULL,&m_enemy1);
	PutHexToList(cart,ENEMYTEXT_OFFSET,ENEMYTEXT_PTRADD,ENEMY_COUNT,cart->dat.TextViewInDTE[7],NULL,&m_enemy2);
	PutHexToList(cart,ENEMYTEXT_OFFSET,ENEMYTEXT_PTRADD,ENEMY_COUNT,cart->dat.TextViewInDTE[7],NULL,&m_enemy3);
	PutHexToList(cart,ENEMYTEXT_OFFSET,ENEMYTEXT_PTRADD,ENEMY_COUNT,cart->dat.TextViewInDTE[7],NULL,&m_enemy4);

	rcPal[0].SetRect(482,99,482 + 48,99 + 16);
	rcPal[1] = rcPal[0];
	rcPal[1].top += 19;
	rcPal[1].bottom += 19;

	rcPreview.left = 209;
	rcPreview.top = 27;

	rcPreview.bottom = rcPreview.top + 98;
	rcPreview.right = rcPreview.left + 112;

	cur = -1;
	form = 0;
	view = 2;
	m_battlelist.SetCurSel(0);
	OnSelchangeBattlelist();

	m_form1.SetCheck(1);
	m_viewmax.SetCheck(1);

	return 1;
}

void CBattle::ReloadGraphics()
{
	int co;

	if(battletype == 4){
		LoadFiendChaosPic(CHAOSDRAW_TABLE,CHAOSPALETTE_TABLE,1);
		return;}
	if(battletype == 3){
		co = picassignment[0];
		if(co == 2) co = 1;
		else if(co == 1) co = 2;	//don't know why... but they switch here
		co *= FIENDDRAW_SHIFT;
		LoadFiendChaosPic(FIENDDRAW_TABLE + co,FIENDPALETTE_TABLE + co,0);
		return;}

	int bigco;
	int size;
	CPaintDC dc(this);
	CDC mDC; mDC.CreateCompatibleDC(&dc);
	CBitmap dummy; dummy.CreateCompatibleBitmap(&dc,1,1);
	CBitmap bmp;
	BYTE pixel[2][2] = {0,2,1,3};
	BYTE colors[4];
	int temp;

	int coX, coY;

	for(bigco = 0; bigco < 4; bigco++){
		size = 4; if(picassignment[bigco] > 1) size = 6;

		m_enemies[bigco].DeleteImageList();
		m_enemies[bigco].Create(size << 3,size << 3,ILC_COLOR16,1,0);
		bmp.CreateCompatibleBitmap(&dc,size << 3,size << 3);
		mDC.SelectObject(&bmp);

		temp = BATTLEPALETTE_OFFSET + (pal[paletteassignment[bigco]] << 2);
		for(co = 0; co < 4; co++) colors[co] = cart->ROM[temp + co];

		temp = BATTLEPATTERNTABLE_OFFSET + (m_patterntables.GetCurSel() << 11) + 0x120;
		if(picassignment[bigco] > 0) temp += 0x100;
		if(picassignment[bigco] > 1) temp += 0x100;
		if(picassignment[bigco] > 2) temp += 0x240;

		for(coY = 0; coY < size; coY++){
		for(coX = 0; coX < size; coX++, temp += 16)
			DrawTile(&mDC,coX << 3,coY << 3,cart,temp,colors);
		}

		mDC.SelectObject(&dummy);
		m_enemies[bigco].Add(&bmp,RGB(255,0,255));
		bmp.DeleteObject();
	}

	mDC.DeleteDC();
	dummy.DeleteObject();
	bmp.DeleteObject();
}

void CBattle::LoadFiendChaosPic(int pattern_off,int palette_off,bool chaos)
{
	int width = 8;
	int height = 8;
	if(chaos){ width  = 14; height = 12;}
	m_enemies[0].DeleteImageList();
	m_enemies[0].Create(width << 3,height << 3,ILC_COLOR16,1,0);

	CPaintDC dc(this);
	CDC mDC; mDC.CreateCompatibleDC(&dc);
	CBitmap bmp; bmp.CreateCompatibleBitmap(&dc,width << 3,height << 3);
	mDC.SelectObject(&bmp);
	
	int offset = BATTLEPALETTE_OFFSET + (pal[0] << 2);
	int ref = BATTLEPALETTE_OFFSET + (pal[1] << 2);
	BYTE pixel[4][4] = {
	//0 palette is the battle background.  Let's just make this green because it's different depending upon location
		0x0F,0x0A,0x1A,0x2A,
	//1 palette is enemy's first loaded palette
		cart->ROM[offset],cart->ROM[offset + 1],cart->ROM[offset + 2],cart->ROM[offset + 3],
	//2 palette is enemy's second loaded palette
		cart->ROM[ref],cart->ROM[ref + 1],cart->ROM[ref + 2],cart->ROM[ref + 3],
	//3 palette is the greyscale for the border...
	 0x0F,0x00,0x0F,0x30};

	BYTE PAL_ASS[8][8];
	int coY, coX, co;
	int temp;
	for(coY = 0, co = 0; coY < 8; coY += 2){
	for(coX = 0; coX < 8; coX += 2, co++){
		temp = cart->ROM[palette_off + co];
		PAL_ASS[coY + 1][coX + 1] = (temp >> 6) & 3;
		PAL_ASS[coY + 1][coX] = (temp >> 4) & 3;
		PAL_ASS[coY][coX + 1] = (temp >> 2) & 3;
		PAL_ASS[coY][coX] = temp & 3;}}

	int palY, palX;
	co = pattern_off;
	ref = BATTLEPATTERNTABLE_OFFSET + (m_patterntables.GetCurSel() << 11);
	for(coY = 0; coY < height; coY++){
	for(coX = 0; coX < width; coX++, co++){
		offset = (cart->ROM[co] << 4) + ref;
		palY = (coY >> 1) + 1;
		palX = (coX >> 1) + 1;
		if(!chaos){ palY += 1; palX += 1;}
		DrawTile(&mDC,coX << 3,coY << 3,cart,offset,pixel[PAL_ASS[palY][palX]]);
	}}

	mDC.DeleteDC();
	m_enemies[0].Add(&bmp,TRANSPARENTCOLOR);
	bmp.DeleteObject();		
}

void CBattle::OnPaint() 
{
	CPaintDC dc(this);
	CBrush br;
	CRect rc;
	int co2;
	for(int co = 0; co < 2; co++){
		rc = rcPal[co]; rc.right = rc.left + 16;
		for(co2 = 1; co2 < 4; co2++, rc.left += 16, rc.right += 16){
			br.CreateSolidBrush(cart->Palette[0][cart->ROM[
				BATTLEPALETTE_OFFSET + (pal[co] << 2) + co2]]);
			dc.FillRect(rc,&br);
			br.DeleteObject();}
	}

	CPoint pt(rcPreview.left,rcPreview.top);
	switch(battletype){
	case 0: DrawSmallEnemies(&dc,9); break;
	case 1: DrawLargeEnemies(&dc,4); break;
	case 2: DrawLargeEnemies(&dc,2); DrawSmallEnemies(&dc,6); break;
	case 3:
		pt.x += 24; pt.y += 16;
		m_enemies[0].Draw(&dc,0,pt,ILD_NORMAL); break;
	case 4: m_enemies[0].Draw(&dc,0,pt,ILD_NORMAL); break;
	}
}

void CBattle::DrawSmallEnemies(CDC* dc,int remain)
{
	CPoint pt;
	int MessY[3] = {32,64,0};
	int drawqty;
	int co;

	pt.x = rcPreview.left;
	if(remain == 6) pt.x += 48;

	int changex = 0;

	for(int count = 0; count < 4 && remain; count++){
		if(picassignment[count] > 1) continue;
		switch(view){
		case 0: drawqty = qtymin[count]; break;
		case 1: drawqty = qtymin[count] + ((qtymax[count] - qtymin[count]) >> 1); break;
		case 2: drawqty = qtymax[count]; break;}
		if(drawqty > remain) drawqty = remain;

		for(co = 0; co < drawqty; co++, remain--, changex += 1){
			if(changex == 3){
				pt.x += 32;
				changex = 0;}
			pt.y = rcPreview.top + MessY[remain % 3];

			m_enemies[count].Draw(dc,0,pt,ILD_NORMAL);
		}
	}
}

void CBattle::DrawLargeEnemies(CDC* dc,int remain)
{
	CPoint pt;
	int drawqty;
	int co;

	pt.x = rcPreview.left;
	pt.y = rcPreview.top;

	int changex = 0;

	for(int count = 0; count < 4 && remain; count++){
		if(picassignment[count] < 2) continue;
		switch(view){
		case 0: drawqty = qtymin[count]; break;
		case 1: drawqty = qtymin[count] + ((qtymax[count] - qtymin[count]) >> 1); break;
		case 2: drawqty = qtymax[count]; break;}
		if(drawqty > remain) drawqty = remain;

		for(co = 0; co < drawqty; co++, remain--, changex += 1){
			if(changex == 2){
				pt.x += 48;
				pt.y -= 96;
				changex = 0;}

			m_enemies[count].Draw(dc,0,pt,ILD_NORMAL);
			pt.y += 48;
		}
	}
}

void CBattle::OnSelchangeBattlelist() 
{
	if(cur != -1) StoreValues();
	cur = m_battlelist.GetCurSel();
	LoadValues();
}

void CBattle::LoadValues()
{
	int offset = BATTLE_OFFSET + (cur * BATTLE_BYTES);
	int temp;
	CString text;

	temp = cart->ROM[offset];
	UpdateBattleType(temp >> 4,0);
	m_patterntables.SetCurSel(temp & 0x0F);

	//the bits in byte 2 are reversed!  Dammit!
	temp = 0;
	for(int co = 1, co2 = 128; co <= 128; co <<= 1, co2 >>= 1)
		if(cart->ROM[offset + 1] & co2) temp |= co;
	UpdatePicAssignment(-1,temp,0);

	m_enemy1.SetCurSel(cart->ROM[offset + 2]);
	m_enemy2.SetCurSel(cart->ROM[offset + 3]);
	m_enemy3.SetCurSel(cart->ROM[offset + 4]);
	m_enemy4.SetCurSel(cart->ROM[offset + 5]);

	temp = cart->ROM[offset + 6 + (form * 8)];
	qtymin[0] = temp >> 4; qtymax[0] = temp & 0x0F;
	text.Format("%d",qtymin[0]); m_qtymin_1.SetWindowText(text);
	text.Format("%d",qtymax[0]); m_qtymax_1.SetWindowText(text);
	
	temp = cart->ROM[offset + 7 + (form * 8)];
	qtymin[1] = temp >> 4; qtymax[1] = temp & 0x0F;
	text.Format("%d",qtymin[1]); m_qtymin_2.SetWindowText(text);
	text.Format("%d",qtymax[1]); m_qtymax_2.SetWindowText(text);

	if(!form){
		temp = cart->ROM[offset + 8];
		qtymin[2] = temp >> 4; qtymax[2] = temp & 0x0F;
		text.Format("%d",qtymin[2]); m_qtymin_3.SetWindowText(text);
		text.Format("%d",qtymax[2]); m_qtymax_3.SetWindowText(text);
		
		temp = cart->ROM[offset + 9];
		qtymin[3] = temp >> 4; qtymax[3] = temp & 0x0F;
		text.Format("%d",qtymin[3]); m_qtymin_4.SetWindowText(text);
		text.Format("%d",qtymax[3]); m_qtymax_4.SetWindowText(text);}

	pal[0] = cart->ROM[offset + 10];
	pal[1] = cart->ROM[offset + 11];

	text.Format("%d",cart->ROM[offset + 12]);
	m_suprised.SetWindowText(text);

	temp = cart->ROM[offset + 13];
	UpdatePaletteAssignment(-1,temp >> 4,0);
	m_norun.SetCheck(temp & 1);

	ReloadGraphics();
	InvalidateRect(rcPreview);
	UpdatePalettes();
}

void CBattle::StoreValues()
{
	int offset = BATTLE_OFFSET + (cur * BATTLE_BYTES);
	int temp;
	int co, co2;
	CString text;

	cart->ROM[offset] = (battletype << 4) + m_patterntables.GetCurSel();

	//Remember..these bits are reversed!
	temp = 0;
	for(co = 0; co < 4; co++){
		temp <<= 2; temp += picassignment[co];}
	cart->ROM[offset + 1] = 0;
	for(co = 1, co2 = 128; co <= 128; co <<= 1, co2 >>= 1)	//reversed!
		if(temp & co2) cart->ROM[offset + 1] |= co;

	cart->ROM[offset + 2] = m_enemy1.GetCurSel();
	cart->ROM[offset + 3] = m_enemy2.GetCurSel();
	cart->ROM[offset + 4] = m_enemy3.GetCurSel();
	cart->ROM[offset + 5] = m_enemy4.GetCurSel();

	cart->ROM[offset + 6 + (form * 8)] = (qtymin[0] << 4) + qtymax[0];
	cart->ROM[offset + 7 + (form * 8)] = (qtymin[1] << 4) + qtymax[1];
	if(!form){
		cart->ROM[offset + 8] = (qtymin[2] << 4) + qtymax[2];
		cart->ROM[offset + 9] = (qtymin[3] << 4) + qtymax[3];}

	cart->ROM[offset + 10] = pal[0];
	cart->ROM[offset + 11] = pal[1];

	m_suprised.GetWindowText(text); temp = StringToInt(text);
	if(temp > 0xFF) temp = 0xFF;
	cart->ROM[offset + 12] = temp;

	cart->ROM[offset + 13] =
		(paletteassignment[0] << 7) +
		(paletteassignment[1] << 6) +
		(paletteassignment[2] << 5) +
		(paletteassignment[3] << 4) +
		(m_norun.GetCheck() != 0);
}

void CBattle::UpdateBattleType(int type, bool redraw)
{
	battletype = type;
	m_type1.SetCheck(battletype == 0);
	m_type2.SetCheck(battletype == 1);
	m_type3.SetCheck(battletype == 2);
	m_type4.SetCheck(battletype == 3);
	m_type5.SetCheck(battletype == 4);
	if(redraw) InvalidateRect(rcPreview);
}

void CBattle::UpdatePicAssignment(int en, int pic, bool redraw)
{
	if(en == -1){
		for(en = 3; en >= 0; en--, pic >>= 2)
			picassignment[en] = pic & 3;}
	else
		picassignment[en] = pic & 3;

	m_pica_1.SetCheck(picassignment[0] == 0);
	m_picb_1.SetCheck(picassignment[0] == 1);
	m_picc_1.SetCheck(picassignment[0] == 2);
	m_picd_1.SetCheck(picassignment[0] == 3);
	m_pica_2.SetCheck(picassignment[1] == 0);
	m_picb_2.SetCheck(picassignment[1] == 1);
	m_picc_2.SetCheck(picassignment[1] == 2);
	m_picd_2.SetCheck(picassignment[1] == 3);
	m_pica_3.SetCheck(picassignment[2] == 0);
	m_picb_3.SetCheck(picassignment[2] == 1);
	m_picc_3.SetCheck(picassignment[2] == 2);
	m_picd_3.SetCheck(picassignment[2] == 3);
	m_pica_4.SetCheck(picassignment[3] == 0);
	m_picb_4.SetCheck(picassignment[3] == 1);
	m_picc_4.SetCheck(picassignment[3] == 2);
	m_picd_4.SetCheck(picassignment[3] == 3);

	if(redraw){
		ReloadGraphics();
		InvalidateRect(rcPreview);}
}

void CBattle::UpdateQtyMin()
{
	CString text;
	m_qtymin_1.GetWindowText(text); qtymin[0] = StringToInt(text);
	m_qtymin_2.GetWindowText(text); qtymin[1] = StringToInt(text);
	m_qtymin_3.GetWindowText(text); qtymin[2] = StringToInt(text);
	m_qtymin_4.GetWindowText(text); qtymin[3] = StringToInt(text);

	if(view != 2) InvalidateRect(rcPreview);
}

void CBattle::UpdateQtyMax()
{
	CString text;
	m_qtymax_1.GetWindowText(text); qtymax[0] = StringToInt(text);
	m_qtymax_2.GetWindowText(text); qtymax[1] = StringToInt(text);
	m_qtymax_3.GetWindowText(text); qtymax[2] = StringToInt(text);
	m_qtymax_4.GetWindowText(text); qtymax[3] = StringToInt(text);

	if(view != 0) InvalidateRect(rcPreview);
}

void CBattle::UpdatePaletteAssignment(int en, int pal, bool redraw)
{
	if(en == -1){
		for(en = 3; en >= 0; en--, pal >>= 1)
			paletteassignment[en] = (pal & 1) == 1;}
	else
		paletteassignment[en] = (pal & 1) == 1;

	m_pala_1.SetCheck(!paletteassignment[0]);
	m_palb_1.SetCheck( paletteassignment[0]);
	m_pala_2.SetCheck(!paletteassignment[1]);
	m_palb_2.SetCheck( paletteassignment[1]);
	m_pala_3.SetCheck(!paletteassignment[2]);
	m_palb_3.SetCheck( paletteassignment[2]);
	m_pala_4.SetCheck(!paletteassignment[3]);
	m_palb_4.SetCheck( paletteassignment[3]);

	if(redraw){
		ReloadGraphics();
		InvalidateRect(rcPreview,0);}
}

void CBattle::UpdatePalettes()
{
	CString text;
	CStatic* m_text[2] = {&m_palette1,&m_palette2};
	for(int co = 0; co < 2; co++){
		if(pal[co] < 0x10) text.Format("[0%X]",pal[co]);
		else text.Format("[%X]",pal[co]);
		m_text[co]->SetWindowText(text);}

	InvalidateRect(rcPal[0],0);
	InvalidateRect(rcPal[1],0);
}

void CBattle::OnViewmax() 
{UpdateView(2);}
void CBattle::OnViewmean() 
{UpdateView(1);}
void CBattle::OnViewmin() 
{UpdateView(0);}
void CBattle::UpdateView(int v)
{view = v;
m_viewmin.SetCheck(v == 0);
m_viewmean.SetCheck(v == 1);
m_viewmax.SetCheck(v == 2);
InvalidateRect(rcPreview);}
void CBattle::OnForm1() 
{UpdateForm(0);}
void CBattle::OnForm2() 
{UpdateForm(1);}
void CBattle::UpdateForm(bool b)
{
	m_form1.SetCheck(!b);
	m_form2.SetCheck(b);
	if(form == b) return;
	StoreValues();
	form = b;
	m_qtymin_3.EnableWindow(!b);
	m_qtymin_4.EnableWindow(!b);
	m_qtymax_3.EnableWindow(!b);
	m_qtymax_4.EnableWindow(!b);
	m_enemy3.EnableWindow(!b);
	m_enemy4.EnableWindow(!b);
	m_pala_3.EnableWindow(!b);
	m_palb_3.EnableWindow(!b);
	m_pala_4.EnableWindow(!b);
	m_palb_4.EnableWindow(!b);
	m_pica_3.EnableWindow(!b);
	m_picb_3.EnableWindow(!b);
	m_picc_3.EnableWindow(!b);
	m_picd_3.EnableWindow(!b);
	m_pica_4.EnableWindow(!b);
	m_picb_4.EnableWindow(!b);
	m_picc_4.EnableWindow(!b);
	m_picd_4.EnableWindow(!b);
	if(b){
		CString text = "";
		m_qtymin_3.SetWindowText(text);
		m_qtymin_4.SetWindowText(text);
		m_qtymax_3.SetWindowText(text);
		m_qtymax_4.SetWindowText(text);}
	LoadValues();
}
void CBattle::OnSelchangePatterntables() 
{ReloadGraphics(); InvalidateRect(rcPreview,0);}
void CBattle::OnType1()
{UpdateType(0);}
void CBattle::OnType2()
{UpdateType(1);}
void CBattle::OnType3()
{UpdateType(2);}
void CBattle::OnType4()
{UpdateType(3);}
void CBattle::OnType5()
{UpdateType(4);}
void CBattle::UpdateType(int update)
{
	if(battletype == update) return;
	m_type1.SetCheck(update == 0);
	m_type2.SetCheck(update == 1);
	m_type3.SetCheck(update == 2);
	m_type4.SetCheck(update == 3);
	m_type5.SetCheck(update == 4);
	if(update >= 3 || (update < 3 && battletype >= 3)){
		battletype = update;
		ReloadGraphics(); InvalidateRect(rcPreview);}
	battletype = update;
	InvalidateRect(rcPreview);
}
void CBattle::OnPala1() 
{UpdatePaletteAssignment(0,0);}
void CBattle::OnPalb1() 
{UpdatePaletteAssignment(0,1);}
void CBattle::OnPala2() 
{UpdatePaletteAssignment(1,0);}
void CBattle::OnPalb2() 
{UpdatePaletteAssignment(1,1);}
void CBattle::OnPala3() 
{UpdatePaletteAssignment(2,0);}
void CBattle::OnPalb3() 
{UpdatePaletteAssignment(2,1);}
void CBattle::OnPala4() 
{UpdatePaletteAssignment(3,0);}
void CBattle::OnPalb4() 
{UpdatePaletteAssignment(3,1);}
void CBattle::OnPica1()
{UpdatePicAssignment(0,0);}
void CBattle::OnPicb1()
{UpdatePicAssignment(0,1);}
void CBattle::OnPicc1()
{UpdatePicAssignment(0,2);}
void CBattle::OnPicd1()
{UpdatePicAssignment(0,3);}
void CBattle::OnPica2()
{UpdatePicAssignment(1,0);}
void CBattle::OnPicb2()
{UpdatePicAssignment(1,1);}
void CBattle::OnPicc2()
{UpdatePicAssignment(1,2);}
void CBattle::OnPicd2()
{UpdatePicAssignment(1,3);}
void CBattle::OnPica3()
{UpdatePicAssignment(2,0);}
void CBattle::OnPicb3()
{UpdatePicAssignment(2,1);}
void CBattle::OnPicc3()
{UpdatePicAssignment(2,2);}
void CBattle::OnPicd3()
{UpdatePicAssignment(2,3);}
void CBattle::OnPica4()
{UpdatePicAssignment(3,0);}
void CBattle::OnPicb4()
{UpdatePicAssignment(3,1);}
void CBattle::OnPicc4()
{UpdatePicAssignment(3,2);}
void CBattle::OnPicd4()
{UpdatePicAssignment(3,3);}

void CBattle::OnEditbatlabel() 
{
	int temp = m_battlelist.GetCurSel();
	ChangeLabel(BATTLELABEL_SIZE,cart->dat.BattleLabels[temp],temp,&m_battlelist,NULL);
}

void CBattle::OnEditpatlabel() 
{
	int temp = m_patterntables.GetCurSel();
	ChangeLabel(BATTLEPATTERNTABLELABEL_SIZE,cart->dat.BattlePatternTableLabels[temp],
		temp,NULL,&m_patterntables);
}

void CBattle::OnLButtonDown(UINT nFlags, CPoint pt) 
{
	int coX;
	for(int co = 0; co < 2; co++){
		if(PtInRect(rcPal[co],pt)){
			coX = (pt.x - rcPal[co].left) >> 4;
			CNESPalette dlg;
			dlg.cart = cart;
			dlg.color = &cart->ROM[BATTLEPALETTE_OFFSET + (pal[co] << 2) + coX + 1];
			if(dlg.DoModal() == IDOK){
				ReloadGraphics();
				InvalidateRect(rcPreview,0);
				InvalidateRect(rcPal[0],0);
				InvalidateRect(rcPal[1],0);}
		}
	}
}
 

void CBattle::OnChangepal1() 
{
	CBattlePalettes dlg;
	dlg.oldpal = pal[0];
	dlg.cart = cart;
	if(dlg.DoModal() == IDOK){
		pal[0] = dlg.newpal;
		ReloadGraphics();
		UpdatePalettes();
		InvalidateRect(rcPreview,0);
	}
}

void CBattle::OnChangepal2() 
{
	CBattlePalettes dlg;
	dlg.oldpal = pal[1];
	dlg.cart = cart;
	if(dlg.DoModal() == IDOK){
		pal[1] = dlg.newpal;
		ReloadGraphics();
		UpdatePalettes();
		InvalidateRect(rcPreview,0);
	}
}

void CBattle::OnEditgraphic() 
{
	StoreValues();
	SaveRomToFile(cart);

	CBattlePatternTables dlg;
	dlg.cart = cart;
	dlg.patterntable = BYTE(m_patterntables.GetCurSel());
	if(battletype < 3) dlg.view = 0;
	if(battletype == 4) dlg.view = 5;
	if(battletype == 3){
		BYTE temp[4] = {1,3,2,4};
		dlg.view = temp[picassignment[0]];
	}
	dlg.palvalues[0] = pal[0];
	dlg.palvalues[1] = pal[1];

	dlg.DoModal();
	
	ReloadGraphics();
	InvalidateRect(rcPreview,0);
	UpdatePalettes();
}

void CBattle::OnSave() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
}

void CBattle::OnOK() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
	else
		CDialog::OnOK();
}

void CBattle::OnCancel() 
{
	ReLoadROM(cart);
	CDialog::OnCancel();
}
