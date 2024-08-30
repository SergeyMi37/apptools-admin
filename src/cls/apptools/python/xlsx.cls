Include apptools.core

/// d ##class(apptools.python.xlsx).test()
Class apptools.python.xlsx
{

/// do ##class(apptools.python.xlsx).sql2xlsx("select * from apptools_core.Log order by id desc","n,,,,,n,,,,d","/tmp/sample-py.xlsx")
ClassMethod sql2xlsx(sql, format = "", file As %String = "d:\_proj\python\sample-py-*.xlsx", title = "")
{
	set st=$$$OK
	set myQuery = ##CLASS(%ResultSet).%New("%DynamicQuery:SQL")
	set st=myQuery.Prepare(sql)
	if 'st q st
	set st=myQuery.Execute()
	if 'st q st
	
	set IsVer=($SYSTEM.Version.Format(5,$zv)'>2021.2)

	;prepare XLSX
	try {
        set openpyxl = ##class(%SYS.Python).Import("openpyxl") 
    } catch err {
        do ..InstallPy("openpyxl")
        set openpyxl = ##class(%SYS.Python).Import("openpyxl") 
    }
	set wb = openpyxl.Workbook()
	#; grab the active worksheet
	set ws = wb.active
	set ws.title = $select($D(format("sheetname"),ds):ds,1:"sheetname")
	set pybuiltins = $system.Python.Import("builtins")
	set pycols = pybuiltins.list()
	do pycols.append(" ")
	do ws.append(pycols)
	if IsVer set ws."__getitem__"("A2").value=$select(title'="":title,$D(format("title"),ds):ds,1:"")

	set pycols = pybuiltins.list()
	set (count)=0
	set ColCount=myQuery.GetColumnCount()
	for i=1:1:ColCount {	
		do pycols.append(myQuery.GetColumnName(i))
		set col=openpyxl.utils."get_column_letter"(i)
		if IsVer set ws."column_dimensions"."__getitem__"(col).width = "20"
	}
	do ws.append(pycols)

	while (myQuery.Next())	{
		set count=count+1
		set pyrows = pybuiltins.list()
		for ii=1:1:ColCount {
			set val=..CleanCtrl(myQuery.GetData(ii))
			if $e($P(format,",",ii),1)="d" { //date
				set val=..ToPyDate(val)
			}
			elseif $e($P(format,",",ii),1,2)="dt" { //datetime
				set val=..ToPyDateTime(val)
			}
			elseif $e($P(format,",",ii),1)="n" { //number
				set val=+val
			}
			do pyrows.append(val)
		}
		do ws.append(pyrows)
	}
   ;}
   	if $g(format("freeze"))'="" {
		; set builtins = $system.Python.Import("builtins") zwrite builtins.type(ws)  zwrite builtins.dir(wb)
		set ws."freeze_panes" = pybuiltins.str(format("freeze")) ;format("freeze")
		;set ws."freeze_panes" = "B2" ;format("freeze")
	}
	else {
		set ws."freeze_panes" = pybuiltins.str("B2") ;default
	}
	if file["*" set file=$replace(file,"*","-"_$zd($h,3)_"_"_$tr($zt($p($h,",",2),1),":"))
	write !,"Save into "_file_" rows: "_count
	do wb.save(file)
	q $GET(count)
}

/// do ##class(apptools.python.xlsx).rest(.par)
ClassMethod rest(par)
{
	Set json = $$$NewDynObj
 	set json.jsonrpc="2.0"
	set json.code=1
	;set json.params=par
	set json.message="OK"
	set json.ns=$namespace
	if $GET(par("params"))'="" {
		set params={}.%FromJSON(par("params"))
		set gn=params.gn
		if gn'="" {
			if 1 {
				job ##class(apptools.python.xlsx).globals2xlsx(gn)::1 
				if $t set json.result="Task runed. "_gn
				else  set json.result="Task not runed. "_gn
			}
			else {
				set st=##class(apptools.python.xlsx).globals2xlsx(gn)
				set json.result="Runed "_gn
			}
		}
	}
	else {
		set json.result="Job not started."
	}
	$$$DynObjToJSON(json)
	q $$$OK
}

