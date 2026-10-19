#if !defined(AFX_ENEMY_H__2FB3AFEC_3AF8_4739_A37B_C71C985332CE__INCLUDED_)
#define AFX_ENEMY_H__2FB3AFEC_3AF8_4739_A37B_C71C985332CE__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Enemy.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CEnemy dialog

class CEnemy : public CDialog
{
// Construction
public:
	CEnemy(CWnd* pParent = NULL);   // standard constructor

	CARTRIDGE* cart;
	int cur;
	int cur_ai;

	void LoadValues();
	void StoreValues();
	void LoadAI();
	void StoreAI();

// Dialog Data
	//{{AFX_DATA(CEnemy)
	enum { IDD = IDD_ENEMY };
	CButton	m_editlabel;
	CButton	m_weak8;
	CButton	m_weak7;
	CButton	m_weak6;
	CButton	m_weak5;
	CButton	m_weak4;
	CButton	m_weak3;
	CButton	m_weak2;
	CButton	m_weak1;
	CEdit	m_unknown;
	CEdit	m_str;
	CButton	m_res8;
	CButton	m_res7;
	CButton	m_res6;
	CButton	m_res5;
	CButton	m_res4;
	CButton	m_res3;
	CButton	m_res2;
	CButton	m_res1;
	CEdit	m_morale;
	CEdit	m_magdef;
	CEdit	m_hp;
	CEdit	m_hits;
	CEdit	m_hit;
	CEdit	m_gold;
	CEdit	m_exp;
	CListBox	m_enemylist;
	CButton	m_eff5;
	CButton	m_eff4;
	CButton	m_eff3;
	CButton	m_eff2;
	CButton	m_eff1;
	CEdit	m_def;
	CEdit	m_critical;
	CButton	m_cat8;
	CButton	m_cat7;
	CButton	m_cat6;
	CButton	m_cat5;
	CButton	m_cat4;
	CButton	m_cat3;
	CButton	m_cat2;
	CButton	m_cat1;
	CEdit	m_ai_magicrate;
	CComboBox	m_ai_magic8;
	CComboBox	m_ai_magic7;
	CComboBox	m_ai_magic6;
	CComboBox	m_ai_magic5;
	CComboBox	m_ai_magic4;
	CComboBox	m_ai_magic3;
	CComboBox	m_ai_magic2;
	CComboBox	m_ai_magic1;
	CEdit	m_ai_abilityrate;
	CComboBox	m_ai_ability4;
	CComboBox	m_ai_ability3;
	CComboBox	m_ai_ability2;
	CComboBox	m_ai_ability1;
	CComboBox	m_ai;
	CEdit	m_agility;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CEnemy)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CEnemy)
	virtual BOOL OnInitDialog();
	afx_msg void OnSelchangeEnemylist();
	afx_msg void OnSelchangeAi();
	afx_msg void OnEditlabel();
	virtual void OnOK();
	virtual void OnCancel();
	afx_msg void OnSave();
	afx_msg void OnEditpic();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_ENEMY_H__2FB3AFEC_3AF8_4739_A37B_C71C985332CE__INCLUDED_)
