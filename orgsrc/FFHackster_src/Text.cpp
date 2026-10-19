// Text.cpp : implementation file
//

#include "stdafx.h"
#include "FFHackster.h"
#include "Text.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CText dialog


CText::CText(CWnd* pParent /*=NULL*/)
	: CDialog(CText::IDD, pParent)
{
	//{{AFX_DATA_INIT(CText)
	//}}AFX_DATA_INIT
}


void CText::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CText)
	DDX_Control(pDX, IDC_CHANGEPTR, m_changeptr);
	DDX_Control(pDX, IDC_NEWSLOT, m_newslot);
	DDX_Control(pDX, IDC_EDITLABEL, m_editlabel);
	DDX_Control(pDX, IDC_KAB, m_kab);
	DDX_Control(pDX, IDC_POINTER, m_pointer);
	DDX_Control(pDX, IDC_DTE, m_dte);
	DDX_Control(pDX, IDC_DIALOGUEBOX, m_dialoguebox);
	DDX_Control(pDX, IDC_TEXTBOX, m_textbox);
	DDX_Control(pDX, IDC_TEXTLIST, m_textlist);
	DDX_Control(pDX, IDC_MAINLIST, m_mainlist);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CText, CDialog)
	//{{AFX_MSG_MAP(CText)
	ON_LBN_SELCHANGE(IDC_MAINLIST, OnSelchangeMainlist)
	ON_LBN_SELCHANGE(IDC_TEXTLIST, OnSelchangeTextlist)
	ON_BN_CLICKED(IDC_EDITLABEL, OnEditlabel)
	ON_BN_CLICKED(IDC_DTE, OnDte)
	ON_BN_CLICKED(IDC_UPDATE, OnUpdate)
	ON_BN_CLICKED(IDC_SAVE, OnSave)
	ON_EN_UPDATE(IDC_TEXTBOX, OnUpdateTextbox)
	ON_EN_UPDATE(IDC_POINTER, OnUpdatePointer)
	ON_BN_CLICKED(IDC_CHANGEPTR, OnChangeptr)
	ON_BN_CLICKED(IDC_DELETESLOT, OnDeleteslot)
	ON_EN_UPDATE(IDC_DIALOGUEBOX, OnUpdateTextbox)
	ON_BN_CLICKED(IDC_NEWSLOT, OnNewslot)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CText message handlers

BOOL CText::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	if(!ReLoadROM(cart)){
		CDialog::OnCancel();
		return 0;}
	
	CString MainListText[10] = {"Items","Weapons","Armor","Gold","Magic","Classes","Enemy Attacks","Enemies","Dialogue","Battle Messages"};
	for(int co = 0; co < 10; co++)
		m_mainlist.InsertString(co,MainListText[co]);

	m_mainlist.SetCurSel(0);
	cur_main = -1;
	OnSelchangeMainlist();

	return 1;
}

void CText::OnSelchangeMainlist() 
{
	if(cur_main != -1 && madechange)
		StoreValues();

	cur_main = m_mainlist.GetCurSel();
	viewDTE = cart->dat.TextViewInDTE[cur_main];

	m_textbox.ShowWindow(cur_main != 8);
	m_editlabel.ShowWindow(cur_main == 8);
	m_dialoguebox.ShowWindow(cur_main == 8);
	m_dte.SetCheck(viewDTE);

	ResetTextList();

	cur_text = -1;
	m_textlist.SetCurSel(0);
	OnSelchangeTextlist();
}

void CText::ResetTextList()
{
	while(m_textlist.GetCount()) m_textlist.DeleteString(0);
	ptradd = BASICTEXT_PTRADD;
	ptroffset = BASICTEXT_OFFSET;
	count = ITEM_COUNT;
	if(cur_main < 6){
		if(cur_main > 0){ ptroffset += count << 1; count = WEAPON_COUNT;}
		if(cur_main > 1){ ptroffset += count << 1; count = ARMOR_COUNT;}
		if(cur_main > 2){ ptroffset += count << 1; count = GOLDITEM_COUNT;}
		if(cur_main > 3){ ptroffset += count << 1; count = MAGIC_COUNT;}
		if(cur_main > 4){ ptroffset += count << 1; count = CLASS_COUNT;}}
	else if(cur_main == 6){
		ptroffset =	ATTACKTEXT_OFFSET;
		ptradd = ATTACKTEXT_PTRADD;
		count = ATTACK_COUNT;}
	else if(cur_main == 7){
		ptroffset =	ENEMYTEXT_OFFSET;
		ptradd = ENEMYTEXT_PTRADD;
		count = ENEMY_COUNT;}
	else if(cur_main == 8){
		ptroffset = DIALOGUE_OFFSET;
		ptradd = DIALOGUE_PTRADD;
		count = DIALOGUE_COUNT;}
	else if(cur_main == 9){
		ptroffset =	BATTLEMESSAGETEXT_OFFSET;
		ptradd = BATTLEMESSAGETEXT_PTRADD;
		count = BATTLEMESSAGE_COUNT;}

	if(cur_main != 8)
		PutHexToList(cart,ptroffset,ptradd,count,viewDTE,&m_textlist,NULL);
	else{
		for(int co = 0; co < DIALOGUE_COUNT; co++)
			m_textlist.InsertString(co,cart->dat.TextLabels[co]);}
}

