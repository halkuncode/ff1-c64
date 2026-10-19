// Shop.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "Shop.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CShop dialog


CShop::CShop(CWnd* pParent /*=NULL*/)
	: CDialog(CShop::IDD, pParent)
{
	//{{AFX_DATA_INIT(CShop)
	//}}AFX_DATA_INIT
}


void CShop::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CShop)
	DDX_Control(pDX, IDC_STARTINGGOLD, m_startinggold);
	DDX_Control(pDX, IDC_PRICE5, m_price5);
	DDX_Control(pDX, IDC_PRICE4, m_price4);
	DDX_Control(pDX, IDC_PRICE3, m_price3);
	DDX_Control(pDX, IDC_PRICE2, m_price2);
	DDX_Control(pDX, IDC_PRICE1, m_price1);
	DDX_Control(pDX, IDC_SHOPTYPE, m_shoptype);
	DDX_Control(pDX, IDC_SHOP, m_shop);
	DDX_Control(pDX, IDC_REMOVE5, m_remove5);
	DDX_Control(pDX, IDC_REMOVE4, m_remove4);
	DDX_Control(pDX, IDC_REMOVE3, m_remove3);
	DDX_Control(pDX, IDC_REMOVE2, m_remove2);
	DDX_Control(pDX, IDC_REMOVE1, m_remove1);
	DDX_Control(pDX, IDC_PRICETEXT, m_pricetext);
	DDX_Control(pDX, IDC_PRICE, m_price);
	DDX_Control(pDX, IDC_POINTER, m_pointer);
	DDX_Control(pDX, IDC_KAB, m_kab);
	DDX_Control(pDX, IDC_ITEM5, m_item5);
	DDX_Control(pDX, IDC_ITEM4, m_item4);
	DDX_Control(pDX, IDC_ITEM3, m_item3);
	DDX_Control(pDX, IDC_ITEM2, m_item2);
	DDX_Control(pDX, IDC_ITEM1, m_item1);
	DDX_Control(pDX, IDC_CHANGEPTR, m_changeptr);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CShop, CDialog)
	//{{AFX_MSG_MAP(CShop)
	ON_LBN_SELCHANGE(IDC_SHOP, OnSelchangeShop)
	ON_LBN_SELCHANGE(IDC_SHOPTYPE, OnSelchangeShoptype)
	ON_BN_CLICKED(IDC_REMOVE1, OnRemove1)
	ON_BN_CLICKED(IDC_REMOVE2, OnRemove2)
	ON_BN_CLICKED(IDC_REMOVE3, OnRemove3)
	ON_BN_CLICKED(IDC_REMOVE4, OnRemove4)
	ON_BN_CLICKED(IDC_REMOVE5, OnRemove5)
	ON_EN_UPDATE(IDC_POINTER, OnUpdatePointer)
	ON_BN_CLICKED(IDC_CHANGEPTR, OnChangeptr)
	ON_BN_CLICKED(IDC_SAVE, OnSave)
	ON_BN_CLICKED(IDC_DELETESLOT, OnDeleteslot)
	ON_BN_CLICKED(IDC_NEWSLOT, OnNewslot)
	ON_CBN_SELCHANGE(IDC_ITEM1, OnSelchangeItem1)
	ON_CBN_SELCHANGE(IDC_ITEM2, OnSelchangeItem2)
	ON_CBN_SELCHANGE(IDC_ITEM3, OnSelchangeItem3)
	ON_CBN_SELCHANGE(IDC_ITEM4, OnSelchangeItem4)
	ON_CBN_SELCHANGE(IDC_ITEM5, OnSelchangeItem5)
	ON_BN_CLICKED(IDC_EDITLABEL, OnEditlabel)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CShop message handlers