/// do ##class(apptools.python.xlsx).globals2xlsx("^tmpQuery","/iris-backup/temp/giszkh-*.xlsx")
ClassMethod globals2xlsx(gn)
{
	set patternxlsx=$lg(@gn,9)
	set paternfile=$lg(@gn,1) //;set pattern="/iris-backup/temp/reports/gis-*.xlsx"
	set transname=$lg(@gn,10)
	set q=""
	for { set q=$o(@gn@(q)) q:q=""
		set GN=$na(@gn@(q))
		if '$d(@GN@(-3,"par"),data) set stat="Is not report "_GN continue
		set format=$lg(data,2)
		set name=$lg(data,1)
		set rows=$lg(data,4)
		set file=$replace(paternfile,"*",transname_"-"_$zd($h,3)_"_"_$zt($p($h,",",2),1))
		set file=$tr(file,":")
		set st=##class(apptools.python.xlsx).gn2xlsx(GN,format,file,name,patternxlsx)
		set stat="rows="_rows_" -> "_st
		set @GN@(-3,"par")=@GN@(-3,"par")_$lb(file)
	}
	quit $G(stat)
}

/// d ##class(apptools.python.xlsx).test()
ClassMethod test() As %Status
{
 new $namespace
 set $namespace="%SYS"
 set sql="select * FROM Security.Applications"
 set gn="^||tmp",format=",n,n,n,n,s5,s5,s40,s5,s50" 
 set format("freeze")="B3" ;freeze
 set format("title")="Title "_sql
 set format("sheetname")="test"
 do ##class(apptools.core.sys).SaveSQL(sql,gn)
 set exec="##class(apptools.python.xlsx).MarkRed(.%AppLogInfoVal, .%AppLogInfoCol, .%AppLogInfoHead, .%AppLogInfoTemp)"
 do ##class(apptools.python.xlsx).gn2xlsx(gn,.format,"/tmp/gn2xlsx*.xlsx","Title "_sql,,,,exec)
 set format("freeze")="B4" ;freeze
 do ##class(apptools.python.xlsx).sql2xlsx(sql,.format,"/tmp/sql2xlsx*.xlsx")
 quit $$$OK
}

