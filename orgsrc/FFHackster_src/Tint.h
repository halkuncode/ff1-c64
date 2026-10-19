#if !defined(AFX_TINT_H__C369665D_8440_4B76_8A25_E71482A6F152__INCLUDED_)
#define AFX_TINT_H__C369665D_8440_4B76_8A25_E71482A6F152__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Tint.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CTint dialog

class CTint : public CDialog
{
// Construction
public:
	CTint(CWnd* pParent = NULL);   // standard constructor
	int tintvalue;
	void UpdateTint(int);

// Dialog Data
	//{{AFX_DATA(CTint)
	enum { IDD = IDD_TINT };
	CButton	m_tint8;
	CButton	m_tint7;
	CButton	m_tint6;
	CButton	m_tint5;
	CButton	m_tint4;
	CButton	m_tint3;
	CButton	m_tint2;
	CButton	m_tint1;
	CButton	m_tint0;
	int		m_tintvariant;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CTint)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CTint)
	virtual BOOL OnInitDialog();
	afx_msg void OnTint0();
	afx_msg void OnTint1();
	afx_msg void OnTint2();
	afx_msg void OnTint3();
	afx_msg void OnTint4();
	afx_msg void OnTint5();
	afx_msg void OnTint6();
	afx_msg void OnTint7();
	afx_msg void OnTint8();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_TINT_H__C369665D_8440_4B76_8A25_E71482A6F152__INCLUDED_)
