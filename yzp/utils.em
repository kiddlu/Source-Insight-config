/* Utils.em - a small collection of useful editing macros */


// Inserts "Returns True .. or False..." at the current line
macro ReturnTrueOrFalse()
{
	hbuf = GetCurrentBuf()
	ln = GetBufLineCur(hbuf)

	InsBufLine(hbuf, ln, "    Returns True if successful or False if errors.")
}



/* Inserts ifdef REVIEW around the selection */
macro IfdefReview()
{
	IfdefSz("REVIEW");
}


/* Inserts ifdef BOGUS around the selection */
macro IfdefBogus()
{
	IfdefSz("BOGUS");
}


/* Inserts ifdef NEVER around the selection */
macro IfdefNever()
{
	IfdefSz("NEVER");
}


// Ask user for ifdef condition and wrap it around current
// selection.
macro InsertIfdef()
{
	sz = Ask("Enter ifdef condition:")
	if (sz != "")
		IfdefSz(sz);
}

macro InsertCPlusPlus()
{
	hbuf = GetCurrentBuf()
	hwnd = GetCurrentWnd()	
	ln	= GetWndSelLnFirst(hwnd)

	InsBufLine(hbuf, ln, "#ifdef __cplusplus")
	InsBufLine(hbuf, ln+1, "extern \"C\" {")
	InsBufLine(hbuf, ln+2, "#endif /* #ifdef __cplusplus */")
	InsBufLine(hbuf, ln+3, "")
	InsBufLine(hbuf, ln+4, "#ifdef __cplusplus")
	InsBufLine(hbuf, ln+5, "}")
	InsBufLine(hbuf, ln+6, "#endif /* #ifdef __cplusplus */")
	
}


// Wrap ifdef <sz> .. endif around the current selection
macro IfdefSz(sz)
{
	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)
	lnLast = GetWndSelLnLast(hwnd)
	 
	hbuf = GetCurrentBuf()
	InsBufLine(hbuf, lnFirst, "#ifdef @sz@")
	InsBufLine(hbuf, lnLast+2, "#endif /* @sz@ */")
}


// Delete the current line and appends it to the clipboard buffer
macro KillLine()
{
	hbufCur = GetCurrentBuf();
	lnCur = GetBufLnCur(hbufCur)
	hbufClip = GetBufHandle("Clipboard")
	AppendBufLine(hbufClip, GetBufLine(hbufCur, lnCur))
	DelBufLine(hbufCur, lnCur)
}


// Paste lines killed with KillLine (clipboard is emptied)
macro PasteKillLine()
{
	Paste
	EmptyBuf(GetBufHandle("Clipboard"))
}



// delete all lines in the buffer
macro EmptyBuf(hbuf)
{
	lnMax = GetBufLineCount(hbuf)
	while (lnMax > 0)
		{
		DelBufLine(hbuf, 0)
		lnMax = lnMax - 1
		}
}


// Ask the user for a symbol name, then jump to its declaration
macro JumpAnywhere()
{
	symbol = Ask("What declaration would you like to see?")
	JumpToSymbolDef(symbol)
}

	
// list all siblings of a user specified symbol
// A sibling is any other symbol declared in the same file.
macro OutputSiblingSymbols()
{
	symbol = Ask("What symbol would you like to list siblings for?")
	hbuf = ListAllSiblings(symbol)
	SetCurrentBuf(hbuf)
}


// Given a symbol name, open the file its declared in and 
// create a new output buffer listing all of the symbols declared
// in that file.  Returns the new buffer handle.
macro ListAllSiblings(symbol)
{
	loc = GetSymbolLocation(symbol)
	if (loc == "")
		{
		msg ("@symbol@ not found.")
		stop
		}
	
	hbufOutput = NewBuf("Results")
	
	hbuf = OpenBuf(loc.file)
	if (hbuf == 0)
		{
		msg ("Can't open file.")
		stop
		}
		
	isymMax = GetBufSymCount(hbuf)
	isym = 0;
	while (isym < isymMax)
		{
		AppendBufLine(hbufOutput, GetBufSymName(hbuf, isym))
		isym = isym + 1
		}

	CloseBuf(hbuf)
	
	return hbufOutput

}


