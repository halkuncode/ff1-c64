#if !defined(AFX_CUSTOMTOOL_H__544455A5_9F33_470B_A7D9_FC80F0573604__INCLUDED_)
#define AFX_CUSTOMTOOL_H__544455A5_9F33_470B_A7D9_FC80F0573604__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// CustomTool.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CCustomTool dialog

class CCustomTool : public CDialog
{
// Construction
public:
	CCustomTool(CWnd* pParent = NULL);   // standard constructor
	int tool;
	DATA* dat;
	CImageList* m_tiles;
	int slot;
	BYTE toolarray[9];

	CRect rcTiles;
	CRect rcTool;
	CPen redpen;


// Dialog Data
	//{{AFX_DATA(CCustomTool)
	enum { IDD = IDD_CUSTOMTOOL };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CCustomTool)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CCustomTool)
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	virtual void OnOK();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_CUSTOMTOOL_H__544455A5_9F33_470B_A7D9_FC80F0573604__INCLUDED_)
