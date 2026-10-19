#if !defined(AFX_COORDS_H__2DA94D31_DBD6_49E1_A2CA_ED716736EE4D__INCLUDED_)
#define AFX_COORDS_H__2DA94D31_DBD6_49E1_A2CA_ED716736EE4D__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Coords.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CCoords dialog

class CCoords : public CDialog
{
// Construction
public:
	CCoords(CWnd* pParent = NULL);   // standard constructor
	CARTRIDGE* cart;
	int cur;
	bool IsOV;

	BYTE type;
	COverworldMap* OVparent;
	CMaps* STparent;

	void InputCoords(CPoint);
	void LoadValues();
	void Boot();
	void UpdateButtons();
	int offset;
	int count;

	void TeleportHere();

// Dialog Data
	//{{AFX_DATA(CCoords)
	enum { IDD = IDD_COORDS };
	CComboBox	m_teleportlist;
	CButton	m_mouseclick;
	CButton	m_followup_forward;
	CButton	m_followup_back;
	CEdit	m_coord_y;
	CEdit	m_coord_x;
	CComboBox	m_coord_l;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CCoords)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
	public:

	// Generated message map functions
	//{{AFX_MSG(CCoords)
	virtual BOOL OnInitDialog();
	afx_msg void OnSelchangeTeleportlist();
	afx_msg void OnSelchangeCoordL();
	afx_msg void OnChangeCoordX();
	afx_msg void OnChangeCoordY();
	afx_msg void OnMouseclick();
	afx_msg void OnEditlabel();
	virtual void OnCancel();
	afx_msg void OnFollowup();
	afx_msg void OnFollowupBack();
	afx_msg void OnFollowupForward();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_COORDS_H__2DA94D31_DBD6_49E1_A2CA_ED716736EE4D__INCLUDED_)
