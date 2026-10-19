#if !defined(AFX_MINIMAP_H__9A93F35D_2E6D_4F7C_8BC4_F23373EB2E79__INCLUDED_)
#define AFX_MINIMAP_H__9A93F35D_2E6D_4F7C_8BC4_F23373EB2E79__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// MiniMap.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CMiniMap dialog

class CMiniMap : public CDialog
{
// Construction
public:
	BYTE* Map;
	BYTE* palette;
	CARTRIDGE* cart;
	BYTE PalAssign[128];

	CRect rcOld;
	CRect rcNew;

	void FixRects(CPoint);
	void UpdateCur();
	void UpdateAll();

	bool mousedown;

	COverworldMap* OVmap;
	CMiniMap(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CMiniMap)
	enum { IDD = IDD_MINIMAP };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMiniMap)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CMiniMap)
	afx_msg void OnPaint();
	virtual void OnCancel();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	virtual BOOL OnInitDialog();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MINIMAP_H__9A93F35D_2E6D_4F7C_8BC4_F23373EB2E79__INCLUDED_)