/// set gn="^||tmp",format="n,s150,,,,,,,,d," 
/// set format("freeze")="B5" ;freeze
/// d ##class(apptools.core.sys).SaveSQL("select * from apptools_core.Log order by id desc",gn)
/// d ##class(apptools.python.xlsx).gn2xlsx(gn,.format,"/iris-backup/temp/test*.xlsx","Test")
ClassMethod gn2xlsx(gn, ByRef format = "", file As %String, title = "", patternxlsx = "", sheetname = "", ByRef info, Execute = "") As %Status
{
	set st=$$$OK

	if '$d(@gn@(1)) q $$$ERROR($$$GeneralError,"Is empty glovals data")

	try {
        set openpyxl = ##class(%SYS.Python).Import("openpyxl") 
    } catch err {
        do ..InstallPy("openpyxl")
        set openpyxl = ##class(%SYS.Python).Import("openpyxl")
    }

	if patternxlsx'="" {
		try {
			set wb = openpyxl."load_workbook"(patternxlsx)
		} catch err {
			set wb = openpyxl.Workbook()
		}
	}
	else {		
		set wb = openpyxl.Workbook()
	}
	set IsVer=($SYSTEM.Version.Format(5,$zv)'>2021.2)
	set sheetname=$select(sheetname'="":sheetname,$D(format("sheetname"),ds):ds,$qs(gn,1)'="":$qs(gn,1),1:"Report")
	
	#; grab the active worksheet
	set ws = wb.active
	set ws.title = sheetname
	set pybuiltins = $system.Python.Import("builtins")
	set pycols = pybuiltins.list()
	
	;do pycols.append(" ")
	;do ws.append(pycols)
	if IsVer set ws."__getitem__"("A1").value=title

	set argsfont = {"color":"000000", "bold":true, "italic":false, "size":18}
	set font = openpyxl.styles.Font(argsfont...)	
	set cell = ws.cell(1,1)
   	set cell.font = font
   	set cell.value = $select(title'="":title,$D(format("title"),ds):ds,1:"")


	set pycols = pybuiltins.list()
	set (count)=0
	set ColCount=$ll(@gn@(0))

	set argsfill = {"start_color":"D3D3D3", "end_color":"D3D3D3", "fill_type":"solid"}
    set fill = openpyxl.styles.PatternFill(argsfill...)	
	set argsfont = {"color":"000000", "bold":true, "italic":false, "size":11}
	set font = openpyxl.styles.Font(argsfont...)
	set argside1 = {"style":"dotted","color":"000000"}
	set argside2 = {"style":"thin","color":"000000"}
	;set side1 = openpyxl.styles.Side(argside1...)
	set side2 = openpyxl.styles.Side(argside2...)
	set argbord = {"left":"","right":"","top":"","bottom":""}
	set argbord.left=side2
	set argbord.right=side2
	set argbord.top=side2
	set argbord.bottom=side2
	set Bord = openpyxl.styles.Border(argbord...)
	;set argalignment = {"horizontal":"center","vertical":"center","text_rotation":45} wrapText=True
	set argalignment = {"horizontal":"center","vertical":"center","wrapText":true}
	set Alig = openpyxl.styles.Alignment(argalignment...)	
	set %AppLogInfoHead=1 //Processing title
	if Execute'="" set %AppLogInfoTemp=openpyxl
	for i=1:1:ColCount {	
		set %AppLogInfoCol=i
		set col=openpyxl.utils."get_column_letter"(i)
		set type=$e($P(format,",",i),1)
		set width=+$e($P(format,",",i),2,*)
		if 'width set width=$select(type="d":20,type="n":10,1:30)
		set ws."column_dimensions"."__getitem__"(col).width = width
		;sheet.row_dimensions[1].height = 30
		set ws."row_dimensions"."__getitem__"(2).height = 40
		;cell = ws.cell(column=col, row=freezerow)
		set cell = ws.cell(2,i)
		set cell.fill = fill        	
    	set cell.font = font
    	set cell.value = $lg(@gn@(0),i)
    	set cell.alignment = Alig
    	set cell.border = Bord
		if Execute'="" {
			set %AppLogInfoVal=cell
			try {
				xecute "set %AppLogInfoVal2="_Execute
				if %AppLogInfoVal'=%AppLogInfoVal2 set countEx=$g(countEx)+1
				set %AppLogInfoVal=%AppLogInfoVal2
			}
			catch e {
				set %AppLogInfoVal.value=$ze
				}
		}

	}
	;do ws.append(pycols)
	set %AppLogInfoHead=0 //We process lines
	for row=1:1 {
		quit:'$d(@gn@(row),data)
		set count=count+1
		;set pyrows = pybuiltins.list()
		for ii=1:1:ColCount {
			set %AppLogInfoCol=ii
			set val=..CleanCtrl($lg(data,ii))
			;if $P(format,",",ii)="d",val'="" { //date
			;	set val=..ToPyDate(val)
			;}
			;if $P(format,",",ii)="n" { //number
			;	set val=+val
			;}
			
			if $e($P(format,",",ii),1)="d" { //date
				set val=..ToPyDate(val)
			}
			elseif $e($P(format,",",ii),1,2)="dt" { //datetime
				set val=..ToPyDateTime(val)
			}
			elseif $e($P(format,",",ii),1)="n" { //number
				set val=+val
			}
			
			set cell = ws.cell(row+2,ii)
			set cell.value=val
			;set ws.cell(row+2,ii).value=val
			;do pyrows.append(val)
			if Execute'="" {
				set %AppLogInfoVal=cell
				try {
					xecute "set %AppLogInfoVal2="_Execute
					if %AppLogInfoVal'=%AppLogInfoVal2 set countEx=$g(countEx)+1
					set %AppLogInfoVal=%AppLogInfoVal2
				}
				catch e {
					set %AppLogInfoVal.value=$ze
				}
			}

		}
		;do ws.append(pyrows)
	}
	if $DATA(format("last-line")) {
		set backgcolor=$g(format("last-line","backgcolor"),"D3D3D3")
		set argsfill = {"start_color":"D3D3D3", "end_color":"D3D3D3", "fill_type":"solid"}
		set argsfill."start_color"=backgcolor
		set argsfill."end_color"=backgcolor
		set fill = openpyxl.styles.PatternFill(argsfill...)	
		for i=1:1:ColCount {	
			set cell = ws.cell(row+1,i)
			set cell.fill = fill        	
        	set cell.font = font
        	set cell.alignment = Alig
        	set cell.border = Bord
		}
	}
	if $g(format("freeze"))'="" {
		; set builtins = $system.Python.Import("builtins") zwrite builtins.type(ws)  zwrite builtins.dir(wb)
		set ws."freeze_panes" = pybuiltins.str(format("freeze")) ;format("freeze")
		;set ws."freeze_panes" = "B2" ;format("freeze")
	}
	else {
		set ws."freeze_panes" = pybuiltins.str("B2") ;default
	}
	set info("infilename")=file
	merge info("format")=format
	set outfile=file
    if file["*" set outfile=$replace(file,"*","-"_$zd($h,3)_"_"_$tr($zt($p($h,",",2),1),":"))
	write !,"Save into "_outfile_" rows: "_count
	set info("rows")=count
	do wb.save(outfile)
	set info("outfilename")=outfile
	quit $$$OK
}