void CText::FindKAB()
{
	int ptrset = BASICTEXT_OFFSET;
	int ptrcount = count << 1;
	if(cur_main <= 5) ptrcount = BASICTEXT_COUNT << 1;
	if(cur_main == 6) ptrset = ATTACKTEXT_OFFSET;
	if(cur_main == 7) ptrset = ENEMYTEXT_OFFSET;
	if(cur_main == 8) ptrset = DIALOGUE_OFFSET;
	if(cur_main == 9) ptrset = BATTLEMESSAGETEXT_OFFSET;

	int largestpointer = textstart;
	int thispointer;
	ptrcount += ptrset;
	for(int co = ptrset; co < ptrcount; co += 2){
		thispointer = cart->ROM[co] + (cart->ROM[co + 1] << 8) + ptradd;
		if(thispointer < textend && thispointer > largestpointer) largestpointer = thispointer;}

	for(co = largestpointer; cart->ROM[co]; co++);

	kab = textend - co - 1;
	CString text;
	text.Format("%d",kab);
	m_kab.SetWindowText(text);
}

void CText::LoadValues()
{
	CEdit* m_field = &m_textbox;
	if(cur_main == 8) m_field = &m_dialoguebox;

	int offset = ptroffset + (cur_text << 1);
	offset = cart->ROM[offset] + (cart->ROM[offset + 1] << 8) + ptradd;
	CString text, temptext;
	text.Format("%X",offset);
	m_pointer.SetWindowText(text);
	text = "";
	temptext = "";
	for(;cart->ROM[offset];offset++){
		temptext = cart->Tables[viewDTE][cart->ROM[offset]];
		if(!temptext.GetLength()){
			if(cart->ROM[offset] < 0x10) temptext.Format("{0%X}",cart->ROM[offset]);
			else temptext.Format("{%X}",cart->ROM[offset]);}
		text += temptext;}

	int find = text.Find("\\n");
	while(find != -1){
		text.SetAt(find,0x0D);
		text.SetAt(find + 1,0x0A);
		find = text.Find("\\n");}

	m_field->SetWindowText(text);

	if(cur_main != 8){
		CString text2;
		m_textlist.GetText(cur_text,text2);
		if(text2 != text)
			UpdateTextList();
	}

	int tempcount = count;
	switch(cur_main){
	case 6: textstart = ATTACKTEXT_START; textend = ATTACKTEXT_END; ptrtblstart = ATTACKTEXT_OFFSET; break;
	case 7: textstart = ENEMYTEXT_START; textend = ENEMYTEXT_END; ptrtblstart = ENEMYTEXT_OFFSET; break;
	case 8: textstart = DIALOGUE_START; textend = DIALOGUE_END; ptrtblstart = DIALOGUE_OFFSET; break;
	case 9: textstart = BATTLEMESSAGETEXT_START; textend = BATTLEMESSAGETEXT_END; ptrtblstart = BATTLEMESSAGE_OFFSET; break;
	default: textstart = BASICTEXT_START; textend = BASICTEXT_END; ptrtblstart = BASICTEXT_OFFSET; tempcount = BASICTEXT_COUNT; break;
	}

	ptrtblend = ptrtblstart + (tempcount << 1);

	FindKAB();
	m_newslot.EnableWindow(kab > 0);
	m_changeptr.EnableWindow(0);

	madechange = 0;
}

