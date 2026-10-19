#if !defined(AFX_ATTACK_H__819F5C22_126A_411C_BB13_B4818F8CD3CE__INCLUDED_)
#define AFX_ATTACK_H__819F5C22_126A_411C_BB13_B4818F8CD3CE__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Attack.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CAttack dialog

class CAttack : public CDialog
{
// Construction
public:
	CAttack(CWnd* pParent = NULL);   // standard constructor

	CARTRIDGE* cart;
	int cur;

	void LoadValues();
	void StoreValues();
	void ChangeEffect(bool);

// Dialog Data
	//{{AFX_DATA(CAttack)
	enum { IDD = IDD_ATTACK };
	CButton	m_eff_effect;
	CButton	m_eff_damage;
	CEdit	m_unknown;
	CButton	m_target;
	CButton	m_elem8;
	CButton	m_elem7;
	CButton	m_elem6;
	CButton	m_elem5;
	CButton	m_elem4;
	CButton	m_elem3;
	CButton	m_elem2;
	CButton	m_elem1;
	CButton	m_effectbox;
	CButton	m_eff5;
	CButton	m_eff4;
	CButton	m_eff3;
	CButton	m_eff2;
	CButton	m_eff1;
	CStatic	m_damagetext;
	CEdit	m_damage;
	CListBox	m_attacklist;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAttack)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CAttack)
	virtual BOOL OnInitDialog();
	afx_msg void OnSelchangeAttacklist();
	afx_msg void OnEffDamage();
	afx_msg void OnEffEffect();
	afx_msg void OnSave();
	virtual void OnCancel();
	virtual void OnOK();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_ATTACK_H__819F5C22_126A_411C_BB13_B4818F8CD3CE__INCLUDED_)
