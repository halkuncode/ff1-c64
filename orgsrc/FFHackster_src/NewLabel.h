#if !defined(AFX_NEWLABEL_H__21BAFDE5_8220_4EC8_AEC3_CE42F4375214__INCLUDED_)
#define AFX_NEWLABEL_H__21BAFDE5_8220_4EC8_AEC3_CE42F4375214__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// NewLabel.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CNewLabel dialog

class CNewLabel : public CDialog
{
// Construction
public:
	CNewLabel(CWnd* pParent = NULL);   // standard constructor
	int length;

// Dialog Data
	//{{AFX_DATA(CNewLabel)
	enum { IDD = IDD_NEWLABEL };
	CString	m_label;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CNewLabel)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CNewLabel)
		// NOTE: the ClassWizard will add member functions here
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_NEWLABEL_H__21BAFDE5_8220_4EC8_AEC3_CE42F4375214__INCLUDED_)
