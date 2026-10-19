//////////////////////////////////////////////
//Functions.cpp
//
//  handles all the functions declared in Functions.h

#include "stdafx.h"
#include "FFHackster.h"
#include "NewLabel.h"

int StringToInt_HEX(CString text)
{
	int ret = 0;
	int len = text.GetLength();
	for(int co = 0; co < len; co++){
		ret <<= 4;
		switch(text.GetAt(co)){
		case '0': break;
		case '1': ret += 1; break;
		case '2': ret += 2; break;
		case '3': ret += 3; break;
		case '4': ret += 4; break;
		case '5': ret += 5; break;
		case '6': ret += 6; break;
		case '7': ret += 7; break;
		case '8': ret += 8; break;
		case '9': ret += 9; break;
		case 'a': case 'A': ret += 0xA; break;
		case 'b': case 'B': ret += 0xB; break;
		case 'c': case 'C': ret += 0xC; break;
		case 'd': case 'D': ret += 0xD; break;
		case 'e': case 'E': ret += 0xE; break;
		case 'f': case 'F': ret += 0xF; break;
		default: ret >>= 4; break;
		}
	}
	return ret;
}

int StringToInt(CString text)
{
	int ret = 0;
	int len = text.GetLength();
	for(int co = 0; co < len; co++){
		ret *= 10;
		switch(text.GetAt(co)){
		case '0': break;
		case '1': ret += 1; break;
		case '2': ret += 2; break;
		case '3': ret += 3; break;
		case '4': ret += 4; break;
		case '5': ret += 5; break;
		case '6': ret += 6; break;
		case '7': ret += 7; break;
		case '8': ret += 8; break;
		case '9': ret += 9; break;
		default: ret /= 10; break;
		}
	}
	return ret;
}

void ChangeLabel(int maxlength,char* label,int arid, 
				 CListBox* m_list,CComboBox* m_combo)
{
	CNewLabel dlg;
	dlg.length = maxlength;
	dlg.m_label = label;
	if(dlg.DoModal() == IDOK){
		int temp;
		lstrcpy(label,dlg.m_label);
		if(m_combo != NULL){
			temp = m_combo->GetCurSel();
			m_combo->DeleteString(arid);
			m_combo->InsertString(arid,label);
			m_combo->SetCurSel(temp);}
		if(m_list != NULL){
			temp = m_list->GetCurSel();
			m_list->DeleteString(arid);
			m_list->InsertString(arid,label);
			m_list->SetCurSel(temp);}
	}
}