BOOL CShop::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	if(!ReLoadROM(cart)){
		CDialog::OnCancel();
		return 0;}
	
	// TODO: Add extra initialization here
	CString shoptypes[7] = {"Weapon","Armor","White","Black","Clinic","Inn","Item"};

	for(int co = 0; co < 7; co++)
		m_shoptype.InsertString(co,shoptypes[co]);

	m_item[0] = &m_item1;
	m_item[1] = &m_item2;
	m_item[2] = &m_item3;
	m_item[3] = &m_item4;
	m_item[4] = &m_item5;
	m_remove[0] = &m_remove1;
	m_remove[1] = &m_remove2;
	m_remove[2] = &m_remove3;
	m_remove[3] = &m_remove4;
	m_remove[4] = &m_remove5;
	m_itprice[0] = &m_price1;
	m_itprice[1] = &m_price2;
	m_itprice[2] = &m_price3;
	m_itprice[3] = &m_price4;
	m_itprice[4] = &m_price5;

	for(co = 0; co < 5; co++){
		PutHexToList(cart,MAGICTEXT_OFFSET,BASICTEXT_PTRADD,MAGIC_COUNT,cart->dat.TextViewInDTE[4],NULL,m_item[co]);
		PutHexToList(cart,GOLDITEMTEXT_OFFSET,BASICTEXT_PTRADD,GOLDITEM_COUNT,cart->dat.TextViewInDTE[3],NULL,m_item[co]);
		PutHexToList(cart,ARMORTEXT_OFFSET,BASICTEXT_PTRADD,ARMOR_COUNT,cart->dat.TextViewInDTE[2],NULL,m_item[co]);
		PutHexToList(cart,WEAPONTEXT_OFFSET,BASICTEXT_PTRADD,WEAPON_COUNT,cart->dat.TextViewInDTE[1],NULL,m_item[co]);
		PutHexToList(cart,BASICTEXT_OFFSET,BASICTEXT_PTRADD,ITEM_COUNT,cart->dat.TextViewInDTE[0],NULL,m_item[co]);
	}

	cur_type = -1;
	m_shoptype.SetCurSel(0);
	OnSelchangeShoptype();

	FindKAB();
	return 1;
}

void CShop::OnSelchangeShop() 
{
	if(cur != -1) StoreValues();

	cur = m_shop.GetCurSel();

	LoadValues();
}

void CShop::OnSelchangeShoptype() 
{
	if(cur_type != -1) StoreValues();

	cur_type = m_shoptype.GetCurSel();
	while(m_shop.GetCount()) m_shop.DeleteString(0);
	for(int co = 0; co < 10;co++)
		m_shop.InsertString(co,cart->dat.ShopLabels[co + (cur_type * 10)]);
	cur = 0;
	m_shop.SetCurSel(0);

	LoadValues();
}

void CShop::FindKAB()
{
	int thispointer;
	int largestpointer = SHOP_START;
	int ptrref = 0;
	
	for(int co = SHOP_OFFSET; co < SHOP_START; co++){
		thispointer = cart->ROM[co] + (cart->ROM[co + 1] << 8) + SHOP_PTRADD;
		if(thispointer < SHOP_END && thispointer > largestpointer){
			largestpointer = thispointer;
			ptrref = co;
	}}
	if(ptrref == 0)
		kab = SHOP_END - SHOP_START;
	else if(ptrref >= 0x38362 && ptrref < 0x3838A){
		//if it's in these bounds... it is a Inn/Clinic... reserve 2 bytes, no break
		kab = SHOP_END - largestpointer - 2;}
	else{
		//if we got here... a normal shop is at the end.  determine it's size and
		// reserve 1 extra byte (for the break)
		for(co = largestpointer; cart->ROM[co]; co++);
		kab = SHOP_END - co - 1;}

	CString text; text.Format("%d",kab);
	m_kab.SetWindowText(text);
}

void CShop::LoadValues()
{
	ptroffset = (cur_type * 20) + (cur << 1) + SHOP_OFFSET;
	int offset = cart->ROM[ptroffset] + (cart->ROM[ptroffset + 1] << 8) + SHOP_PTRADD;

	CString text;
	text.Format("%X",offset);
	m_pointer.SetWindowText(text);

	bool hasprice = (cur_type == 4) || (cur_type == 5);
	m_price.ShowWindow(hasprice);
	m_pricetext.ShowWindow(hasprice);
	int temp, co;

	if(hasprice){
		for(co = 0; co < 5; co++){
			m_item[co]->ShowWindow(0);
			m_remove[co]->ShowWindow(0);
			m_itprice[co]->ShowWindow(0);}
		temp = cart->ROM[offset] + (cart->ROM[offset + 1] << 8);
		text.Format("%d",temp);
		m_price.SetWindowText(text);
		numitems = -1;}
	else{
		for(temp = 0; cart->ROM[offset + temp]; temp++);
		if(temp > 5) temp = 5;
		text = "Remove Item";
		for(co = 0; co < temp; co++){
			m_curitem[co] = cart->ROM[offset + co] - 1;
			m_item[co]->SetCurSel(m_curitem[co]);
			m_item[co]->ShowWindow(1);
			m_remove[co]->SetWindowText(text);
			m_remove[co]->ShowWindow(1);
			m_itprice[co]->ShowWindow(1);
			LoadPrice(co);}
		for(co = temp; co < 5; co++){
			m_curitem[co] = -1;
			m_item[co]->ShowWindow(0);
			m_remove[co]->ShowWindow(0);
			m_itprice[co]->ShowWindow(0);}
		if(temp < 5){
			text = "Add Item";
			m_remove[temp]->SetWindowText(text);
			m_remove[temp]->ShowWindow(1);}
		numitems = temp;
	}

	temp = cart->ROM[STARTINGGOLD_OFFSET] + (cart->ROM[STARTINGGOLD_OFFSET + 1] << 8) + (cart->ROM[STARTINGGOLD_OFFSET + 2] << 16);
	text.Format("%d",temp);
	m_startinggold.SetWindowText(text);

	m_changeptr.EnableWindow(0);
}

