#if !defined(AFX_NESPALETTE_H__9621A6D8_610B_4320_9F30_E61805FB5711__INCLUDED_)
#define AFX_NESPALETTE_H__9621A6D8_610B_4320_9F30_E61805FB5711__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// NESPalette.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CNESPalette dialog

class CNESPalette : public CDialog
{
// Construction
public:
	CARTRIDGE* cart;
	CRect rcPalette;
	BYTE* color;
	CNESPalette(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CNESPalette)
	enum { IDD = IDD_NESPALETTE };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CNESPalette)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CNESPalette)
	afx_msg void OnPaint();
	virtual BOOL OnInitDialog();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_NESPALETTE_H__9621A6D8_610B_4320_9F30_E61805FB5711__INCLUDED_)
