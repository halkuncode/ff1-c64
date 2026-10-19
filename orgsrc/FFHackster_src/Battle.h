#if !defined(AFX_BATTLE_H__615683D6_6786_461F_B5D7_5FCA48BA06E1__INCLUDED_)
#define AFX_BATTLE_H__615683D6_6786_461F_B5D7_5FCA48BA06E1__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Battle.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CBattle dialog

class CBattle : public CDialog
{
// Construction
public:
	CBattle(CWnd* pParent = NULL);   // standard constructor

	CARTRIDGE* cart;
	int cur;
	bool form;
	short view;
	int battletype;
	int picassignment[4];
	bool paletteassignment[4];
	int qtymin[4];
	int qtymax[4];
	int pal[2];
	CImageList m_enemies[4];

	CRect rcPal[2];
	CRect rcPreview;

	void DrawSmallEnemies(CDC*,int);
	void DrawLargeEnemies(CDC*,int);

	void UpdatePalettes();
	void UpdateBattleType(int,bool redraw = 1);
	void UpdatePicAssignment(int,int,bool redraw = 1);
	void UpdatePaletteAssignment(int,int,bool redraw = 1);
	void UpdateForm(bool);
	void UpdateView(int);
	void UpdateType(int);
	void ReloadGraphics();
	void LoadFiendChaosPic(int,int,bool);
	void LoadValues();
	void StoreValues();

// Dialog Data
	//{{AFX_DATA(CBattle)
	enum { IDD = IDD_BATTLE };
	CButton	m_viewmin;
	CButton	m_viewmean;
	CButton	m_viewmax;
	CButton	m_form2;
	CButton	m_form1;
	CButton	m_type5;
	CButton	m_type4;
	CButton	m_type3;
	CButton	m_type2;
	CButton	m_type1;
	CEdit	m_suprised;
	CEdit	m_qtymin_4;
	CEdit	m_qtymin_3;
	CEdit	m_qtymin_2;
	CEdit	m_qtymin_1;
	CEdit	m_qtymax_4;
	CEdit	m_qtymax_3;
	CEdit	m_qtymax_2;
	CEdit	m_qtymax_1;
	CButton	m_picd_4;
	CButton	m_picd_3;
	CButton	m_picd_2;
	CButton	m_picd_1;
	CButton	m_picc_4;
	CButton	m_picc_3;
	CButton	m_picc_2;
	CButton	m_picc_1;
	CButton	m_picb_4;
	CButton	m_picb_3;
	CButton	m_picb_2;
	CButton	m_picb_1;
	CButton	m_pica_4;
	CButton	m_pica_3;
	CButton	m_pica_2;
	CButton	m_pica_1;
	CComboBox	m_patterntables;
	CStatic	m_palette2;
	CStatic	m_palette1;
	CButton	m_palb_4;
	CButton	m_palb_3;
	CButton	m_palb_2;
	CButton	m_palb_1;
	CButton	m_pala_4;
	CButton	m_pala_3;
	CButton	m_pala_2;
	CButton	m_pala_1;
	CButton	m_norun;
	CComboBox	m_enemy4;
	CComboBox	m_enemy3;
	CComboBox	m_enemy2;
	CComboBox	m_enemy1;
	CListBox	m_battlelist;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CBattle)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CBattle)
	afx_msg void OnSelchangeBattlelist();
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg void UpdateQtyMin();
	afx_msg void UpdateQtyMax();
	afx_msg void OnViewmax();
	afx_msg void OnViewmean();
	afx_msg void OnViewmin();
	afx_msg void OnForm1();
	afx_msg void OnForm2();
	afx_msg void OnSelchangePatterntables();
	afx_msg void OnType1();
	afx_msg void OnType2();
	afx_msg void OnType3();
	afx_msg void OnType4();
	afx_msg void OnType5();
	afx_msg void OnPala1();
	afx_msg void OnPala2();
	afx_msg void OnPala3();
	afx_msg void OnPala4();
	afx_msg void OnPalb1();
	afx_msg void OnPalb2();
	afx_msg void OnPalb3();
	afx_msg void OnPalb4();
	afx_msg void OnPica1();
	afx_msg void OnPica2();
	afx_msg void OnPica3();
	afx_msg void OnPica4();
	afx_msg void OnPicb1();
	afx_msg void OnPicb2();
	afx_msg void OnPicb3();
	afx_msg void OnPicb4();
	afx_msg void OnPicc1();
	afx_msg void OnPicc2();
	afx_msg void OnPicc3();
	afx_msg void OnPicc4();
	afx_msg void OnPicd1();
	afx_msg void OnPicd2();
	afx_msg void OnPicd3();
	afx_msg void OnPicd4();
	afx_msg void OnEditbatlabel();
	afx_msg void OnEditpatlabel();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnChangepal1();
	afx_msg void OnChangepal2();
	afx_msg void OnEditgraphic();
	afx_msg void OnSave();
	virtual void OnOK();
	virtual void OnCancel();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_BATTLE_H__615683D6_6786_461F_B5D7_5FCA48BA06E1__INCLUDED_)