void CreateNewDataFile(CARTRIDGE* cart)
{
	/*inits a new data file and saves a copy*/

	//init vars
	for(int co = 0; co < 10; co++) cart->dat.TextViewInDTE[co] = 0;
	cart->dat.TextViewInDTE[5] = 1;
	cart->dat.TextViewInDTE[8] = 1;

	CString text;
	for(co = 0; co < DIALOGUE_COUNT; co++){
		if(co >= 0x10) 
			text.Format("Text: %X",co);
		else
			text.Format("Text: 0%X",co);
		lstrcpy(cart->dat.TextLabels[co],text);}

	for(co = 0; co < AI_COUNT; co++)
		lstrcpy(cart->dat.AILabels[co],const_aitable[co]);

	for(co = 0; co < WEAPONMAGICGRAPHIC_COUNT; co++)
		lstrcpy(cart->dat.WepMagLabels[co],const_wepmagtable[co]);

	for(co = 0; co < SHOP_COUNT; co++)
		lstrcpy(cart->dat.ShopLabels[co],const_shoptable[co]);

	for(co = 0; co < 0x10; co++){
		text.Format("Battle: 0%X",co);
		lstrcpy(cart->dat.BattleLabels[co],text);}
	for(co = 0x10; co < BATTLE_COUNT; co++){
		text.Format("Battle: %X",co);
		lstrcpy(cart->dat.BattleLabels[co],text);}

	for(co = 0; co < BATTLEPATTERNTABLE_COUNT; co++)
		lstrcpy(cart->dat.BattlePatternTableLabels[co],const_patterntables[co]);

	for(co = 0; co < 16; co++)
		lstrcpy(cart->dat.BackdropLabels[co],const_backdroptables[co]);

	for(co = 0; co < ONTELEPORT_COUNT; co++){
		text.Format("Enter: %s",const_onteleporttables[co]);
		lstrcpy(cart->dat.ONTeleportLabels[co],text);}

	for(co = 0; co < MAP_COUNT; co++)
		lstrcpy(cart->dat.MapLabels[co],const_maptables[co]);

	for(int co2 = 0; co2 < 19; co2++){
		for(co = 0; co < 9; co++)
			cart->dat.SmartTools[co2][co] = const_smarttools[co2][co];}

	for(co2 = 0; co2 < 9; co2++){
		for(co = 0; co < 128; co++)
			cart->dat.TintTiles[co2][co] = 0;}

	for(co = 0; co < TREASURE_COUNT; co++)
		lstrcpy(cart->dat.TCLabels[co],const_treasuretables[co]);
	for(co = 0; co < NNTELEPORT_COUNT; co++)
		lstrcpy(cart->dat.NNTeleportLabels[co],const_nnteleporttables[co]);
	for(co = 0; co < NOTELEPORT_COUNT; co++){
		text.Format("Exit: %s",const_noteleporttables[co]);
		lstrcpy(cart->dat.NOTeleportLabels[co],text);}
	for(co = 0; co < TILESET_COUNT; co++)
		lstrcpy(cart->dat.TilesetLabels[co],const_tilesettables[co]);
	for(co = 0; co < SPRITE_COUNT; co++)
		lstrcpy(cart->dat.SpriteLabels[co],const_spritetables[co]);
	for(co = 0; co < MAPSPRITEGRAPHIC_COUNT; co++)
		lstrcpy(cart->dat.SpriteGraphicLabels[co],const_spritegraphictables[co]);

	cart->dat.TintVariant = TINT_VARIANT;

	cart->dat.ShowLastClick = 0;
	cart->dat.DrawDomainGrid = 0;

	//save a copy of this data file
	cart->datafile = fopen(DATAFILE_NAME,"w+b");
	fwrite(HEADER,1,4,cart->datafile);
	fwrite(&cart->dat,1,sizeof(DATA),cart->datafile);
}

void LoadTable(CARTRIDGE* cart,bool DTE,FILE* file)
{
	BYTE buffer[0x1000];
	CString text;
	CString linebreak;
	linebreak.Format("%c%c",0x0D,0x0A);
	fread(buffer,1,0x1000,file);
	fclose(file);
	text.Format("%s",buffer);

	CString ex;
	int find;
	int value;
	bool end = 0;
	while(!end){
		ex = "";
		find = text.Find('=');
		if(find == -1) return;
		
		value = StringToInt_HEX(text.Left(find));
		text = text.Right(text.GetLength() - find - 1);
		find = text.Find(linebreak);
		if(find == -1){
			find = text.GetLength();
			end = 1;}
		ex = text.Left(find);
		text = text.Right(text.GetLength() - find - 2);
		if(value < 256)
			cart->Tables[DTE][value] = ex;
	}
}

bool LoadROM(CARTRIDGE* cart, CWnd* This)
{
	/*same as ReLoadROM, only this remakes the Finger Image list*/
	if(!ReLoadROM(cart)) return 0;

	while(cart->Finger.GetImageCount()) cart->Finger.Remove(0);
	CBitmap bmp;
	CPaintDC dc(This);
	CDC mDC; mDC.CreateCompatibleDC(&dc);
	bmp.CreateCompatibleBitmap(&dc,32,16);
	mDC.SelectObject(&bmp);

	BYTE coY, coX, bigY, bigX;
	int offset = FINGERGRAPHIC_OFFSET;
	BYTE line;
	BYTE pal[4] = {0x35,
		cart->ROM[CHARBATTLEPALETTE_OFFSET + 13],
		cart->ROM[CHARBATTLEPALETTE_OFFSET + 14],
		cart->ROM[CHARBATTLEPALETTE_OFFSET + 15]};
	BYTE pixel[2][2] = {0,2,1,3};
	for(bigY = 0; bigY < 2; bigY++){
	for(bigX = 0; bigX < 2; bigX++, offset += 8){
		for(coY = 0; coY < 8; coY++, offset += 1){
		for(coX = 0, line = 0x80; coX < 8; coX++, line >>= 1){
			mDC.SetPixelV((bigX << 3) + coX,((bigY << 3) + coY),
				cart->Palette[0][pal[pixel
				[(cart->ROM[offset] & line) != 0]
				[(cart->ROM[offset + 8] & line) != 0]]]);
			mDC.SetPixelV(16 + (bigY << 3) + coY,15 - ((bigX << 3) + coX),
				cart->Palette[0][pal[pixel
				[(cart->ROM[offset] & line) != 0]
				[(cart->ROM[offset + 8] & line) != 0]]]);
		}}
	}}

	mDC.DeleteDC();
	cart->Finger.Add(&bmp,cart->Palette[0][pal[0]]);
	bmp.DeleteObject();
	return 1;
}

