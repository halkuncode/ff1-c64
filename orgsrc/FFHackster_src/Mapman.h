#if !defined(AFX_MAPMAN_H__BFC01627_E214_4EF1_A1FA_19C33C4061FB__INCLUDED_)
#define AFX_MAPMAN_H__BFC01627_E214_4EF1_A1FA_19C33C4061FB__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Mapman.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CMapman dialog

class CMapman : public CDialog
{
// Construction
public:
	CMapman(CWnd* pParent = NULL);   // standard constructor

	CARTRIDGE* cart;
	int graphicoffset;
	int paletteoffset;

	BYTE bitmap[0x400];
	BYTE palette[8];
	DRAW_STRUCT draw;
	BYTE PicFormation[16];
	BYTE PalFormation[16];

	void StoreValues();

// Dialog Data
	//{{AFX_DATA(CMapman)
	enum { IDD = IDD_MAPMAN };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMapman)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CMapman)
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnRButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnRButtonUp(UINT nFlags, CPoint point);
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

#endif // !defined(AFX_MAPMAN_H__BFC01627_E214_4EF1_A1FA_19C33C4061FB__INCLUDED_)
