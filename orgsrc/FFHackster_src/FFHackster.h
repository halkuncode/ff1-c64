// FFHackster.h : main header file for the FFHACKSTER application
//

#if !defined(AFX_FFHACKSTER_H__5C96F70B_02AC_4DCA_9FB4_B5B9F1D7687A__INCLUDED_)
#define AFX_FFHACKSTER_H__5C96F70B_02AC_4DCA_9FB4_B5B9F1D7687A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols
#include "constants.h"
#include "functions.h"

/////////////////////////////////////////////////////////////////////////////
// CFFHacksterApp:
// See FFHackster.cpp for the implementation of this class
//

class CFFHacksterApp : public CWinApp
{
public:
	CFFHacksterApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CFFHacksterApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CFFHacksterApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_FFHACKSTER_H__5C96F70B_02AC_4DCA_9FB4_B5B9F1D7687A__INCLUDED_)
