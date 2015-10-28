/*  Copyright(c) 2009-2011 Shenzhen TP-LINK Technologies Co.Ltd.
 *
 * file		ext.em
 * brief	Source Insight macro extension.
 * details	
 *
 * author	
 * version	1.0.0
 * date		23Dec11
 *
 * history 	\arg	1.0.0, 23Dec11, , Create the file.
 */

/* 
 * fn		macro SynHeader()
 * brief	同步声明和定义处的注释，包括函数和全局变量
 * details	
 *
 * param[in]	
 * param[out]	
 *
 * return	
 * retval	
 *
 * note		只能在函数或全局变量的声明处使用该宏，不能在定义处使用。
 *			在声明处使用该宏后，定义处的注释将和声明处的一致。
 */
macro SynHeader()
{
	src_hbuf = GetCurrentBuf()
	src_ln = GetBufLnCur( src_hbuf )
	szFunc = GetCurSymbol()
	if (szFunc == Nil)
	{
		Msg("error, not symbol found in the line where your cursor is!")
		return
	}
	loc = GetSymbolLocation(szFunc)
	if (loc == hNil)
	{
		return
	}
	tar_ln = loc.lnFirst
	flags = False
	if (GetBufName(src_hbuf) == loc.file)
	{
		 if (src_ln == tar_ln)
		 {
		 	Msg("error, you can not synchronize comment in definition point! go to the declaration point and do it")
		 	return 
		 }
		 else if (src_ln > tar_ln)
		 {
		 	flags = True
		 }
	} 

	tar_hbuf = OpenBuf(loc.file)
 	if (tar_hbuf == hNil)
 	{
		Msg("error, can not open the file : " # loc.file)
		return
 	}

	_SynHeader(src_hbuf, src_ln, tar_hbuf, tar_ln, flags)
}

macro _SynHeader(src_hbuf, src_ln, tar_hbuf, tar_ln, flags)
{
	_src_ln = src_ln
	rmCnt = _RemoveHeader(tar_hbuf, tar_ln)
	
	_tar_ln = tar_ln - rmCnt
	if (flags == True)
	{
		_src_ln = src_ln - rmCnt
	}
	lineTemp = GetBufLine(src_hbuf, _src_ln - 1)
	len = strlen(lineTemp)
	if (len < 2)
	{
		return
	}
	lnEnd = _src_ln - 1
	i = lnEnd - 1
	found = False
	while ( i > 0 && found == False)
	{
		lineTemp = GetBufLine(src_hbuf, i)
		len = strlen(lineTemp)
		if (len >= 2 && lineTemp[0] == "/" && lineTemp[1] == "*")
		{
			found = True
		}
		else
		{
			i = i - 1
		}
	}
	lnStart = i
	while (lnEnd >= lnStart)
	{
		InsBufLine(tar_hbuf, _tar_ln, GetBufLine(src_hbuf, lnEnd))
		if (flags == False)
		{
			lnEnd = lnEnd - 1
		}
		else
		{
			lnStart = lnStart + 1
		}
	}
	Msg("comment synchronization done ok! changes occured in : " # GetBufName(tar_hbuf) # ", at line " # tar_ln + 1)
	return
}

macro _RemoveHeader(hbuf, ln)
{
	lineTemp = GetBufLine(hbuf, ln - 1)
	len = strlen(lineTemp)
	if (len > 0)
	{
		if (lineTemp[len - 1] == "/" && lineTemp[len - 2] == "*")
		{
			lnEnd = ln - 1
			i = lnEnd - 1
			found = False
			while ( i > 0 && found == False)
			{
				lineTemp = GetBufLine(hbuf, i)
				len = strlen(lineTemp)
				if (len >= 2 && lineTemp[0] == "/" && lineTemp[1] == "*")
				{
					found = True
				}
				else
				{
					i = i - 1
				}
			}
			lnStart = i 
			count = lnEnd - lnStart + 1
			while (count > 0)
			{
				DelBufLine(hbuf, lnStart)
				count = count - 1
			}
			return lnEnd - lnStart + 1
		}
	}
	return 0
}


/* 
 * fn		macro InsertFileHistory()
 * brief	添加文件修改记录
 * details	
 *
 * param[in]	
 * param[out]	
 *
 * return	
 * retval	
 *
 * note		
 */
macro InsertFileHistory()
{
	hbuf = GetCurrentBuf()
  	ln = GetBufLnCur( hbuf )
	lineTemp = GetBufLine(hbuf, ln)
	szMyName = "Ye Zuopou"

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

	szVersion="x.x.x"
	szHistory="Modify somthing."
	
	InsBufLine(hbuf, ln, " * history 	\\arg	@szVersion@, @szDay@@szMonth@@szYear@, @szMyName@, @szHistory@")
	index = 3
	len = strlen("history")
	while (len > 0)
	{
		lineTemp[index] = " "
		index = index + 1
		len = len - 1
	}
	PutBufLine(hbuf, ln + 1, lineTemp)
}

macro InsertFileHeaderEx()
{
	szMyName = "Ye Zuopou"
	
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

	/* added by YeZuopou, 23Nov11 */
	szBrief="Brief description."
	szDetails=""
	szVersion="1.0.0"
	szHistory="Create the file."
	
	InsBufLine(hbuf, 0, "/* Copyright(c) 2009-@Year@ Shenzhen TP-LINK Technologies Co.Ltd.")
	InsBufLine(hbuf, 1, " *")
	InsBufLine(hbuf, 2, " * file		@szfileName@")
	InsBufLine(hbuf, 3, " * brief	@szBrief@")
	InsBufLine(hbuf, 4, " * details	@szDetails@")
	InsBufLine(hbuf, 5, " *")
	InsBufLine(hbuf, 6, " * author	@szMyName@")
	InsBufLine(hbuf, 7, " * version	@szVersion@")
	InsBufLine(hbuf, 8, " * date		@szDay@@szMonth@@szYear@")
	InsBufLine(hbuf, 9, " *")
	InsBufLine(hbuf, 10, " * history 	\\arg	@szVersion@, @szDay@@szMonth@@szYear@, @szMyName@, @szHistory@")
	InsBufLine(hbuf, 11, " */")
	
	len = strlen(szfileName);
	if (szfileName[len - 1] == "h" && szfileName[len - 2] == ".")
	{
		szfileName[len - 2] = "_";
		macroName = toupper(szfileName);
		InsBufLine(hbuf, 12, "#ifndef\t@macroName@");
		InsBufLine(hbuf, 13, "");
		InsBufLine(hbuf, 14, "/*");
		InsBufLine(hbuf, 15, " * brief\t@macroName@");
		InsBufLine(hbuf, 16, " */");
		InsBufLine(hbuf, 17, "#define\t@macroName@");
		InsBufLine(hbuf, 18, "");
		InsBufLine(hbuf, 19, "");
		InsBufLine(hbuf, 20, "#endif\t/* @macroName@ */");
	}
}

/* Insert Makefile Header */
macro InsertFileHeaderMk()
{
	szMyName = "Ye Zuopou"
	
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

	/* added by YeZuopou, 23Nov11 */
	szBrief="Brief description."
	szDetails=""
	szVersion="1.0.0"
	szHistory="Create the file."
	szShell = "#!/bin/sh"

	InsBufLine(hbuf, 0, "#")	
	InsBufLine(hbuf, 1, "#***************************************************************************************************")
	InsBufLine(hbuf, 2, "# Copyright(c) 2009-@Year@ Shenzhen TP-LINK Technologies Co.Ltd.")
	InsBufLine(hbuf, 3, "#")
	InsBufLine(hbuf, 4, "# file		@szfileName@")
	InsBufLine(hbuf, 5, "# brief		@szBrief@")
	InsBufLine(hbuf, 6, "# details	@szDetails@")
	InsBufLine(hbuf, 7, "#")
	InsBufLine(hbuf, 8, "# author	@szMyName@")
	InsBufLine(hbuf, 9, "# version	@szVersion@")
	InsBufLine(hbuf, 10, "# date		@szDay@@szMonth@@szYear@")
	InsBufLine(hbuf, 11, "#")
	InsBufLine(hbuf, 12, "# history 	\\arg	@szVersion@, @szDay@@szMonth@@szYear@, @szMyName@, @szHistory@")
	InsBufLine(hbuf, 13, "#")
	InsBufLine(hbuf, 14, "#***************************************************************************************************")
	InsBufLine(hbuf, 15, "#")	
	InsBufLine(hbuf, 16, "")
	InsBufLine(hbuf, 17, "@szShell@")
	
}

// Wrap if 0 ... endif around the current selection
macro IfZero()
{
	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)
	lnLast = GetWndSelLnLast(hwnd)
	 
	hbuf = GetCurrentBuf()
	lineFirst = GetBufLine(hbuf, lnFirst);
	lenFirst = GetBufLineLength(hbuf, lnFirst);
	strFirst = "";
	index = 0;
	while (index < lenFirst)
	{
		if (lineFirst[index] == "\t")
		{
			strFirst = cat(strFirst, "\t");
		}
		else if ( lineFirst[index] == " ")
		{
			strFirst = cat(strFirst, " ");
		}
		else
		{
			break;
		}
		index = index + 1;
	}
	
	strIf = cat(strFirst, "#if 0");
	strEndif = cat(strFirst, "#endif\t/* 0 */");
	
	InsBufLine(hbuf, lnFirst, strIf);
	InsBufLine(hbuf, lnLast+2, strEndif);
}

// Wrap if 0 ... endif around the current selection
macro IfZeroElse()
{

	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)
	lnLast = GetWndSelLnLast(hwnd)
	
	hbuf = GetCurrentBuf()
	lineFirst = GetBufLine(hbuf, lnFirst);
	lenFirst = GetBufLineLength(hbuf, lnFirst);
	strFirst = "";
	index = 0;
	while (index < lenFirst)
	{
		if (lineFirst[index] == "\t")
		{
			strFirst = cat(strFirst, "\t");
		}
		else if ( lineFirst[index] == " ")
		{
			strFirst = cat(strFirst, " ");
		}
		else
		{
			break;
		}
		index = index + 1;
	}
	
	strIf = cat(strFirst, "#if 0");
	strElse = cat(strFirst, "#else\t/* 0 */");
	strEndif = cat(strFirst, "#endif\t/* 0 */");
	
	InsBufLine(hbuf, lnFirst, strIf);
	InsBufLine(hbuf, lnLast+2, strElse);
	InsBufLine(hbuf, lnLast+3, "");
	InsBufLine(hbuf, lnLast+4, strEndif);
}