/*-------------------------------------------------------------------------
	I N S E R T   H E A D E R

	Inserts a comment header block at the top of the current function. 
	This actually works on any type of symbol, not just functions.

	To use this, define an environment variable "MYNAME" and set it
	to your email name.  eg. set MYNAME=raygr
-------------------------------------------------------------------------*/
macro InsertHeader()
{
	szMyName = "Yang Jinge"
	
	hbuf = GetCurrentBuf()
	szFunc = GetCurSymbol()
  	ln = GetBufLnCur( hbuf )
 	startLn=ln
 	LnTemp=ln
 	
 	szFuncName1 = GetBufLine(hbuf, ln)
 	slen=strlen(szFuncName1)
	
	if(szFuncName1[slen-1]==";")
	{
		szFuncName1[slen-1]=" "
	}
	else if(szFuncName1[slen-1]!=";" && szFuncName1[slen-1]!=")")
	{
		//funcTemp1=szFuncName1
		funcTemp2=szFuncName1
		while(StrIndexof(szFuncName1,"(",0)==-1)
		{
			LnTemp=LnTemp+1
			szFuncName1=cat(szFuncName1," ")
			szFuncName1=cat(szFuncName1,GetBufLine(hbuf,LnTemp))
			
		}
		
		while((StrIndexof(funcTemp2,"(",0)==-1)||(StrIndexof(funcTemp2,")",0)==-1))
		{
			startLn=startLn+1
			funcTemp2=cat(funcTemp2,GetBufLine(hbuf,startLn))
		}
	}
	else
	{
	}	

	i=startLn-LnTemp
	j=LnTemp
	temp=0
	
	InsBufLine(hbuf, ln + 0,  "/* ")
	InsBufLine(hbuf, ln + 1,  " * fn		@szFuncName1@")
	
	while(i>0)
	{		
		temp=temp+1
		funcNew=""
		funcNew=cat(" *			",GetBufLine(hbuf,j+3))
		newLen=strlen(funcNew)
		if(funcNew[newLen-1]==";")
		{
			funcNew[newLen-1]=" "
		}
		InsBufLine(hbuf, ln +1+temp,  "@funcNew@")
		i=i-1
		j=j+2
	
	}
	
	InsBufLine(hbuf, ln + 2+temp,  " * brief	")
	InsBufLine(hbuf, ln + 3+temp,  " * details	")
	InsBufLine(hbuf, ln + 4+temp,  " *")
	InsBufLine(hbuf, ln + 5+temp,  " * param[in]	")
	InsBufLine(hbuf, ln + 6+temp,  " * param[out]	")
	InsBufLine(hbuf, ln + 7+temp,  " *")
	InsBufLine(hbuf, ln + 8+temp,  " * return	")
	InsBufLine(hbuf, ln + 9+temp,  " * retval	")
	InsBufLine(hbuf, ln + 10+temp, " *")
	InsBufLine(hbuf, ln + 11+temp, " * note		")
	InsBufLine(hbuf, ln + 12+temp, " */")
}

/* InsertFileHeader:

   Inserts a comment header block at the top of the current function. 
   This actually works on any type of symbol, not just functions.

   To use this, define an environment variable "MYNAME" and set it
   to your email name.  eg. set MYNAME=raygr
*/

macro InsertFileHeader()
{
	szMyName = "Yang Jinge"
	
	hbuf = GetCurrentBuf()
	szpathName = GetBufName(hbuf)
	szfileName = GetFileName(szpathName)
	szTime = GetSysTime(1)
	Day = szTime.Day
	Month = szTime.Month
	Year=szTime.year
	szYear = strmid(szTime.year,2,4)
	
	if (Day < 10)
		szDay = "0@Day@"
	else
		szDay = Day
		
		szMonth = NumToName(Month)
		
	InsBufLine(hbuf, 0, "/*  Copyright(c) 2009-@Year@ Shenzhen TP-LINK Technologies Co.Ltd.")
	InsBufLine(hbuf, 1, " *")
	InsBufLine(hbuf, 2, " * file		@szfileName@")
	InsBufLine(hbuf, 3, " * brief		")
	InsBufLine(hbuf, 4, " * details	")
	InsBufLine(hbuf, 5, " *")
	InsBufLine(hbuf, 6, " * author		@szMyName@")
	InsBufLine(hbuf, 7, " * version	")
	InsBufLine(hbuf, 8, " * date		@szDay@@szMonth@@szYear@")
	InsBufLine(hbuf, 9, " *")
	InsBufLine(hbuf, 10, " * history 	\\arg	")
	InsBufLine(hbuf, 11, " */")
	
	
}