bool ReLoadROM(CARTRIDGE* cart)
{
	/*reloads the ROM
		called when "Cancel" is clicked in an editor...so the changes are
		ignored*/

	FILE* romfile = fopen(cart->dat.ROMPath,"r+b");
	if(romfile == NULL)
		return 0;

	fseek(romfile,STAMPEDROM_OFFSET,SEEK_SET);
	BYTE stamped;
	fread(&stamped,1,1,romfile);
	rewind(romfile);

	if(stamped == 0x79){
		fclose(romfile);
		AfxMessageBox("The creator of this hack doesn't want you\nCHEATING!!!");
		return 0;}

	fread(cart->ROM,1,ROM_SIZE,romfile);
	fclose(romfile);
	return 1;
}

CString PutHexToList(CARTRIDGE* cart,int ptr,int ptradd,int count,bool DTE,CListBox* m_list,CComboBox* m_combo)
{
	CString ret = "";
	int offset, co;
	BYTE temp;
	CString text, temptext;
	for(co = 0; co < count; co++, ptr += 2){
		if(co) ret += "\\b";
		offset = cart->ROM[ptr] + (cart->ROM[ptr + 1] << 8) + ptradd;
		text = "";
		while(1){
			temp = cart->ROM[offset];
			if(!temp) break;
			if(cart->Tables[DTE][temp] == ""){
				if(temp < 0x10) temptext.Format("{0%X}",temp);
				else temptext.Format("{%X}",temp);
				text += temptext;}
			else text += cart->Tables[DTE][temp];
			offset += 1;}
		ret += text;
		if(m_list != NULL) m_list->InsertString(co,text);
		if(m_combo != NULL) m_combo->InsertString(co,text);
	}

	return ret;
}

bool SaveRomToFile(CARTRIDGE* cart)
{
	FILE* file = fopen(cart->dat.ROMPath,"w+b");
	if(file == NULL) return 0;
	fwrite(cart->ROM,1,ROM_SIZE,file);
	fclose(file);
	return 1;
}

void ReTintPalette(CARTRIDGE* cart)
{
	bool tinter[9][3] = {1,1,1,0,0,0,0,0,1,0,1,0,1,0,0,0,1,1,1,0,1,1,1,0,1,1,1};
	int co2, co, c;
	int rgb[3];
	int temp;
	for(co2 = 1; co2 < 9; co2++)
	{
		for(co = 0; co < 0x40; co++)
		{
			rgb[0] = cart->Palette[0][co] & 0xFF;
			rgb[1] = (cart->Palette[0][co] >> 8) & 0xFF;
			rgb[2] = (cart->Palette[0][co] >> 16) & 0xFF;

			for(c = 0; c < 3; c++){
				if(tinter[co2][c]){
					rgb[c] += cart->dat.TintVariant;
					if(rgb[c] > 0xFF) rgb[c] = 0xFF;}
				else{
					rgb[c] -= cart->dat.TintVariant;
					if(rgb[c] < 0) rgb[c] = 0;}
			}

			temp = (rgb[2] << 16) + (rgb[1] << 8) + rgb[0];
			if(temp == TRANSPARENTCOLOR) temp = TRANSPARENTCOLORREPLACEMENT;

			cart->Palette[co2][co] = temp;
		}
	}
}

bool CompareStrings(BYTE* str1,BYTE* str2,int length)
{
	for(int co = 0; co < length; co++){
		if(str1[co] != str2[co]) return 0;}

	return 1;
}

void DrawTile(CDC* dc,int tX, int tY,CARTRIDGE* cart,int offset,BYTE* palette,BYTE tint)
{
	BYTE pixel[2][2] = {0,2,1,3};
	BYTE coX, coY, line;
	for(coY = 0; coY < 8; coY++, tX -= 8, tY++, offset++){
	for(coX = 0, line = 0x80; coX < 8; coX++, tX++, line >>= 1){
		dc->SetPixelV(tX,tY,cart->Palette[tint][palette[pixel
			[(cart->ROM[offset] & line) != 0]
			[(cart->ROM[offset + 8] & line) != 0]]]);}}
}