void CShop::StoreValues()
{
	int offset = cart->ROM[ptroffset] + (cart->ROM[ptroffset + 1] << 8) + SHOP_PTRADD;
	bool hasprice = (cur_type == 4) || (cur_type == 5);
	CString text;
	int temp;

	if(hasprice){
		m_price.GetWindowText(text); temp = StringToInt(text);
		if(temp > 0xFFFF) temp = 0xFFFF;
		cart->ROM[offset] = temp & 0xFF;
		cart->ROM[offset + 1] = temp >> 8;}
	else{
		for(int co = 0; co < numitems; co++){
			StorePrice(co);
			cart->ROM[offset + co] = m_item[co]->GetCurSel() + 1;}
	}

	m_startinggold.GetWindowText(text);
	temp = StringToInt(text); if(temp > 0xFFFFFF) temp = 0xFFFFFF;
	cart->ROM[STARTINGGOLD_OFFSET    ] = temp & 0xFF; temp >>= 8;
	cart->ROM[STARTINGGOLD_OFFSET + 1] = temp & 0xFF; temp >>= 8;
	cart->ROM[STARTINGGOLD_OFFSET + 2] = temp & 0xFF;
}

void CShop::LoadPrice(int co)
{
	int offset = ITEMPRICE_OFFSET + (m_curitem[co] << 1);
	int temp = cart->ROM[offset] + (cart->ROM[offset + 1] << 8);
	CString text; text.Format("%d",temp);
	m_itprice[co]->SetWindowText(text);
}

void CShop::StorePrice(int co)
{
	if(m_curitem[co] == -1) return;
	int offset = ITEMPRICE_OFFSET + (m_curitem[co] << 1);
	CString text;
	m_itprice[co]->GetWindowText(text); int temp = StringToInt(text);
	if(temp > 0xFFFF) temp = 0xFFFF;
	cart->ROM[offset] = temp & 0xFF;
	cart->ROM[offset + 1] = temp >> 8;
}

void CShop::OnRemove1() 
{Remove(0);}
void CShop::OnRemove2() 
{Remove(1);}
void CShop::OnRemove3() 
{Remove(2);}
void CShop::OnRemove4() 
{Remove(3);}
void CShop::OnRemove5() 
{Remove(4);}

void CShop::Remove(int id)
{
	StoreValues();
	if(id == numitems){
		Add(id);
		return;}

	numitems -= 1;
	int thisptr = cart->ROM[ptroffset] + (cart->ROM[ptroffset + 1] << 8) + SHOP_PTRADD;
	if(thisptr < SHOP_START || thisptr >= SHOP_END){
		cart->ROM[thisptr + id] = 0x00;
		return;}

	int temp;
	//shift all greater pointers left
	for(int co = SHOP_OFFSET; co < SHOP_START; co += 2){
		temp = cart->ROM[co] + (cart->ROM[co + 1] << 8) + SHOP_PTRADD;
		if(temp > thisptr && temp < SHOP_END){
			temp -= SHOP_PTRADD + 1;
			cart->ROM[co] = temp & 0xFF;
			cart->ROM[co + 1] = temp >> 8;}}

	//shift all data to the left
	for(co = thisptr + id; co < SHOP_END - 1; co++)
		cart->ROM[co] = cart->ROM[co + 1];

	LoadValues();
	FindKAB();
}

void CShop::Add(int id)
{
	StoreValues();
	int thisptr = cart->ROM[ptroffset] + (cart->ROM[ptroffset + 1] << 8) + SHOP_PTRADD;
	int temp;
	if(thisptr < SHOP_START || thisptr >= SHOP_END){
		if(AfxMessageBox("This data is not within standard boundaries.\nIncreasing the size of this data may result in overwriting something.\nAre you sure you want to continue?",MB_YESNO) == IDNO)
			return;
		cart->ROM[thisptr + id] = 1;
		cart->ROM[thisptr + id + 1] = 0;}
	else{
		if(kab < 1){
			AfxMessageBox("Don't have enough KAB.\nCould not increase shop size.");
			return;}

		//shift larger pointers to the right
		for(int co = SHOP_OFFSET; co < SHOP_START; co += 2){
			temp = cart->ROM[co] + (cart->ROM[co + 1] << 8) + SHOP_PTRADD;
			if(temp > thisptr && temp < SHOP_END){
				temp -= SHOP_PTRADD - 1;
				cart->ROM[co] = temp & 0xFF;
				cart->ROM[co + 1] = temp >> 8;}}

		//shift all the data to the right
		for(co = SHOP_END - 2; co >= thisptr + id; co--)
			cart->ROM[co + 1] = cart->ROM[co];

		//insert a non-zero number in the new slot
		cart->ROM[thisptr + id] = 1;
	}

	LoadValues();
	FindKAB();
}

