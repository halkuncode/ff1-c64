#if !defined(AFX_BACKDROP_H__898EF119_9925_4571_BE79_E1DA5D53D11B__INCLUDED_)
#define AFX_BACKDROP_H__898EF119_9925_4571_BE79_E1DA5D53D11B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Backdrop.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CBackdrop dialog

class CBackdrop : public CDialog
{
// Construction
public:
	CBackdrop(CWnd* pParent = NULL);   // standard constructor

	CARTRIDGE* cart;
	BYTE backdrop;

	BYTE bitmap[0x400];
	BYTE palette[4];
	DRAW_STRUCT draw;
	BYTE PicFormation[32];

	void StoreValues();

// Dialog Data
	//{{AFX_DATA(CBackdrop)
	enum { IDD = IDD_BACKDROPGRAPHIC };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CBackdrop)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CBackdrop)
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnRButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnRButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnLButtonDblClk(UINT nFlags, CPoint point);
	afx_msg void OnSave();
	virtual void OnOK();
	afx_msg void OnExportbitmap();
	afx_msg void OnImportbitmap();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_BACKDROP_H__898EF119_9925_4571_BE79_E1DA5D53D11B__INCLUDED_)