macro InsertMark()
{
	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)

	hbuf = GetCurrentBuf()
	lineFirst = GetBufLine(hbuf, lnFirst);
	lenFirst = GetBufLineLength(hbuf, lnFirst);
	strFirst = "";
	index = 0;
	while (index < lenFirst)
	{
		if (lineFirst[index] == "\t")
		{
			strFirst = cat(strFirst, "\t");
		}
		else if ( lineFirst[index] == " ")
		{
			strFirst = cat(strFirst, " ");
		}
		else
		{
			break;
		}
		index = index + 1;
	}

	szMyName = "YeZuopou"
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
		
	strLn0 = cat(strFirst, "/*");
	strLn1 = cat(strFirst, " * brief	Added by @szMyName@ \@ @szDay@@szMonth@@szYear@.");
	strLn2 = cat(strFirst, " */");
	
	InsBufLine(hbuf, lnFirst, strLn0);
	InsBufLine(hbuf, lnFirst + 1, strLn1);
	InsBufLine(hbuf, lnFirst + 2, strLn2);
}

macro InsertBrief()
{
	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)

	hbuf = GetCurrentBuf()
	lineFirst = GetBufLine(hbuf, lnFirst);
	lenFirst = GetBufLineLength(hbuf, lnFirst);
	strFirst = "";
	index = 0;
	while (index < lenFirst)
	{
		if (lineFirst[index] == "\t")
		{
			strFirst = cat(strFirst, "\t");
		}
		else if ( lineFirst[index] == " ")
		{
			strFirst = cat(strFirst, " ");
		}
		else
		{
			break;
		}
		index = index + 1;
	}

	szMyName = "YeZuopou"
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
	
	strLn0 = cat(strFirst, "/*");
	strLn1 = cat(strFirst, " * brief	something.");
	strLn2 = cat(strFirst, " */");
	
	InsBufLine(hbuf, lnFirst, strLn0);
	InsBufLine(hbuf, lnFirst + 1, strLn1);
	InsBufLine(hbuf, lnFirst + 2, strLn2);
}