/// Example coloring a column values if is not null
///  set exec="##class(apptools.python.xlsx).MarkRed(.%AppLogInfoVal, %AppLogInfoCol, %AppLogInfoHead, .%AppLogInfoTemp)"
ClassMethod MarkRed(Val, Col, Head, openpyxl)
{
	s res=Val
	if $g(Head) {
		if res.value="DispatchClass" set Col("DispatchClass",Col)=""
	}
	else {
		if $Data(Col("DispatchClass",Col)) {
			if res.value'="" {
				;set argsfill = {"start_color":"D3D3D3", "end_color":"D3D3D3", "fill_type":"solid"}
    			;set fill = openpyxl.styles.PatternFill(argsfill...)	
				set argsfont = {"color":"DC143C", "bold":true, "italic":false, "size":11} ;color Crimson
				set font = openpyxl.styles.Font(argsfont...)
				;set res.value=$FN(res.value,"",2)
				;set res.fill=fill
				set res.font=font
			}
		}
	}
	q res
}

/// do ##class(apptools.python.xlsx).InstallPy("openpyxl")
ClassMethod InstallPy(lib)
{
    //  depricated  ;set sc = ##class(%SYS.Python).Install("openpyxl")
    set cmd="pip3 install --target /usr/irissys/mgr/python/ "_lib
    if $zversion(1)'=3 {
        set tMgrDir = $System.Util.ManagerDirectory()
		set tBinDir = $System.Util.BinaryDirectory()_"irispip.exe"
		set cmd=tBinDir_" install --target "_tMgrDir_"python "_lib
    }
    set st=##class(%ZPM.PackageManager.Developer.Utils).RunCommandViaZF(cmd,.tLog,.tErr)
    quit $$$OK
}

