#if !defined(AFX_TILEEDIT_H__859B9274_D046_4A80_BFF1_282A41EF7993__INCLUDED_)
#define AFX_TILEEDIT_H__859B9274_D046_4A80_BFF1_282A41EF7993__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// TileEdit.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CTileEdit dialog

class CTileEdit : public CDialog
{
// Construction
public:
	CTileEdit(CWnd* pParent = NULL);   // standard constructor

	CARTRIDGE* cart;
	BYTE tileset;
	BYTE tile;
	BYTE* pal[2];
	BYTE palette[2][16];
	BYTE PicFormation[4];
	BYTE palassign;
	BYTE bitmap[0x4000];
	BYTE curblock;


	DRAW_STRUCT draw;
	CRect rcPatternTables;
	CRect rcFinger;
	CPen redpen;

	void StoreValues();

// Dialog Data
	//{{AFX_DATA(CTileEdit)
	enum { IDD = IDD_TILEEDIT };
	CButton	m_small;
	CButton	m_large;
	CButton	m_showroom;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CTileEdit)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CTileEdit)
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg void OnShowroom();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnRButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnRButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnLButtonDblClk(UINT nFlags, CPoint point);
	afx_msg void OnSave();
	virtual void OnOK();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_TILEEDIT_H__859B9274_D046_4A80_BFF1_282A41EF7993__INCLUDED_)