void DrawTileScale(CDC* dc,int tX, int tY,CARTRIDGE* cart,int offset,BYTE* palette, int scale, BYTE tint)
{
	BYTE temp, coX, coY, line;
	BYTE pixel[2][2] = {0,2,1,3};
	CRect rc(tX,tY,tX + scale,tY + scale);
	CBrush br[4];
	for(temp = 0; temp < 4; temp++)
		br[temp].CreateSolidBrush(cart->Palette[tint][palette[temp]]);

	for(coY = 0; coY < 8; coY++, offset++, rc.top += scale, rc.bottom += scale, rc.left = tX, rc.right = tX + scale){
	for(coX = 0, line = 0x80; coX < 8; coX++, line >>= 1, rc.left += scale, rc.right += scale){
		dc->FillRect(rc,&br[pixel
			[(cart->ROM[offset] & line) != 0]
			[(cart->ROM[offset + 8] & line) != 0]]);}}

	for(temp = 0; temp < 4; temp++)
		br[temp].DeleteObject();
}

void Draw_ROM_Buffer(CARTRIDGE* cart,int offset,DRAW_STRUCT* draw)
{
	BYTE coY, coX, line;
	int co;
	BYTE pixel[2][2] = {0,2,1,3};
	int bmpco = 0;

	for(co = 0; co < draw->Max; co++, offset += 8){
	for(coY = 0; coY < 8; coY++, offset++){
	for(coX = 0, line = 0x80; coX < 8; coX++, line >>= 1, bmpco++)
		draw->bitmap[bmpco] = pixel[(cart->ROM[offset] & line) != 0][(cart->ROM[offset + 8] & line) != 0];
	}}
}

void Draw_Buffer_ROM(CARTRIDGE* cart,int offset,DRAW_STRUCT* draw)
{
	BYTE coY, coX, line;
	int bmpco = 0, co;

	for(co = 0; co < draw->Max; co++, offset += 8){
	for(coY = 0; coY < 8; coY++, offset++){
	cart->ROM[offset] = 0;
	cart->ROM[offset + 8] = 0;
	for(coX = 0, line = 0x80; coX < 8; coX++, line >>= 1, bmpco++){
		if(draw->bitmap[bmpco] & 0x01) cart->ROM[offset] |= line;
		if(draw->bitmap[bmpco] & 0x02) cart->ROM[offset + 8] |= line;
	}}}
}

void Draw_DrawGraphic(CDC* mDC,DRAW_STRUCT* draw,CARTRIDGE* cart,BYTE* pal, bool drawbox, bool hideFF)
{
	CPen redpen; redpen.CreatePen(PS_SOLID,1,RGB(255,0,0));
	CPen* oldpen = mDC->SelectObject(&redpen);
	BYTE coY, coX, paltemp;
	short temp;
	int co = 0;
	int drawX, drawY;
	for(coY = 0, drawY = draw->rcGraphic.top; coY < draw->Height; coY++, drawY += 16){
	for(coX = 0, drawX = draw->rcGraphic.left; coX < draw->Width; coX++, co++, drawX += 16){
		temp = draw->PicFormation[co];
		if(temp == 0xFF && hideFF) continue;

		if(draw->PalFormation == NULL) paltemp = 0;
		else paltemp = draw->PalFormation[(coY * draw->Width) + coX] << 2;
		Draw_DrawBufferTile(mDC,drawX,drawY,cart,draw,&draw->bitmap[temp << 6],&pal[paltemp],2);
		if(drawbox && draw->curblock == temp){
			mDC->MoveTo(drawX,drawY); mDC->LineTo(drawX + 15,drawY);
			mDC->LineTo(drawX + 15, drawY + 15); mDC->LineTo(drawX,drawY + 15);
			mDC->LineTo(drawX,drawY);}
	}}
	mDC->SelectObject(oldpen);
	redpen.DeleteObject();
}

