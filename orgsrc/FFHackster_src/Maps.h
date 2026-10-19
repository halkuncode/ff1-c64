#if !defined(AFX_MAPS_H__A2ACD334_B16D_4459_9329_80F4184FD92F__INCLUDED_)
#define AFX_MAPS_H__A2ACD334_B16D_4459_9329_80F4184FD92F__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Maps.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CMaps dialog

class CMaps : public CDialog
{
// Construction
public:
	CMaps(CWnd* pParent = NULL);   // standard constructor

	void UpdateTeleportLabel(int,bool);

	bool BootToTeleportFollowup;

	CARTRIDGE* cart;
	int cur_map;
	int cur_tileset;
	int cur_tile;
	int cur_tc;
	int cur_tcitem;
	int cur_tiledata;
	int cur_tool;
	BYTE mousedown;

	BYTE DecompressedMap[0x40][0x40];
	CImageList m_sprites;
	CPen redpen;
	CRect rcTiles;
	CRect rcMap;
	CRect rcPalettes;
	CRect rcPalettes2;
	CRect rcTools;
	CRect rcToolRect;
	CPoint ScrollOffset;
	CPoint Sprite_Coords[MAPSPRITE_COUNT];
	bool Sprite_InRoom[MAPSPRITE_COUNT];
	bool Sprite_StandStill[MAPSPRITE_COUNT];
	short Sprite_Value[MAPSPRITE_COUNT];
	int kab;

	
	CPoint ptHover;
	CPoint ptLastClick;
	void UpdateClick(CPoint);
	CImageList m_tools;

	void LoadValues();
	void LoadTileData();
	bool StoreValues();
	void StoreTileData();
	void CompressMap();
	int GetByteCount(int,bool);

	void LoadTC();
	void StoreTC();
	void LoadTCItem();
	void StoreTCItem();

	void ReloadImages(CProgressCtrl*);
	void ReloadSprites(CProgressCtrl*);

	void UpdateTileData();
	void UpdatePics();

	BYTE MapPalette[2][4][4];
	BYTE SpritePalette[2][4];
	BYTE ControlPalette[8];

// Dialog Data
	//{{AFX_DATA(CMaps)
	enum { IDD = IDD_MAPS };
	CButton	m_viewcoords;
	CStatic	m_kab;
	CButton	m_customtool;
	CButton	m_showlastclick;
	CStatic	m_hovering;
	CStatic	m_lastclick;
	CComboBox	m_spritegraphic;
	CButton	m_still;
	CEdit	m_spritecoordy;
	CEdit	m_spritecoordx;
	CComboBox	m_sprite;
	CButton	m_inroom;
	CComboBox	m_sprite_list;
	CButton	m_editlabel;
	CButton	m_warp;
	CComboBox	m_text_list;
	CComboBox	m_teleport_list;
	CButton	m_teleport;
	CEdit	m_tcitem_price;
	CComboBox	m_tcitem_list;
	CComboBox	m_tc_list;
	CButton	m_tc;
	CComboBox	m_special_list;
	CButton	m_special;
	CComboBox	m_shop_list;
	CButton	m_shop;
	CButton	m_move;
	CComboBox	m_fight_list;
	CButton	m_fight;
	CComboBox	m_tileset;
	CEdit	m_probability8;
	CEdit	m_probability7;
	CEdit	m_probability6;
	CEdit	m_probability5;
	CEdit	m_probability4;
	CEdit	m_probability3;
	CEdit	m_probability2;
	CEdit	m_probability1;
	CButton	m_formation8;
	CButton	m_formation7;
	CButton	m_formation6;
	CButton	m_formation5;
	CButton	m_formation4;
	CButton	m_formation3;
	CButton	m_formation2;
	CButton	m_formation1;
	CComboBox	m_battle8;
	CComboBox	m_battle7;
	CComboBox	m_battle6;
	CComboBox	m_battle5;
	CComboBox	m_battle4;
	CComboBox	m_battle3;
	CComboBox	m_battle2;
	CComboBox	m_battle1;
	CScrollBar	m_vscroll;
	CScrollBar	m_hscroll;
	CButton	m_showrooms;
	CListBox	m_maplist;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMaps)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
public:

	// Generated message map functions
	//{{AFX_MSG(CMaps)
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg void OnSelchangeMaplist();
	afx_msg void OnShowrooms();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg void OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg void OnRButtonDblClk(UINT nFlags, CPoint point);
	afx_msg void OnRButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnFight();
	afx_msg void OnShop();
	afx_msg void OnSpecial();
	afx_msg void OnTc();
	afx_msg void OnWarp();
	afx_msg void OnTeleport();
	afx_msg void OnMove();
	afx_msg void OnSelchangeTcList();
	afx_msg void OnSelchangeTcitemList();
	afx_msg void OnSelchangeTileset();
	afx_msg void OnSelchangeSpriteList();
	afx_msg void OnEditspritegfx();
	afx_msg void OnStill();
	afx_msg void OnInroom();
	afx_msg void OnChangeSpritecoordx();
	afx_msg void OnChangeSpritecoordy();
	afx_msg void OnSelchangeSprite();
	afx_msg void OnSelchangeSpritegraphic();
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnRButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnShowlastclick();
	afx_msg void OnCustomtool();
	afx_msg void OnFindkab();
	afx_msg void OnEditSpriteLabel();
	afx_msg void OnEditgfxlabel();
	afx_msg void OnMaplabel();
	afx_msg void OnEditlabel();
	afx_msg void OnTilesetlabel();
	afx_msg void OnSave();
	virtual void OnCancel();
	virtual void OnOK();
	afx_msg void OnLButtonDblClk(UINT nFlags, CPoint point);
	afx_msg void OnMapExport();
	afx_msg void OnMapImport();
	afx_msg void OnViewcoords();
	afx_msg void OnSelchangeTeleportList();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MAPS_H__A2ACD334_B16D_4459_9329_80F4184FD92F__INCLUDED_)