void CText::StoreValues()
{
	//Store values is kind of tricky.. first let's check to see if the text is in the *normal*
	//  text block.  If it isn't... warn the user.
	//  If not... compare the new length with the old length.. make sure we have room, and shift
	//  everything over. (very similar to map data)


	//Step 1:  find: the length of the text (in bytes)...
	//               the offset of the text
	//               the Hex values of the text

	int newlength, oldlength;
	int temp;
	int ptrstart, ptrend;

	ptrstart = ptroffset;
	ptrend = ptrstart + (count << 1);
	if(cur_main < 6){
		ptrstart = BASICTEXT_OFFSET;
		ptrend = ptrstart + (BASICTEXT_COUNT << 1);}

	int offset = ptroffset + (cur_text << 1);
	offset = cart->ROM[offset] + (cart->ROM[offset + 1] << 8) + ptradd;

	for(int co = offset; cart->ROM[co]; co++);
	oldlength = co - offset + 1;		//add 1 to include the 00

	BYTE buffer[200];
	CString text;
	m_textbox.GetWindowText(text);
	if(cur_main == 8) m_dialoguebox.GetWindowText(text);

	newlength = ConvertText(buffer,text);

	int dif = newlength - oldlength;
	bool normaltext = 1;

	//Step 2:  check to see if this is *normally* stored text.  If it is... make sure we have room
	//		   in the kab.. if not.. give an error message and change m_kab (*NOT* the int kab).
	//         if the text is not *normal*, then compare the new size to the old:
	//           if we're making text smaller (or not changing the size) don't worry about it
	//           if we're making it bigger... alert the user and only proceed if they confirm

	if(offset >= textstart && offset < textend){	//normal text
		if(kab - dif < 0){
			AfxMessageBox("Not enough free space in ROM.");
			text.Format("%d",kab - dif);
			m_kab.SetWindowText(text);
			return;}}
	else{											//non-normal text
		normaltext = 0;
		if(dif > 0){
			if(AfxMessageBox("This text is outside of the standard text block.\nIncreasing its size may write over other information.\nAre you sure you want to continue?",MB_YESNO) == IDNO)
				return;
		}
	}


	//Step 3:  if this is normal text... move all the text around to fit the new text

	if(normaltext && dif){
		if(dif > 0){	//shift to the right
			for(co = textend - 1; co > offset; co--)
				cart->ROM[co] = cart->ROM[co - dif];
		}
		if(dif < 0){	//shift to the left
			for(co = offset; co < textend; co++)
				cart->ROM[co] = cart->ROM[co - dif];
		}
		for(co = ptrstart; co < ptrend; co += 2){
			temp = cart->ROM[co] + (cart->ROM[co + 1] << 8) + ptradd;
			if((temp < textend) && (temp > offset)){
				temp += dif - ptradd;
				cart->ROM[co] = temp & 0xFF;
				cart->ROM[co + 1] = temp >> 8;}
		}
	}

	//Step 4:  insert the new text!

	for(co = 0; co < newlength; co++)
		cart->ROM[co + offset] = buffer[co];

	madechange = 0;
	m_changeptr.EnableWindow(0);
}

int CText::ConvertText(BYTE* buffer,CString text)
{
	int length = text.GetLength();
	int bytelength = 0;
	CString temp1;
	CString temp2;
	int co;

	temp1.Format("%c%c",0x0D,0x0A);
	co = text.Replace(temp1,"\\n");


	while(length > 0){
		temp1 = text.Left(1);
		temp2 = text.Left(2);
		if(temp1 == "{"){
			co = text.Find("}");
			if(co == -1) co = text.GetLength();
			temp2 = text.Left(co);
			buffer[bytelength] = StringToInt_HEX(text) & 0xFF;
			length -= co;
			bytelength += 1;
		}
		else{
			for(co = 0; co < 256; co++){
				if(temp2 == cart->Tables[viewDTE][co]) break;}
			if(co != 256){
				buffer[bytelength] = co; bytelength += 1; length -= 1;}
			else{
				for(co = 0; co < 256; co++){
					if(temp1 == cart->Tables[viewDTE][co]) break;}
				if(co != 256){
					buffer[bytelength] = co; bytelength += 1;}
			}
			length -= 1;
		}

		text = text.Right(length);
	}


	buffer[bytelength] = 0;

	return bytelength + 1;
}

void CText::OnSelchangeTextlist() 
{
	if(cur_text != -1 && madechange){
		StoreValues();
		if(cur_main != 8)
			UpdateTextList();
	}
	cur_text = m_textlist.GetCurSel();

	LoadValues();
}

