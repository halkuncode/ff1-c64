#if !defined(AFX_MAGIC_H__BB8727D6_3487_4729_B7B0_B61820B509EF__INCLUDED_)
#define AFX_MAGIC_H__BB8727D6_3487_4729_B7B0_B61820B509EF__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Magic.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CMagic dialog

class CMagic : public CDialog
{
// Construction
public:
	CMagic(CWnd* pParent = NULL);   // standard constructor

	CARTRIDGE* cart;
	int cur;
	int cur_pal;
	int cur_targ;
	int cur_eff;
	bool cur_graphic;

	CRect rcPalette;
	CRect rcFinger;
	CRect rcGraphic;

	CImageList m_graphics;
	int UsesChecks(int);
	void ResetGraphicList();
	void StoreValues();
	void LoadValues();
	void UpdateTarget(int);
	void UpdateEffect(int);

	void ChangeOutBattles(bool);

	bool haltwrite;


// Dialog Data
	//{{AFX_DATA(CMagic)
	enum { IDD = IDD_MAGIC };
	CComboBox	m_outminbox;
	CComboBox	m_outmaxbox;
	CEdit	m_outmin;
	CEdit	m_outmax;
	CComboBox	m_outbattlelist;
	CButton	m_editgfx;
	CButton	m_use9;
	CButton	m_use8;
	CButton	m_use7;
	CButton	m_use6;
	CButton	m_use5;
	CButton	m_use4;
	CButton	m_use3;
	CButton	m_use2;
	CButton	m_use12;
	CButton	m_use11;
	CButton	m_use10;
	CButton	m_use1;
	CComboBox	m_battlemessage;
	CEdit	m_price;
	CEdit	m_unknown;
	CButton	m_target5;
	CButton	m_target4;
	CButton	m_target3;
	CButton	m_target2;
	CButton	m_target1;
	CListBox	m_magiclist;
	CComboBox	m_gfx;
	CButton	m_elem8;
	CButton	m_elem7;
	CButton	m_elem6;
	CButton	m_elem5;
	CButton	m_elem4;
	CButton	m_elem3;
	CButton	m_elem2;
	CButton	m_elem1;
	CButton	m_effectbox;
	CButton	m_effect8;
	CButton	m_effect7;
	CButton	m_effect6;
	CButton	m_effect5;
	CButton	m_effect4;
	CButton	m_effect3;
	CButton	m_effect2;
	CButton	m_effect1;
	CButton	m_eff9;
	CButton	m_eff8;
	CButton	m_eff7;
	CButton	m_eff6;
	CButton	m_eff5;
	CButton	m_eff4;
	CButton	m_eff3;
	CButton	m_eff2;
	CButton	m_eff17;
	CButton	m_eff16;
	CButton	m_eff15;
	CButton	m_eff14;
	CButton	m_eff13;
	CButton	m_eff12;
	CButton	m_eff11;
	CButton	m_eff10;
	CButton	m_eff1;
	CButton	m_editlabel;
	CButton	m_damagebox;
	CEdit	m_damage;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMagic)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CMagic)
	virtual BOOL OnInitDialog();
	afx_msg void OnSelchangeMagiclist();
	afx_msg void OnPaint();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnSelchangeGfx();
	afx_msg void OnTimer(UINT nIDEvent);
	afx_msg void OnTarget1();
	afx_msg void OnTarget2();
	afx_msg void OnTarget3();
	afx_msg void OnTarget4();
	afx_msg void OnTarget5();
	afx_msg void OnEff1();
	afx_msg void OnEff10();
	afx_msg void OnEff11();
	afx_msg void OnEff12();
	afx_msg void OnEff13();
	afx_msg void OnEff14();
	afx_msg void OnEff15();
	afx_msg void OnEff16();
	afx_msg void OnEff17();
	afx_msg void OnEff2();
	afx_msg void OnEff3();
	afx_msg void OnEff4();
	afx_msg void OnEff5();
	afx_msg void OnEff6();
	afx_msg void OnEff7();
	afx_msg void OnEff8();
	afx_msg void OnEff9();
	virtual void OnOK();
	virtual void OnCancel();
	afx_msg void OnSave();
	afx_msg void OnEditlabel();
	afx_msg void OnEditgfx();
	afx_msg void OnSelchangeOutbattlelist();
	afx_msg void OnChangeOutmax();
	afx_msg void OnChangeOutmin();
	afx_msg void OnEditchangeOutmaxbox();
	afx_msg void OnEditchangeOutminbox();
	afx_msg void OnSelchangeOutmaxbox();
	afx_msg void OnSelchangeOutminbox();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MAGIC_H__BB8727D6_3487_4729_B7B0_B61820B509EF__INCLUDED_)