void Draw_DrawAll(CDC* mDC,DRAW_STRUCT* draw,CARTRIDGE* cart,BYTE* pal)
{
	Draw_DrawPalette(mDC,draw->rcPalette.left,draw->rcPalette.top,cart,pal);
	Draw_DrawFinger(mDC,draw,cart);
	Draw_DrawGraphic(mDC,draw,cart,pal,1,1);
	Draw_DrawCloseup(mDC,draw,cart,pal);
}

void Draw_DrawFinger(CDC* mDC,DRAW_STRUCT* draw,CARTRIDGE* cart)
{
	CPoint pt;
	pt.x = (draw->rcFinger.left - 16) + (draw->curpal << 4);
	pt.y = draw->rcFinger.top;
	cart->Finger.Draw(mDC,1,pt,ILD_TRANSPARENT);
}

void Draw_DrawPalette(CDC* mDC,int pX, int pY,CARTRIDGE* cart,BYTE* pal)
{
	CBrush br[3];
	for(BYTE co = 0; co < 3; co++)
		br[co].CreateSolidBrush(cart->Palette[0][pal[co + 1]]);

	CRect rc(pX,pY,pX + 16,pY + 16);
	mDC->FillRect(rc,&br[0]); rc.left += 16; rc.right += 16;
	mDC->FillRect(rc,&br[1]); rc.left += 16; rc.right += 16;
	mDC->FillRect(rc,&br[2]);

	for(co = 0; co < 3; co++)
		br[co].DeleteObject();
}

void Draw_DrawPatternTables(CDC* mDC,DRAW_STRUCT* draw,CARTRIDGE* cart,BYTE* pal,CRect rc,int max,bool drawbox)
{
	CPen redpen; redpen.CreatePen(PS_SOLID,1,RGB(255,0,0));
	CPen* oldpen = mDC->SelectObject(&redpen);
	BYTE coY, coX;
	int co = 0;
	int drawX, drawY;
	for(coY = 0, drawY = rc.top; co < max; coY++, drawY += 16){
	for(coX = 0, drawX = rc.left; coX < 16 && co < max; coX++, co++, drawX += 16)
		Draw_DrawBufferTile(mDC,drawX,drawY,cart,draw,&draw->bitmap[co << 6],pal,2);
	}

	if(drawbox && draw->curblock != 0xFF){
		drawX = rc.left + ((draw->curblock & 0x0F) << 4);
		drawY = rc.top + (draw->curblock & 0xF0);
		mDC->MoveTo(drawX,drawY); mDC->LineTo(drawX + 15,drawY);
		mDC->LineTo(drawX + 15, drawY + 15); mDC->LineTo(drawX,drawY + 15);
		mDC->LineTo(drawX,drawY);}

	mDC->SelectObject(oldpen);
	redpen.DeleteObject();
}

void Draw_DrawCloseup(CDC* mDC,DRAW_STRUCT* draw,CARTRIDGE* cart,BYTE* pal)
{Draw_DrawBufferTile(mDC,draw->rcCloseup.left,draw->rcCloseup.top,cart,draw,&draw->bitmap[draw->curblock << 6],pal,16);}

void Draw_DrawBufferTile(CDC* mDC,int pX,int pY,CARTRIDGE* cart,DRAW_STRUCT* draw,BYTE* bitmap,BYTE* pal,int size)
{
	CBrush br[16];
	BYTE coX, coY;
	int co;
	for(co = 0; co < draw->palmax; co++)
		br[co].CreateSolidBrush(cart->Palette[0][pal[co]]);

	CRect rc;
	for(coY = 0, co = 0, rc.top = pY, rc.bottom = pY + size; coY < 8; coY++, rc.top += size, rc.bottom += size){
	for(coX = 0, rc.left = pX, rc.right = pX + size; coX < 8; coX++, co++, rc.left += size, rc.right += size)
		mDC->FillRect(rc,&br[bitmap[co]]);
	}

	for(co = 0; co < draw->palmax; co++)
		br[co].DeleteObject();
}

