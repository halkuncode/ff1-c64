#if !defined(AFX_OVERWORLDMAP_H__D4F4EFA3_060E_443F_94F9_797904E48555__INCLUDED_)
#define AFX_OVERWORLDMAP_H__D4F4EFA3_060E_443F_94F9_797904E48555__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// OverworldMap.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// COverworldMap dialog

class COverworldMap : public CDialog
{
// Construction
public:
	COverworldMap(CWnd* pParent = NULL);   // standard constructor


	void UpdateTeleportLabel(int);

	bool BootToTeleportFollowup;


	CARTRIDGE* cart;
	CImageList m_sprites;
	CImageList m_backdrop;
	CImageList m_tools;
	CPen redpen;
	CPen bluepen;
	CRect rcTiles;
	CRect rcMap;
	CRect rcBackdrop;
	CRect rcTools;
	CRect rcToolRect;
	CRect rcPalette;

	CPoint ptHover;
	CPoint ptLastClick;
	CPoint ptDomain;

	BYTE DecompressedMap[256][256];
	BYTE palette[2][16];
	CPoint ScrollOffset;
	int cur_tile;
	short cur_tool;
	bool probabilitychanged;
	BYTE mousedown;
	int kab;

	CPoint misccoords[5];

	void DecompressMap();
	void CompressMap();
	void ReloadGraphics();
	void ReloadSpriteGraphics(CProgressCtrl*);
	void InitBackdrops();
	void LoadTileData();
	void StoreTileData();
	void UpdateClick(CPoint);
	void LoadDomain();
	void StoreDomain();
	void UpdateFight(int);
	void UpdateMisc(int);
	void StoreMiscCoords();


// Dialog Data
	//{{AFX_DATA(COverworldMap)
	enum { IDD = IDD_OVERWORLDMAP };
	CButton	m_viewcoords;
	CButton	m_minimap;
	CEdit	m_miscy;
	CEdit	m_miscx;
	CComboBox	m_misccoords;
	CButton	m_customizetool;
	CStatic	m_kab;
	CComboBox	m_backdroplist;
	CButton	m_showlastclick;
	CButton	m_randomencounter;
	CEdit	m_probability8;
	CEdit	m_probability7;
	CEdit	m_probability6;
	CEdit	m_probability5;
	CEdit	m_probability4;
	CEdit	m_probability3;
	CEdit	m_probability2;
	CEdit	m_probability1;
	CStatic	m_lastclick;
	CStatic	m_hovering;
	CButton	m_form8;
	CButton	m_form7;
	CButton	m_form6;
	CButton	m_form5;
	CButton	m_form4;
	CButton	m_form3;
	CButton	m_form2;
	CButton	m_form1;
	CButton	m_drawgrid;
	CStatic	m_domain;
	CComboBox	m_battle8;
	CComboBox	m_battle7;
	CComboBox	m_battle6;
	CComboBox	m_battle5;
	CComboBox	m_battle4;
	CComboBox	m_battle3;
	CComboBox	m_battle2;
	CComboBox	m_battle1;
	CButton	m_fight_river;
	CButton	m_fight_ocean;
	CButton	m_fight_normal;
	CButton	m_fight_none;
	CComboBox	m_teleportbox;
	CButton	m_teleport;
	CButton	m_raiseairship;
	CButton	m_move_walk;
	CButton	m_move_ship;
	CButton	m_move_canoe;
	CButton	m_move_airship;
	CButton	m_forest;
	CButton	m_dockship;
	CButton	m_chime;
	CButton	m_caravan;
	CScrollBar	m_vscroll;
	CScrollBar	m_hscroll;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(COverworldMap)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
public:

	// Generated message map functions
	//{{AFX_MSG(COverworldMap)
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg void OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg void OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnRButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnEditlabel();
	afx_msg void OnSelchangeBackdrop();
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnChangeProbability();
	afx_msg void OnFightNone();
	afx_msg void OnFightNormal();
	afx_msg void OnFightOcean();
	afx_msg void OnFightRiver();
	afx_msg void OnShowlastclick();
	afx_msg void OnDrawgrid();
	afx_msg void OnTeleport();
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnFindKAB();
	afx_msg void OnCustomizetool();
	afx_msg void OnCaravan();
	afx_msg void OnChime();
	afx_msg void OnRaiseairship();
	virtual void OnCancel();
	virtual void OnOK();
	afx_msg void OnSave();
	afx_msg void OnRButtonDblClk(UINT nFlags, CPoint point);
	afx_msg void OnEditgraphics();
	afx_msg void OnLButtonDblClk(UINT nFlags, CPoint point);
	afx_msg void OnSelchangeMisccoords();
	afx_msg void OnChangeMiscx();
	afx_msg void OnChangeMiscy();
	afx_msg void OnRButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnMapExport();
	afx_msg void OnMapImport();
	afx_msg void OnMinimap();
	afx_msg void OnViewcoords();
	afx_msg void OnSelchangeTeleportbox();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_OVERWORLDMAP_H__D4F4EFA3_060E_443F_94F9_797904E48555__INCLUDED_)
