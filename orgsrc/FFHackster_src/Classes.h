#if !defined(AFX_CLASSES_H__68A0D875_C04E_42BF_A551_B6D07283E5FC__INCLUDED_)
#define AFX_CLASSES_H__68A0D875_C04E_42BF_A551_B6D07283E5FC__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Classes.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CClasses dialog

class CClasses : public CDialog
{
// Construction
public:
	CClasses(CWnd* pParent = NULL);   // standard constructor

	int cur_class;
	CARTRIDGE* cart;
	CButton* ar_1m[4];
	CButton* ar_2m[4];
	CButton* ar_3m[4];
	CButton* ar_4m[4];
	CButton* ar_5m[4];
	CButton* ar_6m[4];
	CButton* ar_7m[4];
	CButton* ar_8m[4];
	CButton* ar_strong[4];
	CButton* ar_str[4];
	CButton* ar_agi[4];
	CButton* ar_int[4];
	CButton* ar_vit[4];
	CButton* ar_luc[4];
	CEdit* ar_exp[4];
	CStatic* ar_level[4];
	CStatic* ar_totalhp[4];
	CStatic* ar_totalstr[4];
	CStatic* ar_totalint[4];
	CStatic* ar_totalvit[4];
	CStatic* ar_totalluc[4];
	CStatic* ar_totalagi[4];
	CStatic* ar_totalmagic[4];
	short level_offset;

	short TotalHP[49];
	short TotalStr[49];
	short TotalInt[49];
	short TotalVit[49];
	short TotalLuc[49];
	short TotalAgi[49];
	BYTE TotalMagic[49][8];
	short ViewScale;

	void LoadValues();
	void StoreValues();
	void DisplayRunningTotals();

// Dialog Data
	//{{AFX_DATA(CClasses)
	enum { IDD = IDD_CLASSES };
	CEdit	m_hitpctup;
	CButton	m_mean;
	CButton	m_vit4;
	CButton	m_vit2;
	CButton	m_vit3;
	CButton	m_vit1;
	CStatic	m_totalvit4;
	CStatic	m_totalvit3;
	CStatic	m_totalvit2;
	CStatic	m_totalvit1;
	CStatic	m_totalstr4;
	CStatic	m_totalstr3;
	CStatic	m_totalstr2;
	CStatic	m_totalstr1;
	CStatic	m_totalmag4;
	CStatic	m_totalmag3;
	CStatic	m_totalmag2;
	CStatic	m_totalmag1;
	CStatic	m_totalluc4;
	CStatic	m_totalluc3;
	CStatic	m_totalluc2;
	CStatic	m_totalluc1;
	CStatic	m_totalint4;
	CStatic	m_totalint3;
	CStatic	m_totalint2;
	CStatic	m_totalint1;
	CStatic	m_totalhp4;
	CStatic	m_totalhp3;
	CStatic	m_totalhp2;
	CStatic	m_totalhp1;
	CStatic	m_totalagi4;
	CStatic	m_totalagi3;
	CStatic	m_totalagi2;
	CStatic	m_totalagi1;
	CButton	m_strong4;
	CButton	m_strong3;
	CButton	m_strong2;
	CButton	m_strong1;
	CButton	m_str4;
	CButton	m_str3;
	CButton	m_str2;
	CButton	m_str1;
	CScrollBar	m_scroll;
	CButton	m_min;
	CButton	m_max;
	CEdit	m_magicrangemin;
	CEdit	m_magicrangemax;
	CEdit	m_magic;
	CButton	m_luc4;
	CButton	m_luc3;
	CButton	m_luc2;
	CButton	m_luc1;
	CStatic	m_level4;
	CStatic	m_level3;
	CStatic	m_level2;
	CStatic	m_level1;
	CButton	m_int4;
	CButton	m_int3;
	CButton	m_int2;
	CButton	m_int1;
	CEdit	m_hprangemin;
	CEdit	m_hprangemax;
	CEdit	m_exp4;
	CEdit	m_exp3;
	CEdit	m_exp2;
	CEdit	m_exp1;
	CButton	m_class2;
	CButton	m_class1;
	CButton	m_agi4;
	CButton	m_agi3;
	CButton	m_agi2;
	CButton	m_agi1;
	CButton	m_8m4;
	CButton	m_8m3;
	CButton	m_8m2;
	CButton	m_8m1;
	CButton	m_7m4;
	CButton	m_7m3;
	CButton	m_7m2;
	CButton	m_7m1;
	CButton	m_6m4;
	CButton	m_6m3;
	CButton	m_6m2;
	CButton	m_6m1;
	CButton	m_5m4;
	CButton	m_5m3;
	CButton	m_5m2;
	CButton	m_5m1;
	CButton	m_4m4;
	CButton	m_4m3;
	CButton	m_4m2;
	CButton	m_4m1;
	CButton	m_3m4;
	CButton	m_3m3;
	CButton	m_3m2;
	CButton	m_3m1;
	CButton	m_2m4;
	CButton	m_2m3;
	CButton	m_2m2;
	CButton	m_2m1;
	CButton	m_1m4;
	CButton	m_1m3;
	CButton	m_1m2;
	CButton	m_1m1;
	CEdit	m_vit;
	CEdit	m_unknown;
	CEdit	m_str;
	CEdit	m_startinghp;
	CEdit	m_magdef;
	CEdit	m_luck;
	CEdit	m_int;
	CEdit	m_hit;
	CEdit	m_evade;
	CListBox	m_classlist;
	CEdit	m_damage;
	CEdit	m_agility;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CClasses)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CClasses)
	virtual BOOL OnInitDialog();
	afx_msg void OnSelchangeClasslist();
	afx_msg void OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg void OnMax();
	afx_msg void OnMin();
	afx_msg void RecalculateRunningTotals();
	afx_msg void OnChangeHprangemax();
	afx_msg void OnChangeHprangemin();
	afx_msg void OnCheckBox();
	afx_msg void OnSave();
	virtual void OnOK();
	virtual void OnCancel();
	afx_msg void OnMean();
	afx_msg void OnBattlepic();
	afx_msg void OnMapmanpic();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_CLASSES_H__68A0D875_C04E_42BF_A551_B6D07283E5FC__INCLUDED_)