BYTE Draw_ButtonDown(DRAW_STRUCT* draw,CPoint pt,bool rbutton)
{
	//return values:
	//  1 = Redraw Graphic/Closeup
	//  2 = Redraw Finger
	//  3 = Redraw all

	if(PtInRect(draw->rcPalette,pt)){
		draw->curpal = (BYTE)(((pt.x - draw->rcPalette.left) >> 4) + 1);
		return 2;}
	else if(PtInRect(draw->rcGraphic,pt)){
		pt.y = (pt.y - draw->rcGraphic.top) >> 4;
		pt.x = (pt.x - draw->rcGraphic.left) >> 4;
		short temp = draw->PicFormation[(pt.y * draw->Width) + pt.x];
		if(temp == 0xFF) return 0;
		draw->curblock = (BYTE)temp;
		return 1;}
	else if(PtInRect(draw->rcCloseup,pt)){
		draw->mousedown = 1 + rbutton;
		draw->mouseclick.x = (pt.x - draw->rcCloseup.left) >> 4;
		draw->mouseclick.y = (pt.y - draw->rcCloseup.top) >> 4;
		BYTE* temp = &draw->bitmap[(draw->curblock << 6) + (draw->mouseclick.y << 3) + draw->mouseclick.x];
		if(rbutton) *temp = 0;
		else *temp = draw->curpal;
		return 1;}

	return 0;
}

bool Draw_MouseMove(DRAW_STRUCT* draw,CPoint pt)
{
	if(draw->mousedown && PtInRect(draw->rcCloseup,pt)){
		CPoint click;
		click.x = (pt.x - draw->rcCloseup.left) >> 4;
		click.y = (pt.y - draw->rcCloseup.top) >> 4;
		if(click != draw->mouseclick){
			draw->mouseclick = click;
			BYTE* set = &draw->bitmap[(draw->curblock << 6) + (draw->mouseclick.y << 3) + draw->mouseclick.x];
			if(draw->mousedown == 2) *set = 0;
			else *set = draw->curpal;
			return 1;
		}
	}
	return 0;
}

void Draw_ExportToBmp(DRAW_STRUCT* draw, CARTRIDGE* cart, BYTE* pal)
{
	CFileDialog dlg(0,"bmp",NULL,OFN_OVERWRITEPROMPT,"16/256 Color Bitmaps (*.bmp)|*bmp|All Files (*.*)|*.*||");
	if(dlg.DoModal() != IDOK) return;

	FILE* file = fopen(dlg.GetPathName(),"w+b");
	if(file == NULL){
		AfxMessageBox("Unable to create bitmap");
		return;}

	BYTE header[118];
	int height = draw->Height << 3;
	int width = draw->Width << 3;
	for(int co = 0; co < 118; co++)
		header[co] = 0;

	header[0] = 'B';
	header[1] = 'M';		//file type

	header[10] = 118;		//offset to the data
	header[14] = 40;		//size of rest of header

	header[18] = width & 0xFF;
	header[19] = (width >> 8) & 0xFF;
	header[20] = (width >> 16) & 0xFF;
	header[21] = (width >> 24) & 0xFF;	//bitmap's width

	header[22] = height & 0xFF;
	header[23] = (height >> 8) & 0xFF;
	header[24] = (height >> 16) & 0xFF;
	header[25] = (height >> 24) & 0xFF;	//bitmap's height

	header[26] = 1;		//# of planes

	header[28] = 4;		//bits per pixel  (4 = 16 colors)

	int temp, co2 = 54;	//palette
	for(co = 0; co < draw->palmax; co++, co2 += 4){
		temp = cart->Palette[0][pal[co]];
		header[co2] = temp >> 16;
		header[co2 + 1] = (temp >> 8) & 0xFF;
		header[co2 + 2] = temp & 0xFF;}

	fwrite(header,1,118,file);

	BYTE bmtemp[4];
	BYTE bigY, smallY;
	BYTE palshot = 0;

	for(height = (draw->Height << 3) - 1; height >= 0; height--){
	for(width = 0; width < draw->Width; width++){
		bigY = height >> 3;
		smallY = height & 0x07;

		co = draw->PicFormation[(bigY * draw->Width) + width];
		if(draw->PalFormation != NULL) palshot = draw->PalFormation[(bigY * draw->Width) + width] << 2;
		if(co != 0xFF){
			co = (co << 6) + (smallY << 3);
			for(co2 = 0; co2 < 4; co2++, co += 2)
				bmtemp[co2] = ((draw->bitmap[co] + palshot) << 4) + draw->bitmap[co + 1] + palshot;
		}
		else{
			for(co = 0; co < 4; co++)
				bmtemp[co] = 0;}

		fwrite(bmtemp,1,4,file);

	}}

	fclose(file);
}

