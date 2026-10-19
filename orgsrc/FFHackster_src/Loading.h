#if !defined(AFX_LOADING_H__CF045029_96E6_4767_A0D4_E1D5E4948C26__INCLUDED_)
#define AFX_LOADING_H__CF045029_96E6_4767_A0D4_E1D5E4948C26__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Loading.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CLoading dialog

class CLoading : public CDialog
{
// Construction
public:
	CLoading(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CLoading)
	enum { IDD = IDD_LOADING };
	CProgressCtrl	m_progress;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CLoading)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CLoading)
		// NOTE: the ClassWizard will add member functions here
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_LOADING_H__CF045029_96E6_4767_A0D4_E1D5E4948C26__INCLUDED_)