void CText::UpdateTextList()
{
	int temp = m_textlist.GetCurSel();
	if(cur_main == 8) return;
	CString text = "";
	CString temptext;
	int offset = ptroffset + (cur_text << 1);
	offset = cart->ROM[offset] + (cart->ROM[offset + 1] << 8) + ptradd;
	for(int co = offset; cart->ROM[co]; co++){
		temptext = cart->Tables[viewDTE][cart->ROM[co]];
		if(temptext == ""){
			if(cart->ROM[co] < 0x10) temptext.Format("{0%X}",cart->ROM[co]);
			else temptext.Format("{%X}",cart->ROM[co]);}
		text += temptext;}

	m_textlist.DeleteString(cur_text);
	m_textlist.InsertString(cur_text,text);
	m_textlist.SetCurSel(temp);
}

void CText::OnEditlabel() 
{
	ChangeLabel(TEXTLABEL_SIZE,cart->dat.TextLabels[cur_text],cur_text,&m_textlist,NULL);
}

void CText::OnDte() 
{
	viewDTE = 0;
	if(m_dte.GetCheck()) viewDTE = 1;
	cart->dat.TextViewInDTE[cur_main] = viewDTE;
	if(cur_main != 8) ResetTextList();
	m_textlist.SetCurSel(cur_text);
}

void CText::OnUpdate() 
{
	StoreValues();
	FindKAB();
	UpdateTextList();
}

void CText::OnOK() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
	else
		CDialog::OnOK();
}

void CText::OnSave() 
{
	StoreValues();
	if(!SaveRomToFile(cart))
		AfxMessageBox("Unable to save ROM.");
}

void CText::OnUpdateTextbox() 
{madechange = 1;}

void CText::OnUpdatePointer() 
{m_changeptr.EnableWindow(1);}

void CText::OnChangeptr() 
{
	//Make sure the pointer is in bounds
	CString text;
	m_pointer.GetWindowText(text);
	int pointer = StringToInt_HEX(text);

	if(pointer < ptradd || pointer > (ptradd + 0xFFFF)){
		text.Format("Pointer is out of range.\nMust be between %X - %X",ptradd,ptradd + 0xFFFF);
		AfxMessageBox(text);
		LoadValues();
		return;}

	int offset = ptroffset + (cur_text << 1);
	pointer -= ptradd;
	cart->ROM[offset] = pointer & 0xFF;
	cart->ROM[offset + 1] = pointer >> 8;
	UpdateTextList();
	LoadValues();
}

void CText::OnCancel() 
{
	ReLoadROM(cart);
	CDialog::OnCancel();
}

void CText::OnDeleteslot() 
{
	int offset = ptroffset + (cur_text << 1);
	offset = cart->ROM[offset] + (cart->ROM[offset + 1] << 8) + ptradd;
	if(offset < textstart || offset > textend){
		AfxMessageBox("The slot is not in the standard text boundaries.\nCannot remove slot.");
		return;}

	int largestptr = textstart;
	int thisptr;
	for(int co = ptrtblstart; co < ptrtblend; co += 2){
		thisptr = cart->ROM[co] + (cart->ROM[co + 1] << 8) + ptradd;
		if(thisptr > largestptr && thisptr < textend)
			largestptr = thisptr;}

	if(largestptr == offset){
		AfxMessageBox("This is the last slot.\nCannot delete the last slot.");
		return;}

	if(AfxMessageBox("Really remove current slot?\nThis text will be deleted.",MB_YESNO) == IDNO) return;

	for(int currentlength = offset; cart->ROM[currentlength]; currentlength += 1);
	currentlength -= offset;
	currentlength += 1;

	
	int temp;
	int ptrstart, ptrend;
	ptrstart = ptroffset;
	ptrend = ptrstart + (count << 1);
	if(cur_main < 6){
		ptrstart = BASICTEXT_OFFSET;
		ptrend = ptrstart + (BASICTEXT_COUNT << 1);}

	//adjust pointers
	for(co = ptrstart; co < ptrend; co += 2){
		temp = cart->ROM[co] + (cart->ROM[co + 1] << 8) + ptradd;
		if(temp > offset && temp < textend){
			temp -= currentlength;
			temp -= ptradd;
			cart->ROM[co] = temp & 0xFF;
			cart->ROM[co + 1] = temp >> 8;}
	}
	//shift all text
	for(co = offset; co < textend; co++)
		cart->ROM[co] = cart->ROM[co + currentlength];

	UpdateTextList();
	LoadValues();
}

void CText::OnNewslot() 
{
	if(kab < 1){
		AfxMessageBox("Not enough space in ROM.\nYou must have at least 1 byte free");
		return;}

	CString text;
	int slot = textend - kab;
	text.Format("%X",slot);
	m_pointer.SetWindowText(text);
	OnChangeptr();
}