void CShop::OnUpdatePointer() 
{m_changeptr.EnableWindow(1);}

void CShop::OnChangeptr() 
{
	StoreValues();
	CString text;
	m_pointer.GetWindowText(text);

	int temp = StringToInt_HEX(text) - SHOP_PTRADD;

	if(temp < 0 || temp > 0x10000){
		text.Format("Pointer is out of range.\nMust be between %X-%X",SHOP_PTRADD,SHOP_PTRADD + 0x10000);
		AfxMessageBox(text);
		LoadValues();
		FindKAB();
		return;}

	cart->ROM[ptroffset] = temp & 0xFF;
	cart->ROM[ptroffset + 1] = temp >> 8;

	LoadValues();
	FindKAB();
	return;
}

void CShop::OnSave() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
}

void CShop::OnOK() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
	else
		CDialog::OnOK();
}

void CShop::OnCancel() 
{
	ReLoadROM(cart);
	CDialog::OnCancel();
}

void CShop::OnDeleteslot() 
{
	int offset = cart->ROM[ptroffset] + (cart->ROM[ptroffset + 1] << 8) + SHOP_PTRADD;
	if(offset < SHOP_START || offset > SHOP_END){
		AfxMessageBox("The slot is not in the standard shop boundaries.\nCannot remove slot.");
		return;}

	int largestptr = SHOP_START;
	int thisptr;
	for(int co = SHOP_OFFSET; co < SHOP_START; co += 2){
		thisptr = cart->ROM[co] + (cart->ROM[co + 1] << 8) + SHOP_PTRADD;
		if(thisptr > largestptr && thisptr < SHOP_END)
			largestptr = thisptr;}

	if(largestptr == offset){
		AfxMessageBox("This is the last slot.\nCannot delete the last slot.");
		return;}
		
	if(AfxMessageBox("Really delete this slot?",MB_YESNO) == IDNO) return;

	int shift = numitems;
	if(numitems == -1) shift = 2;
	for(co = SHOP_OFFSET; co < SHOP_START; co += 2){
		thisptr = cart->ROM[co] + (cart->ROM[co + 1] << 8) + SHOP_PTRADD;
		if(thisptr > offset){
			thisptr -= SHOP_PTRADD + shift;
			cart->ROM[co] = thisptr & 0xFF;
			cart->ROM[co + 1] = thisptr >> 8;
		}
	}

	for(co = offset + shift; co < SHOP_END; co++)
		cart->ROM[co - shift] = cart->ROM[co];

	FindKAB();
	LoadValues();
}

void CShop::OnNewslot() 
{
	int minkab = 1;
	if((cur_type == 4) || (cur_type == 5)) minkab = 2;

	if(kab < minkab){
		AfxMessageBox("Not enough KAB.\nCannot create a new slot.");
		return;}

	int newptr = SHOP_END - kab;

	for(minkab--; minkab >= 0; minkab--)
		cart->ROM[newptr + minkab] = 0;

	newptr -= SHOP_PTRADD;
	cart->ROM[ptroffset] = newptr & 0xFF;
	cart->ROM[ptroffset + 1] = newptr >> 8;


	FindKAB();
	LoadValues();
}

void CShop::OnSelchangeItem1() 
{SelChangeItem(0);}
void CShop::OnSelchangeItem2() 
{SelChangeItem(1);}
void CShop::OnSelchangeItem3() 
{SelChangeItem(2);}
void CShop::OnSelchangeItem4() 
{SelChangeItem(3);}
void CShop::OnSelchangeItem5() 
{SelChangeItem(4);}

void CShop::SelChangeItem(int co)
{
	if(m_curitem[co] != -1) StorePrice(co);
	m_curitem[co] = m_item[co]->GetCurSel();
	LoadPrice(co);
}

void CShop::OnEditlabel() 
{
	ChangeLabel(SHOPLABEL_SIZE,cart->dat.ShopLabels[(cur_type * 10) + cur],cur,&m_shop,NULL);
}
