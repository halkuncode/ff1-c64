// FFHacksterDlg.h : header file
//

#if !defined(AFX_FFHACKSTERDLG_H__F7D4DB2E_0108_41BA_9452_37BA3390472D__INCLUDED_)
#define AFX_FFHACKSTERDLG_H__F7D4DB2E_0108_41BA_9452_37BA3390472D__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CFFHacksterDlg dialog

class CFFHacksterDlg : public CDialog
{
// Construction
public:
	CFFHacksterDlg(CWnd* pParent = NULL);	// standard constructor
	
	//added vars and functions
	CARTRIDGE cart;
	void GoToMapScreen(bool);


// Dialog Data
	//{{AFX_DATA(CFFHacksterDlg)
	enum { IDD = IDD_FFHACKSTER_DIALOG };
	CStatic	m_rompath;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CFFHacksterDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	//{{AFX_MSG(CFFHacksterDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	virtual void OnCancel();
	afx_msg void OnOverworldmap();
	afx_msg void OnText();
	afx_msg void OnArmor();
	afx_msg void OnWeapon();
	afx_msg void OnEnemy();
	afx_msg void OnAttack();
	afx_msg void OnMagic();
	afx_msg void OnShop();
	afx_msg void OnBattle();
	afx_msg void OnMaps();
	afx_msg void OnClasses();
	afx_msg void OnAbout();
	afx_msg void OnOpen();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_FFHACKSTERDLG_H__F7D4DB2E_0108_41BA_9452_37BA3390472D__INCLUDED_)