macro InsertBlock()
{
	
	hbuf = GetCurrentBuf()
	hwnd = GetCurrentWnd()	
	ln = GetWndSelLnFirst(hwnd)

	InsBufLine(hbuf, ln  ,  "/*-------------------------------------------- [  ] ----------------------------------------------*/")
	InsBufLine(hbuf, ln+1,  "/*@@BEGIN                                                                                          */")
	InsBufLine(hbuf, ln+2,  "/*{                                                                                               */")	
	InsBufLine(hbuf, ln+3,  "")
	InsBufLine(hbuf, ln+4,  "")
	InsBufLine(hbuf, ln+5,  "")
	InsBufLine(hbuf, ln+6,  "/*}                                                                                               */")
	InsBufLine(hbuf, ln+7,  "/*@@END                                                                                            */")
	InsBufLine(hbuf, ln+8,  "/*-------------------------------------------- [  ] ----------------------------------------------*/")	
}

macro InsertMkFileHeader()
{
	szMyName = getenv(MYNAME)
	
	hbuf = GetCurrentBuf()

	InsBufLine(hbuf, 0, "/*-------------------------------------------------------------------------")
	
	/* if owner variable exists, insert Owner: name */
	InsBufLine(hbuf, 1, "    ")
	if (strlen(szMyName) > 0)
		{
		sz = "    Owner: @szMyName@"
		InsBufLine(hbuf, 2, " ")
		InsBufLine(hbuf, 3, sz)
		ln = 4
		}
	else
		ln = 2
	
	InsBufLine(hbuf, ln, "-------------------------------------------------------------------------*/")
}