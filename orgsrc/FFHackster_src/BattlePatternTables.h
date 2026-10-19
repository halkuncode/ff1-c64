#if !defined(AFX_BATTLEPATTERNTABLES_H__FF7A1F7A_4BAC_4748_8C4F_5842C9473EA4__INCLUDED_)
#define AFX_BATTLEPATTERNTABLES_H__FF7A1F7A_4BAC_4748_8C4F_5842C9473EA4__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// BattlePatternTables.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CBattlePatternTables dialog

class CBattlePatternTables : public CDialog
{
// Construction
public:
	CBattlePatternTables(CWnd* pParent = NULL);   // standard constructor

	CARTRIDGE* cart;
	BYTE palette[16];
	BYTE patterntable;
	BYTE view;
	BYTE palview;
	BYTE palvalues[2];

	DRAW_STRUCT draw;
	BYTE bitmap[0x2000];
	CRect rcPattern;
	CRect rcMaxGraphic;
	CRect rcFinger;
	BYTE PicFormation[168];
	BYTE PalFormation[168];

	short cur_backdrop;

	void InitView();
	void UpdatePalView(BYTE up,bool redraw = 1);
	void UpdatePaletteRadios();
	void StoreValues();

// Dialog Data
	//{{AFX_DATA(CBattlePatternTables)
	enum { IDD = IDD_BATTLEPATTERNTABLES };
	CButton	m_reshape;
	CButton	m_repalette;
	CComboBox	m_backdrop;
	CButton	m_pal4;
	CButton	m_pal3;
	CButton	m_pal2;
	CButton	m_pal1;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CBattlePatternTables)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CBattlePatternTables)
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnPal1();
	afx_msg void OnPal2();
	afx_msg void OnPal3();
	afx_msg void OnPal4();
	afx_msg void OnSelchangeBackdrop();
	afx_msg void OnRButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnRButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnRepalette();
	afx_msg void OnReshape();
	virtual void OnOK();
	afx_msg void OnSave();
	virtual void OnCancel();
	afx_msg void OnExportbitmap();
	afx_msg void OnLButtonDblClk(UINT nFlags, CPoint point);
	afx_msg void OnImportbitmap();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_BATTLEPATTERNTABLES_H__FF7A1F7A_4BAC_4748_8C4F_5842C9473EA4__INCLUDED_)
