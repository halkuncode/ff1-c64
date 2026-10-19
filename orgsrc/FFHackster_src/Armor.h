#if !defined(AFX_ARMOR_H__7A92585B_823D_4EA7_A12F_EA5E0EF2156E__INCLUDED_)
#define AFX_ARMOR_H__7A92585B_823D_4EA7_A12F_EA5E0EF2156E__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Armor.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CArmor dialog

class CArmor : public CDialog
{
// Construction
public:
	CArmor(CWnd* pParent = NULL);   // standard constructor
	CARTRIDGE* cart;

	int cur;

	void LoadValues();
	void StoreValues();

// Dialog Data
	//{{AFX_DATA(CArmor)
	enum { IDD = IDD_ARMOR };
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
	CEdit	m_price;
	CEdit	m_evade;
	CButton	m_def8;
	CButton	m_def7;
	CButton	m_def6;
	CButton	m_def5;
	CButton	m_def4;
	CButton	m_def3;
	CButton	m_def2;
	CButton	m_def1;
	CEdit	m_def;
	CComboBox	m_spellcast;
	CListBox	m_armorlist;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CArmor)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CArmor)
	virtual BOOL OnInitDialog();
	afx_msg void OnSelchangeArmorlist();
	virtual void OnOK();
	virtual void OnCancel();
	afx_msg void OnSave();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_ARMOR_H__7A92585B_823D_4EA7_A12F_EA5E0EF2156E__INCLUDED_)
