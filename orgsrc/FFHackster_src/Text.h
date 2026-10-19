#if !defined(AFX_TEXT_H__972BE22A_6892_41BD_B0E5_5269E6E56DC6__INCLUDED_)
#define AFX_TEXT_H__972BE22A_6892_41BD_B0E5_5269E6E56DC6__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Text.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CText dialog

class CText : public CDialog
{
// Construction
public:
	CText(CWnd* pParent = NULL);   // standard constructor

	
	CARTRIDGE* cart;
	int cur_main;
	int cur_text;
	bool viewDTE;
	int ptroffset;
	int ptradd;
	int count;
	int kab;
	int textstart;
	int textend;
	int ptrtblstart;
	int ptrtblend;
	bool madechange;


	void FindKAB();
	void StoreValues();
	void LoadValues();
	void ResetTextList();
	void UpdateTextList();
	int ConvertText(BYTE*,CString);



// Dialog Data
	//{{AFX_DATA(CText)
	enum { IDD = IDD_TEXT };
	CButton	m_changeptr;
	CButton	m_newslot;
	CButton	m_editlabel;
	CStatic	m_kab;
	CEdit	m_pointer;
	CButton	m_dte;
	CEdit	m_dialoguebox;
	CEdit	m_textbox;
	CListBox	m_textlist;
	CListBox	m_mainlist;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CText)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CText)
	virtual BOOL OnInitDialog();
	afx_msg void OnSelchangeMainlist();
	afx_msg void OnSelchangeTextlist();
	afx_msg void OnEditlabel();
	afx_msg void OnDte();
	afx_msg void OnUpdate();
	virtual void OnOK();
	afx_msg void OnSave();
	afx_msg void OnUpdateTextbox();
	afx_msg void OnUpdatePointer();
	afx_msg void OnChangeptr();
	virtual void OnCancel();
	afx_msg void OnDeleteslot();
	afx_msg void OnNewslot();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_TEXT_H__972BE22A_6892_41BD_B0E5_5269E6E56DC6__INCLUDED_)