/// Date YYYY-MM-DD HH:MM:SS to Python dt.datetime
ClassMethod ToPyDateTime(val, ByRef dt)
{
	quit:'val val
	if val["." set val=$p(val,".",3)_"-"_$p(val,".",2)_"-"_$p(val,".",1) // format YYYY-MM-DD
	if val'["-" set val=$zd(+val,3) // $h format
	set dt = ##class(%SYS.Python).Import("datetime")
	set val=dt.datetime(+$p(val,"-",1), +$p(val,"-",2), +$p($p(val,"-",3)," "),+$p($p(val,":",1)," ",2),+$p($p(val,":",2)," ",2),+$p($p(val,":",3)," ",2))
	quit val
}

/// Date YYYY-MM-DD to Python dt.date
ClassMethod ToPyDate(val, ByRef dt)
{
	quit:'val val
	if val["." set val=$p(val,".",3)_"-"_$p(val,".",2)_"-"_$p(val,".",1) // format YYYY-MM-DD
	if val'["-" w 111_val_111 set val=$zd(+val,3) // $h format
	set dt = ##class(%SYS.Python).Import("datetime")
	set val=dt.date(+$p(val,"-",1), +$p(val,"-",2), +$p($p(val,"-",3)," "))
	quit val
}

ClassMethod CleanCtrl(val)
{
	quit $zstrip(val,"*C")
}

/// d ##class(apptools.python.xlsx).testxlsx2gn()
ClassMethod testxlsx2gn() As %Status
{
  set gn="^tmpXlsXread"
  set info("fields-name-rowcol")="3,1"
  set st=##class(apptools.python.xlsx).xlsx2gn("/iris-backup/temp/2022-07-18_182506.xlsx",gn,.info)
  if 'st write $System.Status.GetErrorText(st) quit
  zw @gn
}

/// d ##class(apptools.python.xlsx).xlsx2gn("/iris-backup/temp/test.xlsx","^||tmp",.info)
/// set info("fields-name-rowcol")="3,1"
ClassMethod xlsx2gn(filename As %String, gn, ByRef info) As %Status
{
	set st=$$$OK
	try {
        set openpyxl = ##class(%SYS.Python).Import("openpyxl") 
    } catch err {
        do ..InstallPy("openpyxl")
        set openpyxl = ##class(%SYS.Python).Import("openpyxl")
    }

	if filename'="" {
	try {
			set arg = {"data_only":true}
			set wb = openpyxl."load_workbook"(filename,arg...) ;data_only=True
			set st=..xlsx2gnrun(gn,.wb,.info)
		} catch err {
			set st = $$$ERROR($$$GeneralError,"Error open filename "_filename)
		}

	}
	else {		
		quit $$$ERROR($$$GeneralError,"Is empty filename")
	}
	quit st
}

ClassMethod xlsx2gnrun(gn, wb, ByRef info) As %Status
{
	set st=$$$OK
	set startrow=1
	set startcol=1
	set pybuiltins = $system.Python.Import("builtins")
	set sheet = wb.active
	set maxcols=sheet."max_column"
	set maxrows=sheet."max_row"
	kill @gn
	try {
		if $DATA(info("fields-name-rowcol"),rowcol) {
			set row=$p(rowcol,",")
			set col=$p(rowcol,",",2)
			set list=""
			for ii=col:1:maxcols {
				set cell = sheet.cell(+row,+ii)
				set value=pybuiltins.str(cell.value)
				if $D(info("fields-rename"),rename),$lg(rename,ii)'="" set value=$lg(rename,ii)
				set list=list_$lb(value)
				if value="" set value=" "
				set @gn@(-1,value)=ii
			}
			set @gn@(0)=list
			set startrow=row+1
			if $p(rowcol,",",3) set startrow=$p(rowcol,",",3)
			set startcol=col
		}
		for i=startrow:1:maxrows {
			set list=""
			for ii=startcol:1:maxcols {
				set cell = sheet.cell(i,ii)
				set value=pybuiltins.str(cell.value)
				set list=list_$lb(value)
			}
			set @gn@($i(count))=list
		}
	}
	catch ex { 
		Set st = $g(%objlasterror, $$$OK)
   		Set st = $$$ADDSC(st, ex.AsStatus())
	}
	quit st
}

}