/*-------------------------------------------
 Insert the struct of .h file
------------------------------------------------*/
macro InsertFileStruct()
{
	
	hbuf = GetCurrentBuf()
	hwnd = GetCurrentWnd()	
	ln	= GetWndSelLnFirst(hwnd)
		
	InsBufLine(hbuf, ln,    "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+1,  "/*                                           DEFINES                                              */")	
	InsBufLine(hbuf, ln+2,  "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+3,  "")
	InsBufLine(hbuf, ln+4,  "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+5,  "/*                                           TYPES                                                */")	
	InsBufLine(hbuf, ln+6,  "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+7,  "")
	InsBufLine(hbuf, ln+8,  "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+9,  "/*                                           VARIABLES                                            */")	
	InsBufLine(hbuf, ln+10, "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+11, "")
	InsBufLine(hbuf, ln+12, "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+13, "/*                                           FUNCTIONS                                            */")	
	InsBufLine(hbuf, ln+14, "/**************************************************************************************************/")
}

macro InsertCommonComment()
{
	hbuf = GetCurrentBuf()
	/*
	szCommon = GetCurSymbol()
	ln = GetSymbolLine(szCommon)
	*/
	hwnd = GetCurrentWnd()	
	ln = GetWndSelLnFirst(hwnd)
	
	InsBufLine(hbuf, ln, "/* ")
	InsBufLine(hbuf, ln+1, " * brief	")
	InsBufLine(hbuf, ln+2, " */")
	
}

/******************************************************************************
 NumToName -- change the month number to name
 
 ******************************************************************************/
macro NumToName(Month)
{
 if (Month == 1)
  return "Jan"
 if (Month == 2)
  return "Feb"
 if (Month == 3)
  return "Mar"
 if (Month == 4)
  return "Apr"
 if (Month == 5)
  return "May"
 if (Month == 6)
  return "Jun"
 if (Month == 7)
  return "Jul"
 if (Month == 8)
  return "Aug"
 if (Month == 9)
  return "Sep"
 if (Month == 10)
  return "Oct"
 if (Month == 11)
  return "Nov"
 if (Month == 12)
  return "Dec"
}






macro StrIndexof(str,substr,startIndex)
{
lstr = strlen(str)
lsub = strlen(substr)
i    = startIndex
while(i <= lstr - lsub)
{
   if(substr == strmid(str,i,i+lsub))
   {
    return i
   }
   i = i + 1
}
return -1
}




/*get the name of the file*/
macro GetFileName(pathName)
{
	nlength = strlen(pathName)
	i = nlength - 1
	name = ""
	while (i + 1)
	{
   	ch = pathName[i]
   	if ("\\" == "@ch@")
		break
   	i = i - 1
	}
	i = i + 1
	while (i < nlength)
	{
   	name = cat(name, pathName[i])
   	i = i + 1
	}
	return name
	}	
	
macro PreventIncludeRepeatedly()
{
	hwnd	= GetCurrentWnd()
	lnFirst	= GetWndSelLnFirst(hwnd)
	lnLast	= GetWndSelLnLast(hwnd)

	/* get file name */
	szFileName	=	Ask("Enter header file's name without .h:")	
	szFileName	=	toupper(szFileName)
	szFileName	=	cat("__", szFileName)
	szFileName	=	cat(szFileName, "_H__")
	 
	hbuf = GetCurrentBuf()
	InsBufLine(hbuf, lnFirst,	"#ifndef @szFileName@")
	InsBufLine(hbuf, lnFirst +1,	"#define @szFileName@")
	InsBufLine(hbuf, lnFirst +2,	"")
	InsBufLine(hbuf, lnLast  +4,	"")
	InsBufLine(hbuf, lnLast  +5,	"#endif	/* @szFileName@ */")
}

/*-------------------------------------------
 Insert the struct of .c file
------------------------------------------------*/
macro InsertSourceFileStruct()
{
	
	hbuf = GetCurrentBuf()
	hwnd = GetCurrentWnd()	
	ln = GetWndSelLnFirst(hwnd)
		
	InsBufLine(hbuf, ln,    "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+1,  "/*                                           DEFINES                                              */")	
	InsBufLine(hbuf, ln+2,  "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+3,  "")
	InsBufLine(hbuf, ln+4,  "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+5,  "/*                                           TYPES                                                */")	
	InsBufLine(hbuf, ln+6,  "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+7,  "")
	InsBufLine(hbuf, ln+8,  "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+9,  "/*                                           EXTERN_PROTOTYPES                                    */")	
	InsBufLine(hbuf, ln+10, "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+11, "")
	InsBufLine(hbuf, ln+12, "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+13, "/*                                           LOCAL_PROTOTYPES                                     */")	
	InsBufLine(hbuf, ln+14, "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+15, "")
	InsBufLine(hbuf, ln+16, "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+17, "/*                                           VARIABLES                                            */")	
	InsBufLine(hbuf, ln+18, "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+19, "")
	InsBufLine(hbuf, ln+20, "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+21, "/*                                           LOCAL_FUNCTIONS                                      */")	
	InsBufLine(hbuf, ln+22, "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+23, "")
	InsBufLine(hbuf, ln+24, "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+25, "/*                                           PUBLIC_FUNCTIONS                                     */")	
	InsBufLine(hbuf, ln+26, "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+27, "")
	InsBufLine(hbuf, ln+28, "/**************************************************************************************************/")
	InsBufLine(hbuf, ln+29, "/*                                           GLOBAL_FUNCTIONS                                     */")	
	InsBufLine(hbuf, ln+30, "/**************************************************************************************************/")
}

macro InsertOneComment()
{
	hbuf = GetCurrentBuf()

	str = "/*   */"
	SetBufSelText(hbuf, str)			

	
}
