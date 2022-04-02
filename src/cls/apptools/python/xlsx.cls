Include apptools.core

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
	
	;prepare XLSX
	set file=$Replace(file,"*",$Tr($zts,".,"))
	try {
        set openpyxl = ##class(%SYS.Python).Import("openpyxl") 
    } catch err {
        do ..InstallPy("openpyxl")
        set openpyxl = ##class(%SYS.Python).Import("openpyxl") 
    }
	set wb = openpyxl.Workbook()
	#; grab the active worksheet
	set ws = wb.active
	set ws.title = "Report"
	set pybuiltins = $system.Python.Import("builtins")
	set pycols = pybuiltins.list()
	do pycols.append(" ")
	do ws.append(pycols)
	set ws."__getitem__"("A2").value=title

	set pycols = pybuiltins.list()
	set (count)=0
	set ColCount=myQuery.GetColumnCount()
	for i=1:1:ColCount {	
		do pycols.append(myQuery.GetColumnName(i))
		set col=$C(i+64)
		if i<27 set ws."column_dimensions"."__getitem__"(col).width = "20"
	}
	do ws.append(pycols)

	while (myQuery.Next())	{
		set count=count+1
		set pyrows = pybuiltins.list()
		for ii=1:1:ColCount {
			set val=..CleanCtrl(myQuery.GetData(ii))
			if $P(format,",",ii)="d" { //date
				set val=..ToPyDate(val)
			}
			if $P(format,",",ii)="n" { //number
				set val=+val
			}
			do pyrows.append(val)
		}
		do ws.append(pyrows)
	}
   ;}
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

/// do ##class(apptools.python.xlsx).globals2xlsx("^tmpQuery","/backup/temp/giszkh-*.xlsx")
ClassMethod globals2xlsx(gn)
{
	set patternxlsx=$lg(@gn,9)
	set paternfile=$lg(@gn,1) //;set pattern="/backup/temp/reports/gis-*.xlsx"
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

ClassMethod gn2xlsx(gn, format = "", file As %String, title = "", patternxlsx = "")
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
	;set sheetname="Report"
	set sheetname=$qs(gn,1)
	
	#; grab the active worksheet
	set ws = wb.active
	set ws.title = sheetname_$g(a)
	set pybuiltins = $system.Python.Import("builtins")
	set pycols = pybuiltins.list()
	;do pycols.append(" ")
	;do ws.append(pycols)
	set ws."__getitem__"("A1").value=title

	set pycols = pybuiltins.list()
	set (count)=0
	set ColCount=$ll(@gn@(0))
	for i=1:1:ColCount {	
		do pycols.append($lg(@gn@(0),i))
		set col=$C(i+64)
		if i<27 {
			set width=$s($P(format,",",i)="d":17,$P(format,",",i)="n":10,1:30)
			set ws."column_dimensions"."__getitem__"(col).width = width
		}
	}
	do ws.append(pycols)

	for row=1:1 {
		quit:'$d(@gn@(row),data)
		set count=count+1
		set pyrows = pybuiltins.list()
		for ii=1:1:ColCount {
			set val=..CleanCtrl($lg(data,ii))
			if $P(format,",",ii)="d",val'="" { //date
				set val=..ToPyDate(val)
			}
			if $P(format,",",ii)="n" { //number
				set val=+val
			}
			do pyrows.append(val)
		}
		do ws.append(pyrows)
	}
   ;}
	write !,"Save into "_file_" rows: "_count
	do wb.save(file)
	q $GET(count)
}

/// do ##class(apptools.python.xlsx).InstallPy("openpyxl")
ClassMethod InstallPy(lib)
{
    //  depricated  ;set sc = ##class(%SYS.Python).Install("openpyxl")
    set cmd="pip3 install --target /usr/irissys/mgr/python/ "_lib
    if '$zversion(1)=3 {
        set tMgrDir = $System.Util.ManagerDirectory()
		set tBinDir = $System.Util.BinaryDirectory()_"irispip.exe"
		set cmd=tBinDir_" install --target "_tMgrDir_"python "_lib
    }
    set st=##class(%ZPM.PackageManager.Developer.Utils).RunCommandViaZF(cmd,.tLog,.tErr)
    quit $$$OK
}

/// Date YYYY-MM-DD to Python dt.datetime
ClassMethod ToPyDate(val, ByRef dt)
{
	if val'["-" set val=$zd(+val,3) // $h format
	set dt = ##class(%SYS.Python).Import("datetime")
	set val=dt.datetime(+$p(val,"-",1), +$p(val,"-",2), +$p($p(val,"-",3)," "),+$p($p(val,":",1)," ",2),+$p($p(val,":",2)," ",2),+$p($p(val,":",3)," ",2))
	quit val
}

ClassMethod CleanCtrl(val)
{
	quit $zstrip(val,"*C")
}

}

