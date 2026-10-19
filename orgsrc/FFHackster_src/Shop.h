#if !defined(AFX_SHOP_H__5A98EF79_B54B_4344_94AD_CC5725AA9099__INCLUDED_)
#define AFX_SHOP_H__5A98EF79_B54B_4344_94AD_CC5725AA9099__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Shop.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CShop dialog

class CShop : public CDialog
{
// Construction
public:
	CShop(CWnd* pParent = NULL);   // standard constructor

	CARTRIDGE* cart;

	int cur_type;
	int cur;
	int shopsize;
	int kab;

	int ptroffset;
	int numitems;

	void FindKAB();
	void LoadValues();
	void StoreValues();
	void Remove(int);
	void Add(int);
	void LoadPrice(int);
	void StorePrice(int);
	void SelChangeItem(int);

	CComboBox* m_item[5];
	CButton* m_remove[5];
	CEdit* m_itprice[5];
	int m_curitem[5];

// Dialog Data
	//{{AFX_DATA(CShop)
	enum { IDD = IDD_SHOP };
	CEdit	m_startinggold;
	CEdit	m_price5;
	CEdit	m_price4;
	CEdit	m_price3;
	CEdit	m_price2;
	CEdit	m_price1;
	CListBox	m_shoptype;
	CListBox	m_shop;
	CButton	m_remove5;
	CButton	m_remove4;
	CButton	m_remove3;
	CButton	m_remove2;
	CButton	m_remove1;
	CStatic	m_pricetext;
	CEdit	m_price;
	CEdit	m_pointer;
	CStatic	m_kab;
	CComboBox	m_item5;
	CComboBox	m_item4;
	CComboBox	m_item3;
	CComboBox	m_item2;
	CComboBox	m_item1;
	CButton	m_changeptr;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CShop)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CShop)
	virtual BOOL OnInitDialog();
	afx_msg void OnSelchangeShop();
	afx_msg void OnSelchangeShoptype();
	afx_msg void OnRemove1();
	afx_msg void OnRemove2();
	afx_msg void OnRemove3();
	afx_msg void OnRemove4();
	afx_msg void OnRemove5();
	afx_msg void OnUpdatePointer();
	afx_msg void OnChangeptr();
	afx_msg void OnSave();
	virtual void OnOK();
	virtual void OnCancel();
	afx_msg void OnDeleteslot();
	afx_msg void OnNewslot();
	afx_msg void OnSelchangeItem1();
	afx_msg void OnSelchangeItem2();
	afx_msg void OnSelchangeItem3();
	afx_msg void OnSelchangeItem4();
	afx_msg void OnSelchangeItem5();
	afx_msg void OnEditlabel();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_SHOP_H__5A98EF79_B54B_4344_94AD_CC5725AA9099__INCLUDED_)
