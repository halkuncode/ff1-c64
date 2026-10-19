#if !defined(AFX_WEPMAGGRAPHIC_H__2724C844_E3E9_4D32_8DEA_23529A62EDCB__INCLUDED_)
#define AFX_WEPMAGGRAPHIC_H__2724C844_E3E9_4D32_8DEA_23529A62EDCB__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// WepMagGraphic.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CWepMagGraphic dialog

class CWepMagGraphic : public CDialog
{
// Construction
public:
	CWepMagGraphic(CWnd* pParent = NULL);   // standard constructor
	CARTRIDGE* cart;
	bool IsWeapon;
	BYTE paletteref;
	short graphic;

	BYTE PicFormation[8];
	BYTE palette[4];
	BYTE bitmap[0x200];
	DRAW_STRUCT draw;

	void StoreGraphic();

// Dialog Data
	//{{AFX_DATA(CWepMagGraphic)
	enum { IDD = IDD_WEPMAG_GRAPHIC };
	CButton	m_weapon;
	CButton	m_magic;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CWepMagGraphic)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CWepMagGraphic)
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnRButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnRButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnSave();
	virtual void OnOK();
	afx_msg void OnExportbitmap();
	afx_msg void OnImportbitmap();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_WEPMAGGRAPHIC_H__2724C844_E3E9_4D32_8DEA_23529A62EDCB__INCLUDED_)
