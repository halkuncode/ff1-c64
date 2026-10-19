#if !defined(AFX_WEAPON_H__934F677B_38CF_427D_ABFE_2789BD1D545D__INCLUDED_)
#define AFX_WEAPON_H__934F677B_38CF_427D_ABFE_2789BD1D545D__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Weapon.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CWeapon dialog

class CWeapon : public CDialog
{
// Construction
public:
	CWeapon(CWnd* pParent = NULL);   // standard constructor

	CARTRIDGE* cart;
	int cur;
	int cur_pal;
	CRect rcPalette;
	CRect rcFinger;
	CRect rcGraphic;

	CImageList m_graphics;
	void ResetGraphicList();

	void StoreValues();
	void LoadValues();

// Dialog Data
	//{{AFX_DATA(CWeapon)
	enum { IDD = IDD_WEAPON };
	CButton	m_elem8;
	CButton	m_elem7;
	CButton	m_elem6;
	CButton	m_elem5;
	CButton	m_elem3;
	CButton	m_elem4;
	CButton	m_elem2;
	CButton	m_elem1;
	CButton	m_editgfx;
	CListBox	m_weaponlist;
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
	CEdit	m_unknown;
	CComboBox	m_spellcast;
	CEdit	m_price;
	CEdit	m_hit;
	CComboBox	m_gfx;
	CEdit	m_damage;
	CButton	m_cat8;
	CButton	m_cat7;
	CButton	m_cat6;
	CButton	m_cat5;
	CButton	m_cat4;
	CButton	m_cat3;
	CButton	m_cat2;
	CButton	m_cat1;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CWeapon)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CWeapon)
	virtual BOOL OnInitDialog();
	afx_msg void OnSelchangeWeaponlist();
	afx_msg void OnEditlabel();
	afx_msg void OnPaint();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnSelchangeGfx();
	virtual void OnOK();
	virtual void OnCancel();
	afx_msg void OnSave();
	afx_msg void OnEditgfx();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_WEAPON_H__934F677B_38CF_427D_ABFE_2789BD1D545D__INCLUDED_)
