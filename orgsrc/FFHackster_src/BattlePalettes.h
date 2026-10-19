#if !defined(AFX_BATTLEPALETTES_H__2BCE6B23_AC11_46CE_9D3C_34D3FE3D110E__INCLUDED_)
#define AFX_BATTLEPALETTES_H__2BCE6B23_AC11_46CE_9D3C_34D3FE3D110E__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// BattlePalettes.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CBattlePalettes dialog

class CBattlePalettes : public CDialog
{
// Construction
public:
	CBattlePalettes(CWnd* pParent = NULL);   // standard constructor
	CARTRIDGE* cart;
	int oldpal;
	int newpal;
	CRect drawrect;
	CRect rcOldPal;
	CRect rcNewPal;
	CPoint FindCurPoint();

// Dialog Data
	//{{AFX_DATA(CBattlePalettes)
	enum { IDD = IDD_BATTLEPALETTES };
	CStatic	m_origpal;
	CStatic	m_newpal;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CBattlePalettes)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CBattlePalettes)
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_BATTLEPALETTES_H__2BCE6B23_AC11_46CE_9D3C_34D3FE3D110E__INCLUDED_)