void Draw_ImportFromBmp(DRAW_STRUCT* draw, CARTRIDGE* cart, BYTE* palette)
{
	CFileDialog dlg(1,"bmp",NULL,OFN_HIDEREADONLY,"16/256 Color Bitmaps (*.bmp)|*bmp|All Files (*.*)|*.*||");
	if(dlg.DoModal() != IDOK) return;

	FILE* file = fopen(dlg.GetPathName(),"rb");
	if(file == NULL){
		AfxMessageBox("Unable to load bitmap");
		return;}
	BYTE header[54];

	fread(header,1,54,file);

	if(header[0] != 'B' || header[1] != 'M'){
		AfxMessageBox("Not a valid bitmap");
		return;}

	if(header[28] != 4 && header[28] != 8){
		AfxMessageBox("Only 16 and 256 color bitmaps are supported.");
		return;}

	int height = header[22] + (header[23] << 8) + (header[24] << 16) + (header[25] << 24);
	int width = header[18] + (header[19] << 8) + (header[20] << 16) + (header[21] << 24);
	int numcolors = 1 << header[28];

	BYTE bmppalette[256][4];
	fread(bmppalette,1,numcolors << 2,file);

	BYTE PaletteExchange[4][256];
	int co;
	BYTE pal;
	int palentry;
	int dif, lowestdif;
	for(int co2 = 0; co2 < draw->palmax; co2 += 4){
		for(co = 0; co < numcolors; co++){
			lowestdif = 0x1000000;
			for(pal = 0; pal < 4; pal++){
				palentry = cart->Palette[0][palette[co2 + pal]];
				dif = 0;
				dif += abs((palentry & 0xFF) - bmppalette[co][2]);
				dif += abs(((palentry >> 8) & 0xFF) - bmppalette[co][1]);
				dif += abs(((palentry >> 16) & 0xFF) - bmppalette[co][0]);
				if(dif < lowestdif){
					lowestdif = dif;
					PaletteExchange[co2 >> 2][co] = pal;}
				if(!dif) break;
			}
	}}

	//Okay... the palette is loaded... and all the best palette conversions are found... now lets
	// actually LOAD the bitmap

	int readpixels = draw->Width << 3;
	if(width < readpixels) readpixels = width;
	
	BYTE pixelsperblock = 4;
	if(numcolors == 16) pixelsperblock = 8;

	int blockcount = width / pixelsperblock;
	if(width % pixelsperblock) blockcount += 1;

	int goodblocks = readpixels / pixelsperblock;
	int skippixels = readpixels % pixelsperblock;
	if(skippixels){
		goodblocks += 1;
		skippixels = pixelsperblock - skippixels;}

	int readlines = draw->Height << 3;
	if(readlines > height) readlines = height;
	if(readlines < height)
		fseek(file,(height - readlines) * (blockcount << 2),SEEK_CUR);

	int coY, coX;
	BYTE PixelLine[112];
	int arid;
	BYTE usepal = 0;
	for(coY = readlines - 1; coY >= 0; coY--){
		
		fread(PixelLine,1,goodblocks << 2,file);
		fseek(file,(blockcount - goodblocks) << 2,SEEK_CUR);

		if(numcolors == 256){
			for(coX = (goodblocks << 2) - skippixels - 1; coX >= 0; coX--){
				arid = ((coY >> 3) * draw->Width) + (coX >> 3);
				if(draw->PalFormation != NULL) usepal = draw->PalFormation[arid];
				arid = draw->PicFormation[arid];
				if(arid == 0xFF) continue;
				draw->bitmap[(arid << 6) + ((coY & 7) << 3) + (coX & 7)] = PaletteExchange[usepal][PixelLine[coX]];
			}
		}
		else{
			for(coX = (goodblocks << 2) - (skippixels >> 1) - 1; coX >= 0; coX--){
				arid = ((coY >> 3) * draw->Width) + (coX >> 2);
				if(draw->PalFormation != NULL) usepal = draw->PalFormation[arid];
				arid = draw->PicFormation[arid];
				if(arid == 0xFF) continue;
				draw->bitmap[(arid << 6) + ((coY & 7) << 3) + ((coX << 1) & 7)] = PaletteExchange[usepal][PixelLine[coX] >> 4];
				draw->bitmap[(arid << 6) + ((coY & 7) << 3) + (((coX << 1) + 1) & 7)] = PaletteExchange[usepal][PixelLine[coX] & 0x0F];
			}
		}
	}

	fclose(file);
}