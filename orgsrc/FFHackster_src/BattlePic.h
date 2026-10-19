#if !defined(AFX_BATTLEPIC_H__E2CFFD07_1ED2_456B_90F8_471E3D1EA4DB__INCLUDED_)
#define AFX_BATTLEPIC_H__E2CFFD07_1ED2_456B_90F8_471E3D1EA4DB__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// BattlePic.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CBattlePic dialog

class CBattlePic : public CDialog
{
// Construction
public:
	CBattlePic(CWnd* pParent = NULL);   // standard constructor
	CARTRIDGE* cart;
	int Class;

	DRAW_STRUCT draw;

	BYTE bitmap[0x800];
	BYTE PalAssign;
	BYTE palette[4];
	BYTE PicFormation[39];
	
	void ReLoadPalette();
	void UpdatePalAssignment(BYTE);
	void StoreGraphic();
	void StorePalette();

// Dialog Data
	//{{AFX_DATA(CBattlePic)
	enum { IDD = IDD_BATTLEPIC };
	CButton	m_palette4;
	CButton	m_palette3;
	CButton	m_palette2;
	CButton	m_palette1;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CBattlePic)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CBattlePic)
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnRButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnRButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnPalette1();
	afx_msg void OnPalette2();
	afx_msg void OnPalette3();
	afx_msg void OnPalette4();
	afx_msg void OnLButtonDblClk(UINT nFlags, CPoint point);
	virtual void OnCancel();
	virtual void OnOK();
	afx_msg void OnSave();
	afx_msg void OnExportbitmap();
	afx_msg void OnImportbitmap();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_BATTLEPIC_H__E2CFFD07_1ED2_456B_90F8_471E3D1EA4DB__INCLUDED_)
